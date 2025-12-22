package api

import (
	"database/sql"
	"net/http"
	"time"

	"github.com/blowjobs-ai/backend/internal/auth"
	"github.com/blowjobs-ai/backend/internal/models"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/lib/pq"
)

func (s *Server) Register(c *gin.Context) {
	var req models.CreateUserRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Validate user type
	if req.UserType != models.UserTypeJobSeeker && req.UserType != models.UserTypeRecruiter {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid user type. Must be 'job_seeker' or 'recruiter'"})
		return
	}

	// Hash password
	hashedPassword, err := auth.HashPassword(req.Password)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to process password"})
		return
	}

	// Create user
	var user models.User
	err = s.db.QueryRow(`
		INSERT INTO users (email, password_hash, first_name, user_type)
		VALUES ($1, $2, $3, $4)
		RETURNING id, email, first_name, user_type, is_active, swipe_streak, total_swipes, total_matches, badges, created_at, updated_at
	`, req.Email, hashedPassword, req.FirstName, req.UserType).Scan(
		&user.ID, &user.Email, &user.FirstName, &user.UserType,
		&user.IsActive, &user.SwipeStreak, &user.TotalSwipes, &user.TotalMatches,
		pq.Array(&user.Badges), &user.CreatedAt, &user.UpdatedAt,
	)

	if err != nil {
		if pqErr, ok := err.(*pq.Error); ok && pqErr.Code == "23505" {
			c.JSON(http.StatusConflict, gin.H{"error": "Email already registered"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create user"})
		return
	}

	// Create empty profile based on user type
	if req.UserType == models.UserTypeJobSeeker {
		_, err = s.db.Exec(`INSERT INTO job_seeker_profiles (user_id) VALUES ($1)`, user.ID)
	} else {
		_, err = s.db.Exec(`INSERT INTO recruiter_profiles (user_id, company_name) VALUES ($1, $2)`, user.ID, "")
	}
	if err != nil {
		// Log but don't fail - profile can be created later
	}

	// Create daily streak entry
	_, _ = s.db.Exec(`INSERT INTO daily_streaks (user_id) VALUES ($1)`, user.ID)

	// Generate JWT
	token, expiresAt, err := s.jwtManager.Generate(user.ID, user.Email, string(user.UserType))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate token"})
		return
	}

	c.JSON(http.StatusCreated, models.AuthResponse{
		Token:     token,
		User:      user,
		ExpiresAt: expiresAt,
	})
}

func (s *Server) Login(c *gin.Context) {
	var req models.LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var user models.User
	var passwordHash string
	err := s.db.QueryRow(`
		SELECT id, email, password_hash, first_name, user_type, is_active, 
		       swipe_streak, total_swipes, total_matches, badges, created_at, updated_at
		FROM users WHERE email = $1
	`, req.Email).Scan(
		&user.ID, &user.Email, &passwordHash, &user.FirstName, &user.UserType,
		&user.IsActive, &user.SwipeStreak, &user.TotalSwipes, &user.TotalMatches,
		pq.Array(&user.Badges), &user.CreatedAt, &user.UpdatedAt,
	)

	if err == sql.ErrNoRows {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid email or password"})
		return
	}
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch user"})
		return
	}

	if !auth.CheckPassword(req.Password, passwordHash) {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid email or password"})
		return
	}

	if !user.IsActive {
		c.JSON(http.StatusForbidden, gin.H{"error": "Account is deactivated"})
		return
	}

	// Update last login
	now := time.Now()
	user.LastLoginAt = &now
	_, _ = s.db.Exec(`UPDATE users SET last_login_at = $1 WHERE id = $2`, now, user.ID)

	// Generate JWT
	token, expiresAt, err := s.jwtManager.Generate(user.ID, user.Email, string(user.UserType))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate token"})
		return
	}

	c.JSON(http.StatusOK, models.AuthResponse{
		Token:     token,
		User:      user,
		ExpiresAt: expiresAt,
	})
}

func (s *Server) RefreshToken(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)
	email := c.MustGet("email").(string)
	userType := c.MustGet("user_type").(string)

	token, expiresAt, err := s.jwtManager.Generate(userID, email, userType)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate token"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"token":      token,
		"expires_at": expiresAt,
	})
}

func (s *Server) GetCurrentUser(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)

	var user models.User
	err := s.db.QueryRow(`
		SELECT id, email, first_name, user_type, is_active, 
		       swipe_streak, total_swipes, total_matches, badges, 
		       last_login_at, created_at, updated_at
		FROM users WHERE id = $1
	`, userID).Scan(
		&user.ID, &user.Email, &user.FirstName, &user.UserType,
		&user.IsActive, &user.SwipeStreak, &user.TotalSwipes, &user.TotalMatches,
		pq.Array(&user.Badges), &user.LastLoginAt, &user.CreatedAt, &user.UpdatedAt,
	)

	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch user"})
		return
	}

	c.JSON(http.StatusOK, user)
}

func (s *Server) UpdateCurrentUser(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)

	var req struct {
		FirstName string `json:"first_name"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	_, err := s.db.Exec(`
		UPDATE users SET first_name = $1, updated_at = $2 WHERE id = $3
	`, req.FirstName, time.Now(), userID)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update user"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "User updated successfully"})
}

func (s *Server) GetUserStats(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)

	var stats models.UserStats

	// Get today's swipes
	s.db.QueryRow(`
		SELECT COUNT(*) FROM swipes 
		WHERE swiper_id = $1 AND created_at >= CURRENT_DATE
	`, userID).Scan(&stats.TodaySwipes)

	// Get weekly swipes
	s.db.QueryRow(`
		SELECT COUNT(*) FROM swipes 
		WHERE swiper_id = $1 AND created_at >= CURRENT_DATE - INTERVAL '7 days'
	`, userID).Scan(&stats.WeeklySwipes)

	// Get current streak
	s.db.QueryRow(`
		SELECT current_streak FROM daily_streaks WHERE user_id = $1
	`, userID).Scan(&stats.CurrentStreak)

	// Get total matches
	s.db.QueryRow(`
		SELECT COUNT(*) FROM matches 
		WHERE (job_seeker_id = $1 OR recruiter_id = $1) AND status = 'matched'
	`, userID).Scan(&stats.TotalMatches)

	// Get pending messages
	s.db.QueryRow(`
		SELECT COALESCE(SUM(unread_count), 0) FROM matches 
		WHERE (job_seeker_id = $1 OR recruiter_id = $1) AND status = 'matched'
	`, userID).Scan(&stats.PendingMessages)

	c.JSON(http.StatusOK, stats)
}

