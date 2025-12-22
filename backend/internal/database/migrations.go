package database

import (
	"database/sql"
	"fmt"
)

func RunMigrations(db *sql.DB) error {
	migrations := []string{
		// Users table
		`CREATE TABLE IF NOT EXISTS users (
			id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
			email VARCHAR(255) UNIQUE NOT NULL,
			password_hash VARCHAR(255) NOT NULL,
			first_name VARCHAR(100) NOT NULL,
			user_type VARCHAR(20) NOT NULL CHECK (user_type IN ('job_seeker', 'recruiter')),
			is_active BOOLEAN DEFAULT true,
			swipe_streak INTEGER DEFAULT 0,
			total_swipes INTEGER DEFAULT 0,
			total_matches INTEGER DEFAULT 0,
			badges TEXT[] DEFAULT '{}',
			last_swipe_date TIMESTAMP,
			last_login_at TIMESTAMP,
			created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
			updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
		)`,

		// Job seeker profiles
		`CREATE TABLE IF NOT EXISTS job_seeker_profiles (
			id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
			user_id UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,
			headline VARCHAR(255),
			summary TEXT,
			skills TEXT[] DEFAULT '{}',
			experience_level VARCHAR(20),
			years_of_experience INTEGER DEFAULT 0,
			education JSONB DEFAULT '[]',
			work_experience JSONB DEFAULT '[]',
			certifications TEXT[] DEFAULT '{}',
			languages TEXT[] DEFAULT '{}',
			preferred_locations TEXT[] DEFAULT '{}',
			work_preference VARCHAR(20) DEFAULT 'any',
			expected_salary_min INTEGER DEFAULT 0,
			expected_salary_max INTEGER DEFAULT 0,
			salary_currency VARCHAR(10) DEFAULT 'USD',
			available_from TIMESTAMP,
			open_to_relocation BOOLEAN DEFAULT false,
			desired_job_titles TEXT[] DEFAULT '{}',
			industries TEXT[] DEFAULT '{}',
			is_profile_complete BOOLEAN DEFAULT false,
			profile_completeness INTEGER DEFAULT 0,
			created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
			updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
		)`,

		// Recruiter profiles
		`CREATE TABLE IF NOT EXISTS recruiter_profiles (
			id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
			user_id UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,
			company_name VARCHAR(255) NOT NULL,
			company_website VARCHAR(255),
			company_size VARCHAR(50),
			industry VARCHAR(100),
			position VARCHAR(100),
			bio TEXT,
			is_verified BOOLEAN DEFAULT false,
			total_jobs_posted INTEGER DEFAULT 0,
			total_hires INTEGER DEFAULT 0,
			response_rate DECIMAL(5,2) DEFAULT 0,
			avg_response_time INTEGER DEFAULT 0,
			created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
			updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
		)`,

		// Jobs table
		`CREATE TABLE IF NOT EXISTS jobs (
			id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
			recruiter_id UUID REFERENCES users(id) ON DELETE CASCADE,
			title VARCHAR(255) NOT NULL,
			description TEXT NOT NULL,
			requirements TEXT[] DEFAULT '{}',
			responsibilities TEXT[] DEFAULT '{}',
			benefits TEXT[] DEFAULT '{}',
			skills TEXT[] DEFAULT '{}',
			experience_level VARCHAR(20),
			min_years_exp INTEGER DEFAULT 0,
			max_years_exp INTEGER DEFAULT 10,
			job_type VARCHAR(20) NOT NULL,
			work_preference VARCHAR(20) DEFAULT 'any',
			location VARCHAR(255),
			salary_min INTEGER DEFAULT 0,
			salary_max INTEGER DEFAULT 0,
			salary_currency VARCHAR(10) DEFAULT 'USD',
			show_salary BOOLEAN DEFAULT true,
			industry VARCHAR(100),
			company_name VARCHAR(255),
			company_size VARCHAR(50),
			status VARCHAR(20) DEFAULT 'active',
			application_count INTEGER DEFAULT 0,
			view_count INTEGER DEFAULT 0,
			match_count INTEGER DEFAULT 0,
			is_featured BOOLEAN DEFAULT false,
			expires_at TIMESTAMP,
			created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
			updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
		)`,

		// Swipes table
		`CREATE TABLE IF NOT EXISTS swipes (
			id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
			swiper_id UUID REFERENCES users(id) ON DELETE CASCADE,
			swiped_id UUID NOT NULL,
			swipe_type VARCHAR(20) NOT NULL CHECK (swipe_type IN ('job', 'profile')),
			direction VARCHAR(10) NOT NULL CHECK (direction IN ('left', 'right', 'up')),
			created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
			UNIQUE(swiper_id, swiped_id, swipe_type)
		)`,

		// Matches table
		`CREATE TABLE IF NOT EXISTS matches (
			id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
			job_id UUID REFERENCES jobs(id) ON DELETE CASCADE,
			job_seeker_id UUID REFERENCES users(id) ON DELETE CASCADE,
			recruiter_id UUID REFERENCES users(id) ON DELETE CASCADE,
			status VARCHAR(20) DEFAULT 'pending',
			application_status VARCHAR(20) DEFAULT 'active',
			interview_status VARCHAR(20) DEFAULT 'none',
			job_seeker_swiped_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
			recruiter_swiped_at TIMESTAMP,
			matched_at TIMESTAMP,
			last_message_at TIMESTAMP,
			unread_count INTEGER DEFAULT 0,
			created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
			updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
			UNIQUE(job_id, job_seeker_id)
		)`,

		// Messages table
		`CREATE TABLE IF NOT EXISTS messages (
			id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
			match_id UUID REFERENCES matches(id) ON DELETE CASCADE,
			sender_id UUID REFERENCES users(id) ON DELETE CASCADE,
			type VARCHAR(20) DEFAULT 'text',
			content TEXT NOT NULL,
			is_read BOOLEAN DEFAULT false,
			read_at TIMESTAMP,
			created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
		)`,

		// Interviews table
		`CREATE TABLE IF NOT EXISTS interviews (
			id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
			match_id UUID REFERENCES matches(id) ON DELETE CASCADE,
			scheduled_at TIMESTAMP NOT NULL,
			duration INTEGER DEFAULT 60,
			type VARCHAR(20) NOT NULL,
			location TEXT,
			instructions TEXT,
			status VARCHAR(20) DEFAULT 'scheduled',
			reminder_sent BOOLEAN DEFAULT false,
			feedback TEXT,
			result VARCHAR(20),
			created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
			updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
		)`,

		// User badges table
		`CREATE TABLE IF NOT EXISTS user_badges (
			id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
			user_id UUID REFERENCES users(id) ON DELETE CASCADE,
			badge_type VARCHAR(50) NOT NULL,
			unlocked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
			UNIQUE(user_id, badge_type)
		)`,

		// Daily streaks table
		`CREATE TABLE IF NOT EXISTS daily_streaks (
			user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
			current_streak INTEGER DEFAULT 0,
			longest_streak INTEGER DEFAULT 0,
			last_active_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
			streak_started TIMESTAMP DEFAULT CURRENT_TIMESTAMP
		)`,

		// Indexes for better performance
		`CREATE INDEX IF NOT EXISTS idx_jobs_recruiter ON jobs(recruiter_id)`,
		`CREATE INDEX IF NOT EXISTS idx_jobs_status ON jobs(status)`,
		`CREATE INDEX IF NOT EXISTS idx_swipes_swiper ON swipes(swiper_id)`,
		`CREATE INDEX IF NOT EXISTS idx_matches_job_seeker ON matches(job_seeker_id)`,
		`CREATE INDEX IF NOT EXISTS idx_matches_recruiter ON matches(recruiter_id)`,
		`CREATE INDEX IF NOT EXISTS idx_messages_match ON messages(match_id)`,
		`CREATE INDEX IF NOT EXISTS idx_interviews_match ON interviews(match_id)`,
	}

	for i, migration := range migrations {
		if _, err := db.Exec(migration); err != nil {
			return fmt.Errorf("migration %d failed: %w", i+1, err)
		}
	}

	return nil
}

