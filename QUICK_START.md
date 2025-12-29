# Quick Start Guide

## 🚀 Get Started in 5 Minutes

### 1. Prerequisites Check
```bash
# Check Go version (need 1.21+)
go version

# Check Flutter version (need 3.0+)
flutter --version

# Check Docker (for database)
docker --version
```

### 2. Start Database
```bash
# Start PostgreSQL with Docker
docker-compose up -d postgres

# Or use existing PostgreSQL instance
```

### 3. Start Backend
```bash
cd backend

# Create .env file (optional, uses defaults if not present)
# DATABASE_URL=postgres://postgres:postgres@localhost:5432/blowjobs?sslmode=disable
# JWT_SECRET=your-secret-key
# ENVIRONMENT=development

# Seed database (first time only)
go run ./cmd/seed

# Start server
go run ./cmd/server
```

Backend runs on: `http://localhost:8080`

### 4. Start Frontend
```bash
cd frontend

# Install dependencies
flutter pub get

# Run app
flutter run -d chrome --web-port=8081
```

Frontend runs on: `http://localhost:8081`

### 5. Login & Test

**Job Seeker Account:**
- Email: `jobseeker@demo.com`
- Password: `demo123`

**Recruiter Account:**
- Email: `recruiter@demo.com`
- Password: `demo123`

## 🎯 Quick Test Scenarios

### Test Job Seeker Flow
1. Login as `jobseeker@demo.com`
2. Click "Discover" tab
3. Swipe right on jobs you like
4. Upload CV from profile menu
5. View matches in "Hired!" tab

### Test Recruiter Flow
1. Login as `recruiter@demo.com`
2. View candidates in swipe screen
3. Create job from dashboard
4. View company stats

## 🐛 Troubleshooting

### Backend won't start
- Check PostgreSQL is running: `docker ps`
- Check DATABASE_URL in .env
- Check port 8080 is available

### Frontend won't compile
- Run `flutter clean && flutter pub get`
- Check Flutter version: `flutter --version`
- Check for linter errors: `flutter analyze`

### No jobs/candidates showing
- Run seed script: `go run ./cmd/seed`
- Check database connection
- Check user type (job_seeker vs recruiter)

### CV upload fails
- Check file size (< 5MB)
- Check file type (PDF, DOC, DOCX only)
- Check backend is running
- Check network tab for errors

## 📝 Environment Variables

### Backend (.env)
```env
DATABASE_URL=postgres://postgres:postgres@localhost:5432/blowjobs?sslmode=disable
JWT_SECRET=your-super-secret-jwt-key-change-in-production
ENVIRONMENT=development
PORT=8080
```

### Frontend
Uses environment provider (defaults to production API)
- Development: `http://localhost:8080/api/v1`
- Production: `https://blowjobs-backend-production.up.railway.app/api/v1`

## 🔧 Development Tips

### Hot Reload
- Frontend: Press `r` in terminal or save file (auto-reload)
- Backend: Restart server after code changes

### Database Reset
```bash
# Drop and recreate database
docker-compose down -v
docker-compose up -d postgres

# Run migrations and seed
go run ./cmd/seed
```

### View Logs
- Backend: Check terminal output
- Frontend: Check browser console (F12)
- Database: `docker logs <container-id>`

## 📚 Next Steps

1. Read [README.md](./README.md) for full documentation
2. Check [TESTING.md](./TESTING.md) for testing guide
3. Explore the codebase structure
4. Customize design and features

## 🆘 Need Help?

- Check [TESTING.md](./TESTING.md) for common issues
- Review error messages in console
- Check API endpoints in backend logs
- Verify database connection

