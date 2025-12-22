package config

import (
	"os"
	"time"
)

type Config struct {
	DatabaseURL     string
	JWTSecret       string
	JWTExpiration   time.Duration
	Environment     string
	AllowedOrigins  []string
}

func Load() *Config {
	return &Config{
		DatabaseURL:    getEnv("DATABASE_URL", "postgres://postgres:postgres@localhost:5432/blowjobs?sslmode=disable"),
		JWTSecret:      getEnv("JWT_SECRET", "your-super-secret-jwt-key-change-in-production"),
		JWTExpiration:  24 * time.Hour * 7, // 7 days
		Environment:    getEnv("ENVIRONMENT", "development"),
		AllowedOrigins: []string{"*"},
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

