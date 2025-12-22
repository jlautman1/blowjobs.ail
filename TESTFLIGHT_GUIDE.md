# 📱 TestFlight Upload Guide - For Mac User

This guide walks through uploading the BlowJobs.ai iOS app to TestFlight so it can be installed on iPhones from anywhere (no WiFi needed).

**Time estimate:** 30-60 minutes (first time), 10-15 minutes for future updates

---

## ✅ Prerequisites Checklist

Before starting, make sure you have:

- [ ] **Mac** (macOS 12+ recommended)
- [ ] **Apple Developer Account** ($99/year) - [Sign up here](https://developer.apple.com/programs/)
- [ ] **Xcode** installed (latest version from App Store)
- [ ] **Flutter** installed on the Mac
- [ ] **Git** installed (usually comes with Xcode)
- [ ] **CocoaPods** installed (we'll check this)

---

## Step 1: Verify Prerequisites

### 1.1 Check Flutter Installation

Open **Terminal** (Applications → Utilities → Terminal) and run:

```bash
flutter doctor
```

**Expected output:** Should show Flutter version and checkmarks for installed components.

**If Flutter is NOT installed:**
```bash
# Install Flutter
brew install --cask flutter

# Or download from: https://docs.flutter.dev/get-started/install/macos
# Then add to PATH
```

**Verify Flutter web is enabled:**
```bash
flutter config --enable-web
```

### 1.2 Check CocoaPods

```bash
pod --version
```

**If CocoaPods is NOT installed:**
```bash
sudo gem install cocoapods
```

### 1.3 Check Xcode

```bash
xcode-select --version
```

**If Xcode is NOT installed:**
- Open **App Store** on Mac
- Search for **"Xcode"**
- Click **Install** (it's large, ~12GB, takes a while)
- After installation, open Xcode once to accept licenses

### 1.4 Verify Apple Developer Account

1. Go to: https://developer.apple.com/account
2. Sign in with your Apple ID
3. Make sure you see **"Active"** status (paid membership)

---

## Step 2: Get the Code

### 2.1 Clone the Repository

In Terminal, navigate to where you want the project (e.g., Desktop):

```bash
cd ~/Desktop
git clone https://github.com/jlautman1/blowjobs.ail.git
cd blowjobs.ail
```

### 2.2 Verify Project Structure

You should see:
```
blowjobs.ail/
├── backend/
├── frontend/
├── docker-compose.yml
└── README.md
```

---

## Step 3: Install iOS Dependencies

### 3.1 Navigate to Frontend

```bash
cd frontend
```

### 3.2 Install Flutter Dependencies

```bash
flutter pub get
```

### 3.3 Install iOS Pods

```bash
cd ios
pod install
cd ..
```

**Note:** First time may take a few minutes. You should see:
```
Pod installation complete! There are X dependencies from the Podfile.
```

---

## Step 4: Configure Xcode Project

### 4.1 Open the Project in Xcode

```bash
open ios/Runner.xcworkspace
```

**Important:** Open `.xcworkspace`, NOT `.xcodeproj`!

### 4.2 Select the Runner Target

1. In Xcode's left sidebar, click on **"Runner"** (blue icon at the top)
2. In the main panel, select the **"Runner"** target (under TARGETS)

### 4.3 Configure Signing & Capabilities

1. Click the **"Signing & Capabilities"** tab
2. Check **"Automatically manage signing"**
3. Under **"Team"**, select your Apple Developer team
   - If you don't see your team, click **"Add Account..."** and sign in

### 4.4 Set Bundle Identifier

1. Still in **Signing & Capabilities**
2. Find **"Bundle Identifier"**
3. Change it to something unique, e.g.:
   - `com.yourname.blowjobsai`
   - Or `com.yourcompany.blowjobsai`
   - **Important:** This must be unique and match what you'll use in App Store Connect

**Write down this Bundle Identifier** - you'll need it later!

---

## Step 5: Create App in App Store Connect

### 5.1 Log In to App Store Connect

1. Open browser and go to: https://appstoreconnect.apple.com
2. Sign in with your **Apple Developer account** (same Apple ID)

### 5.2 Create New App

1. Click **"My Apps"** (top menu)
2. Click the **"+"** button (top left) → **"New App"**

### 5.3 Fill App Information

Fill in the form:

- **Platform:** Select **iOS**
- **Name:** `BlowJobs.ai` (or whatever you want - this is what users see)
- **Primary Language:** English (or your preference)
- **Bundle ID:** 
  - Click **"Register a new Bundle ID"** if you haven't used the one from Step 4.4
  - Or select existing Bundle ID that matches what you set in Xcode
- **SKU:** Any unique identifier (e.g., `blowjobs-ai-001`)
  - This is internal only, users never see it
- **User Access:** 
  - **Full Access** (recommended for now)

Click **"Create"**

### 5.4 Note Your App ID

After creation, you'll see your app's page. **Write down the App ID** (you might need it later).

---

## Step 6: Build the iOS App

### 6.1 Set API URL (IMPORTANT)

**Before building, you need to decide on the backend API URL.**

**Option A: Use a placeholder (for now)**
- We'll update this later when backend is hosted
- For now, use: `https://api.example.com/api/v1`

**Option B: If backend is already hosted**
- Use the actual URL, e.g.: `https://api.yourdomain.com/api/v1`

### 6.2 Build for Release

In Terminal (still in `frontend/` directory):

```bash
flutter build ios --release \
  --dart-define=API_URL=https://api.example.com/api/v1
```

**Replace `https://api.example.com/api/v1` with your actual backend URL when ready.**

**What happens:**
- Flutter compiles the app (takes 2-5 minutes)
- Creates an iOS build in `build/ios/iphoneos/`

---

## Step 7: Create Archive in Xcode

### 7.1 Select Build Target

1. In Xcode, look at the top toolbar
2. Next to the **Play ▶️** button, you'll see a device selector
3. Click it and select **"Any iOS Device (arm64)"**
   - **Don't select a simulator!** Must be a real device or "Any iOS Device"

### 7.2 Create Archive

1. In Xcode menu: **Product → Archive**
2. Wait for build to complete (5-10 minutes first time)
3. When done, **Organizer** window opens automatically
   - If it doesn't, go to: **Window → Organizer**

### 7.3 Verify Archive

In Organizer, you should see:
- Your app name
- Today's date
- Version number

---

## Step 8: Upload to App Store Connect

### 8.1 Distribute App

1. In **Organizer** window, select your archive
2. Click **"Distribute App"** button (right side)

### 8.2 Choose Distribution Method

1. Select **"App Store Connect"**
2. Click **"Next"**

### 8.3 Choose Upload Options

1. Select **"Upload"** (not "Export")
2. Click **"Next"**

### 8.4 Review Distribution Options

1. Leave defaults (usually fine)
2. Click **"Next"**

### 8.5 Review App Information

1. Verify Bundle ID matches what you set in App Store Connect
2. Click **"Upload"**

### 8.6 Wait for Upload

- Upload progress bar appears
- Takes 5-15 minutes depending on internet speed
- When done, you'll see: **"Upload Successful"**

**Note:** You can close Xcode now. The upload continues in background.

---

## Step 9: Process Build in App Store Connect

### 9.1 Wait for Processing

1. Go back to: https://appstoreconnect.apple.com
2. Navigate to: **My Apps → [Your App Name]**
3. Click **"TestFlight"** tab (top menu)
4. You should see your build under **"iOS Builds"** with status: **"Processing"**

**Wait time:** Usually 10-30 minutes for Apple to process

### 9.2 Build Becomes Available

When processing completes:
- Status changes to **"Ready to Submit"** or shows a version number
- You'll get an email notification (if enabled)

---

## Step 10: Add Internal Testers

### 10.1 Add Yourself as Tester

1. In **TestFlight** tab, go to **"Internal Testing"** section
2. Click **"+"** to add testers
3. Enter your **Apple ID email** (the one you use for App Store)
4. Click **"Add"**

### 10.2 Add Colleagues (Optional)

Repeat Step 10.1 for each colleague's Apple ID email.

**Note:** Internal testers must be part of your Apple Developer team.

---

## Step 11: Install TestFlight App on iPhone

### 11.1 Install TestFlight App

1. On your iPhone, open **App Store**
2. Search for **"TestFlight"**
3. Install the **TestFlight** app (by Apple)

### 11.2 Sign In to TestFlight

1. Open **TestFlight** app on iPhone
2. Sign in with the **same Apple ID** you added as a tester
3. You should see **"BlowJobs.ai"** (or your app name) listed

### 11.3 Install the App

1. Tap on your app
2. Tap **"Install"**
3. Wait for download and installation
4. App icon appears on home screen

**🎉 Done!** The app is now installed and can be used from anywhere (as long as backend is accessible).

---

## Step 12: Update Backend URL (When Ready)

When the backend is hosted and you have a public URL:

### 12.1 Update API URL in Code

In `frontend/lib/core/services/api_service.dart`, find:

```dart
static const String baseUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://localhost:8080/api/v1',
);
```

Or rebuild with new URL:

```bash
cd frontend
flutter build ios --release \
  --dart-define=API_URL=https://your-actual-backend-url.com/api/v1
```

### 12.2 Create New Archive and Upload

Repeat **Steps 7-9** to create a new build with the updated API URL and upload it.

---

## 🔄 Future Updates (Quick Process)

When you need to update the app:

1. Make code changes
2. **Step 6:** Build with new API URL (if changed)
3. **Step 7:** Create new archive
4. **Step 8:** Upload to App Store Connect
5. **Step 9:** Wait for processing
6. Testers get notification to update in TestFlight app

---

## 🐛 Troubleshooting

### "No signing certificate found"

**Solution:**
1. In Xcode: **Preferences → Accounts**
2. Select your Apple ID
3. Click **"Download Manual Profiles"**
4. Go back to **Signing & Capabilities** and try again

### "Bundle ID already exists"

**Solution:**
- Change Bundle ID in Xcode to something more unique
- Or use the existing Bundle ID in App Store Connect

### "Upload failed" or "Invalid bundle"

**Solution:**
- Make sure you selected **"Any iOS Device"** not a simulator
- Clean build: In Xcode: **Product → Clean Build Folder** (Shift+Cmd+K)
- Try archiving again

### Build takes forever

**Solution:**
- First build always takes longer (10-20 minutes)
- Subsequent builds are faster (5-10 minutes)
- Make sure you have good internet connection

### TestFlight app doesn't show the build

**Solution:**
- Make sure you're signed in with the **same Apple ID** that was added as tester
- Wait a few more minutes - sometimes there's a delay
- Check email for any notifications from Apple

---

## 📝 Summary Checklist

- [ ] Flutter installed and working
- [ ] CocoaPods installed
- [ ] Xcode installed and opened at least once
- [ ] Apple Developer account active ($99/year)
- [ ] Code cloned from GitHub
- [ ] iOS dependencies installed (`pod install`)
- [ ] Xcode project configured (signing, bundle ID)
- [ ] App created in App Store Connect
- [ ] iOS app built (`flutter build ios --release`)
- [ ] Archive created in Xcode
- [ ] Archive uploaded to App Store Connect
- [ ] Build processed by Apple
- [ ] Testers added in TestFlight
- [ ] TestFlight app installed on iPhone
- [ ] App installed from TestFlight

---

## 🆘 Need Help?

If you get stuck:
1. Check the error message carefully
2. Search for the error on Google/Stack Overflow
3. Check Apple Developer forums: https://developer.apple.com/forums/
4. Verify all prerequisites are met

---

**Good luck! 🚀**

