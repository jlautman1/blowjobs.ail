package models

import (
	"time"

	"github.com/google/uuid"
)

type UserType string

const (
	UserTypeJobSeeker  UserType = "job_seeker"
	UserTypeRecruiter  UserType = "recruiter"
)

type User struct {
	ID           uuid.UUID  `json:"id"`
	Email        string     `json:"email"`
	PasswordHash string     `json:"-"`
	FirstName    string     `json:"first_name"`
	UserType     UserType   `json:"user_type"`
	IsActive     bool       `json:"is_active"`
	CreatedAt    time.Time  `json:"created_at"`
	UpdatedAt    time.Time  `json:"updated_at"`
	LastLoginAt  *time.Time `json:"last_login_at,omitempty"`
	
	// Gamification
	SwipeStreak     int       `json:"swipe_streak"`
	TotalSwipes     int       `json:"total_swipes"`
	TotalMatches    int       `json:"total_matches"`
	Badges          []string  `json:"badges"`
	LastSwipeDate   *time.Time `json:"last_swipe_date,omitempty"`
}

type UserStats struct {
	TodaySwipes      int `json:"today_swipes"`
	WeeklySwipes     int `json:"weekly_swipes"`
	CurrentStreak    int `json:"current_streak"`
	TotalMatches     int `json:"total_matches"`
	PendingMessages  int `json:"pending_messages"`
	ProfileViews     int `json:"profile_views"`
}

// CreateUserRequest is used for user registration
type CreateUserRequest struct {
	Email     string   `json:"email" binding:"required,email"`
	Password  string   `json:"password" binding:"required,min=8"`
	FirstName string   `json:"first_name" binding:"required"`
	UserType  UserType `json:"user_type" binding:"required"`
}

// LoginRequest is used for user authentication
type LoginRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required"`
}

// AuthResponse is returned after successful login/registration
type AuthResponse struct {
	Token     string `json:"token"`
	User      User   `json:"user"`
	ExpiresAt int64  `json:"expires_at"`
}

