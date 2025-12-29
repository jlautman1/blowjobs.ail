package database

import (
	"database/sql"
	"fmt"
)

// RunMigrationsV2 adds CV upload support and other enhancements
func RunMigrationsV2(db *sql.DB) error {
	migrations := []string{
		// Add CV fields to job_seeker_profiles
		`ALTER TABLE job_seeker_profiles 
		 ADD COLUMN IF NOT EXISTS cv_url TEXT,
		 ADD COLUMN IF NOT EXISTS cv_uploaded_at TIMESTAMP,
		 ADD COLUMN IF NOT EXISTS cv_analysis JSONB DEFAULT '{}'`,

		// Add company details fields to recruiter_profiles
		`ALTER TABLE recruiter_profiles 
		 ADD COLUMN IF NOT EXISTS company_logo_url TEXT,
		 ADD COLUMN IF NOT EXISTS company_description TEXT,
		 ADD COLUMN IF NOT EXISTS company_culture TEXT[] DEFAULT '{}',
		 ADD COLUMN IF NOT EXISTS company_benefits TEXT[] DEFAULT '{}'`,
	}

	for i, migration := range migrations {
		if _, err := db.Exec(migration); err != nil {
			return fmt.Errorf("migration v2 %d failed: %w", i+1, err)
		}
	}

	return nil
}

