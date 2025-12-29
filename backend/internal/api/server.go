package api

import (
	"database/sql"
	"net/http"
	"strings"

	"github.com/blowjobs-ai/backend/internal/auth"
	"github.com/blowjobs-ai/backend/internal/config"
	"github.com/blowjobs-ai/backend/internal/websocket"
	"github.com/gin-gonic/gin"
)

type Server struct {
	db         *sql.DB
	hub        *websocket.Hub
	cfg        *config.Config
	jwtManager *auth.JWTManager
	router     *gin.Engine
}

func NewServer(db *sql.DB, hub *websocket.Hub, cfg *config.Config) *Server {
	s := &Server{
		db:         db,
		hub:        hub,
		cfg:        cfg,
		jwtManager: auth.NewJWTManager(cfg.JWTSecret, cfg.JWTExpiration),
	}

	s.setupRouter()
	return s
}

func (s *Server) setupRouter() {
	if s.cfg.Environment == "production" {
		gin.SetMode(gin.ReleaseMode)
	}

	r := gin.Default()

	// CORS middleware
	r.Use(func(c *gin.Context) {
		c.Header("Access-Control-Allow-Origin", "*")
		c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS")
		c.Header("Access-Control-Allow-Headers", "Origin, Content-Type, Authorization")
		
		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(http.StatusNoContent)
			return
		}
		c.Next()
	})

	// Health check
	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"status": "healthy", "service": "blowjobs-ai-api"})
	})

	// API v1 routes
	v1 := r.Group("/api/v1")
	{
		// Auth routes (public)
		auth := v1.Group("/auth")
		{
			auth.POST("/register", s.Register)
			auth.POST("/login", s.Login)
			auth.POST("/refresh", s.RefreshToken)
		}

		// Protected routes
		protected := v1.Group("")
		protected.Use(s.authMiddleware())
		{
			// User routes
			protected.GET("/me", s.GetCurrentUser)
			protected.PUT("/me", s.UpdateCurrentUser)
			protected.GET("/me/stats", s.GetUserStats)

			// Profile routes
			profiles := protected.Group("/profiles")
			{
				profiles.GET("/job-seeker", s.GetJobSeekerProfile)
				profiles.PUT("/job-seeker", s.UpdateJobSeekerProfile)
				profiles.GET("/recruiter", s.GetRecruiterProfile)
				profiles.PUT("/recruiter", s.UpdateRecruiterProfile)
			}

			// Job routes
			jobs := protected.Group("/jobs")
			{
				jobs.POST("", s.CreateJob)
				jobs.GET("", s.GetJobs)
				jobs.GET("/:id", s.GetJob)
				jobs.PUT("/:id", s.UpdateJob)
				jobs.DELETE("/:id", s.DeleteJob)
				jobs.GET("/feed", s.GetJobFeed)        // For job seekers
				jobs.GET("/my-jobs", s.GetMyJobs)      // For recruiters
			}

			// Candidate routes (for recruiters)
			candidates := protected.Group("/candidates")
			{
				candidates.GET("/feed", s.GetCandidateFeed)
				candidates.GET("/:id", s.GetCandidateProfile)
			}

			// Swipe routes
			swipes := protected.Group("/swipes")
			{
				swipes.POST("", s.RecordSwipe)
				swipes.GET("/history", s.GetSwipeHistory)
				swipes.DELETE("/reset", s.ResetSwipes) // Dev only
			}

			// Match routes
			matches := protected.Group("/matches")
			{
				matches.GET("", s.GetMatches)
				matches.GET("/:id", s.GetMatch)
				matches.PUT("/:id/status", s.UpdateMatchStatus)
				matches.DELETE("/:id", s.UnmatchMatch)
			}

			// Chat routes
			chat := protected.Group("/chat")
			{
				chat.GET("/conversations", s.GetConversations)
				chat.GET("/:match_id/messages", s.GetMessages)
				chat.POST("/:match_id/messages", s.SendMessage)
				chat.PUT("/:match_id/read", s.MarkMessagesRead)
			}

			// Interview routes
			interviews := protected.Group("/interviews")
			{
				interviews.POST("", s.ScheduleInterview)
				interviews.GET("", s.GetInterviews)
				interviews.GET("/:id", s.GetInterview)
				interviews.PUT("/:id", s.UpdateInterview)
				interviews.DELETE("/:id", s.CancelInterview)
				interviews.PUT("/:id/result", s.RecordInterviewResult)
			}

			// Gamification routes
			gamification := protected.Group("/gamification")
			{
				gamification.GET("/stats", s.GetGamificationStats)
				gamification.GET("/badges", s.GetBadges)
				gamification.GET("/achievements", s.GetAchievements)
				gamification.POST("/daily-reward", s.ClaimDailyReward)
			}
		}

		// WebSocket route
		v1.GET("/ws", s.authMiddleware(), s.HandleWebSocket)
	}

	s.router = r
}

func (s *Server) Run(addr string) error {
	return s.router.Run(addr)
}

// authMiddleware validates JWT tokens
func (s *Server) authMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Authorization header required"})
			return
		}

		tokenString := strings.TrimPrefix(authHeader, "Bearer ")
		if tokenString == authHeader {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Bearer token required"})
			return
		}

		claims, err := s.jwtManager.Verify(tokenString)
		if err != nil {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Invalid or expired token"})
			return
		}

		c.Set("user_id", claims.UserID)
		c.Set("email", claims.Email)
		c.Set("user_type", claims.UserType)
		c.Next()
	}
}

