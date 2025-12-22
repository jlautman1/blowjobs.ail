package models

import (
	"time"

	"github.com/google/uuid"
)

type BadgeType string

const (
	BadgeFirstSwipe      BadgeType = "first_swipe"
	BadgeFirstMatch      BadgeType = "first_match"
	BadgeStreakStarter   BadgeType = "streak_3"      // 3 day streak
	BadgeStreakMaster    BadgeType = "streak_7"      // 7 day streak
	BadgeStreakLegend    BadgeType = "streak_30"     // 30 day streak
	BadgeActiveSeeker    BadgeType = "active_50"     // 50 swipes
	BadgePowerSeeker     BadgeType = "power_100"     // 100 swipes
	BadgeMatchMaker      BadgeType = "matches_5"     // 5 matches
	BadgePopular         BadgeType = "matches_25"    // 25 matches
	BadgeInterviewer     BadgeType = "interviews_3"  // 3 interviews
	BadgeHired           BadgeType = "hired"         // Got hired!
	BadgeQuickResponder  BadgeType = "quick_respond" // Responds within 1 hour
	BadgeProfilePro      BadgeType = "profile_100"   // 100% profile completion
	BadgeEarlyAdopter    BadgeType = "early_adopter" // Joined in first month
)

type Badge struct {
	ID          BadgeType `json:"id"`
	Name        string    `json:"name"`
	Description string    `json:"description"`
	Icon        string    `json:"icon"`
	Rarity      string    `json:"rarity"` // common, rare, epic, legendary
	UnlockedAt  time.Time `json:"unlocked_at,omitempty"`
	IsUnlocked  bool      `json:"is_unlocked"`
}

// UserBadge tracks which badges a user has earned
type UserBadge struct {
	ID         uuid.UUID `json:"id"`
	UserID     uuid.UUID `json:"user_id"`
	BadgeType  BadgeType `json:"badge_type"`
	UnlockedAt time.Time `json:"unlocked_at"`
}

// DailyStreak tracks user's daily activity
type DailyStreak struct {
	UserID        uuid.UUID  `json:"user_id"`
	CurrentStreak int        `json:"current_streak"`
	LongestStreak int        `json:"longest_streak"`
	LastActiveAt  time.Time  `json:"last_active_at"`
	StreakStarted time.Time  `json:"streak_started"`
}

// Achievement for displaying progress
type Achievement struct {
	ID          string  `json:"id"`
	Name        string  `json:"name"`
	Description string  `json:"description"`
	Icon        string  `json:"icon"`
	Progress    int     `json:"progress"`    // Current progress
	Target      int     `json:"target"`      // Required for completion
	Percentage  float64 `json:"percentage"`  // Progress percentage
	IsComplete  bool    `json:"is_complete"`
	Reward      string  `json:"reward,omitempty"`
}

// DailyReward for daily login rewards
type DailyReward struct {
	Day        int    `json:"day"`
	Reward     string `json:"reward"`
	IsClaimed  bool   `json:"is_claimed"`
	IsToday    bool   `json:"is_today"`
	IsUnlocked bool   `json:"is_unlocked"`
}

// GamificationStats for user dashboard
type GamificationStats struct {
	Level           int           `json:"level"`
	XP              int           `json:"xp"`
	XPToNextLevel   int           `json:"xp_to_next_level"`
	CurrentStreak   int           `json:"current_streak"`
	LongestStreak   int           `json:"longest_streak"`
	TotalBadges     int           `json:"total_badges"`
	UnlockedBadges  []Badge       `json:"unlocked_badges"`
	Achievements    []Achievement `json:"achievements"`
	DailyRewards    []DailyReward `json:"daily_rewards"`
	TodayProgress   TodayProgress `json:"today_progress"`
}

type TodayProgress struct {
	SwipesCount    int  `json:"swipes_count"`
	SwipesGoal     int  `json:"swipes_goal"`
	HasNewMatch    bool `json:"has_new_match"`
	MessagesCount  int  `json:"messages_count"`
	ProfileViews   int  `json:"profile_views"`
}

// GetAllBadges returns all available badges with their definitions
func GetAllBadges() []Badge {
	return []Badge{
		{ID: BadgeFirstSwipe, Name: "First Steps", Description: "Made your first swipe", Icon: "👆", Rarity: "common"},
		{ID: BadgeFirstMatch, Name: "It's a Match!", Description: "Got your first match", Icon: "💫", Rarity: "common"},
		{ID: BadgeStreakStarter, Name: "Streak Starter", Description: "3 day activity streak", Icon: "🔥", Rarity: "common"},
		{ID: BadgeStreakMaster, Name: "Streak Master", Description: "7 day activity streak", Icon: "⚡", Rarity: "rare"},
		{ID: BadgeStreakLegend, Name: "Streak Legend", Description: "30 day activity streak", Icon: "🌟", Rarity: "legendary"},
		{ID: BadgeActiveSeeker, Name: "Active Seeker", Description: "50 total swipes", Icon: "🎯", Rarity: "common"},
		{ID: BadgePowerSeeker, Name: "Power Seeker", Description: "100 total swipes", Icon: "💪", Rarity: "rare"},
		{ID: BadgeMatchMaker, Name: "Match Maker", Description: "5 matches", Icon: "🤝", Rarity: "rare"},
		{ID: BadgePopular, Name: "Popular", Description: "25 matches", Icon: "⭐", Rarity: "epic"},
		{ID: BadgeInterviewer, Name: "Interview Pro", Description: "3 interviews scheduled", Icon: "📅", Rarity: "rare"},
		{ID: BadgeHired, Name: "Hired!", Description: "Got the job!", Icon: "🎉", Rarity: "legendary"},
		{ID: BadgeQuickResponder, Name: "Quick Responder", Description: "Respond within 1 hour", Icon: "⚡", Rarity: "rare"},
		{ID: BadgeProfilePro, Name: "Profile Pro", Description: "100% profile complete", Icon: "✨", Rarity: "common"},
		{ID: BadgeEarlyAdopter, Name: "Early Adopter", Description: "Joined in the first month", Icon: "🚀", Rarity: "epic"},
	}
}

