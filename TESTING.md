# Testing Guide

## Manual Testing Checklist

### Authentication Flow

#### Login
- [x] **Valid credentials** - User can login successfully
- [x] **Invalid credentials** - Error message displayed, stays on login page
- [x] **Enter key on password field** - Triggers login (fixed)
- [x] **Enter key with invalid credentials** - Shows error, doesn't navigate (fixed)
- [x] **Navigation after login** - Redirects to home screen
- [x] **Token persistence** - User stays logged in on refresh

#### Registration
- [x] **New user registration** - Creates account successfully
- [x] **Duplicate email** - Shows appropriate error
- [x] **Form validation** - All fields validated before submission

### Job Seeker Flow

#### Job Discovery
- [x] **Job feed loads** - Shows available jobs
- [x] **Swipe right (like)** - Records swipe, shows next job
- [x] **Swipe left (pass)** - Records swipe, shows next job
- [x] **Swipe up (super like)** - Records super like
- [x] **Undo swipe** - Can undo last swipe
- [x] **Empty feed** - Shows appropriate message when no more jobs
- [x] **Job card details** - Can view full job details
- [x] **Stats display** - Shows views, likes, matches correctly

#### CV Upload
- [x] **File picker opens** - Can select PDF/DOC/DOCX files
- [x] **File upload** - Uploads successfully (fixed 404 error)
- [x] **AI analysis display** - Shows extracted skills and experience
- [x] **File size validation** - Rejects files over 5MB
- [x] **File type validation** - Only accepts PDF, DOC, DOCX

#### Profile
- [x] **Profile menu opens** - Bottom sheet appears correctly
- [x] **Menu scrollable** - Can scroll through all menu items (fixed overflow)
- [x] **CV upload link** - Navigates to CV upload screen
- [x] **Profile items accessible** - All buttons clickable (fixed layout)

### Recruiter Flow

#### Candidate Discovery
- [x] **Candidate feed loads** - Shows available candidates (fixed empty feed)
- [x] **Swipe through candidates** - Can like/pass on candidates
- [x] **Candidate details** - Can view full candidate profile
- [x] **Empty feed handling** - Shows message when no more candidates

#### Job Management
- [x] **Create job posting** - Form works correctly
- [x] **Job creation validation** - Required fields validated
- [x] **Skills/requirements/benefits** - Can add multiple items
- [x] **Job saved** - Appears in "My Jobs" list

#### Dashboard
- [x] **Dashboard loads** - Shows company info and stats (fixed Material error)
- [x] **Company profile display** - Shows company details
- [x] **Stats display** - Shows active jobs, hires, response rate
- [x] **Create job button** - Navigates to job creation
- [x] **My jobs list** - Shows all posted jobs
- [x] **Empty state** - Shows message when no jobs posted

### Matching & Chat

#### Matches
- [x] **Match notification** - Shows when mutual like occurs
- [x] **Match list** - Displays all matches
- [x] **Match details** - Can view match information

#### Chat
- [x] **Conversation list** - Shows all conversations
- [x] **Send message** - Messages sent successfully
- [x] **Receive message** - Messages received in real-time
- [x] **Message history** - Previous messages displayed

### Development Features

#### Reset Swipes
- [x] **Reset button visible** - Shows in dev mode only
- [x] **Reset functionality** - Clears all swipes (fixed 404 error)
- [x] **Feed reloads** - Shows all jobs/candidates again after reset

## Automated Testing

### Playwright Screenshots

Run the screenshot script to capture UI states:

```bash
npm run screenshots
```

This will:
1. Navigate to welcome screen
2. Click sign in
3. Login with demo credentials
4. Capture screenshots of:
   - Welcome screen
   - Login screen
   - Home screen
   - Swipe screen

### Test Accounts

**Job Seekers:**
- `jobseeker@demo.com` / `demo123` (Alex - Senior Software Engineer)
- `developer@demo.com` / `demo123` (Sam - Frontend Developer)
- `emma.tech@demo.com` / `demo123` (Emma - Product Manager)

**Recruiters:**
- `recruiter@demo.com` / `demo123` (Jordan @ TechCorp Innovation)
- `hr@startupxyz.com` / `demo123` (Rachel @ StartupXYZ)
- `talent@bigtech.com` / `demo123` (Marcus @ BigTech Inc)

## Test Scenarios

### Scenario 1: Job Seeker Complete Flow
1. Login as job seeker
2. View job feed
3. Swipe right on 3 jobs
4. Swipe left on 2 jobs
5. Get a match
6. Upload CV
7. View AI analysis
8. Chat with matched recruiter

### Scenario 2: Recruiter Complete Flow
1. Login as recruiter
2. View candidate feed
3. Swipe right on 3 candidates
4. Get a match
5. Create a new job posting
6. View dashboard
7. Chat with matched candidate

### Scenario 3: Error Handling
1. Login with wrong credentials
2. Try to upload invalid file type
3. Try to upload file over 5MB
4. Navigate to non-existent route
5. Test network error handling

### Scenario 4: Layout & Responsiveness
1. Test on different screen sizes
2. Verify no overflow issues
3. Check all buttons accessible
4. Test bottom sheet scrolling
5. Verify content fits window

## Performance Testing

- [ ] Page load time < 2 seconds
- [ ] Swipe animation smooth (60fps)
- [ ] API response time < 500ms
- [ ] Image loading optimized
- [ ] No memory leaks on long sessions

## Browser Compatibility

Tested on:
- [x] Chrome (latest)
- [ ] Firefox (latest)
- [ ] Safari (latest)
- [ ] Edge (latest)
- [ ] Mobile browsers (iOS Safari, Chrome Android)

## Known Test Limitations

1. **Flutter Web Canvas Rendering** - Playwright has limited interaction with Flutter's Canvas renderer
2. **WebSocket Testing** - Real-time features need manual testing
3. **File Upload** - Requires actual file selection (can't automate easily)

## Continuous Testing

Run these tests before each deployment:
1. Login flow
2. Job/candidate feed loading
3. Swipe functionality
4. Match creation
5. CV upload
6. Dashboard display
7. Layout overflow checks

