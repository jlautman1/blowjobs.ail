package api

import (
	"database/sql"
	"net/http"
	"time"

	"github.com/blowjobs-ai/backend/internal/models"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

func (s *Server) GetMatches(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)
	userType := c.MustGet("user_type").(string)

	var query string
	if userType == "job_seeker" {
		query = `
			SELECT m.id, m.job_id, m.job_seeker_id, m.recruiter_id, m.status,
			       m.application_status, m.interview_status, m.matched_at,
			       m.last_message_at, m.unread_count,
			       j.title, j.company_name, u.first_name as recruiter_name
			FROM matches m
			JOIN jobs j ON j.id = m.job_id
			JOIN users u ON u.id = m.recruiter_id
			WHERE m.job_seeker_id = $1 AND m.status = 'matched'
			ORDER BY COALESCE(m.last_message_at, m.matched_at) DESC
		`
	} else {
		query = `
			SELECT m.id, m.job_id, m.job_seeker_id, m.recruiter_id, m.status,
			       m.application_status, m.interview_status, m.matched_at,
			       m.last_message_at, m.unread_count,
			       j.title, j.company_name, u.first_name as job_seeker_name
			FROM matches m
			JOIN jobs j ON j.id = m.job_id
			JOIN users u ON u.id = m.job_seeker_id
			WHERE m.recruiter_id = $1 AND m.status = 'matched'
			ORDER BY COALESCE(m.last_message_at, m.matched_at) DESC
		`
	}

	rows, err := s.db.Query(query, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch matches"})
		return
	}
	defer rows.Close()

	matches := []models.MatchWithDetails{}
	for rows.Next() {
		var m models.MatchWithDetails
		var jobTitle, companyName, otherName string

		if err := rows.Scan(
			&m.ID, &m.JobID, &m.JobSeekerID, &m.RecruiterID, &m.Status,
			&m.ApplicationStatus, &m.InterviewStatus, &m.MatchedAt,
			&m.LastMessageAt, &m.UnreadCount,
			&jobTitle, &companyName, &otherName,
		); err != nil {
			continue
		}

		m.Job = models.JobCard{
			ID:          m.JobID,
			Title:       jobTitle,
			CompanyName: companyName,
		}
		m.CompanyName = companyName

		if userType == "job_seeker" {
			m.RecruiterName = otherName
		} else {
			m.JobSeekerName = otherName
		}

		matches = append(matches, m)
	}

	c.JSON(http.StatusOK, matches)
}

func (s *Server) GetMatch(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)
	matchID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid match ID"})
		return
	}

	var m models.MatchWithDetails
	var jobTitle, companyName, jobSeekerName, recruiterName string

	err = s.db.QueryRow(`
		SELECT m.id, m.job_id, m.job_seeker_id, m.recruiter_id, m.status,
		       m.application_status, m.interview_status, m.matched_at,
		       m.last_message_at, m.unread_count,
		       j.title, j.company_name,
		       js.first_name as job_seeker_name,
		       r.first_name as recruiter_name
		FROM matches m
		JOIN jobs j ON j.id = m.job_id
		JOIN users js ON js.id = m.job_seeker_id
		JOIN users r ON r.id = m.recruiter_id
		WHERE m.id = $1 AND (m.job_seeker_id = $2 OR m.recruiter_id = $2)
	`, matchID, userID).Scan(
		&m.ID, &m.JobID, &m.JobSeekerID, &m.RecruiterID, &m.Status,
		&m.ApplicationStatus, &m.InterviewStatus, &m.MatchedAt,
		&m.LastMessageAt, &m.UnreadCount,
		&jobTitle, &companyName, &jobSeekerName, &recruiterName,
	)

	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, gin.H{"error": "Match not found"})
		return
	}
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch match"})
		return
	}

	m.Job = models.JobCard{ID: m.JobID, Title: jobTitle, CompanyName: companyName}
	m.CompanyName = companyName
	m.JobSeekerName = jobSeekerName
	m.RecruiterName = recruiterName

	c.JSON(http.StatusOK, m)
}

func (s *Server) UpdateMatchStatus(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)
	userType := c.MustGet("user_type").(string)

	if userType != "recruiter" {
		c.JSON(http.StatusForbidden, gin.H{"error": "Only recruiters can update match status"})
		return
	}

	matchID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid match ID"})
		return
	}

	var req struct {
		ApplicationStatus models.ApplicationStatus `json:"application_status"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Verify ownership and update
	result, err := s.db.Exec(`
		UPDATE matches SET application_status = $1, updated_at = $2
		WHERE id = $3 AND recruiter_id = $4
	`, req.ApplicationStatus, time.Now(), matchID, userID)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update status"})
		return
	}

	rowsAffected, _ := result.RowsAffected()
	if rowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Match not found"})
		return
	}

	// Get job seeker ID to send notification
	var jobSeekerID uuid.UUID
	var jobTitle string
	s.db.QueryRow(`
		SELECT m.job_seeker_id, j.title FROM matches m
		JOIN jobs j ON j.id = m.job_id
		WHERE m.id = $1
	`, matchID).Scan(&jobSeekerID, &jobTitle)

	// Send status update notification
	s.hub.SendToUser(jobSeekerID, map[string]interface{}{
		"type": "status_update",
		"payload": map[string]interface{}{
			"match_id":   matchID.String(),
			"job_title":  jobTitle,
			"new_status": req.ApplicationStatus,
		},
	})

	// Create system message about status change
	statusMessage := getStatusMessage(req.ApplicationStatus)
	s.db.Exec(`
		INSERT INTO messages (match_id, sender_id, type, content)
		VALUES ($1, $2, 'status', $3)
	`, matchID, userID, statusMessage)

	c.JSON(http.StatusOK, gin.H{"message": "Status updated successfully"})
}

func (s *Server) UnmatchMatch(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)
	matchID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid match ID"})
		return
	}

	result, err := s.db.Exec(`
		UPDATE matches SET status = 'unmatched', updated_at = $1
		WHERE id = $2 AND (job_seeker_id = $3 OR recruiter_id = $3)
	`, time.Now(), matchID, userID)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to unmatch"})
		return
	}

	rowsAffected, _ := result.RowsAffected()
	if rowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Match not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Unmatched successfully"})
}

func getStatusMessage(status models.ApplicationStatus) string {
	messages := map[models.ApplicationStatus]string{
		models.ApplicationStatusReviewing: "📋 Your application is being reviewed",
		models.ApplicationStatusInterview: "🎉 Congratulations! You've been invited for an interview",
		models.ApplicationStatusOffered:   "🎊 Amazing news! You've received a job offer",
		models.ApplicationStatusRejected:  "We've decided to move forward with other candidates",
		models.ApplicationStatusHired:     "🎉 Welcome to the team! You're hired!",
	}
	if msg, ok := messages[status]; ok {
		return msg
	}
	return "Application status updated"
}

