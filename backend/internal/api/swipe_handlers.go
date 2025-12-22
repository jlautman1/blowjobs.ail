package api

import (
	"database/sql"
	"net/http"
	"time"

	"github.com/blowjobs-ai/backend/internal/models"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

func (s *Server) RecordSwipe(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)
	userType := c.MustGet("user_type").(string)

	var req models.SwipeRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	swipeType := "job"
	if userType == "recruiter" {
		swipeType = "profile"
	}

	// Record the swipe
	_, err := s.db.Exec(`
		INSERT INTO swipes (swiper_id, swiped_id, swipe_type, direction)
		VALUES ($1, $2, $3, $4)
		ON CONFLICT (swiper_id, swiped_id, swipe_type) DO UPDATE SET direction = $4
	`, userID, req.TargetID, swipeType, req.Direction)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to record swipe"})
		return
	}

	// Update user's swipe stats
	s.updateSwipeStats(userID)

	// Check for match only if swiped right
	if req.Direction != models.SwipeRight && req.Direction != models.SwipeUp {
		c.JSON(http.StatusOK, models.MatchResponse{IsMatch: false})
		return
	}

	// Handle matching logic
	var matchResponse models.MatchResponse

	if userType == "job_seeker" {
		// Job seeker swiped right on a job
		matchResponse = s.handleJobSeekerSwipe(userID, req.TargetID)
	} else {
		// Recruiter swiped right on a profile
		matchResponse = s.handleRecruiterSwipe(userID, req.TargetID)
	}

	c.JSON(http.StatusOK, matchResponse)
}

func (s *Server) handleJobSeekerSwipe(jobSeekerID, jobID uuid.UUID) models.MatchResponse {
	// Get job details
	var recruiterID uuid.UUID
	var jobTitle, companyName string
	err := s.db.QueryRow(`
		SELECT recruiter_id, title, company_name FROM jobs WHERE id = $1
	`, jobID).Scan(&recruiterID, &jobTitle, &companyName)
	if err != nil {
		return models.MatchResponse{IsMatch: false}
	}

	// Get job seeker's profile ID
	var profileID uuid.UUID
	s.db.QueryRow(`SELECT id FROM job_seeker_profiles WHERE user_id = $1`, jobSeekerID).Scan(&profileID)

	// Check if recruiter already swiped right on this job seeker for this job
	var existingSwipe string
	err = s.db.QueryRow(`
		SELECT direction FROM swipes 
		WHERE swiper_id = $1 AND swiped_id = $2 AND swipe_type = 'profile'
	`, recruiterID, profileID).Scan(&existingSwipe)

	if err == sql.ErrNoRows || (existingSwipe != string(models.SwipeRight) && existingSwipe != string(models.SwipeUp)) {
		// No match yet - create pending match entry
		s.db.Exec(`
			INSERT INTO matches (job_id, job_seeker_id, recruiter_id, status, job_seeker_swiped_at)
			VALUES ($1, $2, $3, 'pending', $4)
			ON CONFLICT (job_id, job_seeker_id) DO NOTHING
		`, jobID, jobSeekerID, recruiterID, time.Now())

		// Update job application count
		s.db.Exec(`UPDATE jobs SET application_count = application_count + 1 WHERE id = $1`, jobID)

		return models.MatchResponse{IsMatch: false}
	}

	// It's a match!
	now := time.Now()
	var matchID uuid.UUID
	err = s.db.QueryRow(`
		INSERT INTO matches (job_id, job_seeker_id, recruiter_id, status, job_seeker_swiped_at, recruiter_swiped_at, matched_at)
		VALUES ($1, $2, $3, 'matched', $4, $4, $4)
		ON CONFLICT (job_id, job_seeker_id) 
		DO UPDATE SET status = 'matched', matched_at = $4
		RETURNING id
	`, jobID, jobSeekerID, recruiterID, now).Scan(&matchID)

	if err != nil {
		return models.MatchResponse{IsMatch: false}
	}

	// Update match counts
	s.db.Exec(`UPDATE users SET total_matches = total_matches + 1 WHERE id IN ($1, $2)`, jobSeekerID, recruiterID)
	s.db.Exec(`UPDATE jobs SET match_count = match_count + 1 WHERE id = $1`, jobID)

	// Award badges if applicable
	s.checkAndAwardBadges(jobSeekerID)
	s.checkAndAwardBadges(recruiterID)

	// Send real-time notification to recruiter
	s.hub.SendToUser(recruiterID, map[string]interface{}{
		"type": "match",
		"payload": map[string]interface{}{
			"match_id":  matchID.String(),
			"job_title": jobTitle,
			"message":   "You have a new match!",
		},
	})

	return models.MatchResponse{
		IsMatch: true,
		Match: &models.MatchWithDetails{
			Match: models.Match{
				ID:          matchID,
				JobID:       jobID,
				JobSeekerID: jobSeekerID,
				RecruiterID: recruiterID,
				Status:      models.MatchStatusMatched,
				MatchedAt:   &now,
			},
			CompanyName: companyName,
			Job: models.JobCard{
				ID:          jobID,
				Title:       jobTitle,
				CompanyName: companyName,
			},
		},
	}
}

func (s *Server) handleRecruiterSwipe(recruiterID, profileID uuid.UUID) models.MatchResponse {
	// Get job seeker user ID
	var jobSeekerID uuid.UUID
	var firstName string
	err := s.db.QueryRow(`
		SELECT p.user_id, u.first_name FROM job_seeker_profiles p
		JOIN users u ON u.id = p.user_id
		WHERE p.id = $1
	`, profileID).Scan(&jobSeekerID, &firstName)
	if err != nil {
		return models.MatchResponse{IsMatch: false}
	}

	// Check if job seeker already swiped right on any of this recruiter's jobs
	var jobID uuid.UUID
	var jobTitle, companyName string
	err = s.db.QueryRow(`
		SELECT j.id, j.title, j.company_name FROM jobs j
		JOIN swipes s ON s.swiped_id = j.id
		WHERE j.recruiter_id = $1 
		AND s.swiper_id = $2 
		AND s.swipe_type = 'job'
		AND s.direction IN ('right', 'up')
		LIMIT 1
	`, recruiterID, jobSeekerID).Scan(&jobID, &jobTitle, &companyName)

	if err == sql.ErrNoRows {
		// No match yet - the job seeker hasn't swiped on any jobs from this recruiter
		return models.MatchResponse{IsMatch: false}
	}

	// It's a match!
	now := time.Now()
	var matchID uuid.UUID
	err = s.db.QueryRow(`
		INSERT INTO matches (job_id, job_seeker_id, recruiter_id, status, recruiter_swiped_at, matched_at)
		VALUES ($1, $2, $3, 'matched', $4, $4)
		ON CONFLICT (job_id, job_seeker_id) 
		DO UPDATE SET status = 'matched', recruiter_swiped_at = $4, matched_at = $4
		RETURNING id
	`, jobID, jobSeekerID, recruiterID, now).Scan(&matchID)

	if err != nil {
		return models.MatchResponse{IsMatch: false}
	}

	// Update match counts
	s.db.Exec(`UPDATE users SET total_matches = total_matches + 1 WHERE id IN ($1, $2)`, jobSeekerID, recruiterID)
	s.db.Exec(`UPDATE jobs SET match_count = match_count + 1 WHERE id = $1`, jobID)

	// Award badges if applicable
	s.checkAndAwardBadges(jobSeekerID)
	s.checkAndAwardBadges(recruiterID)

	// Send real-time notification to job seeker
	s.hub.SendToUser(jobSeekerID, map[string]interface{}{
		"type": "match",
		"payload": map[string]interface{}{
			"match_id":     matchID.String(),
			"job_title":    jobTitle,
			"company_name": companyName,
			"message":      "You have a new match!",
		},
	})

	return models.MatchResponse{
		IsMatch: true,
		Match: &models.MatchWithDetails{
			Match: models.Match{
				ID:          matchID,
				JobID:       jobID,
				JobSeekerID: jobSeekerID,
				RecruiterID: recruiterID,
				Status:      models.MatchStatusMatched,
				MatchedAt:   &now,
			},
			JobSeekerName: firstName,
			CompanyName:   companyName,
			Job: models.JobCard{
				ID:          jobID,
				Title:       jobTitle,
				CompanyName: companyName,
			},
		},
	}
}

func (s *Server) updateSwipeStats(userID uuid.UUID) {
	now := time.Now()
	today := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, now.Location())

	// Update total swipes
	s.db.Exec(`UPDATE users SET total_swipes = total_swipes + 1, last_swipe_date = $1 WHERE id = $2`, now, userID)

	// Update daily streak
	var lastActive time.Time
	var currentStreak int
	err := s.db.QueryRow(`SELECT last_active_at, current_streak FROM daily_streaks WHERE user_id = $1`, userID).Scan(&lastActive, &currentStreak)

	if err == sql.ErrNoRows {
		// Create new streak entry
		s.db.Exec(`INSERT INTO daily_streaks (user_id, current_streak, longest_streak, last_active_at) VALUES ($1, 1, 1, $2)`, userID, now)
		return
	}

	lastActiveDate := time.Date(lastActive.Year(), lastActive.Month(), lastActive.Day(), 0, 0, 0, 0, lastActive.Location())
	yesterday := today.AddDate(0, 0, -1)

	if lastActiveDate.Equal(today) {
		// Already active today, just update timestamp
		s.db.Exec(`UPDATE daily_streaks SET last_active_at = $1 WHERE user_id = $2`, now, userID)
	} else if lastActiveDate.Equal(yesterday) {
		// Continue streak
		newStreak := currentStreak + 1
		s.db.Exec(`
			UPDATE daily_streaks 
			SET current_streak = $1, longest_streak = GREATEST(longest_streak, $1), last_active_at = $2 
			WHERE user_id = $3
		`, newStreak, now, userID)
		s.db.Exec(`UPDATE users SET swipe_streak = $1 WHERE id = $2`, newStreak, userID)
	} else {
		// Streak broken, reset to 1
		s.db.Exec(`
			UPDATE daily_streaks 
			SET current_streak = 1, last_active_at = $1, streak_started = $1 
			WHERE user_id = $2
		`, now, userID)
		s.db.Exec(`UPDATE users SET swipe_streak = 1 WHERE id = $1`, userID)
	}
}

func (s *Server) GetSwipeHistory(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)

	rows, err := s.db.Query(`
		SELECT id, swiped_id, swipe_type, direction, created_at
		FROM swipes
		WHERE swiper_id = $1
		ORDER BY created_at DESC
		LIMIT 100
	`, userID)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch swipe history"})
		return
	}
	defer rows.Close()

	swipes := []models.Swipe{}
	for rows.Next() {
		var swipe models.Swipe
		if err := rows.Scan(&swipe.ID, &swipe.SwipedID, &swipe.SwipeType, &swipe.Direction, &swipe.CreatedAt); err != nil {
			continue
		}
		swipe.SwiperID = userID
		swipes = append(swipes, swipe)
	}

	c.JSON(http.StatusOK, swipes)
}

