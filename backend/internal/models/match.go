package models

import (
	"time"

	"github.com/google/uuid"
)

type SwipeDirection string

const (
	SwipeLeft  SwipeDirection = "left"  // Pass/Reject
	SwipeRight SwipeDirection = "right" // Like/Interested
	SwipeUp    SwipeDirection = "up"    // Super Like (premium feature)
)

type MatchStatus string

const (
	MatchStatusPending   MatchStatus = "pending"   // One side swiped right
	MatchStatusMatched   MatchStatus = "matched"   // Both sides swiped right
	MatchStatusUnmatched MatchStatus = "unmatched" // One side unmatched
)

type InterviewStatus string

const (
	InterviewStatusNone       InterviewStatus = "none"
	InterviewStatusScheduled  InterviewStatus = "scheduled"
	InterviewStatusCompleted  InterviewStatus = "completed"
	InterviewStatusCancelled  InterviewStatus = "cancelled"
	InterviewStatusNoShow     InterviewStatus = "no_show"
)

type ApplicationStatus string

const (
	ApplicationStatusActive    ApplicationStatus = "active"
	ApplicationStatusReviewing ApplicationStatus = "reviewing"
	ApplicationStatusInterview ApplicationStatus = "interview"
	ApplicationStatusOffered   ApplicationStatus = "offered"
	ApplicationStatusRejected  ApplicationStatus = "rejected"
	ApplicationStatusWithdrawn ApplicationStatus = "withdrawn"
	ApplicationStatusHired     ApplicationStatus = "hired"
)

// Swipe records a user's swipe action
type Swipe struct {
	ID           uuid.UUID      `json:"id"`
	SwiperID     uuid.UUID      `json:"swiper_id"`     // User who swiped
	SwipedID     uuid.UUID      `json:"swiped_id"`     // Job ID (if job seeker) or Profile ID (if recruiter)
	SwipeType    string         `json:"swipe_type"`    // "job" or "profile"
	Direction    SwipeDirection `json:"direction"`
	CreatedAt    time.Time      `json:"created_at"`
}

// Match represents a mutual match between job seeker and job
type Match struct {
	ID                uuid.UUID         `json:"id"`
	JobID             uuid.UUID         `json:"job_id"`
	JobSeekerID       uuid.UUID         `json:"job_seeker_id"`
	RecruiterID       uuid.UUID         `json:"recruiter_id"`
	Status            MatchStatus       `json:"status"`
	ApplicationStatus ApplicationStatus `json:"application_status"`
	InterviewStatus   InterviewStatus   `json:"interview_status"`
	JobSeekerSwipedAt time.Time         `json:"job_seeker_swiped_at"`
	RecruiterSwipedAt *time.Time        `json:"recruiter_swiped_at,omitempty"`
	MatchedAt         *time.Time        `json:"matched_at,omitempty"`
	LastMessageAt     *time.Time        `json:"last_message_at,omitempty"`
	UnreadCount       int               `json:"unread_count"`
	CreatedAt         time.Time         `json:"created_at"`
	UpdatedAt         time.Time         `json:"updated_at"`
}

// MatchWithDetails includes related info for display
type MatchWithDetails struct {
	Match
	Job             JobCard    `json:"job"`
	JobSeekerName   string     `json:"job_seeker_name"`
	RecruiterName   string     `json:"recruiter_name"`
	CompanyName     string     `json:"company_name"`
	LastMessage     *Message   `json:"last_message,omitempty"`
}

// Interview represents a scheduled interview
type Interview struct {
	ID              uuid.UUID       `json:"id"`
	MatchID         uuid.UUID       `json:"match_id"`
	ScheduledAt     time.Time       `json:"scheduled_at"`
	Duration        int             `json:"duration"` // In minutes
	Type            string          `json:"type"`     // video, phone, in_person
	Location        string          `json:"location"` // Address or video link
	Instructions    string          `json:"instructions"`
	Status          InterviewStatus `json:"status"`
	ReminderSent    bool            `json:"reminder_sent"`
	Feedback        string          `json:"feedback,omitempty"`
	Result          string          `json:"result,omitempty"` // pass, fail, pending
	CreatedAt       time.Time       `json:"created_at"`
	UpdatedAt       time.Time       `json:"updated_at"`
}

// CreateInterviewRequest for scheduling an interview
type CreateInterviewRequest struct {
	MatchID      uuid.UUID `json:"match_id" binding:"required"`
	ScheduledAt  time.Time `json:"scheduled_at" binding:"required"`
	Duration     int       `json:"duration" binding:"required"`
	Type         string    `json:"type" binding:"required"`
	Location     string    `json:"location"`
	Instructions string    `json:"instructions"`
}

// SwipeRequest for recording a swipe
type SwipeRequest struct {
	TargetID  uuid.UUID      `json:"target_id" binding:"required"`
	Direction SwipeDirection `json:"direction" binding:"required"`
}

// MatchResponse returned when a match occurs
type MatchResponse struct {
	IsMatch bool              `json:"is_match"`
	Match   *MatchWithDetails `json:"match,omitempty"`
}

