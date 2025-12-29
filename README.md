# BlowJobs.ai - Job Matching Platform

A modern, Tinder-style job matching application that connects job seekers with recruiters through an intuitive swipe-based interface.

## 🎯 Product Vision

Build a mobile-first job matching app using Tinder-style swipe interactions to discover jobs quickly and intuitively.

The experience should feel:
- **Energetic** - Full of life and enthusiasm
- **Optimistic** - Positive outlook on job searching
- **Friendly** - Approachable and welcoming
- **Modern** - Cutting-edge design and technology

This is not a "corporate job board" — it should feel like finding your next job shouldn't feel stressful.

## 👥 Target Audience

- Students & graduates
- Junior–mid professionals
- Sales, tech, marketing, operations roles
- Startup-oriented, mobile-native users

## 🎨 Design Philosophy

### Visual Style Keywords
- **Bright** - Vibrant, energetic colors
- **Clean** - Minimal, uncluttered interface
- **Airy** - Generous spacing and breathing room
- **Friendly** - Warm, approachable design
- **Rounded** - Soft, friendly shapes
- **Card-driven** - Content organized in cards

### Avoid
- Dark mode
- Heavy corporate blue
- Over-designed gradients
- Dense UI

### Color System

**Base Colors:**
- Background (Primary): `#FFFFFF`
- Secondary Background: `#F8FAFC`
- Card Background: `#FFFFFF`
- Primary Text: `#0F172A`
- Secondary Text: `#475569`

**Action Colors:**
- Swipe Right / Like / Match (Green): `#22C55E`
- Swipe Left / Skip (Soft Red): `#F87171`
- Super Like / Priority (Purple): `#8B5CF6`
- Primary CTA (Blue / Teal): `#0EA5E9` or `#06B6D4`

**Rules:**
- Max 3 accent colors per screen
- One dominant accent per screen
- Use color to guide behavior, not decorate

## ✅ Recent Fixes & Improvements

### Critical Bug Fixes (December 2024)
1. **Login Enter Key Issue** - Fixed navigation on failed login when pressing Enter
2. **Candidate Feed Empty** - Fixed query to show candidates for recruiters
3. **CV Upload 404** - Fixed multipart form-data Content-Type header
4. **Reset Swipes 404** - Fixed environment configuration for dev endpoint
5. **Dashboard Material Error** - Added proper Scaffold wrapper
6. **Bottom Overflow** - Replaced with DraggableScrollableSheet
7. **Page Layout Overflow** - Added SafeArea and proper constraints

### Design Improvements
- **Minimalist Approach** - Removed excessive gradients, simplified color palette
- **Premium Job Cards** - Better typography, spacing, and borders
- **Clean Navigation** - Flat design with subtle borders instead of shadows
- **Improved Stats** - Better visual hierarchy and cleaner dividers
- **Responsive Layout** - Content properly fits window, no overflow issues

### New Features Added
- **CV Upload with AI Analysis** - Job seekers can upload CVs for automatic analysis
- **Job Creation** - Recruiters can create detailed job postings
- **Recruiter Dashboard** - Company profile, stats, and job management
- **Enhanced Profile Menu** - Scrollable, draggable bottom sheet

## 🚀 Core Features

### 1. Swipe-Based Job Discovery
- **Swipe Right** → Interested / Like
- **Swipe Left** → Not relevant
- **Swipe Up (⭐)** → High interest / Priority
- All interactions feel immediate, fun, and obvious
- Undo functionality available

### 2. Dual User Types

#### Job Seekers
- Swipe through job listings
- Upload CV with AI analysis
- Receive AI-powered job recommendations
- Match with recruiters
- Chat with matched companies
- Schedule interviews through the app

#### Recruiters
- Swipe through anonymous candidate profiles
- Create and manage job postings
- View company dashboard with analytics
- Match with job seekers
- Chat with candidates
- Schedule interviews

### 3. CV Upload & AI Analysis
- Upload CV (PDF, DOC, DOCX)
- AI automatically extracts:
  - Skills
  - Experience level
  - Years of experience
  - Education
  - Other relevant information
- Data used to improve job matching

### 4. Job Creation & Management
- Recruiters can create detailed job postings
- Include:
  - Job title and description
  - Company details
  - Salary range
  - Required skills
  - Benefits
  - Work preferences (remote/hybrid/onsite)
- Manage multiple job postings from dashboard

### 5. Recruiter Dashboard
- View company profile
- See active jobs count
- Track total hires
- Monitor response rate
- Quick actions (create job, edit company)

### 6. Matching & Chat
- Mutual matches enable chat
- Real-time messaging
- Interview scheduling
- Automated reminders

## 🏗️ Technical Architecture

### Frontend
- **Framework**: Flutter (Web-first, mobile-ready)
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **HTTP Client**: Dio
- **UI Components**: Material Design 3
- **Icons**: Iconsax
- **Animations**: Flutter Animate

### Backend
- **Language**: Go
- **Framework**: Gin
- **Database**: PostgreSQL
- **Authentication**: JWT
- **WebSocket**: Real-time chat support
- **File Storage**: Local filesystem (CV uploads)

### Database Schema
- Users (job_seekers, recruiters)
- Job listings
- Swipes
- Matches
- Messages
- Interviews
- Profiles (with CV data)

## 📋 Setup Instructions

### Prerequisites
- Go 1.21+
- Flutter 3.0+
- PostgreSQL 14+
- Docker (optional, for database)

### Backend Setup

1. **Clone the repository**
```bash
cd backend
```

2. **Install dependencies**
```bash
go mod download
```

3. **Set up environment variables**
Create a `.env` file:
```env
DATABASE_URL=postgres://postgres:postgres@localhost:5432/blowjobs?sslmode=disable
JWT_SECRET=your-super-secret-jwt-key-change-in-production
ENVIRONMENT=development
PORT=8080
```

4. **Start PostgreSQL** (using Docker)
```bash
docker-compose up -d postgres
```

5. **Run migrations**
The migrations run automatically on server start.

6. **Seed the database** (optional)
```bash
go run ./cmd/seed
```

7. **Start the server**
```bash
go run ./cmd/server
```

The API will be available at `http://localhost:8080/api/v1`

### Frontend Setup

1. **Navigate to frontend**
```bash
cd frontend
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
flutter run -d chrome --web-port=8081
```

The app will be available at `http://localhost:8081`

## 🧪 Testing

### Manual Testing with Playwright

We use Playwright for end-to-end testing and screenshot capture.

**Take screenshots:**
```bash
npm run screenshots
```

This will:
1. Navigate to the app
2. Login with demo credentials
3. Capture screenshots of:
   - Welcome screen
   - Login screen
   - Home screen
   - Swipe screen

**Demo Accounts:**
- Job Seeker: `jobseeker@demo.com` / `demo123`
- Recruiter: `recruiter@demo.com` / `demo123`

### Test Scenarios

1. **Job Seeker Flow**
   - Login → View jobs → Swipe → Match → Chat
   - Upload CV → View AI analysis
   - Complete profile

2. **Recruiter Flow**
   - Login → View candidates → Swipe → Match → Chat
   - Create job posting
   - View dashboard
   - Edit company details

3. **Error Handling**
   - Invalid login credentials
   - Network errors
   - Empty feeds
   - File upload errors

## 🎯 Design Improvements Implemented

### Recent Updates
1. **Minimalist Design**
   - Removed excessive gradients (flat design)
   - Simplified color palette (consistent, refined colors)
   - Cleaner shadows (replaced with subtle borders)
   - Flat design approach throughout

2. **Premium Job Cards**
   - Better typography (larger, bolder titles with letter spacing)
   - Improved spacing (more breathing room)
   - Subtle borders instead of heavy shadows
   - Cleaner chip design with proper borders
   - Refined company logo containers

3. **Simplified Navigation**
   - Removed gradient logos (flat colored backgrounds)
   - Cleaner app bar with subtle borders instead of shadows
   - Simplified profile buttons (no heavy borders)
   - Bottom navigation with clean borders

4. **Better Stats Display**
   - Subtle background for stats row
   - Cleaner dividers with reduced opacity
   - Better visual hierarchy

5. **Improved Layout & UX**
   - Fixed all overflow issues
   - Proper SafeArea implementation
   - Draggable bottom sheets for better mobile experience
   - Content properly constrained to window size
   - All buttons accessible and clickable

## 📝 API Endpoints

### Authentication
- `POST /api/v1/auth/register` - Register new user
- `POST /api/v1/auth/login` - Login
- `POST /api/v1/auth/refresh` - Refresh token

### Profiles
- `GET /api/v1/profiles/job-seeker` - Get job seeker profile
- `PUT /api/v1/profiles/job-seeker` - Update job seeker profile
- `POST /api/v1/profiles/job-seeker/cv` - Upload CV
- `GET /api/v1/profiles/recruiter` - Get recruiter profile
- `PUT /api/v1/profiles/recruiter` - Update recruiter profile

### Jobs
- `GET /api/v1/jobs/feed` - Get job feed (job seekers)
- `POST /api/v1/jobs` - Create job (recruiters)
- `GET /api/v1/jobs/my-jobs` - Get my jobs (recruiters)

### Candidates
- `GET /api/v1/candidates/feed` - Get candidate feed (recruiters)

### Swipes
- `POST /api/v1/swipes` - Record swipe
- `GET /api/v1/swipes/history` - Get swipe history
- `DELETE /api/v1/swipes/reset` - Reset swipes (dev only)

### Matches
- `GET /api/v1/matches` - Get matches
- `GET /api/v1/matches/:id` - Get match details

### Chat
- `GET /api/v1/chat/conversations` - Get conversations
- `GET /api/v1/chat/:match_id/messages` - Get messages
- `POST /api/v1/chat/:match_id/messages` - Send message

## 🐛 Known Issues & Fixes

### Fixed Issues
1. ✅ **Login with Enter key** - Now properly validates before navigation, checks auth state before redirecting
2. ✅ **Candidate feed empty** - Fixed query to show candidates even without complete profiles, removed strict `is_profile_complete` requirement
3. ✅ **CV upload 404** - Fixed Content-Type header issue (Dio now sets multipart/form-data automatically)
4. ✅ **Reset swipes 404** - Environment defaults to "development" in config, endpoint works correctly
5. ✅ **Dashboard Material widget error** - Added Scaffold wrapper with proper AppBar
6. ✅ **Bottom overflow in profile menu** - Replaced with DraggableScrollableSheet for proper scrolling
7. ✅ **Page layout overflow** - Added SafeArea and ClipRect to ensure content fits window
8. ✅ **Profile menu not scrollable** - Implemented proper scrollable bottom sheet with drag support

### Future Improvements
- [ ] Real AI integration for CV analysis (currently placeholder)
- [ ] File upload to cloud storage (S3/Cloudinary)
- [ ] Interview scheduling UI
- [ ] Push notifications
- [ ] Mobile app builds (iOS/Android)
- [ ] Integration with Glassdoor/LinkedIn job feeds
- [ ] Advanced matching algorithm
- [ ] Analytics dashboard for recruiters

## 🧪 Testing

See [TESTING.md](./TESTING.md) for comprehensive testing guide including:
- Manual testing checklist
- Automated testing with Playwright
- Test scenarios
- Performance testing
- Browser compatibility

## 📚 Design Guidelines

### Typography
- **Font**: Inter (via Google Fonts)
- **Titles**: Semi-Bold
- **Body**: Regular
- **Buttons**: Medium
- **Rules**: Max 2 font sizes per screen, clear hierarchy, generous line spacing

### UX Principles
- Minimal text
- Clear visual cues
- Friendly microcopy
- Immediate feedback on every action
- Explain relevance ("Shown because you selected Remote + Marketing")

### Tone & Copy
- Human
- Short
- Encouraging
- Clear

**Examples:**
- "Looks good"
- "Skip"
- "High priority"
- "Matched"
- "This job fits your preferences"

## 🚀 Deployment

### Backend (Railway)
The backend is deployed on Railway at:
`https://blowjobs-backend-production.up.railway.app`

### Frontend
Currently runs locally. For production:
1. Build Flutter web app: `flutter build web`
2. Deploy to hosting service (Vercel, Netlify, etc.)

## 📄 License

[Your License Here]

## 👥 Contributors

[Your Team Here]

## 📖 Additional Documentation

- **[QUICK_START.md](./QUICK_START.md)** - Get started in 5 minutes
- **[TESTING.md](./TESTING.md)** - Comprehensive testing guide
- **API Documentation** - See API endpoints section above

## 📞 Support

For issues or questions, please open an issue on GitHub.

## 🎉 Acknowledgments

Built with modern web technologies to make job searching fun and efficient.

---

**Built with ❤️ for making job searching fun and efficient**
