# 🚀 Manual Deployment Steps - Render + Netlify (No Payment Required)

This guide uses **manual setup** instead of Blueprint to avoid payment requirements.

---

## 🌐 Step 1: Deploy Backend to Render (Manual Method)

### 1.1 Sign Up / Log In to Render

1. Go to: **https://render.com**
2. Click **"Get Started for Free"** or **"Sign In"**
3. Sign up with **GitHub** (easiest)
4. **Note:** Render may ask for payment info, but you can use free tier - they won't charge unless you upgrade

### 1.2 Create PostgreSQL Database (Free)

1. In Render dashboard, click **"New +"** → **"PostgreSQL"**
2. Fill in:
   - **Name:** `blowjobs-db`
   - **Database:** `blowjobs`
   - **User:** `blowjobs_user`
   - **Region:** Choose closest to you (e.g., Oregon)
   - **Plan:** Select **"Free"** (if available) or **"Starter"** (free tier)
3. Click **"Create Database"**
4. Wait for database to be created (1-2 minutes)

### 1.3 Get Database Connection String

1. Click on your database (`blowjobs-db`)
2. Find **"Connection String"** or **"Internal Database URL"**
3. Copy it - looks like:
   ```
   postgres://blowjobs_user:password@dpg-xxxxx-a/blowjobs
   ```
4. **📝 Save this - you'll need it!**

### 1.4 Create Web Service (Backend)

1. In Render dashboard, click **"New +"** → **"Web Service"**
2. Connect your GitHub account (if not already)
3. Select repository: **`jlautman1/blowjobs.ail`**
4. Fill in settings:

   **Basic Settings:**
   - **Name:** `blowjobs-backend`
   - **Region:** Same as database
   - **Branch:** `main`
   - **Root Directory:** `backend`
   - **Environment:** `Go`
   - **Build Command:** `go mod download && go build -o server ./cmd/server`
   - **Start Command:** `./server`

   **Environment Variables:**
   Click **"Add Environment Variable"** and add:
   
   - **Key:** `PORT` → **Value:** `10000`
   - **Key:** `GIN_MODE` → **Value:** `release`
   - **Key:** `DATABASE_URL` → **Value:** (paste the connection string from Step 1.3)
   - **Key:** `JWT_SECRET` → **Value:** (generate a random string, e.g., `your-super-secret-jwt-key-12345`)
   - **Key:** `ENVIRONMENT` → **Value:** `production`

5. **Plan:** Select **"Free"** (if available)
6. Click **"Create Web Service"**

### 1.5 Wait for Deployment

- Render builds your backend (5-10 minutes)
- Watch the build logs
- When done, you'll see: **"Your service is live"**

### 1.6 Get Your Backend URL

1. In your web service dashboard
2. Your URL is at the top, e.g.:
   - `https://blowjobs-backend.onrender.com`
3. **API endpoint:** `https://blowjobs-backend.onrender.com/api/v1`
4. **📝 Write this down!**

### 1.7 Test Backend

Open in browser:
```
https://YOUR-BACKEND-URL.onrender.com/health
```

Should return: `{"status":"healthy","service":"blowjobs-ai-api"}`

### 1.8 Run Migrations & Seed Data

**Option A: Using Render Shell**

1. In your web service, click **"Shell"** tab
2. Run:
   ```bash
   go run ./cmd/server
   ```
   Wait for it to start, then press `Ctrl+C`
3. Run:
   ```bash
   go run ./cmd/seed
   ```

**Option B: Using Local Terminal (Easier)**

1. On your computer, set the DATABASE_URL:
   ```bash
   # Windows PowerShell
   $env:DATABASE_URL="YOUR_CONNECTION_STRING_FROM_STEP_1.3"
   ```
2. Run migrations:
   ```bash
   cd backend
   go run ./cmd/server
   # Wait, then Ctrl+C
   ```
3. Seed data:
   ```bash
   go run ./cmd/seed
   ```

---

## 🎨 Step 2: Deploy Frontend to Netlify

### 2.1 Build Frontend Locally

On your Windows computer:

```bash
cd frontend
flutter build web --release --no-tree-shake-icons --dart-define=API_URL=https://YOUR-BACKEND-URL.onrender.com/api/v1
```

**Replace `YOUR-BACKEND-URL` with your actual Render URL!**

Example:
```bash
flutter build web --release --no-tree-shake-icons --dart-define=API_URL=https://blowjobs-backend.onrender.com/api/v1
```

This creates `frontend/build/web/` folder.

### 2.2 Sign Up / Log In to Netlify

1. Go to: **https://app.netlify.com**
2. Click **"Sign up"** or **"Log in"**
3. Sign up with **GitHub** (easiest)
4. **No payment required!**

### 2.3 Deploy Frontend (Drag & Drop)

1. In Netlify dashboard, find the drag & drop area
2. Open File Explorer on Windows
3. Navigate to: `C:\Users\jlaut\OneDrive\Desktop\Projects\get-higered\frontend\build\web`
4. **Drag the entire `web` folder** onto Netlify
5. Wait for upload (1-2 minutes)

### 2.4 Get Your Frontend URL

- Netlify gives you a URL like: `https://random-name-12345.netlify.app`
- **📝 Write this down!**

### 2.5 (Optional) Change Site Name

1. In Netlify dashboard → **Site settings**
2. Click **"Change site name"**
3. Choose a custom name, e.g.: `blowjobs-ai`
4. New URL: `https://blowjobs-ai.netlify.app`

---

## ✅ Step 3: Test Your Deployed App

### 3.1 Test Backend

```
https://YOUR-BACKEND-URL.onrender.com/health
```

Should return: `{"status":"healthy"}`

### 3.2 Test Frontend

```
https://YOUR-FRONTEND-URL.netlify.app
```

Try logging in:
- Email: `jobseeker@demo.com`
- Password: `demo123`

### 3.3 Test on iPhone

1. Open Safari on iPhone
2. Go to: `https://YOUR-FRONTEND-URL.netlify.app`
3. Should work from anywhere! 🎉

---

## 💳 About Payment Info

**Render may ask for payment info, but:**
- You can use **free tier** without being charged
- They only charge if you **manually upgrade** to paid plan
- Free tier includes:
  - Web service (spins down after 15 min inactivity)
  - PostgreSQL database (free tier)
- **You won't be charged** unless you explicitly upgrade

**If you're uncomfortable:**
- You can use **Railway** instead (also free tier, $5/month credit)
- Or **Fly.io** (generous free tier)

---

## 🔄 Future Updates

### Update Backend

1. Make code changes
2. Push to GitHub:
   ```bash
   git add .
   git commit -m "Update backend"
   git push
   ```
3. Render **auto-deploys** (or click "Manual Deploy" in dashboard)

### Update Frontend

1. Make code changes
2. Rebuild:
   ```bash
   cd frontend
   flutter build web --release --no-tree-shake-icons --dart-define=API_URL=https://YOUR-BACKEND-URL.onrender.com/api/v1
   ```
3. Drag new `build/web` folder to Netlify

---

## 🐛 Troubleshooting

### Render asks for payment

- This is normal - they verify payment method but won't charge for free tier
- You can proceed - just make sure to select **"Free"** plan when creating services

### Backend won't start

- Check Render logs (in dashboard)
- Verify `DATABASE_URL` environment variable is correct
- Make sure database is running

### First request is slow (30-60 seconds)

- Normal on free tier (spins down after 15 min)
- First request "wakes up" the server
- Subsequent requests are fast
- **Solution:** Upgrade to paid tier ($7/month) for always-on

---

## 📝 Summary

**Backend:** `https://YOUR-BACKEND-URL.onrender.com`  
**Frontend:** `https://YOUR-FRONTEND-URL.netlify.app`  
**Cost:** $0/month (free tier)

**Share the frontend URL with your colleague!** 🚀

