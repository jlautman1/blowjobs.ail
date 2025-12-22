package api

import (
	"net/http"
	"strconv"
	"time"

	"github.com/blowjobs-ai/backend/internal/models"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

func (s *Server) GetConversations(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)
	userType := c.MustGet("user_type").(string)

	// Fix: Count unread messages from the OTHER user only (not your own messages)
	var query string
	if userType == "job_seeker" {
		query = `
			SELECT m.id, u.first_name, j.title, j.company_name,
			       COALESCE(unread.cnt, 0) as unread_count, m.application_status, m.updated_at,
			       msg.content as last_message
			FROM matches m
			JOIN jobs j ON j.id = m.job_id
			JOIN users u ON u.id = m.recruiter_id
			LEFT JOIN LATERAL (
				SELECT content FROM messages 
				WHERE match_id = m.id 
				ORDER BY created_at DESC LIMIT 1
			) msg ON true
			LEFT JOIN LATERAL (
				SELECT COUNT(*) as cnt FROM messages 
				WHERE match_id = m.id AND sender_id != $1 AND is_read = false
			) unread ON true
			WHERE m.job_seeker_id = $1 AND m.status = 'matched'
			ORDER BY COALESCE(m.last_message_at, m.matched_at) DESC
		`
	} else {
		query = `
			SELECT m.id, u.first_name, j.title, j.company_name,
			       COALESCE(unread.cnt, 0) as unread_count, m.application_status, m.updated_at,
			       msg.content as last_message
			FROM matches m
			JOIN jobs j ON j.id = m.job_id
			JOIN users u ON u.id = m.job_seeker_id
			LEFT JOIN LATERAL (
				SELECT content FROM messages 
				WHERE match_id = m.id 
				ORDER BY created_at DESC LIMIT 1
			) msg ON true
			LEFT JOIN LATERAL (
				SELECT COUNT(*) as cnt FROM messages 
				WHERE match_id = m.id AND sender_id != $1 AND is_read = false
			) unread ON true
			WHERE m.recruiter_id = $1 AND m.status = 'matched'
			ORDER BY COALESCE(m.last_message_at, m.matched_at) DESC
		`
	}

	rows, err := s.db.Query(query, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch conversations"})
		return
	}
	defer rows.Close()

	conversations := []models.Conversation{}
	for rows.Next() {
		var conv models.Conversation
		var lastMessage *string

		if err := rows.Scan(
			&conv.MatchID, &conv.OtherUserName, &conv.JobTitle, &conv.CompanyName,
			&conv.UnreadCount, &conv.Status, &conv.UpdatedAt, &lastMessage,
		); err != nil {
			continue
		}

		if lastMessage != nil {
			conv.LastMessage = &models.Message{Content: *lastMessage}
		}

		conversations = append(conversations, conv)
	}

	c.JSON(http.StatusOK, conversations)
}

func (s *Server) GetMessages(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)
	matchID, err := uuid.Parse(c.Param("match_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid match ID"})
		return
	}

	// Verify user is part of this match
	var exists bool
	s.db.QueryRow(`
		SELECT EXISTS(
			SELECT 1 FROM matches 
			WHERE id = $1 AND (job_seeker_id = $2 OR recruiter_id = $2)
		)
	`, matchID, userID).Scan(&exists)

	if !exists {
		c.JSON(http.StatusForbidden, gin.H{"error": "Access denied"})
		return
	}

	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "50"))
	offset, _ := strconv.Atoi(c.DefaultQuery("offset", "0"))

	rows, err := s.db.Query(`
		SELECT m.id, m.match_id, m.sender_id, m.type, m.content, 
		       m.is_read, m.read_at, m.created_at, u.first_name
		FROM messages m
		JOIN users u ON u.id = m.sender_id
		WHERE m.match_id = $1
		ORDER BY m.created_at DESC
		LIMIT $2 OFFSET $3
	`, matchID, limit, offset)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch messages"})
		return
	}
	defer rows.Close()

	messages := []models.MessageWithSender{}
	for rows.Next() {
		var msg models.MessageWithSender
		if err := rows.Scan(
			&msg.ID, &msg.MatchID, &msg.SenderID, &msg.Type, &msg.Content,
			&msg.IsRead, &msg.ReadAt, &msg.CreatedAt, &msg.SenderName,
		); err != nil {
			continue
		}
		msg.IsMine = msg.SenderID == userID
		messages = append(messages, msg)
	}

	// Reverse to show oldest first
	for i, j := 0, len(messages)-1; i < j; i, j = i+1, j-1 {
		messages[i], messages[j] = messages[j], messages[i]
	}

	c.JSON(http.StatusOK, messages)
}

func (s *Server) SendMessage(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)
	matchID, err := uuid.Parse(c.Param("match_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid match ID"})
		return
	}

	var req struct {
		Content string `json:"content" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Verify user is part of this match and get other user
	var jobSeekerID, recruiterID uuid.UUID
	err = s.db.QueryRow(`
		SELECT job_seeker_id, recruiter_id FROM matches 
		WHERE id = $1 AND status = 'matched' AND (job_seeker_id = $2 OR recruiter_id = $2)
	`, matchID, userID).Scan(&jobSeekerID, &recruiterID)

	if err != nil {
		c.JSON(http.StatusForbidden, gin.H{"error": "Match not found or access denied"})
		return
	}

	// Insert message
	var msg models.Message
	err = s.db.QueryRow(`
		INSERT INTO messages (match_id, sender_id, type, content)
		VALUES ($1, $2, 'text', $3)
		RETURNING id, match_id, sender_id, type, content, is_read, created_at
	`, matchID, userID, req.Content).Scan(
		&msg.ID, &msg.MatchID, &msg.SenderID, &msg.Type, &msg.Content, &msg.IsRead, &msg.CreatedAt,
	)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to send message"})
		return
	}

	// Update match's last message time and increment unread count for recipient
	s.db.Exec(`
		UPDATE matches SET last_message_at = $1, unread_count = unread_count + 1, updated_at = $1
		WHERE id = $2
	`, time.Now(), matchID)

	// Determine recipient
	recipientID := jobSeekerID
	if userID == jobSeekerID {
		recipientID = recruiterID
	}

	// Get sender name
	var senderName string
	s.db.QueryRow(`SELECT first_name FROM users WHERE id = $1`, userID).Scan(&senderName)

	// Send real-time notification
	s.hub.SendToUser(recipientID, map[string]interface{}{
		"type": "message",
		"payload": map[string]interface{}{
			"match_id":    matchID.String(),
			"message_id":  msg.ID.String(),
			"sender_name": senderName,
			"content":     req.Content,
			"created_at":  msg.CreatedAt,
		},
	})

	c.JSON(http.StatusCreated, msg)
}

func (s *Server) MarkMessagesRead(c *gin.Context) {
	userID := c.MustGet("user_id").(uuid.UUID)
	matchID, err := uuid.Parse(c.Param("match_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid match ID"})
		return
	}

	now := time.Now()

	// Mark all messages as read (except own messages)
	_, err = s.db.Exec(`
		UPDATE messages SET is_read = true, read_at = $1
		WHERE match_id = $2 AND sender_id != $3 AND is_read = false
	`, now, matchID, userID)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to mark messages read"})
		return
	}

	// Reset unread count
	s.db.Exec(`UPDATE matches SET unread_count = 0 WHERE id = $1`, matchID)

	c.JSON(http.StatusOK, gin.H{"message": "Messages marked as read"})
}
