package models

import (
	"time"

	"github.com/google/uuid"
)

type ExperienceLevel string

const (
	ExperienceLevelEntry     ExperienceLevel = "entry"
	ExperienceLevelJunior    ExperienceLevel = "junior"
	ExperienceLevelMid       ExperienceLevel = "mid"
	ExperienceLevelSenior    ExperienceLevel = "senior"
	ExperienceLevelLead      ExperienceLevel = "lead"
	ExperienceLevelExecutive ExperienceLevel = "executive"
)

type WorkPreference string

const (
	WorkPreferenceRemote WorkPreference = "remote"
	WorkPreferenceHybrid WorkPreference = "hybrid"
	WorkPreferenceOnsite WorkPreference = "onsite"
	WorkPreferenceAny    WorkPreference = "any"
)

// JobSeekerProfile is the detailed profile for job seekers (shown anonymously to recruiters)
type JobSeekerProfile struct {
	ID                  uuid.UUID       `json:"id"`
	UserID              uuid.UUID       `json:"user_id"`
	FirstName           string          `json:"first_name"` // Only first name shown
	Headline            string          `json:"headline"`   // e.g., "Senior Software Engineer"
	Summary             string          `json:"summary"`
	Skills              []string        `json:"skills"`
	ExperienceLevel     ExperienceLevel `json:"experience_level"`
	YearsOfExperience   int             `json:"years_of_experience"`
	Education           []Education     `json:"education"`
	WorkExperience      []WorkExperience `json:"work_experience"`
	Certifications      []string        `json:"certifications"`
	Languages           []string        `json:"languages"`
	PreferredLocations  []string        `json:"preferred_locations"`
	WorkPreference      WorkPreference  `json:"work_preference"`
	ExpectedSalaryMin   int             `json:"expected_salary_min"`
	ExpectedSalaryMax   int             `json:"expected_salary_max"`
	SalaryCurrency      string          `json:"salary_currency"`
	AvailableFrom       *time.Time      `json:"available_from,omitempty"`
	OpenToRelocation    bool            `json:"open_to_relocation"`
	DesiredJobTitles    []string        `json:"desired_job_titles"`
	Industries          []string        `json:"industries"`
	IsProfileComplete   bool            `json:"is_profile_complete"`
	ProfileCompleteness int             `json:"profile_completeness"` // Percentage 0-100
	CreatedAt           time.Time       `json:"created_at"`
	UpdatedAt           time.Time       `json:"updated_at"`
}

type Education struct {
	Institution  string     `json:"institution"`
	Degree       string     `json:"degree"`
	FieldOfStudy string     `json:"field_of_study"`
	StartDate    time.Time  `json:"start_date"`
	EndDate      *time.Time `json:"end_date,omitempty"`
	IsCurrent    bool       `json:"is_current"`
}

type WorkExperience struct {
	// Company name is anonymized - shown as industry/size
	CompanySize   string     `json:"company_size"` // startup, small, medium, large, enterprise
	Industry      string     `json:"industry"`
	JobTitle      string     `json:"job_title"`
	Description   string     `json:"description"`
	Achievements  []string   `json:"achievements"`
	Skills        []string   `json:"skills"`
	StartDate     time.Time  `json:"start_date"`
	EndDate       *time.Time `json:"end_date,omitempty"`
	IsCurrent     bool       `json:"is_current"`
}

// RecruiterProfile is the profile for recruiters/headhunters
type RecruiterProfile struct {
	ID              uuid.UUID  `json:"id"`
	UserID          uuid.UUID  `json:"user_id"`
	FirstName       string     `json:"first_name"`
	CompanyName     string     `json:"company_name"`
	CompanyWebsite  string     `json:"company_website"`
	CompanySize     string     `json:"company_size"`
	Industry        string     `json:"industry"`
	Position        string     `json:"position"` // e.g., "Senior Recruiter"
	Bio             string     `json:"bio"`
	IsVerified      bool       `json:"is_verified"`
	TotalJobsPosted int        `json:"total_jobs_posted"`
	TotalHires      int        `json:"total_hires"`
	ResponseRate    float64    `json:"response_rate"` // Percentage
	AvgResponseTime int        `json:"avg_response_time"` // In hours
	CreatedAt       time.Time  `json:"created_at"`
	UpdatedAt       time.Time  `json:"updated_at"`
}

// CreateJobSeekerProfileRequest for creating/updating job seeker profile
type CreateJobSeekerProfileRequest struct {
	Headline           string          `json:"headline"`
	Summary            string          `json:"summary"`
	Skills             []string        `json:"skills"`
	ExperienceLevel    ExperienceLevel `json:"experience_level"`
	YearsOfExperience  int             `json:"years_of_experience"`
	Education          []Education     `json:"education"`
	WorkExperience     []WorkExperience `json:"work_experience"`
	Certifications     []string        `json:"certifications"`
	Languages          []string        `json:"languages"`
	PreferredLocations []string        `json:"preferred_locations"`
	WorkPreference     WorkPreference  `json:"work_preference"`
	ExpectedSalaryMin  int             `json:"expected_salary_min"`
	ExpectedSalaryMax  int             `json:"expected_salary_max"`
	SalaryCurrency     string          `json:"salary_currency"`
	AvailableFrom      *time.Time      `json:"available_from"`
	OpenToRelocation   bool            `json:"open_to_relocation"`
	DesiredJobTitles   []string        `json:"desired_job_titles"`
	Industries         []string        `json:"industries"`
}

// CreateRecruiterProfileRequest for creating/updating recruiter profile
type CreateRecruiterProfileRequest struct {
	CompanyName    string `json:"company_name" binding:"required"`
	CompanyWebsite string `json:"company_website"`
	CompanySize    string `json:"company_size"`
	Industry       string `json:"industry"`
	Position       string `json:"position"`
	Bio            string `json:"bio"`
}

