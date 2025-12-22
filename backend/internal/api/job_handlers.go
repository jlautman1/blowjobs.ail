package api

import (
	"database/sql"
	"fmt"
	"net/http"
	"strconv"
	"time"

	"github.com/blowjobs-ai/backend/internal/models"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/lib/pq"
)

func (s *Server) CreateJob(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)
	userType := c.MustGet("user_type").(string)

	if userType != "recruiter" {
		c.JSON(http.StatusForbidden, gin.H{"error": "Only recruiters can create jobs"})
		return
	}

	var req models.CreateJobRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Get recruiter's company info
	var companyName, companySize string
	s.db.QueryRow(`
		SELECT company_name, company_size FROM recruiter_profiles WHERE user_id = $1
	`, userID).Scan(&companyName, &companySize)

	var job models.Job
	err := s.db.QueryRow(`
		INSERT INTO jobs (
			recruiter_id, title, description, requirements, responsibilities,
			benefits, skills, experience_level, min_years_exp, max_years_exp,
			job_type, work_preference, location, salary_min, salary_max,
			salary_currency, show_salary, industry, company_name, company_size
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20)
		RETURNING id, recruiter_id, title, description, status, created_at, updated_at
	`,
		userID, req.Title, req.Description, pq.Array(req.Requirements),
		pq.Array(req.Responsibilities), pq.Array(req.Benefits), pq.Array(req.Skills),
		req.ExperienceLevel, req.MinYearsExp, req.MaxYearsExp, req.JobType,
		req.WorkPreference, req.Location, req.SalaryMin, req.SalaryMax,
		req.SalaryCurrency, req.ShowSalary, req.Industry, companyName, companySize,
	).Scan(
		&job.ID, &job.RecruiterID, &job.Title, &job.Description,
		&job.Status, &job.CreatedAt, &job.UpdatedAt,
	)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create job"})
		return
	}

	// Update recruiter's job count
	s.db.Exec(`
		UPDATE recruiter_profiles SET total_jobs_posted = total_jobs_posted + 1 
		WHERE user_id = $1
	`, userID)

	c.JSON(http.StatusCreated, job)
}

func (s *Server) GetJobs(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	if page < 1 {
		page = 1
	}
	if limit > 50 {
		limit = 50
	}
	offset := (page - 1) * limit

	rows, err := s.db.Query(`
		SELECT id, recruiter_id, title, description, skills, experience_level,
		       job_type, work_preference, location, salary_min, salary_max,
		       salary_currency, show_salary, company_name, company_size, status,
		       is_featured, created_at
		FROM jobs
		WHERE status = 'active'
		ORDER BY is_featured DESC, created_at DESC
		LIMIT $1 OFFSET $2
	`, limit, offset)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch jobs"})
		return
	}
	defer rows.Close()

	jobs := []models.Job{}
	for rows.Next() {
		var job models.Job
		if err := rows.Scan(
			&job.ID, &job.RecruiterID, &job.Title, &job.Description,
			pq.Array(&job.Skills), &job.ExperienceLevel, &job.JobType,
			&job.WorkPreference, &job.Location, &job.SalaryMin, &job.SalaryMax,
			&job.SalaryCurrency, &job.ShowSalary, &job.CompanyName, &job.CompanySize,
			&job.Status, &job.IsFeatured, &job.CreatedAt,
		); err != nil {
			continue
		}
		jobs = append(jobs, job)
	}

	c.JSON(http.StatusOK, gin.H{
		"jobs":  jobs,
		"page":  page,
		"limit": limit,
	})
}

func (s *Server) GetJob(c *gin.Context) {
	jobID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid job ID"})
		return
	}

	var job models.Job
	err = s.db.QueryRow(`
		SELECT id, recruiter_id, title, description, requirements, responsibilities,
		       benefits, skills, experience_level, min_years_exp, max_years_exp,
		       job_type, work_preference, location, salary_min, salary_max,
		       salary_currency, show_salary, industry, company_name, company_size,
		       status, application_count, view_count, match_count, is_featured,
		       expires_at, created_at, updated_at
		FROM jobs WHERE id = $1
	`, jobID).Scan(
		&job.ID, &job.RecruiterID, &job.Title, &job.Description,
		pq.Array(&job.Requirements), pq.Array(&job.Responsibilities),
		pq.Array(&job.Benefits), pq.Array(&job.Skills), &job.ExperienceLevel,
		&job.MinYearsExp, &job.MaxYearsExp, &job.JobType, &job.WorkPreference,
		&job.Location, &job.SalaryMin, &job.SalaryMax, &job.SalaryCurrency,
		&job.ShowSalary, &job.Industry, &job.CompanyName, &job.CompanySize,
		&job.Status, &job.ApplicationCount, &job.ViewCount, &job.MatchCount,
		&job.IsFeatured, &job.ExpiresAt, &job.CreatedAt, &job.UpdatedAt,
	)

	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, gin.H{"error": "Job not found"})
		return
	}
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch job"})
		return
	}

	// Increment view count
	s.db.Exec(`UPDATE jobs SET view_count = view_count + 1 WHERE id = $1`, jobID)

	c.JSON(http.StatusOK, job)
}

func (s *Server) UpdateJob(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)
	jobID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid job ID"})
		return
	}

	// Verify ownership
	var ownerID uuid.UUID
	s.db.QueryRow(`SELECT recruiter_id FROM jobs WHERE id = $1`, jobID).Scan(&ownerID)
	if ownerID != userID {
		c.JSON(http.StatusForbidden, gin.H{"error": "You can only update your own jobs"})
		return
	}

	var req models.CreateJobRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	_, err = s.db.Exec(`
		UPDATE jobs SET
			title = $1, description = $2, requirements = $3, responsibilities = $4,
			benefits = $5, skills = $6, experience_level = $7, min_years_exp = $8,
			max_years_exp = $9, job_type = $10, work_preference = $11, location = $12,
			salary_min = $13, salary_max = $14, salary_currency = $15, show_salary = $16,
			industry = $17, updated_at = $18
		WHERE id = $19
	`,
		req.Title, req.Description, pq.Array(req.Requirements), pq.Array(req.Responsibilities),
		pq.Array(req.Benefits), pq.Array(req.Skills), req.ExperienceLevel,
		req.MinYearsExp, req.MaxYearsExp, req.JobType, req.WorkPreference, req.Location,
		req.SalaryMin, req.SalaryMax, req.SalaryCurrency, req.ShowSalary,
		req.Industry, time.Now(), jobID,
	)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update job"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Job updated successfully"})
}

func (s *Server) DeleteJob(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)
	jobID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid job ID"})
		return
	}

	// Verify ownership and delete
	result, err := s.db.Exec(`DELETE FROM jobs WHERE id = $1 AND recruiter_id = $2`, jobID, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete job"})
		return
	}

	rowsAffected, _ := result.RowsAffected()
	if rowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Job not found or you don't have permission"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Job deleted successfully"})
}

func (s *Server) GetMyJobs(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)

	rows, err := s.db.Query(`
		SELECT id, title, description, skills, experience_level, job_type,
		       work_preference, location, status, application_count, view_count,
		       match_count, is_featured, created_at
		FROM jobs
		WHERE recruiter_id = $1
		ORDER BY created_at DESC
	`, userID)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch jobs"})
		return
	}
	defer rows.Close()

	jobs := []models.Job{}
	for rows.Next() {
		var job models.Job
		if err := rows.Scan(
			&job.ID, &job.Title, &job.Description, pq.Array(&job.Skills),
			&job.ExperienceLevel, &job.JobType, &job.WorkPreference, &job.Location,
			&job.Status, &job.ApplicationCount, &job.ViewCount, &job.MatchCount,
			&job.IsFeatured, &job.CreatedAt,
		); err != nil {
			continue
		}
		jobs = append(jobs, job)
	}

	c.JSON(http.StatusOK, jobs)
}

func (s *Server) GetJobFeed(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)
	userType := c.MustGet("user_type").(string)

	if userType != "job_seeker" {
		c.JSON(http.StatusForbidden, gin.H{"error": "Only job seekers can view job feed"})
		return
	}

	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	if limit > 50 {
		limit = 50
	}

	// Get jobs that user hasn't swiped on yet
	rows, err := s.db.Query(`
		SELECT j.id, j.title, j.company_name, j.location, j.work_preference,
		       j.job_type, j.experience_level, j.skills, j.salary_min, j.salary_max,
		       j.salary_currency, j.show_salary, j.benefits, j.is_featured
		FROM jobs j
		WHERE j.status = 'active'
		AND j.id NOT IN (
			SELECT swiped_id FROM swipes 
			WHERE swiper_id = $1 AND swipe_type = 'job'
		)
		ORDER BY j.is_featured DESC, j.created_at DESC
		LIMIT $2
	`, userID, limit)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch job feed"})
		return
	}
	defer rows.Close()

	cards := []models.JobCard{}
	for rows.Next() {
		var card models.JobCard
		var salaryMin, salaryMax int
		var salaryCurrency string
		var showSalary bool

		if err := rows.Scan(
			&card.ID, &card.Title, &card.CompanyName, &card.Location,
			&card.WorkPreference, &card.JobType, &card.ExperienceLevel,
			pq.Array(&card.Skills), &salaryMin, &salaryMax, &salaryCurrency,
			&showSalary, pq.Array(&card.Benefits), &card.IsFeatured,
		); err != nil {
			continue
		}

		if showSalary && salaryMax > 0 {
			card.SalaryRange = fmt.Sprintf("%s %dk - %dk", salaryCurrency, salaryMin/1000, salaryMax/1000)
		}

		cards = append(cards, card)
	}

	c.JSON(http.StatusOK, cards)
}

func (s *Server) GetCandidateFeed(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)
	userType := c.MustGet("user_type").(string)

	if userType != "recruiter" {
		c.JSON(http.StatusForbidden, gin.H{"error": "Only recruiters can view candidate feed"})
		return
	}

	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	if limit > 50 {
		limit = 50
	}

	// Get job seeker profiles that recruiter hasn't swiped on
	rows, err := s.db.Query(`
		SELECT p.id, u.first_name, p.headline, COALESCE(p.summary, ''),
		       p.experience_level, p.years_of_experience, p.skills, p.work_preference,
		       p.preferred_locations, p.expected_salary_min, p.expected_salary_max,
		       p.salary_currency, p.languages, p.certifications, p.open_to_relocation
		FROM job_seeker_profiles p
		JOIN users u ON u.id = p.user_id
		WHERE u.is_active = true
		AND p.is_profile_complete = true
		AND p.id NOT IN (
			SELECT swiped_id FROM swipes 
			WHERE swiper_id = $1 AND swipe_type = 'profile'
		)
		ORDER BY p.updated_at DESC
		LIMIT $2
	`, userID, limit)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch candidate feed"})
		return
	}
	defer rows.Close()

	cards := []models.ProfileCard{}
	for rows.Next() {
		var card models.ProfileCard
		var locations []string
		var salaryMin, salaryMax int
		var salaryCurrency string

		if err := rows.Scan(
			&card.ID, &card.FirstName, &card.Headline, &card.Summary,
			&card.ExperienceLevel, &card.YearsOfExperience, pq.Array(&card.Skills),
			&card.WorkPreference, pq.Array(&locations), &salaryMin, &salaryMax,
			&salaryCurrency, pq.Array(&card.Languages), pq.Array(&card.Certifications),
			&card.OpenToRelocation,
		); err != nil {
			continue
		}

		if len(locations) > 0 {
			card.PreferredLocation = locations[0]
		}
		if salaryMax > 0 {
			card.ExpectedSalary = fmt.Sprintf("%s %dk - %dk", salaryCurrency, salaryMin/1000, salaryMax/1000)
		}

		cards = append(cards, card)
	}

	c.JSON(http.StatusOK, cards)
}

func (s *Server) GetCandidateProfile(c *gin.Context) {
	userType := c.MustGet("user_type").(string)
	if userType != "recruiter" {
		c.JSON(http.StatusForbidden, gin.H{"error": "Only recruiters can view candidate profiles"})
		return
	}

	profileID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid profile ID"})
		return
	}

	var profile models.JobSeekerProfile
	err = s.db.QueryRow(`
		SELECT p.id, u.first_name, p.headline, p.summary, p.skills,
		       p.experience_level, p.years_of_experience, p.work_experience,
		       p.certifications, p.languages, p.preferred_locations, p.work_preference
		FROM job_seeker_profiles p
		JOIN users u ON u.id = p.user_id
		WHERE p.id = $1 AND p.is_profile_complete = true
	`, profileID).Scan(
		&profile.ID, &profile.FirstName, &profile.Headline, &profile.Summary,
		pq.Array(&profile.Skills), &profile.ExperienceLevel, &profile.YearsOfExperience,
		&profile.WorkExperience, pq.Array(&profile.Certifications),
		pq.Array(&profile.Languages), pq.Array(&profile.PreferredLocations),
		&profile.WorkPreference,
	)

	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, gin.H{"error": "Profile not found"})
		return
	}
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch profile"})
		return
	}

	c.JSON(http.StatusOK, profile)
}

