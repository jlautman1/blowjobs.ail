package api

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/blowjobs-ai/backend/internal/models"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/lib/pq"
)

func (s *Server) GetJobSeekerProfile(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)

	var profile models.JobSeekerProfile
	var educationJSON, workExpJSON []byte

	var cvURL sql.NullString
	var cvUploadedAt sql.NullTime
	var cvAnalysisJSON []byte

	err := s.db.QueryRow(`
		SELECT p.id, p.user_id, u.first_name, p.headline, p.summary, p.skills,
		       p.experience_level, p.years_of_experience, p.education, p.work_experience,
		       p.certifications, p.languages, p.preferred_locations, p.work_preference,
		       p.expected_salary_min, p.expected_salary_max, p.salary_currency,
		       p.available_from, p.open_to_relocation, p.desired_job_titles, p.industries,
		       p.is_profile_complete, p.profile_completeness, 
		       p.cv_url, p.cv_uploaded_at, p.cv_analysis,
		       p.created_at, p.updated_at
		FROM job_seeker_profiles p
		JOIN users u ON u.id = p.user_id
		WHERE p.user_id = $1
	`, userID).Scan(
		&profile.ID, &profile.UserID, &profile.FirstName, &profile.Headline, &profile.Summary,
		pq.Array(&profile.Skills), &profile.ExperienceLevel, &profile.YearsOfExperience,
		&educationJSON, &workExpJSON, pq.Array(&profile.Certifications),
		pq.Array(&profile.Languages), pq.Array(&profile.PreferredLocations),
		&profile.WorkPreference, &profile.ExpectedSalaryMin, &profile.ExpectedSalaryMax,
		&profile.SalaryCurrency, &profile.AvailableFrom, &profile.OpenToRelocation,
		pq.Array(&profile.DesiredJobTitles), pq.Array(&profile.Industries),
		&profile.IsProfileComplete, &profile.ProfileCompleteness,
		&cvURL, &cvUploadedAt, &cvAnalysisJSON,
		&profile.CreatedAt, &profile.UpdatedAt,
	)

	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, gin.H{"error": "Profile not found"})
		return
	}
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch profile"})
		return
	}

	// Parse JSON fields
	json.Unmarshal(educationJSON, &profile.Education)
	json.Unmarshal(workExpJSON, &profile.WorkExperience)

	// Build response with CV info
	response := map[string]interface{}{
		"id":                  profile.ID,
		"user_id":             profile.UserID,
		"first_name":          profile.FirstName,
		"headline":             profile.Headline,
		"summary":              profile.Summary,
		"skills":               profile.Skills,
		"experience_level":     profile.ExperienceLevel,
		"years_of_experience":  profile.YearsOfExperience,
		"education":            profile.Education,
		"work_experience":      profile.WorkExperience,
		"certifications":      profile.Certifications,
		"languages":            profile.Languages,
		"preferred_locations":  profile.PreferredLocations,
		"work_preference":      profile.WorkPreference,
		"expected_salary_min":  profile.ExpectedSalaryMin,
		"expected_salary_max":  profile.ExpectedSalaryMax,
		"salary_currency":      profile.SalaryCurrency,
		"available_from":       profile.AvailableFrom,
		"open_to_relocation":   profile.OpenToRelocation,
		"desired_job_titles":   profile.DesiredJobTitles,
		"industries":           profile.Industries,
		"is_profile_complete":  profile.IsProfileComplete,
		"profile_completeness": profile.ProfileCompleteness,
		"created_at":           profile.CreatedAt,
		"updated_at":           profile.UpdatedAt,
	}

	if cvURL.Valid {
		response["cv_url"] = cvURL.String
	}
	if cvUploadedAt.Valid {
		response["cv_uploaded_at"] = cvUploadedAt.Time
	}
	if len(cvAnalysisJSON) > 0 {
		var analysis map[string]interface{}
		json.Unmarshal(cvAnalysisJSON, &analysis)
		response["cv_analysis"] = analysis
	}

	c.JSON(http.StatusOK, response)
}

func (s *Server) UpdateJobSeekerProfile(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)

	var req models.CreateJobSeekerProfileRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	educationJSON, _ := json.Marshal(req.Education)
	workExpJSON, _ := json.Marshal(req.WorkExperience)

	// Calculate profile completeness
	completeness := calculateProfileCompleteness(req)

	_, err := s.db.Exec(`
		UPDATE job_seeker_profiles SET
			headline = $1, summary = $2, skills = $3, experience_level = $4,
			years_of_experience = $5, education = $6, work_experience = $7,
			certifications = $8, languages = $9, preferred_locations = $10,
			work_preference = $11, expected_salary_min = $12, expected_salary_max = $13,
			salary_currency = $14, available_from = $15, open_to_relocation = $16,
			desired_job_titles = $17, industries = $18, is_profile_complete = $19,
			profile_completeness = $20, updated_at = $21
		WHERE user_id = $22
	`,
		req.Headline, req.Summary, pq.Array(req.Skills), req.ExperienceLevel,
		req.YearsOfExperience, educationJSON, workExpJSON,
		pq.Array(req.Certifications), pq.Array(req.Languages), pq.Array(req.PreferredLocations),
		req.WorkPreference, req.ExpectedSalaryMin, req.ExpectedSalaryMax,
		req.SalaryCurrency, req.AvailableFrom, req.OpenToRelocation,
		pq.Array(req.DesiredJobTitles), pq.Array(req.Industries), completeness >= 80,
		completeness, time.Now(), userID,
	)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update profile"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message":              "Profile updated successfully",
		"profile_completeness": completeness,
	})
}

func (s *Server) GetRecruiterProfile(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)

	var profile models.RecruiterProfile
	err := s.db.QueryRow(`
		SELECT p.id, p.user_id, u.first_name, p.company_name, p.company_website,
		       p.company_size, p.industry, p.position, p.bio, p.is_verified,
		       p.total_jobs_posted, p.total_hires, p.response_rate, p.avg_response_time,
		       p.created_at, p.updated_at
		FROM recruiter_profiles p
		JOIN users u ON u.id = p.user_id
		WHERE p.user_id = $1
	`, userID).Scan(
		&profile.ID, &profile.UserID, &profile.FirstName, &profile.CompanyName,
		&profile.CompanyWebsite, &profile.CompanySize, &profile.Industry,
		&profile.Position, &profile.Bio, &profile.IsVerified,
		&profile.TotalJobsPosted, &profile.TotalHires, &profile.ResponseRate,
		&profile.AvgResponseTime, &profile.CreatedAt, &profile.UpdatedAt,
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

func (s *Server) UpdateRecruiterProfile(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)

	var req models.CreateRecruiterProfileRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	_, err := s.db.Exec(`
		UPDATE recruiter_profiles SET
			company_name = $1, company_website = $2, company_size = $3,
			industry = $4, position = $5, bio = $6, updated_at = $7
		WHERE user_id = $8
	`, req.CompanyName, req.CompanyWebsite, req.CompanySize,
		req.Industry, req.Position, req.Bio, time.Now(), userID)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update profile"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Profile updated successfully"})
}

func calculateProfileCompleteness(profile models.CreateJobSeekerProfileRequest) int {
	total := 0
	maxScore := 100

	// Basic info (30 points)
	if profile.Headline != "" {
		total += 10
	}
	if profile.Summary != "" {
		total += 10
	}
	if len(profile.Skills) > 0 {
		total += 10
	}

	// Experience (20 points)
	if profile.ExperienceLevel != "" {
		total += 10
	}
	if len(profile.WorkExperience) > 0 {
		total += 10
	}

	// Education (10 points)
	if len(profile.Education) > 0 {
		total += 10
	}

	// Preferences (20 points)
	if len(profile.PreferredLocations) > 0 {
		total += 5
	}
	if profile.WorkPreference != "" {
		total += 5
	}
	if profile.ExpectedSalaryMin > 0 || profile.ExpectedSalaryMax > 0 {
		total += 10
	}

	// Additional (20 points)
	if len(profile.DesiredJobTitles) > 0 {
		total += 10
	}
	if len(profile.Industries) > 0 {
		total += 5
	}
	if len(profile.Languages) > 0 {
		total += 5
	}

	if total > maxScore {
		total = maxScore
	}

	return total
}

// UploadCV handles CV file upload and AI analysis
func (s *Server) UploadCV(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)

	// Get file from form
	file, err := c.FormFile("cv")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No file provided"})
		return
	}

	// Validate file type
	ext := strings.ToLower(filepath.Ext(file.Filename))
	if ext != ".pdf" && ext != ".doc" && ext != ".docx" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid file type. Only PDF, DOC, and DOCX are allowed"})
		return
	}

	// Validate file size (5MB max)
	if file.Size > 5*1024*1024 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "File too large. Maximum size is 5MB"})
		return
	}

	// Create uploads directory if it doesn't exist
	uploadDir := "./uploads/cv"
	if err := os.MkdirAll(uploadDir, 0755); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create upload directory"})
		return
	}

	// Generate unique filename
	fileID := uuid.New().String()
	filename := fmt.Sprintf("%s%s", fileID, ext)
	filePath := filepath.Join(uploadDir, filename)

	// Save file
	src, err := file.Open()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to open file"})
		return
	}
	defer src.Close()

	dst, err := os.Create(filePath)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save file"})
		return
	}
	defer dst.Close()

	if _, err := io.Copy(dst, src); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save file"})
		return
	}

	// Generate URL (in production, this would be a CDN URL)
	cvURL := fmt.Sprintf("/uploads/cv/%s", filename)

	// Basic AI Analysis (placeholder - in production, use actual AI service)
	analysis := performCVAnalysis(file.Filename, filePath)

	analysisJSON, _ := json.Marshal(analysis)

	// Update profile with CV info
	_, err = s.db.Exec(`
		UPDATE job_seeker_profiles SET
			cv_url = $1,
			cv_uploaded_at = $2,
			cv_analysis = $3,
			updated_at = $4
		WHERE user_id = $5
	`, cvURL, time.Now(), analysisJSON, time.Now(), userID)

	if err != nil {
		// If profile doesn't exist, create it
		_, err = s.db.Exec(`
			INSERT INTO job_seeker_profiles (user_id, cv_url, cv_uploaded_at, cv_analysis, updated_at)
			VALUES ($1, $2, $3, $4, $5)
			ON CONFLICT (user_id) DO UPDATE SET
				cv_url = EXCLUDED.cv_url,
				cv_uploaded_at = EXCLUDED.cv_uploaded_at,
				cv_analysis = EXCLUDED.cv_analysis,
				updated_at = EXCLUDED.updated_at
		`, userID, cvURL, time.Now(), analysisJSON, time.Now())
		
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save CV info"})
			return
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"message":   "CV uploaded and analyzed successfully",
		"cv_url":    cvURL,
		"analysis":  analysis,
	})
}

// performCVAnalysis performs basic analysis on the CV
// In production, this would use an AI service to extract skills, experience, etc.
func performCVAnalysis(filename, filePath string) map[string]interface{} {
	// Placeholder analysis - in production, integrate with AI service
	// For now, return basic structure that can be populated by actual AI
	
	// Extract filename info as placeholder
	lowerName := strings.ToLower(filename)
	
	analysis := map[string]interface{}{
		"skills":              []string{"JavaScript", "Python", "React"}, // Placeholder
		"experience_level":    "mid",                                      // Placeholder
		"years_of_experience": 3,                                          // Placeholder
		"education":          []string{"Bachelor's Degree"},             // Placeholder
		"analyzed_at":        time.Now().Format(time.RFC3339),
		"status":             "completed",
	}

	// Basic keyword detection from filename (very simple placeholder)
	if strings.Contains(lowerName, "senior") || strings.Contains(lowerName, "sr") {
		analysis["experience_level"] = "senior"
		analysis["years_of_experience"] = 7
	} else if strings.Contains(lowerName, "junior") || strings.Contains(lowerName, "jr") {
		analysis["experience_level"] = "junior"
		analysis["years_of_experience"] = 1
	}

	return analysis
}

