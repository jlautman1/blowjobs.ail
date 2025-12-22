package models

import (
	"time"

	"github.com/google/uuid"
)

type JobType string

const (
	JobTypeFullTime   JobType = "full_time"
	JobTypePartTime   JobType = "part_time"
	JobTypeContract   JobType = "contract"
	JobTypeFreelance  JobType = "freelance"
	JobTypeInternship JobType = "internship"
)

type JobStatus string

const (
	JobStatusActive   JobStatus = "active"
	JobStatusPaused   JobStatus = "paused"
	JobStatusClosed   JobStatus = "closed"
	JobStatusFilled   JobStatus = "filled"
)

// Job represents a job posting by a recruiter
type Job struct {
	ID                uuid.UUID       `json:"id"`
	RecruiterID       uuid.UUID       `json:"recruiter_id"`
	Title             string          `json:"title"`
	Description       string          `json:"description"`
	Requirements      []string        `json:"requirements"`
	Responsibilities  []string        `json:"responsibilities"`
	Benefits          []string        `json:"benefits"`
	Skills            []string        `json:"skills"`
	ExperienceLevel   ExperienceLevel `json:"experience_level"`
	MinYearsExp       int             `json:"min_years_exp"`
	MaxYearsExp       int             `json:"max_years_exp"`
	JobType           JobType         `json:"job_type"`
	WorkPreference    WorkPreference  `json:"work_preference"`
	Location          string          `json:"location"`
	SalaryMin         int             `json:"salary_min"`
	SalaryMax         int             `json:"salary_max"`
	SalaryCurrency    string          `json:"salary_currency"`
	ShowSalary        bool            `json:"show_salary"`
	Industry          string          `json:"industry"`
	CompanyName       string          `json:"company_name"`
	CompanySize       string          `json:"company_size"`
	Status            JobStatus       `json:"status"`
	ApplicationCount  int             `json:"application_count"`
	ViewCount         int             `json:"view_count"`
	MatchCount        int             `json:"match_count"`
	IsFeatured        bool            `json:"is_featured"`
	ExpiresAt         *time.Time      `json:"expires_at,omitempty"`
	CreatedAt         time.Time       `json:"created_at"`
	UpdatedAt         time.Time       `json:"updated_at"`
}

// CreateJobRequest for creating a new job posting
type CreateJobRequest struct {
	Title            string          `json:"title" binding:"required"`
	Description      string          `json:"description" binding:"required"`
	Requirements     []string        `json:"requirements"`
	Responsibilities []string        `json:"responsibilities"`
	Benefits         []string        `json:"benefits"`
	Skills           []string        `json:"skills" binding:"required"`
	ExperienceLevel  ExperienceLevel `json:"experience_level" binding:"required"`
	MinYearsExp      int             `json:"min_years_exp"`
	MaxYearsExp      int             `json:"max_years_exp"`
	JobType          JobType         `json:"job_type" binding:"required"`
	WorkPreference   WorkPreference  `json:"work_preference" binding:"required"`
	Location         string          `json:"location"`
	SalaryMin        int             `json:"salary_min"`
	SalaryMax        int             `json:"salary_max"`
	SalaryCurrency   string          `json:"salary_currency"`
	ShowSalary       bool            `json:"show_salary"`
	Industry         string          `json:"industry"`
}

// JobCard is the simplified version shown when swiping
type JobCard struct {
	ID              uuid.UUID       `json:"id"`
	Title           string          `json:"title"`
	CompanyName     string          `json:"company_name"`
	Location        string          `json:"location"`
	WorkPreference  WorkPreference  `json:"work_preference"`
	JobType         JobType         `json:"job_type"`
	ExperienceLevel ExperienceLevel `json:"experience_level"`
	Skills          []string        `json:"skills"`
	SalaryRange     string          `json:"salary_range,omitempty"` // Formatted string if shown
	Benefits        []string        `json:"benefits"`
	IsFeatured      bool            `json:"is_featured"`
	MatchScore      int             `json:"match_score"` // 0-100 based on profile match
}

// ProfileCard is the simplified job seeker profile shown to recruiters
type ProfileCard struct {
	ID                uuid.UUID       `json:"id"`
	FirstName         string          `json:"first_name"`
	Headline          string          `json:"headline"`
	Summary           string          `json:"summary,omitempty"`
	ExperienceLevel   ExperienceLevel `json:"experience_level"`
	YearsOfExperience int             `json:"years_of_experience"`
	Skills            []string        `json:"skills"`
	WorkPreference    WorkPreference  `json:"work_preference"`
	PreferredLocation string          `json:"preferred_location"`
	ExpectedSalary    string          `json:"expected_salary,omitempty"`
	Languages         []string        `json:"languages,omitempty"`
	Certifications    []string        `json:"certifications,omitempty"`
	OpenToRelocation  bool            `json:"open_to_relocation"`
	MatchScore        int             `json:"match_score"` // 0-100 based on job requirements match
}

