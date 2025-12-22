package models

import (
	"time"

	"github.com/google/uuid"
)

type MessageType string

const (
	MessageTypeText       MessageType = "text"
	MessageTypeSystem     MessageType = "system"     // System notifications
	MessageTypeInterview  MessageType = "interview"  // Interview scheduled/updated
	MessageTypeStatus     MessageType = "status"     // Application status update
)

// Message represents a chat message between matched users
type Message struct {
	ID        uuid.UUID   `json:"id"`
	MatchID   uuid.UUID   `json:"match_id"`
	SenderID  uuid.UUID   `json:"sender_id"`
	Type      MessageType `json:"type"`
	Content   string      `json:"content"`
	IsRead    bool        `json:"is_read"`
	ReadAt    *time.Time  `json:"read_at,omitempty"`
	CreatedAt time.Time   `json:"created_at"`
}

// MessageWithSender includes sender info
type MessageWithSender struct {
	Message
	SenderName string `json:"sender_name"`
	IsMine     bool   `json:"is_mine"` // True if current user sent it
}

// SendMessageRequest for sending a new message
type SendMessageRequest struct {
	MatchID uuid.UUID `json:"match_id" binding:"required"`
	Content string    `json:"content" binding:"required"`
}

// Conversation represents a chat thread
type Conversation struct {
	MatchID       uuid.UUID          `json:"match_id"`
	OtherUserName string             `json:"other_user_name"`
	JobTitle      string             `json:"job_title"`
	CompanyName   string             `json:"company_name"`
	LastMessage   *Message           `json:"last_message,omitempty"`
	UnreadCount   int                `json:"unread_count"`
	Status        ApplicationStatus  `json:"status"`
	UpdatedAt     time.Time          `json:"updated_at"`
}

// WebSocket message types
type WSMessage struct {
	Type    string      `json:"type"`
	Payload interface{} `json:"payload"`
}

type WSChatMessage struct {
	MatchID   string `json:"match_id"`
	Content   string `json:"content"`
}

type WSTypingIndicator struct {
	MatchID  string `json:"match_id"`
	IsTyping bool   `json:"is_typing"`
}

type WSNotification struct {
	Type    string `json:"type"` // match, message, interview, status
	Title   string `json:"title"`
	Body    string `json:"body"`
	Data    interface{} `json:"data,omitempty"`
}

