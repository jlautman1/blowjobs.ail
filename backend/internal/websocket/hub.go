package websocket

import (
	"encoding/json"
	"log"
	"sync"

	"github.com/google/uuid"
)

type Hub struct {
	// Registered clients by user ID
	clients    map[uuid.UUID]*Client
	clientsMux sync.RWMutex

	// Inbound messages from clients
	broadcast chan []byte

	// Register requests from clients
	register chan *Client

	// Unregister requests from clients
	unregister chan *Client
}

func NewHub() *Hub {
	return &Hub{
		clients:    make(map[uuid.UUID]*Client),
		broadcast:  make(chan []byte),
		register:   make(chan *Client),
		unregister: make(chan *Client),
	}
}

func (h *Hub) Run() {
	for {
		select {
		case client := <-h.register:
			h.clientsMux.Lock()
			h.clients[client.UserID] = client
			h.clientsMux.Unlock()
			log.Printf("Client registered: %s", client.UserID)

		case client := <-h.unregister:
			h.clientsMux.Lock()
			if _, ok := h.clients[client.UserID]; ok {
				delete(h.clients, client.UserID)
				close(client.Send)
			}
			h.clientsMux.Unlock()
			log.Printf("Client unregistered: %s", client.UserID)

		case message := <-h.broadcast:
			h.clientsMux.RLock()
			for _, client := range h.clients {
				select {
				case client.Send <- message:
				default:
					close(client.Send)
					delete(h.clients, client.UserID)
				}
			}
			h.clientsMux.RUnlock()
		}
	}
}

// SendToUser sends a message to a specific user
func (h *Hub) SendToUser(userID uuid.UUID, message interface{}) error {
	data, err := json.Marshal(message)
	if err != nil {
		return err
	}

	h.clientsMux.RLock()
	client, ok := h.clients[userID]
	h.clientsMux.RUnlock()

	if ok {
		select {
		case client.Send <- data:
		default:
			h.clientsMux.Lock()
			close(client.Send)
			delete(h.clients, userID)
			h.clientsMux.Unlock()
		}
	}

	return nil
}

// SendToUsers sends a message to multiple users
func (h *Hub) SendToUsers(userIDs []uuid.UUID, message interface{}) error {
	data, err := json.Marshal(message)
	if err != nil {
		return err
	}

	h.clientsMux.RLock()
	defer h.clientsMux.RUnlock()

	for _, userID := range userIDs {
		if client, ok := h.clients[userID]; ok {
			select {
			case client.Send <- data:
			default:
				// Client buffer is full, skip
			}
		}
	}

	return nil
}

// IsOnline checks if a user is currently connected
func (h *Hub) IsOnline(userID uuid.UUID) bool {
	h.clientsMux.RLock()
	defer h.clientsMux.RUnlock()
	_, ok := h.clients[userID]
	return ok
}

// Register adds a client to the hub
func (h *Hub) Register(client *Client) {
	h.register <- client
}

// Unregister removes a client from the hub
func (h *Hub) Unregister(client *Client) {
	h.unregister <- client
}

