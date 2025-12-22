package main

import (
	"database/sql"
	"fmt"
	"log"
	"os"

	"github.com/blowjobs-ai/backend/internal/auth"
	_ "github.com/joho/godotenv/autoload"
	_ "github.com/lib/pq"
)

func main() {
	// Get database URL from environment or use default
	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		dbURL = "postgres://postgres:postgres@localhost:5432/blowjobs?sslmode=disable"
	}

	// Connect to database
	db, err := sql.Open("postgres", dbURL)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer db.Close()

	if err := db.Ping(); err != nil {
		log.Fatalf("Failed to ping database: %v", err)
	}

	fmt.Println("🚀 Connected to database, seeding dummy data...")
	fmt.Println("")

	password, _ := auth.HashPassword("demo123")

	// ============================================
	// CREATE JOB SEEKERS (10+ profiles)
	// ============================================
	fmt.Println("👤 Creating Job Seeker Profiles...")

	jobSeekers := []struct {
		email     string
		firstName string
		headline  string
		summary   string
		skills    string
		years     int
		salaryMin int
		salaryMax int
		locations string
		workPref  string
		expLevel  string
	}{
		{"jobseeker@demo.com", "Alex", "Senior Software Engineer", "Passionate full-stack developer with 5 years of experience building scalable web applications.", `{Go,Flutter,React,TypeScript,PostgreSQL,Docker}`, 5, 80000, 120000, `{San Francisco,Remote}`, "hybrid", "senior"},
		{"developer@demo.com", "Sam", "Frontend Developer", "Creative frontend developer specializing in React and Vue.js. I love building beautiful UIs.", `{React,Vue.js,TypeScript,CSS,Figma,Tailwind}`, 3, 70000, 100000, `{Los Angeles,Remote}`, "remote", "mid"},
		{"emma.tech@demo.com", "Emma", "Product Manager", "Ex-Google PM with a passion for user-centric products. MBA from Stanford.", `{Product Strategy,Agile,Data Analysis,Figma,SQL}`, 6, 120000, 180000, `{New York,San Francisco}`, "hybrid", "senior"},
		{"mike.dev@demo.com", "Mike", "Junior Backend Developer", "Recent CS graduate eager to learn and grow. Strong foundation in Python and Java.", `{Python,Java,SQL,Git,Linux,Docker}`, 1, 55000, 75000, `{Austin,Remote}`, "remote", "junior"},
		{"sarah.design@demo.com", "Sarah", "UX/UI Designer", "Design lead with 4 years of experience creating intuitive digital experiences.", `{Figma,Sketch,Adobe XD,User Research,Prototyping}`, 4, 85000, 115000, `{Seattle,Remote}`, "hybrid", "mid"},
		{"david.data@demo.com", "David", "Data Scientist", "ML engineer specializing in NLP and recommendation systems. PhD in Computer Science.", `{Python,TensorFlow,PyTorch,SQL,Spark,AWS}`, 5, 130000, 180000, `{Boston,Remote}`, "remote", "senior"},
		{"lisa.marketing@demo.com", "Lisa", "Growth Marketing Manager", "Drove 300% user growth at Series B startup. Expert in paid acquisition and SEO.", `{Google Ads,Facebook Ads,SEO,Analytics,A/B Testing}`, 4, 90000, 130000, `{New York,Los Angeles}`, "hybrid", "mid"},
		{"james.ops@demo.com", "James", "Operations Manager", "Streamlined operations for 3 startups. Six Sigma certified with MBA.", `{Process Optimization,Lean,Excel,SQL,Tableau}`, 7, 95000, 140000, `{Chicago,Remote}`, "onsite", "senior"},
		{"nina.sales@demo.com", "Nina", "Sales Development Rep", "Top performer with track record of exceeding quotas. SaaS sales expert.", `{Salesforce,HubSpot,Cold Calling,LinkedIn Sales,Negotiation}`, 2, 60000, 90000, `{Denver,Remote}`, "hybrid", "junior"},
		{"carlos.mobile@demo.com", "Carlos", "iOS Developer", "Built 5 apps with 1M+ downloads. Swift and SwiftUI enthusiast.", `{Swift,SwiftUI,Objective-C,Firebase,Core Data}`, 4, 100000, 145000, `{Miami,Remote}`, "remote", "mid"},
		{"amy.hr@demo.com", "Amy", "HR Coordinator", "People-first HR professional passionate about building great company cultures.", `{Recruiting,HRIS,Onboarding,Employee Relations,Benefits}`, 3, 55000, 75000, `{Phoenix,Remote}`, "hybrid", "mid"},
		{"tom.devops@demo.com", "Tom", "DevOps Engineer", "Infrastructure wizard. Reduced deploy times by 80% at previous company.", `{Kubernetes,Terraform,AWS,CI/CD,Docker,Linux}`, 5, 115000, 165000, `{Seattle,Remote}`, "remote", "senior"},
	}

	for _, js := range jobSeekers {
		var id string
		err = db.QueryRow(`
			INSERT INTO users (email, password_hash, first_name, user_type)
			VALUES ($1, $2, $3, $4)
			ON CONFLICT (email) DO UPDATE SET password_hash = $2
			RETURNING id
		`, js.email, password, js.firstName, "job_seeker").Scan(&id)

		if err != nil {
			log.Printf("Error creating %s: %v", js.email, err)
			continue
		}

		_, err = db.Exec(`
			INSERT INTO job_seeker_profiles (user_id, headline, summary, skills, years_of_experience, expected_salary_min, expected_salary_max, preferred_locations, work_preference, experience_level, is_profile_complete, profile_completeness)
			VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, true, 85)
			ON CONFLICT (user_id) DO UPDATE SET 
				headline = $2, summary = $3, skills = $4, years_of_experience = $5, 
				expected_salary_min = $6, expected_salary_max = $7,
				preferred_locations = $8, work_preference = $9, experience_level = $10,
				is_profile_complete = true, profile_completeness = 85
		`, id, js.headline, js.summary, js.skills, js.years, js.salaryMin, js.salaryMax, js.locations, js.workPref, js.expLevel)

		if err != nil {
			log.Printf("Error creating profile for %s: %v", js.email, err)
		} else {
			fmt.Printf("  ✓ %s - %s\n", js.firstName, js.headline)
		}

		db.Exec(`INSERT INTO daily_streaks (user_id) VALUES ($1) ON CONFLICT DO NOTHING`, id)
	}

	// ============================================
	// CREATE RECRUITERS (5 companies)
	// ============================================
	fmt.Println("")
	fmt.Println("🏢 Creating Recruiter Profiles...")

	recruiters := []struct {
		email       string
		firstName   string
		companyName string
		bio         string
		companySize string
		industry    string
		website     string
		position    string
	}{
		{"recruiter@demo.com", "Jordan", "TechCorp Innovation", "A leading technology company building the future of work.", "51-200", "Technology", "https://techcorp.example.com", "Senior Technical Recruiter"},
		{"hr@startupxyz.com", "Rachel", "StartupXYZ", "Fast-growing fintech startup revolutionizing payments.", "11-50", "Fintech", "https://startupxyz.example.com", "Head of Talent"},
		{"talent@bigtech.com", "Marcus", "BigTech Inc", "Fortune 500 tech giant with global presence.", "10000+", "Technology", "https://bigtech.example.com", "Technical Recruiter"},
		{"hiring@creativeco.com", "Sophia", "CreativeCo Agency", "Award-winning creative agency working with top brands.", "51-200", "Marketing/Advertising", "https://creativeco.example.com", "People Operations"},
		{"jobs@healthstart.com", "Daniel", "HealthStart", "Healthcare startup making wellness accessible to everyone.", "11-50", "Healthcare", "https://healthstart.example.com", "Recruiting Manager"},
	}

	recruiterIDs := make(map[string]string)

	for _, r := range recruiters {
		var id string
		err = db.QueryRow(`
			INSERT INTO users (email, password_hash, first_name, user_type)
			VALUES ($1, $2, $3, $4)
			ON CONFLICT (email) DO UPDATE SET password_hash = $2
			RETURNING id
		`, r.email, password, r.firstName, "recruiter").Scan(&id)

		if err != nil {
			log.Printf("Error creating recruiter %s: %v", r.email, err)
			continue
		}

		recruiterIDs[r.companyName] = id

		_, err = db.Exec(`
			INSERT INTO recruiter_profiles (user_id, company_name, bio, company_size, industry, company_website, position, is_verified)
			VALUES ($1, $2, $3, $4, $5, $6, $7, true)
			ON CONFLICT (user_id) DO UPDATE SET 
				company_name = $2, bio = $3, company_size = $4,
				industry = $5, company_website = $6, position = $7
		`, id, r.companyName, r.bio, r.companySize, r.industry, r.website, r.position)

		if err != nil {
			log.Printf("Error creating recruiter profile for %s: %v", r.email, err)
		} else {
			fmt.Printf("  ✓ %s @ %s\n", r.firstName, r.companyName)
		}

		db.Exec(`INSERT INTO daily_streaks (user_id) VALUES ($1) ON CONFLICT DO NOTHING`, id)
	}

	// ============================================
	// CREATE JOB LISTINGS (15+ jobs)
	// ============================================
	fmt.Println("")
	fmt.Println("💼 Creating Job Listings...")

	jobs := []struct {
		company     string
		title       string
		description string
		salaryMin   int
		salaryMax   int
		location    string
		workPref    string
		skills      string
		jobType     string
		expLevel    string
	}{
		// TechCorp Innovation jobs
		{"TechCorp Innovation", "Senior Backend Engineer", "Build scalable microservices using Go and Kubernetes.", 120000, 180000, "San Francisco, CA", "hybrid", `{Go,Kubernetes,PostgreSQL,Redis,gRPC}`, "full_time", "senior"},
		{"TechCorp Innovation", "Flutter Mobile Developer", "Create beautiful cross-platform mobile apps.", 100000, 150000, "Remote", "remote", `{Flutter,Dart,Firebase,REST,CI/CD}`, "full_time", "mid"},
		{"TechCorp Innovation", "Full Stack Engineer", "Work across the entire stack on exciting features.", 110000, 170000, "Austin, TX", "hybrid", `{React,TypeScript,Node.js,PostgreSQL,AWS}`, "full_time", "mid"},

		// StartupXYZ jobs
		{"StartupXYZ", "Product Manager", "Lead product strategy for our mobile banking app.", 130000, 170000, "New York, NY", "hybrid", `{Product Strategy,Agile,SQL,Figma}`, "full_time", "senior"},
		{"StartupXYZ", "Junior Frontend Developer", "Join our growing team and learn from the best.", 65000, 85000, "Remote", "remote", `{React,JavaScript,CSS,Git}`, "full_time", "junior"},
		{"StartupXYZ", "Data Analyst", "Turn data into actionable insights for the team.", 80000, 110000, "New York, NY", "hybrid", `{SQL,Python,Tableau,Excel}`, "full_time", "mid"},

		// BigTech Inc jobs
		{"BigTech Inc", "Staff Engineer", "Drive technical excellence across multiple teams.", 180000, 280000, "Seattle, WA", "hybrid", `{Java,Distributed Systems,AWS,Leadership}`, "full_time", "senior"},
		{"BigTech Inc", "Machine Learning Engineer", "Build ML models that power our recommendation engine.", 150000, 220000, "San Francisco, CA", "hybrid", `{Python,TensorFlow,PyTorch,MLOps}`, "full_time", "senior"},
		{"BigTech Inc", "Software Engineer Intern", "12-week summer internship program.", 8000, 10000, "Seattle, WA", "onsite", `{Python,Java,Algorithms}`, "internship", "entry"},

		// CreativeCo Agency jobs
		{"CreativeCo Agency", "Senior UX Designer", "Lead design for Fortune 500 client projects.", 95000, 135000, "Los Angeles, CA", "hybrid", `{Figma,User Research,Prototyping,Design Systems}`, "full_time", "senior"},
		{"CreativeCo Agency", "Content Marketing Manager", "Create compelling content that drives engagement.", 75000, 100000, "Remote", "remote", `{Content Strategy,SEO,Social Media,Analytics}`, "full_time", "mid"},
		{"CreativeCo Agency", "Graphic Designer", "Create stunning visuals for top brands.", 60000, 85000, "Los Angeles, CA", "hybrid", `{Adobe Creative Suite,Illustration,Branding}`, "full_time", "mid"},

		// HealthStart jobs
		{"HealthStart", "iOS Developer", "Build the app that makes healthcare accessible.", 110000, 150000, "Remote", "remote", `{Swift,SwiftUI,HealthKit,Firebase}`, "full_time", "mid"},
		{"HealthStart", "Customer Success Manager", "Help healthcare providers succeed with our platform.", 70000, 95000, "Boston, MA", "hybrid", `{Customer Success,SaaS,Healthcare,Communication}`, "full_time", "mid"},
		{"HealthStart", "Growth Marketing Lead", "Scale our user acquisition efforts 10x.", 100000, 140000, "Remote", "remote", `{Paid Ads,SEO,Analytics,Growth Strategy}`, "full_time", "senior"},
	}

	for _, job := range jobs {
		recruiterID := recruiterIDs[job.company]
		if recruiterID == "" {
			continue
		}

		_, err = db.Exec(`
			INSERT INTO jobs (recruiter_id, title, description, salary_min, salary_max, location, work_preference, skills, job_type, experience_level, status, company_name)
			VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, 'active', $11)
		`, recruiterID, job.title, job.description, job.salaryMin, job.salaryMax, job.location, job.workPref, job.skills, job.jobType, job.expLevel, job.company)

		if err != nil {
			log.Printf("Error creating job '%s': %v", job.title, err)
		} else {
			fmt.Printf("  ✓ %s @ %s\n", job.title, job.company)
		}
	}

	// ============================================
	// SUMMARY
	// ============================================
	fmt.Println("")
	fmt.Println("========================================")
	fmt.Println("✅ Seeding completed successfully!")
	fmt.Println("========================================")
	fmt.Println("")
	fmt.Println("📱 Demo Accounts (all passwords: demo123)")
	fmt.Println("")
	fmt.Println("JOB SEEKERS (swipe through jobs):")
	fmt.Println("  • jobseeker@demo.com (Alex)")
	fmt.Println("  • developer@demo.com (Sam)")
	fmt.Println("  • emma.tech@demo.com (Emma)")
	fmt.Println("  • mike.dev@demo.com (Mike)")
	fmt.Println("  • and 8 more...")
	fmt.Println("")
	fmt.Println("RECRUITERS (swipe through candidates):")
	fmt.Println("  • recruiter@demo.com (Jordan @ TechCorp)")
	fmt.Println("  • hr@startupxyz.com (Rachel @ StartupXYZ)")
	fmt.Println("  • talent@bigtech.com (Marcus @ BigTech)")
	fmt.Println("  • and 2 more...")
	fmt.Println("")
	fmt.Println("📊 Created:")
	fmt.Printf("  • %d Job Seekers\n", len(jobSeekers))
	fmt.Printf("  • %d Recruiters\n", len(recruiters))
	fmt.Printf("  • %d Job Listings\n", len(jobs))
	fmt.Println("")
}
