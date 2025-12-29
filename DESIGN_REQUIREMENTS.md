# Complete Design Requirements & Feedback

## 🎯 Product Vision

Build a mobile-first job matching app using Tinder-style swipe interactions to discover jobs quickly and intuitively.

The experience should feel:
- **Energetic** - Full of life and enthusiasm
- **Optimistic** - Positive outlook on job searching
- **Friendly** - Approachable and welcoming
- **Modern** - Cutting-edge design and technology

**This is not a "corporate job board"** — it should feel like finding your next job shouldn't feel stressful.

## 👥 Target Audience

- Students & graduates
- Junior–mid professionals
- Sales, tech, marketing, operations roles
- Startup-oriented, mobile-native users

## 🎨 Visual Style & Personality

### Style Keywords
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

## 🎨 Color System (Bright & Vibrant)

### Base Colors
- Background (Primary): `#FFFFFF`
- Secondary Background: `#F8FAFC`
- Card Background: `#FFFFFF`
- Primary Text: `#0F172A`
- Secondary Text: `#475569`

### Action Colors
- Swipe Right / Like / Match (Green): `#22C55E`
- Swipe Left / Skip (Soft Red): `#F87171`
- Super Like / Priority (Purple): `#8B5CF6`
- Primary CTA (Blue / Teal): `#0EA5E9` or `#06B6D4`

### Rules
- Max 3 accent colors
- One dominant accent per screen
- Use color to guide behavior, not decorate

## 📝 Typography

### Recommended Fonts
- Inter
- SF Pro
- Roboto

### Usage
- Titles: Semi-Bold
- Body: Regular
- Buttons: Medium

### Design Rules
- No more than 2 font sizes per screen
- Clear hierarchy
- Generous line spacing

## 💳 Job Card Design (The Heart of the App)

### Card Should Feel
- **Large** - Takes up significant screen space
- **Clean** - Uncluttered, focused
- **Breathing** - Generous spacing

### Card Content (Hebrew Instructions Translated)

**What's on the card:**
- 🔹 **Job Title** (Large, prominent)
- 🔹 **Company Name** (Smaller)
- 🔹 **Salary / Location** (Icons)
- 🔹 **Tags:**
  - Remote
  - Full-Time
  - Junior / Senior
- 🔹 **Logo / Image**

### Card Visual Requirements
- Large, rounded corners (24px+)
- Generous padding (32px+)
- Vibrant colors
- Premium shadows
- Gradient accents
- Color accent bar at top
- Logo with gradient background

## 👆 Swipe Actions (Mandatory & Clear)

### ➡️ Swipe Right
- "Interested in me" / "Like"
- **Visual:** Green color hint
- Immediate feedback

### ⬅️ Swipe Left
- "Not relevant" / "Pass"
- **Visual:** Red color hint
- Immediate feedback

### ⬆️ Swipe Up / ⭐
- "Very interested" (Boost / Priority)
- **Visual:** Purple color hint
- Premium feel

### Visual Color System
- **Green** = Approval / Like
- **Red** = Rejection / Pass
- **Purple** = Premium / Super Like

## ✨ Animations (Critical for Experience)

### Card Animations
- Card tilts with finger movement
- Background color changes during swipe
- Smooth rotation during swipe
- Card follows finger naturally
- Color hints appear progressively

### Haptic Feedback
- Small vibration on swipe actions
- Different patterns for different actions

### Match Animation
- 🎉 Celebration animation
- "It's a Match! The company saw you"
- Short, exciting, not spammy
- Confetti or similar celebration effect

## 👤 Candidate Profile (Also Tinder-style)

### Profile Elements
- Profile photo / icon
- Short bio:
  - "SDR | SaaS | English Native"
- Skills as chips
- **Match percentage:**
  - "82% Match"
  - Displayed prominently

### Swipe Actions (Same as Job Cards)
- ➡️ Swipe Right: "Interested in me"
- ⬅️ Swipe Left: "Not relevant"
- ⬆️ Swipe Up / ⭐: "Very interested" (Boost / Priority)

### Visual
- Green = Approval
- Red = Rejection
- Purple = Premium

## 📱 Core Screens

### 7.1 Swipe Screen (Main Experience)

Each job appears as a **large, rounded card centered on the screen**.

**Card content:**
- Job Title (large)
- Company Name
- Company Logo
- Location (icon)
- Salary range (optional)
- Tags (rounded chips):
  - Remote
  - Full-Time
  - Junior / Senior
- Match percentage (small, subtle)

**Interaction:**
- Card follows finger
- Slight rotation during swipe
- Color hint appears:
  - Green → Like
  - Red → Skip
  - Purple → Priority

### 7.2 Match Screen

Displayed on successful match.

**Content:**
- Light celebration animation
- Headline: "It's a Match!"
- Short message: "This company is interested in you."
- Actions:
  - Send CV
  - Apply
  - Start chat

**Tone:**
- Positive
- Short
- Non-spammy

### 7.3 User Profile Screen

**Purpose:** Build confidence and trust.

**Elements:**
- Profile photo or avatar
- Name
- Headline (e.g. "Junior Product Manager | UX")
- Short bio (1–2 lines)
- Skills as colored chips
- Experience level
- Profile completion indicator (progress bar)

**Primary CTA:**
- Upload CV
- Complete profile

## 🚀 Onboarding (Fast & Friendly)

Before first swipe, ask 5 quick questions:
1. Field of interest
2. Experience level
3. Salary expectations
4. Location / Remote preference
5. Employment type

**Rules:**
- One question per screen
- Tap / swipe only
- No forms
- Completion under 60 seconds

## 💡 UX Principles

- Minimal text
- Clear visual cues
- Friendly microcopy
- Immediate feedback on every action
- Explain relevance: "Shown because you selected Remote + Marketing"

## 💰 Monetization (Design-Ready)

Prepare UI hooks for:
- ⭐ Super Like
- 🚀 Profile Boost
- 👀 See who liked you
- 🔓 Priority matching

Integrate subtly — never interrupt core swipe flow.

## 📝 Tone & Copy Guidelines

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

## 🐛 Colleague Feedback (Hebrew - Translated)

### Design Issues
1. **"העיצוב נראה זול" (Design looks cheap)**
   - Need premium, high-quality design
   - Better materials, shadows, depth
   - More vibrant, less flat

2. **"פלטת צבעים לא הכי נעימה לעין בקטע שהיא מאוד מבולגנת" (Color palette not pleasant, very messy)**
   - Simplify color palette
   - Use max 3 accent colors
   - Clear color hierarchy
   - Consistent color usage

3. **"לנסות שהעיצוב ממשק יהיה יותר מינימליסטי זה מאוד מבלבל כל הנקודות והצבעים" (Make interface more minimalist, too many dots and colors confusing)**
   - Remove excessive decorative elements
   - Cleaner layout
   - Better visual hierarchy
   - Strategic use of color

4. **"הקלפים של המשרות נראים זולים" (Job cards look cheap)**
   - Complete redesign needed
   - Larger, more prominent
   - Premium materials
   - Better shadows and depth
   - Vibrant gradients

### Missing Features
5. **"חסר תהליך של העלאת קורות חיים וAI שינתח את זה מהצד של המועמדים וידע לנווט את זה למגייסים" (Missing CV upload with AI analysis for job seekers)**
   - ✅ Implemented (needs enhancement)

6. **"הליך יצירת משרה ופרטי חברה אצל המגייסים" (Job creation and company details for recruiters)**
   - ✅ Implemented (needs enhancement)

7. **"ואולי גם איזה דאשבורד למגייסים" (Maybe a dashboard for recruiters)**
   - ✅ Implemented (needs enhancement)

## 🎯 Main Features

### 1. Profiles for Job Seekers and Headhunters

**Job Seekers:**
- Swipe between job offers
- Jobs from:
  - Hunter-users uploaded
  - Job websites
  - Fetched from Glassdoor and LinkedIn (if possible)

**Headhunters:**
- Scroll through anonymous but detailed profiles of job-seekers
- When there's a match between a head-hunter profile of a job to a job-seeker profile, they can chat (just like in Tinder)

### 2. Interview Process Management

The app should handle the whole process:
- Help recruiters schedule job interviews with job-seekers
- Hold exact instructions of how to get to the interview location
- Send automated reminders to users on the day of the interview
- And so on

### 3. Design Requirements

- Look **classy and elegant**
- Have a **good flow**
- Be **fun to scroll**

## 🚨 Current Issues to Fix

1. **Design looks cheap** - Need major redesign
2. **Color palette messy** - Simplify and improve
3. **Too many dots and colors** - More minimalist
4. **Job cards look cheap** - Complete redesign needed
5. **Not enough dopamine** - Need more vibrant, fun, engaging
6. **Not trendy enough** - Need modern, alive design
7. **Not fun to swipe** - Need better animations and interactions

## ✅ Success Criteria

The app should:
- Look **premium and high-quality** (not cheap)
- Feel **alive and trendy**
- Provide **dopamine rush** when using
- Be **fun to swipe**
- Have **more color** (but strategic)
- Be **better overall** than current state

## 🎨 Redesign Priorities

1. **Job Cards** - Complete redesign, larger, more vibrant
2. **Color System** - More vibrant, strategic use
3. **Animations** - Smooth, engaging, fun
4. **Typography** - Larger, bolder, more readable
5. **Spacing** - More generous, airy
6. **Shadows & Depth** - Premium materials
7. **Gradients** - Strategic, vibrant use
8. **Interactions** - Immediate feedback, smooth

