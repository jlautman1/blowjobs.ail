## 🚀 BlowJobs.ai – AI-Powered Job Matching

Modern swipe-based job matching for job seekers and recruiters, built with **Go**, **PostgreSQL**, and **Flutter Web**.

---

## 1. General Info

- **Getting the code** (for people new to git)
- **Setting up the backend & database**
- **Running the website on your computer**
- **Testing the website on your phone (same WiFi)**
- **Testing on a real phone with a USB cable (Android & iPhone)**
- **Testing on an Android emulator**
- **Test profiles (demo accounts) you can use**

Everything below assumes you are starting from scratch.

---

### 1.1 Get the Code (Clone the Repo)

### 1.1 Install Git (if you don’t have it)

- **Windows**: Install from `https://git-scm.com/download/win`
- **macOS**: `xcode-select --install` or install from `https://git-scm.com`
- **Linux (Debian/Ubuntu)**:

```bash
sudo apt update
sudo apt install git
```

### 1.2 Open a Terminal

- **Windows**: Press Start → type **“PowerShell”** → open **Windows PowerShell**
- **macOS**: Open **Terminal** from Applications → Utilities
- **Linux**: Open your terminal emulator

### 1.3 Clone the Repository

In your terminal:

```bash
git clone https://github.com/jlautman1/blowjobs.ail.git
cd blowjobs.ail
```

From now on, all commands assume your terminal is in this project folder.

---

## 2. Prerequisites (Required to Run the Code)

You’ll need these installed:

- **Go** (1.21+)
- **PostgreSQL** 14+ (or Docker)
- **Flutter** (with web and your platform enabled)
- **Chrome** browser

### 2.1 Check Go

```bash
go version
```

If missing, install from `https://go.dev/dl`.

### 2.2 Check Flutter

```bash
flutter doctor
```

If missing, install from `https://docs.flutter.dev/get-started/install`.

Make sure Flutter web is enabled:

```bash
flutter config --enable-web
```

### 2.3 PostgreSQL (via Docker – recommended)

Install Docker Desktop:

- `https://www.docker.com/products/docker-desktop`

Then, from the project root:

```bash
docker-compose up -d postgres
```

This starts a Postgres database container named (by default) `blowjobs-db`.

---

## 3. How to Run the Code

### 3.1 Backend Setup (API Server)

In a terminal (project root):

```bash
cd backend
```

### 3.1 Run Database Migrations

```bash
go run ./cmd/server  # first run will apply migrations, then fail if DB not ready
```

If the server starts successfully, stop it with:

- **Windows**: press `Ctrl + C` in the PowerShell window
- **macOS/Linux**: press `Ctrl + C`

> If migrations already ran, you can skip re-running this step in the future.

### 3.2 Seed Demo Data

```bash
go run ./cmd/seed
```

You should see logs about creating job seekers, recruiters, and jobs.

### 3.3 Start the Backend Server

From `backend/`:

```bash
go run ./cmd/server
```

The API will listen on:

- `http://localhost:8080`

Keep this terminal window **running** while you test the app.

---

### 3.4 Run the Website on Your Computer (Chrome)

Open **a new terminal** in the project root:

```bash
cd frontend
flutter run -d chrome --web-port=3000 --dart-define=API_URL=http://localhost:8080/api/v1
```

What happens:

- Chrome opens automatically
- App runs at `http://localhost:3000`
- Backend API is called at `http://localhost:8080/api/v1`

You can now test the full flow directly in your browser.

---

## 4. Testing

### 4.1 Test the Website on Your Phone (Same WiFi, No Cable)

This lets **any phone** (Android or iPhone) open the web app over your local network, using the Flutter web build.

### 5.1 Find Your Computer’s IP Address

Run this in a terminal:

- **Windows (PowerShell)**:

```powershell
ipconfig
```

Look for `IPv4 Address` under your Wi-Fi adapter, e.g. `192.168.7.3`.

- **macOS/Linux** (one option):

```bash
ip addr show | grep "inet "
```

Pick the IP on your local network, e.g. `192.168.1.50`.

We’ll call this IP: `YOUR_IP`.

### 5.2 Start Backend (If Not Already Running)

From `backend/`:

```bash
go run ./cmd/server
```

### 5.3 Run Flutter Web So Phones Can Reach It

Open a **new terminal**, from the project root:

```bash
cd frontend

flutter run -d chrome \
  --web-hostname=0.0.0.0 \
  --web-port=8081 \
  --dart-define=API_URL=http://YOUR_IP:8080/api/v1
```

- `0.0.0.0` makes the dev server accessible from other devices on your network.
- Backend URL uses `YOUR_IP` so phones can reach it (they can’t see `localhost` on your computer).

### 5.4 Allow Firewall (Windows Only, One-Time)

Open **PowerShell as Administrator** and run:

```powershell
netsh advfirewall firewall add rule name="BlowJobs Web" dir=in action=allow protocol=tcp localport=8081
netsh advfirewall firewall add rule name="BlowJobs API" dir=in action=allow protocol=tcp localport=8080
```

### 5.5 Open on Your Phone

1. Connect your phone to the **same WiFi** as your computer
2. Open Safari/Chrome on the phone
3. Visit:

```text
http://YOUR_IP:8081
```

Example: `http://192.168.7.3:8081`

### 5.6 Quick Connectivity Test (Optional)

On the phone, test the backend health:

```text
http://YOUR_IP:8080/health
```

If you see `{"status":"ok"}`, the phone can reach the API.

---

### 4.2 Test on a Real Phone via USB Cable

Here we run the **native Flutter app** on your phone.

#### 4.2.1 Android Phone (Any OS)

##### Enable Developer Mode & USB Debugging

On your Android phone:

1. **Settings → About phone → Build number** → tap 7 times → “You are now a developer”
2. **Settings → Developer options → USB debugging** → enable

##### Connect the Phone

- Plug phone into your computer with a USB cable
- Accept any “Allow USB debugging” prompts on the phone

##### Verify Device

From the project root:

```bash
flutter devices
```

You should see your Android device listed.

##### Run the App on Android

Make sure the backend is running (`go run ./cmd/server`).

Then from `frontend/`:

```bash
cd frontend
flutter run -d <device-id> --dart-define=API_URL=http://YOUR_IP:8080/api/v1
```

If only one Android device is connected, you can omit `-d <device-id>`:

```bash
flutter run --dart-define=API_URL=http://YOUR_IP:8080/api/v1
```

The app will install and run on your Android phone.

---

#### 4.2.2 iPhone (Requires macOS + Xcode)

Apple only allows iOS apps to be built from macOS with Xcode.

##### Requirements

- A **Mac** with macOS
- **Xcode** installed from the App Store
- **Flutter** installed on the Mac
- An **Apple ID**
- Your iPhone + USB cable

##### Set Up iOS Project

On the Mac, in the project root:

```bash
cd frontend/ios
pod install
cd ..
```

##### Open in Xcode and Configure Signing

1. Open `frontend/ios/Runner.xcworkspace` in **Xcode**
2. Select the **Runner** target
3. Go to **Signing & Capabilities**
4. Check **“Automatically manage signing”**
5. Choose your **Team** (your Apple ID)

##### Connect iPhone and Trust Device

1. Plug in your iPhone with USB
2. On iPhone, tap **Trust This Computer**
3. In **Settings → General → VPN & Device Management**, trust your developer profile if asked

##### Run the App

Make sure the backend is running and reachable at `http://YOUR_IP:8080`.

From `frontend/` on the Mac:

```bash
cd frontend
flutter run -d ios --dart-define=API_URL=http://YOUR_IP:8080/api/v1
```

The app will build and run on your iPhone.

---

### 4.3 Test on Android Emulator

This is useful if you don’t have a physical Android device.

#### Install Android Studio

Download and install from:

- `https://developer.android.com/studio`

During setup, make sure you install:

- Android SDK
- Android SDK Platform-Tools
- Android Emulator

#### Create an Emulator (AVD)

In Android Studio:

1. **Tools → Device Manager**
2. Click **Create Device**
3. Choose a phone (e.g. Pixel 6)
4. Choose a system image (e.g. Android 13, API 33)
5. Finish

#### Start the Emulator

In Device Manager, click the **Play ▶️** button next to the virtual device.

#### Run the App on the Emulator

Make sure the backend is running (`go run ./cmd/server`).

In a terminal from `frontend/`:

```bash
cd frontend
flutter devices          # make sure the emulator appears
flutter run -d <emulator-id> --dart-define=API_URL=http://YOUR_IP:8080/api/v1
```

If the emulator is the only Android device, you can often just run:

```bash
flutter run --dart-define=API_URL=http://YOUR_IP:8080/api/v1
```

---

### 4.4 Test Profiles (Demo Accounts)

After running the seed script (`go run ./cmd/seed`), these demo profiles are created for testing:

| Profile Type        | Name    | Email                       | Password  |
|---------------------|---------|-----------------------------|-----------|
| Job Seeker          | Alex    | `jobseeker@demo.com`        | `demo123` |
| Job Seeker          | Sam     | `developer@demo.com`        | `demo123` |
| Job Seeker          | Emma    | `emma.tech@demo.com`        | `demo123` |
| Job Seeker          | Mike    | `mike.dev@demo.com`         | `demo123` |
| Job Seeker          | Sarah   | `sarah.design@demo.com`     | `demo123` |
| Job Seeker          | David   | `david.data@demo.com`       | `demo123` |
| Job Seeker          | Lisa    | `lisa.marketing@demo.com`   | `demo123` |
| Recruiter (TechCorp)| Jordan  | `recruiter@demo.com`        | `demo123` |
| Recruiter (Startup) | Rachel  | `hr@startupxyz.com`         | `demo123` |
| Recruiter (BigTech) | Marcus  | `talent@bigtech.com`        | `demo123` |

> All other seeded demo users also use the password **`demo123`**.

Typical end-to-end testing flow:

- Login as **job seeker**, swipe right on a job
- Login as **recruiter**, swipe right on that candidate
- See the **match** and try the **chat**

---

## 🧰 9. Optional: Makefile Shortcuts

If you’re comfortable with **make**, there are helper commands defined in `Makefile` (may evolve over time):

| Command            | What it Does                            |
|--------------------|------------------------------------------|
| `make setup`       | Install tools & set up DB (first time)  |
| `make backend`     | Start only the backend API              |
| `make frontend`    | Start frontend in Chrome (localhost)    |

These are optional; all important flows are already described with raw commands above.

---

## 🐛 10. Troubleshooting (Common Issues)

- **Port 8080 already in use**
  - Another process is using the port. On Windows PowerShell:
  ```powershell
  netstat -ano | Select-String ":8080"
  taskkill /F /PID <PID_FROM_ABOVE>
  ```
- **Phone cannot reach `http://YOUR_IP:8081`**
  - Make sure phone and computer are on **same WiFi**
  - Check Windows Firewall rules (see section 5.4)
  - Verify backend health from phone: `http://YOUR_IP:8080/health`

If you get stuck, the safest reset is:

1. Stop all `go`, `flutter`, and `python` processes
2. Restart Docker Desktop (for Postgres)
3. Start backend again
4. Start frontend again using the commands above

---

## 🏗️ 11. Tech Stack (High Level)

| Layer        | Tech                         |
|-------------|------------------------------|
| Backend     | Go, Gin, PostgreSQL, JWT     |
| Frontend    | Flutter (Web), Riverpod      |
| Realtime    | WebSockets (chat, events)    |

---

Made for job seekers and recruiters who don’t want to blow the opportunity. 💼🔥


