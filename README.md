# 🚀 BlowJobs.ai - Don't Blow This Job Opportunity!

<p align="center">
  <strong>AI-powered job matching app that connects job seekers with recruiters through an engaging swipe interface.</strong>
</p>

<p align="center">
  <a href="#-quick-start">Quick Start</a> •
  <a href="#-prerequisites">Prerequisites</a> •
  <a href="#-running-the-app">Running</a> •
  <a href="#-testing-on-different-platforms">Testing</a> •
  <a href="#-testing-on-your-phone-via-network-easiest-for-any-phone">📱 Phone Testing</a> •
  <a href="#-features">Features</a>
</p>

---

## 🚀 Quick Start

```bash
# 1. Install dependencies
make install

# 2. Setup database
make setup

# 3. Run the app (opens in Chrome)
make run
```

That's it! The app will open at `http://localhost:3000`

---

## 🔐 Demo Accounts

Use these pre-seeded accounts to test the app:

| Account Type | Email | Password |
|-------------|-------|----------|
| **Job Seeker** | `jobseeker@demo.com` | `demo123` |
| **Recruiter** | `recruiter@demo.com` | `demo123` |
| **Second Job Seeker** | `developer@demo.com` | `demo123` |

> **Note:** Run `npm run seed` after setting up the database to create these demo accounts.

---

## 📋 Prerequisites

Before running BlowJobs.ai, you need to install the following tools:

### 1. Go (Backend)

**Check if installed:**
```bash
go version
```
Expected output: `go version go1.21.x` or higher

**Install Go:**

| Platform | Installation |
|----------|-------------|
| **Windows** | Download from [go.dev/dl](https://go.dev/dl/) and run the installer |
| **macOS** | `brew install go` or download from [go.dev/dl](https://go.dev/dl/) |
| **Linux** | `sudo apt install golang-go` or `sudo snap install go --classic` |

After installation, verify with `go version`

---

### 2. Flutter (Frontend)

**Check if installed:**
```bash
flutter doctor
```
Expected output: Shows Flutter version and checks for dependencies

**Install Flutter:**

| Platform | Installation |
|----------|-------------|
| **Windows** | 1. Download from [flutter.dev](https://docs.flutter.dev/get-started/install/windows)<br>2. Extract to `C:\flutter`<br>3. Add `C:\flutter\bin` to PATH |
| **macOS** | `brew install flutter` or download from [flutter.dev](https://docs.flutter.dev/get-started/install/macos) |
| **Linux** | `sudo snap install flutter --classic` or download from [flutter.dev](https://docs.flutter.dev/get-started/install/linux) |

**After installation:**
```bash
flutter doctor
```

Fix any issues shown by `flutter doctor`. Common fixes:
- Accept Android licenses: `flutter doctor --android-licenses`
- Enable web: `flutter config --enable-web`

---

### 3. PostgreSQL (Database)

**Check if installed:**
```bash
psql --version
```
Expected output: `psql (PostgreSQL) 14.x` or higher

**Option A: Install PostgreSQL directly**

| Platform | Installation |
|----------|-------------|
| **Windows** | Download from [postgresql.org](https://www.postgresql.org/download/windows/) |
| **macOS** | `brew install postgresql@15` then `brew services start postgresql@15` |
| **Linux** | `sudo apt install postgresql postgresql-contrib` then `sudo systemctl start postgresql` |

**Option B: Use Docker (Easier)**
```bash
docker-compose up -d postgres
```
This starts PostgreSQL automatically. No installation needed!

---

### 4. Chrome Browser

Required for web testing (the easiest way to test).

**Check:** Just open Chrome. If you have it, you're good!

**Install:** Download from [google.com/chrome](https://www.google.com/chrome/)

---

### 5. Make (Build Tool)

**Check if installed:**
```bash
make --version
```

**Install Make:**

| Platform | Installation |
|----------|-------------|
| **Windows** | Install via [Chocolatey](https://chocolatey.org/): `choco install make`<br>Or use Git Bash (comes with make) |
| **macOS** | `xcode-select --install` (comes with Xcode CLI tools) |
| **Linux** | `sudo apt install build-essential` |

---

### 6. Docker (Optional but Recommended)

Makes database setup easier.

**Check if installed:**
```bash
docker --version
docker-compose --version
```

**Install Docker:**
- Download [Docker Desktop](https://www.docker.com/products/docker-desktop/) for Windows/macOS
- Linux: `sudo apt install docker.io docker-compose`

---

## 🏃 Running the App

### Using Make (Recommended)

```bash
# First time only - install everything
make setup

# Start the app
make run
```

### Using npm

```bash
npm install
npm run setup
npm start
```

### Using Docker (Everything in containers)

```bash
docker-compose up -d
```

### Manual Start

**Terminal 1 - Backend:**
```bash
cd backend
go run cmd/server/main.go
```

**Terminal 2 - Frontend:**
```bash
cd frontend
flutter run -d chrome --web-port=3000
```

---

## 🧪 Testing on Different Platforms

### 📊 Platform Comparison

| Platform | Difficulty | Setup Time | Best For |
|----------|-----------|------------|----------|
| **Web (Chrome)** | ⭐ Easiest | 0 min | Quick testing, development |
| **Windows Desktop** | ⭐ Easy | 0 min | Windows users |
| **Android Emulator** | ⭐⭐ Medium | 30 min | Android-specific testing |
| **iOS Simulator** | ⭐⭐ Medium | 30 min | iOS-specific testing (macOS only) |
| **Physical Android** | ⭐⭐ Medium | 10 min | Real device testing |
| **Physical iPhone** | ⭐⭐⭐ Hard | 1+ hour | Real iOS testing (needs Apple Developer account) |

---

### 🌐 Testing on Web (Chrome) - EASIEST

**No emulator needed!** This is the fastest way to test.

**Run:**
```bash
make frontend
```

Or manually:
```bash
cd frontend
flutter run -d chrome --web-port=3000
```

**What happens:**
- Chrome opens automatically
- App runs at `http://localhost:3000`
- Hot reload works (press `r` in terminal)

**Limitations:**
- Some mobile gestures work differently
- No push notifications
- No haptic feedback

---

### 🖥️ Testing on Windows Desktop

**Requirements:** Windows 10 or later

**Enable Windows development:**
```bash
flutter config --enable-windows-desktop
```

**Run:**
```bash
cd frontend
flutter run -d windows
```

**What happens:**
- Native Windows app opens
- Full desktop experience
- Hot reload supported

---

### 🤖 Testing on Android Emulator

#### Step 1: Install Android Studio

1. Download [Android Studio](https://developer.android.com/studio)
2. Run the installer
3. During setup, make sure to install:
   - Android SDK
   - Android SDK Platform-Tools
   - Android Emulator

#### Step 2: Create Virtual Device

1. Open Android Studio
2. Go to **Tools → Device Manager** (or AVD Manager)
3. Click **Create Device**
4. Choose a phone (e.g., Pixel 6)
5. Select a system image (e.g., API 33 - Android 13)
6. Click **Finish**

#### Step 3: Start Emulator

1. In Device Manager, click the **Play ▶️** button next to your device
2. Wait for the emulator to boot up

#### Step 4: Run the App

```bash
cd frontend
flutter run -d android
```

Or with make:
```bash
make frontend-android
```

**Tips:**
- First boot takes 2-5 minutes
- Keep emulator running between tests
- Use `flutter devices` to see available devices

---

### 🍎 Testing on iOS Simulator (macOS Only)

#### Step 1: Install Xcode

1. Open App Store on your Mac
2. Search for "Xcode"
3. Install (it's ~12GB, takes a while)
4. Open Xcode once to accept licenses

#### Step 2: Install Command Line Tools

```bash
xcode-select --install
sudo xcodebuild -license accept
```

#### Step 3: Install CocoaPods

```bash
sudo gem install cocoapods
```

Or with Homebrew:
```bash
brew install cocoapods
```

#### Step 4: Setup iOS Project

```bash
cd frontend/ios
pod install
cd ..
```

#### Step 5: Open Simulator

```bash
open -a Simulator
```

Or: Xcode → Open Developer Tool → Simulator

#### Step 6: Run the App

```bash
flutter run -d ios
```

**Tips:**
- Choose iPhone model: **File → Open Simulator → iOS X → iPhone 15**
- Simulator is faster than Android emulator
- Use `Cmd + Shift + H` for home button

---

### 📱 Testing on Physical Android Phone

#### Step 1: Enable Developer Mode on Phone

1. Go to **Settings → About Phone**
2. Tap **Build Number** 7 times
3. You'll see "You are now a developer!"

#### Step 2: Enable USB Debugging

1. Go to **Settings → Developer Options**
2. Enable **USB Debugging**
3. (Optional) Enable **Install via USB**

#### Step 3: Connect Phone

1. Connect phone to computer with USB cable
2. On phone, tap **Allow** when prompted for USB debugging

#### Step 4: Verify Connection

```bash
flutter devices
```

You should see your phone listed.

#### Step 5: Run the App

```bash
flutter run -d <device-id>
```

Or if only one device:
```bash
flutter run
```

**Tips:**
- Use a good USB cable (data cable, not just charging)
- Keep phone unlocked during installation
- First install may ask for permission on phone

---

### 📱 Testing on Physical iPhone

**⚠️ This requires macOS and more setup than Android**

#### Step 1: Prerequisites

- macOS computer
- Xcode installed
- Apple ID (free)
- iPhone connected via USB

#### Step 2: Setup Signing

1. Open `frontend/ios/Runner.xcworkspace` in Xcode
2. Select **Runner** in the left panel
3. Go to **Signing & Capabilities**
4. Check **Automatically manage signing**
5. Select your Team (your Apple ID)

#### Step 3: Trust Developer on iPhone

1. Connect iPhone to Mac
2. On iPhone: **Settings → General → VPN & Device Management**
3. Trust your developer certificate

#### Step 4: Run

```bash
flutter run -d ios
```

**Tips:**
- First run takes longer (builds native code)
- Free Apple ID limits: app expires after 7 days
- For App Store: need $99/year Apple Developer account

---

### 📱 Testing on Your Phone via Network (Easiest for Any Phone!)

**No cables, no emulators!** Access the web app directly from any phone on your local network.

#### Step 1: Find Your Computer's IP Address

**Windows:**
```powershell
ipconfig
```
Look for `IPv4 Address` under your WiFi adapter (e.g., `192.168.1.100`)

**macOS/Linux:**
```bash
ifconfig | grep "inet "
# or
ip addr show | grep "inet "
```

#### Step 2: Start the Database

```bash
docker-compose up -d postgres
```

#### Step 3: Seed Demo Data

```bash
cd backend
go run ./cmd/seed
```

#### Step 4: Start the Backend

```bash
cd backend
go run ./cmd/server
```

#### Step 5: Build & Serve the Web App

Replace `YOUR_IP` with your actual IP address (e.g., `192.168.1.100`):

```bash
cd frontend

# Build with your IP address
flutter build web --no-tree-shake-icons --dart-define=API_URL=http://YOUR_IP:8080/api/v1

# Serve the app
cd build/web
python -m http.server 8081 --bind 0.0.0.0
```

#### Step 6: Allow Firewall Access (Windows Only)

Open **PowerShell as Administrator** and run:

```powershell
netsh advfirewall firewall add rule name="BlowJobs Web" dir=in action=allow protocol=tcp localport=8081
netsh advfirewall firewall add rule name="BlowJobs API" dir=in action=allow protocol=tcp localport=8080
```

#### Step 7: Access from Your Phone

1. Connect your phone to the **same WiFi network** as your computer
2. Open your phone's browser (Safari, Chrome, etc.)
3. Go to: `http://YOUR_IP:8081` (e.g., `http://192.168.1.100:8081`)

#### 🧪 Test Connectivity First

Before loading the app, test the API:
```
http://YOUR_IP:8080/health
```
You should see: `{"status":"ok"}`

#### 📱 Add to Home Screen (Optional)

**iPhone:** Tap Share → "Add to Home Screen"  
**Android:** Tap Menu (⋮) → "Add to Home Screen"

This gives you an app-like icon!

#### 🔐 Demo Accounts for Testing

| Type | Email | Password |
|------|-------|----------|
| Job Seeker | `jobseeker@demo.com` | `demo123` |
| Recruiter | `recruiter@demo.com` | `demo123` |

#### 🎯 Quick Match Test

1. Login as `jobseeker@demo.com` → Swipe RIGHT on a TechCorp job
2. Logout → Login as `recruiter@demo.com` → Swipe RIGHT on "Alex"
3. 🎉 See the match celebration with confetti!

---

## 🛠️ Available Make Commands

| Command | Description |
|---------|-------------|
| `make run` | Start backend + frontend (Chrome) |
| `make setup` | First-time setup (install + database) |
| `make install` | Install all dependencies |
| `make backend` | Start only backend |
| `make frontend` | Start frontend in Chrome |
| `make frontend-android` | Start frontend on Android |
| `make frontend-ios` | Start frontend on iOS |
| `make frontend-windows` | Start frontend on Windows |
| `make docker` | Start with Docker |
| `make docker-stop` | Stop Docker services |
| `make clean` | Clean build files |
| `make help` | Show all commands |

---

## ✨ Features

### For Job Seekers
- 🔄 **Swipe Interface** - Swipe right to apply, left to skip, up for super like
- 📝 **Anonymous Profiles** - First name only, no photos required
- 💬 **Real-time Chat** - Message recruiters instantly after matching
- 📅 **Interview Scheduling** - Receive and manage interview invitations
- 🏆 **Gamification** - Streaks, badges, achievements, and daily rewards

### For Recruiters
- 📋 **Job Posting** - Create detailed job listings
- 👥 **Candidate Discovery** - Browse anonymous but detailed profiles
- 🎯 **Smart Matching** - Match with interested candidates
- 💼 **Application Tracking** - Manage the entire hiring pipeline

### Gamification Features
- 🔥 **Daily Streaks** - Keep your activity streak going
- 🏅 **14 Unique Badges** - First Match, Power Seeker, Streak Legend, etc.
- 🎊 **Match Celebrations** - Confetti animations on matches
- 📈 **XP & Levels** - Progress system with rewards
- 🎁 **Daily Rewards** - Login bonuses that increase with streaks

---

## 🏗️ Tech Stack

| Component | Technology |
|-----------|-----------|
| **Backend** | Go, Gin, PostgreSQL, JWT, WebSockets |
| **Frontend** | Flutter, Riverpod, go_router |
| **Database** | PostgreSQL 15 |
| **Containerization** | Docker, Docker Compose |

---

## 📁 Project Structure

```
get-higered/
├── backend/                    # Go API Server
│   ├── cmd/server/main.go     # Entry point
│   ├── internal/
│   │   ├── api/               # REST endpoints
│   │   ├── auth/              # JWT & passwords
│   │   ├── database/          # PostgreSQL
│   │   ├── models/            # Data structures
│   │   └── websocket/         # Real-time chat
│   └── Dockerfile
│
├── frontend/                   # Flutter App
│   ├── lib/
│   │   ├── core/              # Theme, router, services
│   │   └── features/          # Screens and widgets
│   └── pubspec.yaml
│
├── docker-compose.yml
├── Makefile
├── package.json
└── README.md
```

---

## 🔮 Roadmap

### Phase 2 (Coming Soon)
- [ ] Job board API integrations (Indeed, Adzuna)
- [ ] Push notifications
- [ ] Video interview integration
- [ ] Resume parsing with AI

### Phase 3
- [ ] Contract management
- [ ] Salary negotiation tools
- [ ] Company reviews

---

## 🐛 Troubleshooting

### "flutter: command not found"
Add Flutter to your PATH. See [Flutter installation](https://docs.flutter.dev/get-started/install).

### "go: command not found"
Add Go to your PATH. Restart terminal after installing.

### Database connection error
Make sure PostgreSQL is running:
```bash
# Check if running
pg_isready

# Or use Docker
docker-compose up -d postgres
```

### Android emulator not detected
```bash
flutter doctor --android-licenses
flutter doctor
```

### iOS build fails
```bash
cd frontend/ios
pod install --repo-update
cd ..
flutter clean
flutter run -d ios
```

---

## 📄 License

MIT License - see [LICENSE](LICENSE) file.

---

<p align="center">
  Made with ❤️ for job seekers and recruiters everywhere
</p>
