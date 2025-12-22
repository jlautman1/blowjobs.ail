package api

import (
	"net/http"
	"time"

	"github.com/blowjobs-ai/backend/internal/models"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

func (s *Server) GetGamificationStats(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)

	var stats models.GamificationStats

	// Get streak info
	s.db.QueryRow(`
		SELECT current_streak, longest_streak FROM daily_streaks WHERE user_id = $1
	`, userID).Scan(&stats.CurrentStreak, &stats.LongestStreak)

	// Get user stats
	var totalSwipes, totalMatches int
	s.db.QueryRow(`
		SELECT total_swipes, total_matches FROM users WHERE id = $1
	`, userID).Scan(&totalSwipes, &totalMatches)

	// Calculate level and XP (simple formula)
	stats.XP = totalSwipes*10 + totalMatches*100 + stats.CurrentStreak*50
	stats.Level = stats.XP/1000 + 1
	stats.XPToNextLevel = (stats.Level * 1000) - stats.XP

	// Get unlocked badges
	rows, err := s.db.Query(`
		SELECT badge_type, unlocked_at FROM user_badges WHERE user_id = $1
	`, userID)
	if err == nil {
		defer rows.Close()
		allBadges := models.GetAllBadges()
		badgeMap := make(map[models.BadgeType]models.Badge)
		for _, b := range allBadges {
			badgeMap[b.ID] = b
		}

		for rows.Next() {
			var badgeType models.BadgeType
			var unlockedAt time.Time
			if err := rows.Scan(&badgeType, &unlockedAt); err == nil {
				if badge, ok := badgeMap[badgeType]; ok {
					badge.IsUnlocked = true
					badge.UnlockedAt = unlockedAt
					stats.UnlockedBadges = append(stats.UnlockedBadges, badge)
				}
			}
		}
	}
	stats.TotalBadges = len(stats.UnlockedBadges)

	// Get today's progress
	s.db.QueryRow(`
		SELECT COUNT(*) FROM swipes WHERE swiper_id = $1 AND created_at >= CURRENT_DATE
	`, userID).Scan(&stats.TodayProgress.SwipesCount)
	stats.TodayProgress.SwipesGoal = 20 // Daily goal

	// Check for new matches today
	s.db.QueryRow(`
		SELECT EXISTS(SELECT 1 FROM matches WHERE 
			(job_seeker_id = $1 OR recruiter_id = $1) 
			AND matched_at >= CURRENT_DATE)
	`, userID).Scan(&stats.TodayProgress.HasNewMatch)

	// Get achievements
	stats.Achievements = s.getAchievements(userID, totalSwipes, totalMatches, stats.CurrentStreak)

	// Get daily rewards (simplified - could be expanded)
	stats.DailyRewards = s.getDailyRewards(stats.CurrentStreak)

	c.JSON(http.StatusOK, stats)
}

func (s *Server) GetBadges(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)

	allBadges := models.GetAllBadges()

	// Get user's unlocked badges
	unlockedMap := make(map[models.BadgeType]time.Time)
	rows, err := s.db.Query(`SELECT badge_type, unlocked_at FROM user_badges WHERE user_id = $1`, userID)
	if err == nil {
		defer rows.Close()
		for rows.Next() {
			var badgeType models.BadgeType
			var unlockedAt time.Time
			if rows.Scan(&badgeType, &unlockedAt) == nil {
				unlockedMap[badgeType] = unlockedAt
			}
		}
	}

	// Mark unlocked badges
	for i := range allBadges {
		if unlockedAt, ok := unlockedMap[allBadges[i].ID]; ok {
			allBadges[i].IsUnlocked = true
			allBadges[i].UnlockedAt = unlockedAt
		}
	}

	c.JSON(http.StatusOK, allBadges)
}

func (s *Server) GetAchievements(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)

	var totalSwipes, totalMatches, currentStreak int
	s.db.QueryRow(`SELECT total_swipes, total_matches FROM users WHERE id = $1`, userID).Scan(&totalSwipes, &totalMatches)
	s.db.QueryRow(`SELECT current_streak FROM daily_streaks WHERE user_id = $1`, userID).Scan(&currentStreak)

	achievements := s.getAchievements(userID, totalSwipes, totalMatches, currentStreak)
	c.JSON(http.StatusOK, achievements)
}

func (s *Server) ClaimDailyReward(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)

	// Check if already claimed today
	var lastActive time.Time
	err := s.db.QueryRow(`SELECT last_active_at FROM daily_streaks WHERE user_id = $1`, userID).Scan(&lastActive)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to check reward status"})
		return
	}

	today := time.Now().Truncate(24 * time.Hour)
	lastActiveDay := lastActive.Truncate(24 * time.Hour)

	if lastActiveDay.Equal(today) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Daily reward already claimed"})
		return
	}

	// Claim reward (update streak)
	now := time.Now()
	s.db.Exec(`UPDATE daily_streaks SET last_active_at = $1 WHERE user_id = $2`, now, userID)

	// Get current streak for reward calculation
	var streak int
	s.db.QueryRow(`SELECT current_streak FROM daily_streaks WHERE user_id = $1`, userID).Scan(&streak)

	reward := getStreakReward(streak)

	c.JSON(http.StatusOK, gin.H{
		"message": "Daily reward claimed!",
		"reward":  reward,
		"streak":  streak,
	})
}

func (s *Server) checkAndAwardBadges(userID uuid.UUID) {
	var totalSwipes, totalMatches int
	var currentStreak int

	s.db.QueryRow(`SELECT total_swipes, total_matches FROM users WHERE id = $1`, userID).Scan(&totalSwipes, &totalMatches)
	s.db.QueryRow(`SELECT current_streak FROM daily_streaks WHERE user_id = $1`, userID).Scan(&currentStreak)

	badgesToAward := []models.BadgeType{}

	// Check swipe badges
	if totalSwipes >= 1 {
		badgesToAward = append(badgesToAward, models.BadgeFirstSwipe)
	}
	if totalSwipes >= 50 {
		badgesToAward = append(badgesToAward, models.BadgeActiveSeeker)
	}
	if totalSwipes >= 100 {
		badgesToAward = append(badgesToAward, models.BadgePowerSeeker)
	}

	// Check match badges
	if totalMatches >= 1 {
		badgesToAward = append(badgesToAward, models.BadgeFirstMatch)
	}
	if totalMatches >= 5 {
		badgesToAward = append(badgesToAward, models.BadgeMatchMaker)
	}
	if totalMatches >= 25 {
		badgesToAward = append(badgesToAward, models.BadgePopular)
	}

	// Check streak badges
	if currentStreak >= 3 {
		badgesToAward = append(badgesToAward, models.BadgeStreakStarter)
	}
	if currentStreak >= 7 {
		badgesToAward = append(badgesToAward, models.BadgeStreakMaster)
	}
	if currentStreak >= 30 {
		badgesToAward = append(badgesToAward, models.BadgeStreakLegend)
	}

	// Award badges (ignore duplicates)
	for _, badge := range badgesToAward {
		s.db.Exec(`
			INSERT INTO user_badges (user_id, badge_type) VALUES ($1, $2)
			ON CONFLICT (user_id, badge_type) DO NOTHING
		`, userID, badge)
	}

	// Update user's badge array
	s.db.Exec(`
		UPDATE users SET badges = (
			SELECT ARRAY_AGG(badge_type) FROM user_badges WHERE user_id = $1
		) WHERE id = $1
	`, userID)
}

func (s *Server) getAchievements(userID uuid.UUID, totalSwipes, totalMatches, currentStreak int) []models.Achievement {
	achievements := []models.Achievement{
		{
			ID:          "swipes_50",
			Name:        "Active Seeker",
			Description: "Complete 50 swipes",
			Icon:        "🎯",
			Progress:    min(totalSwipes, 50),
			Target:      50,
			IsComplete:  totalSwipes >= 50,
		},
		{
			ID:          "swipes_100",
			Name:        "Power Seeker",
			Description: "Complete 100 swipes",
			Icon:        "💪",
			Progress:    min(totalSwipes, 100),
			Target:      100,
			IsComplete:  totalSwipes >= 100,
		},
		{
			ID:          "matches_5",
			Name:        "Match Maker",
			Description: "Get 5 matches",
			Icon:        "🤝",
			Progress:    min(totalMatches, 5),
			Target:      5,
			IsComplete:  totalMatches >= 5,
		},
		{
			ID:          "streak_7",
			Name:        "Week Warrior",
			Description: "7 day activity streak",
			Icon:        "🔥",
			Progress:    min(currentStreak, 7),
			Target:      7,
			IsComplete:  currentStreak >= 7,
		},
	}

	// Calculate percentage
	for i := range achievements {
		if achievements[i].Target > 0 {
			achievements[i].Percentage = float64(achievements[i].Progress) / float64(achievements[i].Target) * 100
		}
	}

	return achievements
}

func (s *Server) getDailyRewards(currentStreak int) []models.DailyReward {
	rewards := []models.DailyReward{
		{Day: 1, Reward: "10 XP", IsUnlocked: currentStreak >= 0, IsClaimed: currentStreak >= 1},
		{Day: 2, Reward: "20 XP", IsUnlocked: currentStreak >= 1, IsClaimed: currentStreak >= 2},
		{Day: 3, Reward: "🔥 Badge", IsUnlocked: currentStreak >= 2, IsClaimed: currentStreak >= 3},
		{Day: 4, Reward: "40 XP", IsUnlocked: currentStreak >= 3, IsClaimed: currentStreak >= 4},
		{Day: 5, Reward: "50 XP", IsUnlocked: currentStreak >= 4, IsClaimed: currentStreak >= 5},
		{Day: 6, Reward: "60 XP", IsUnlocked: currentStreak >= 5, IsClaimed: currentStreak >= 6},
		{Day: 7, Reward: "⚡ Badge", IsUnlocked: currentStreak >= 6, IsClaimed: currentStreak >= 7},
	}

	// Mark today
	todayIndex := currentStreak % 7
	if todayIndex < len(rewards) {
		rewards[todayIndex].IsToday = true
	}

	return rewards
}

func getStreakReward(streak int) string {
	switch {
	case streak >= 30:
		return "🌟 Legendary Streak Bonus! +200 XP"
	case streak >= 7:
		return "⚡ Week Streak Badge! +100 XP"
	case streak >= 3:
		return "🔥 Streak Badge! +50 XP"
	default:
		return "+10 XP"
	}
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}

func (s *Server) HandleWebSocket(c *gin.Context) {
	// WebSocket upgrade handled by gorilla
	c.JSON(http.StatusOK, gin.H{"message": "WebSocket endpoint"})
}
