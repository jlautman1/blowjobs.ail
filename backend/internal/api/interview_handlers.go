package api

import (
	"database/sql"
	"net/http"
	"time"

	"github.com/blowjobs-ai/backend/internal/models"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

func (s *Server) ScheduleInterview(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)
	userType := c.MustGet("user_type").(string)

	if userType != "recruiter" {
		c.JSON(http.StatusForbidden, gin.H{"error": "Only recruiters can schedule interviews"})
		return
	}

	var req models.CreateInterviewRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Verify match ownership
	var matchExists bool
	var jobSeekerID uuid.UUID
	var jobTitle string
	err := s.db.QueryRow(`
		SELECT m.job_seeker_id, j.title FROM matches m
		JOIN jobs j ON j.id = m.job_id
		WHERE m.id = $1 AND m.recruiter_id = $2 AND m.status = 'matched'
	`, req.MatchID, userID).Scan(&jobSeekerID, &jobTitle)

	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, gin.H{"error": "Match not found"})
		return
	}
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to verify match"})
		return
	}
	matchExists = true
	_ = matchExists

	// Create interview
	var interview models.Interview
	err = s.db.QueryRow(`
		INSERT INTO interviews (match_id, scheduled_at, duration, type, location, instructions)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id, match_id, scheduled_at, duration, type, location, instructions, status, created_at
	`, req.MatchID, req.ScheduledAt, req.Duration, req.Type, req.Location, req.Instructions).Scan(
		&interview.ID, &interview.MatchID, &interview.ScheduledAt, &interview.Duration,
		&interview.Type, &interview.Location, &interview.Instructions, &interview.Status, &interview.CreatedAt,
	)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to schedule interview"})
		return
	}

	// Update match status
	s.db.Exec(`
		UPDATE matches SET application_status = 'interview', interview_status = 'scheduled', updated_at = $1
		WHERE id = $2
	`, time.Now(), req.MatchID)

	// Create system message
	interviewMessage := formatInterviewMessage(interview)
	s.db.Exec(`
		INSERT INTO messages (match_id, sender_id, type, content)
		VALUES ($1, $2, 'interview', $3)
	`, req.MatchID, userID, interviewMessage)

	// Send notification to job seeker
	s.hub.SendToUser(jobSeekerID, map[string]interface{}{
		"type": "interview",
		"payload": map[string]interface{}{
			"interview_id": interview.ID.String(),
			"job_title":    jobTitle,
			"scheduled_at": interview.ScheduledAt,
			"type":         interview.Type,
			"message":      "You have a new interview scheduled!",
		},
	})

	c.JSON(http.StatusCreated, interview)
}

func (s *Server) GetInterviews(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)
	userType := c.MustGet("user_type").(string)

	var query string
	if userType == "job_seeker" {
		query = `
			SELECT i.id, i.match_id, i.scheduled_at, i.duration, i.type, 
			       i.location, i.instructions, i.status, i.created_at,
			       j.title, j.company_name
			FROM interviews i
			JOIN matches m ON m.id = i.match_id
			JOIN jobs j ON j.id = m.job_id
			WHERE m.job_seeker_id = $1
			ORDER BY i.scheduled_at ASC
		`
	} else {
		query = `
			SELECT i.id, i.match_id, i.scheduled_at, i.duration, i.type, 
			       i.location, i.instructions, i.status, i.created_at,
			       j.title, u.first_name as candidate_name
			FROM interviews i
			JOIN matches m ON m.id = i.match_id
			JOIN jobs j ON j.id = m.job_id
			JOIN users u ON u.id = m.job_seeker_id
			WHERE m.recruiter_id = $1
			ORDER BY i.scheduled_at ASC
		`
	}

	rows, err := s.db.Query(query, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch interviews"})
		return
	}
	defer rows.Close()

	type InterviewWithDetails struct {
		models.Interview
		JobTitle      string `json:"job_title,omitempty"`
		CompanyName   string `json:"company_name,omitempty"`
		CandidateName string `json:"candidate_name,omitempty"`
	}

	interviews := []InterviewWithDetails{}
	for rows.Next() {
		var i InterviewWithDetails
		var extra string

		if err := rows.Scan(
			&i.ID, &i.MatchID, &i.ScheduledAt, &i.Duration, &i.Type,
			&i.Location, &i.Instructions, &i.Status, &i.CreatedAt,
			&i.JobTitle, &extra,
		); err != nil {
			continue
		}

		if userType == "job_seeker" {
			i.CompanyName = extra
		} else {
			i.CandidateName = extra
		}

		interviews = append(interviews, i)
	}

	c.JSON(http.StatusOK, interviews)
}

func (s *Server) GetInterview(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)
	interviewID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid interview ID"})
		return
	}

	var interview models.Interview
	err = s.db.QueryRow(`
		SELECT i.id, i.match_id, i.scheduled_at, i.duration, i.type, 
		       i.location, i.instructions, i.status, i.feedback, i.result, i.created_at
		FROM interviews i
		JOIN matches m ON m.id = i.match_id
		WHERE i.id = $1 AND (m.job_seeker_id = $2 OR m.recruiter_id = $2)
	`, interviewID, userID).Scan(
		&interview.ID, &interview.MatchID, &interview.ScheduledAt, &interview.Duration,
		&interview.Type, &interview.Location, &interview.Instructions, &interview.Status,
		&interview.Feedback, &interview.Result, &interview.CreatedAt,
	)

	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, gin.H{"error": "Interview not found"})
		return
	}
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch interview"})
		return
	}

	c.JSON(http.StatusOK, interview)
}

func (s *Server) UpdateInterview(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)
	userType := c.MustGet("user_type").(string)

	if userType != "recruiter" {
		c.JSON(http.StatusForbidden, gin.H{"error": "Only recruiters can update interviews"})
		return
	}

	interviewID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid interview ID"})
		return
	}

	var req struct {
		ScheduledAt  *time.Time `json:"scheduled_at"`
		Duration     *int       `json:"duration"`
		Type         *string    `json:"type"`
		Location     *string    `json:"location"`
		Instructions *string    `json:"instructions"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Verify ownership
	var matchID, jobSeekerID uuid.UUID
	err = s.db.QueryRow(`
		SELECT i.match_id, m.job_seeker_id FROM interviews i
		JOIN matches m ON m.id = i.match_id
		WHERE i.id = $1 AND m.recruiter_id = $2
	`, interviewID, userID).Scan(&matchID, &jobSeekerID)

	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, gin.H{"error": "Interview not found"})
		return
	}

	// Build dynamic update
	_, err = s.db.Exec(`
		UPDATE interviews SET 
			scheduled_at = COALESCE($1, scheduled_at),
			duration = COALESCE($2, duration),
			type = COALESCE($3, type),
			location = COALESCE($4, location),
			instructions = COALESCE($5, instructions),
			updated_at = $6
		WHERE id = $7
	`, req.ScheduledAt, req.Duration, req.Type, req.Location, req.Instructions, time.Now(), interviewID)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update interview"})
		return
	}

	// Notify job seeker
	s.hub.SendToUser(jobSeekerID, map[string]interface{}{
		"type": "interview_update",
		"payload": map[string]interface{}{
			"interview_id": interviewID.String(),
			"message":      "Interview details have been updated",
		},
	})

	c.JSON(http.StatusOK, gin.H{"message": "Interview updated successfully"})
}

func (s *Server) CancelInterview(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)
	interviewID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid interview ID"})
		return
	}

	// Cancel interview (both parties can cancel)
	result, err := s.db.Exec(`
		UPDATE interviews i SET status = 'cancelled', updated_at = $1
		FROM matches m
		WHERE i.id = $2 AND i.match_id = m.id 
		AND (m.job_seeker_id = $3 OR m.recruiter_id = $3)
	`, time.Now(), interviewID, userID)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to cancel interview"})
		return
	}

	rowsAffected, _ := result.RowsAffected()
	if rowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Interview not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Interview cancelled"})
}

func (s *Server) RecordInterviewResult(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)
	userType := c.MustGet("user_type").(string)

	if userType != "recruiter" {
		c.JSON(http.StatusForbidden, gin.H{"error": "Only recruiters can record interview results"})
		return
	}

	interviewID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid interview ID"})
		return
	}

	var req struct {
		Result   string `json:"result" binding:"required"` // pass, fail
		Feedback string `json:"feedback"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Verify ownership and update
	var matchID, jobSeekerID uuid.UUID
	err = s.db.QueryRow(`
		SELECT i.match_id, m.job_seeker_id FROM interviews i
		JOIN matches m ON m.id = i.match_id
		WHERE i.id = $1 AND m.recruiter_id = $2
	`, interviewID, userID).Scan(&matchID, &jobSeekerID)

	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, gin.H{"error": "Interview not found"})
		return
	}

	// Update interview
	s.db.Exec(`
		UPDATE interviews SET status = 'completed', result = $1, feedback = $2, updated_at = $3
		WHERE id = $4
	`, req.Result, req.Feedback, time.Now(), interviewID)

	// Update match status based on result
	newStatus := models.ApplicationStatusActive
	if req.Result == "pass" {
		newStatus = models.ApplicationStatusOffered
	} else {
		newStatus = models.ApplicationStatusRejected
	}

	s.db.Exec(`
		UPDATE matches SET application_status = $1, interview_status = 'completed', updated_at = $2
		WHERE id = $3
	`, newStatus, time.Now(), matchID)

	// Notify job seeker
	message := "Interview results are in!"
	if req.Result == "pass" {
		message = "🎉 Great news! You passed the interview!"
	}

	s.hub.SendToUser(jobSeekerID, map[string]interface{}{
		"type": "interview_result",
		"payload": map[string]interface{}{
			"interview_id": interviewID.String(),
			"result":       req.Result,
			"message":      message,
		},
	})

	c.JSON(http.StatusOK, gin.H{"message": "Interview result recorded"})
}

func formatInterviewMessage(i models.Interview) string {
	return "📅 Interview Scheduled!\n" +
		"Date: " + i.ScheduledAt.Format("Monday, January 2, 2006 at 3:04 PM") + "\n" +
		"Duration: " + string(rune(i.Duration)) + " minutes\n" +
		"Type: " + i.Type + "\n" +
		"Location: " + i.Location
}

