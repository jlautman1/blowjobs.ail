# 🚀 Railway Deployment Guide - Free & No Payment Info Required

This guide walks you through deploying BlowJobs.ai to **Railway** (backend + database) and **Netlify** (frontend) - **completely FREE** with no payment info required!

**Time estimate:** 20-30 minutes

---

## ✅ Prerequisites

- [ ] Code pushed to GitHub
- [ ] GitHub account
- [ ] Flutter installed on your computer (for building frontend)

---

## 🚂 Step 1: Deploy Backend to Railway

### 1.1 Sign Up / Log In to Railway

1. Go to: **https://railway.app**
2. Click **"Start a New Project"** or **"Log In"**
3. Sign up with **GitHub** (click "Deploy from GitHub repo")
4. **No payment info required!** Railway gives you $5/month free credit

### 1.2 Create New Project

1. After signing in, click **"New Project"**
2. Select **"Deploy from GitHub repo"**
3. Authorize Railway to access your GitHub (if prompted)
4. Select your repository: **`jlautman1/blowjobs.ail`**
5. Railway will start detecting your project

### 1.3 Add PostgreSQL Database

1. In your Railway project dashboard, click **"+ New"** button
2. Select **"Database"** → **"Add PostgreSQL"**
3. Railway automatically creates a PostgreSQL database
4. **Wait 1-2 minutes** for database to be provisioned

### 1.4 Configure Backend Service

Railway should auto-detect your Go backend, but let's verify settings:

1. Click on the **backend service** (or create one if not auto-created)
2. Go to **"Settings"** tab
3. Configure:

   **Service Settings:**
   - **Root Directory:** `backend`
   - **Build Command:** `go mod download && go build -o server ./cmd/server`
   - **Start Command:** `./server`

   **Environment Variables:**
   Click **"Variables"** tab and add:

   - **Key:** `PORT` → **Value:** `${{PORT}}` (Railway provides this automatically)
   - **Key:** `GIN_MODE` → **Value:** `release`
   - **Key:** `DATABASE_URL` → **Value:** Click **"Reference Variable"** → Select your PostgreSQL database → Choose `DATABASE_URL`
   - **Key:** `JWT_SECRET` → **Value:** (generate a random string, e.g., `your-super-secret-jwt-key-12345`)
   - **Key:** `ENVIRONMENT` → **Value:** `production`

4. Railway will **auto-deploy** when you save changes

### 1.5 Wait for Deployment

- Railway builds your backend (5-10 minutes first time)
- Watch the build logs in real-time
- When done, you'll see: **"Deployed successfully"**

### 1.6 Get Your Backend URL

1. In your backend service, click **"Settings"** tab
2. Scroll to **"Networking"** section
3. Click **"Generate Domain"** (if not already generated)
4. Your backend URL will be something like:
   - `https://blowjobs-backend-production.up.railway.app`
5. **API endpoint:** `https://YOUR-BACKEND-URL.up.railway.app/api/v1`
6. **📝 Write this URL down!** You'll need it for the frontend.

### 1.7 Test Backend

Open in browser:
```
https://YOUR-BACKEND-URL.up.railway.app/health
```

Should return: `{"status":"healthy","service":"blowjobs-ai-api"}`

### 1.8 Run Migrations & Seed Data

**Option A: Using Railway CLI (Recommended)**

1. Install Railway CLI:
   ```bash
   # Windows (PowerShell)
   iwr https://railway.app/install.sh | iex
   
   # Or download from: https://railway.app/cli
   ```

2. Login:
   ```bash
   railway login
   ```

3. Link to your project:
   ```bash
   railway link
   # Select your project
   ```

4. Run migrations:
   ```bash
   cd backend
   railway run go run ./cmd/server
   # Wait for it to start, then Ctrl+C
   ```

5. Seed data:
   ```bash
   railway run go run ./cmd/seed
   ```

**Option B: Using Local Terminal with DATABASE_URL**

1. In Railway dashboard, go to your PostgreSQL database
2. Click **"Variables"** tab
3. Copy the `DATABASE_URL` value
4. On your computer, set it:
   ```bash
   # Windows PowerShell
   $env:DATABASE_URL="YOUR_DATABASE_URL_FROM_RAILWAY"
   ```
5. Run migrations:
   ```bash
   cd backend
   go run ./cmd/server
   # Wait, then Ctrl+C
   ```
6. Seed data:
   ```bash
   go run ./cmd/seed
   ```

**Option C: One-Off Service (Easiest)**

1. In Railway dashboard, click **"+ New"** → **"Empty Service"**
2. Name it: `migrations`
3. Set **Root Directory:** `backend`
4. Add environment variable: `DATABASE_URL` (reference from PostgreSQL)
5. In **"Deployments"** tab, click **"..."** → **"Run Command"**
6. Enter: `go run ./cmd/server`
7. Wait, then run: `go run ./cmd/seed`
8. Delete this service after seeding (optional)

---

## 🎨 Step 2: Deploy Frontend to Netlify

### 2.1 Build Frontend Locally

On your Windows computer, in the project folder:

```bash
cd frontend
flutter build web --release --no-tree-shake-icons --dart-define=API_URL=https://YOUR-BACKEND-URL.up.railway.app/api/v1
```

**Replace `YOUR-BACKEND-URL` with your actual Railway URL!**

Example:
```bash
flutter build web --release --no-tree-shake-icons --dart-define=API_URL=https://blowjobs-backend-production.up.railway.app/api/v1
```

This creates `frontend/build/web/` folder.

### 2.2 Sign Up / Log In to Netlify

1. Go to: **https://app.netlify.com**
2. Click **"Sign up"** or **"Log in"**
3. Sign up with **GitHub** (easiest)
4. **No payment required!**

### 2.3 Deploy Frontend (Drag & Drop Method - Easiest)

1. In Netlify dashboard, find the drag & drop area that says:
   - **"Want to deploy a new site without connecting to Git? Drag and drop your site output folder here"**
2. Open **File Explorer** on Windows
3. Navigate to: `C:\Users\jlaut\OneDrive\Desktop\Projects\get-higered\frontend\build\web`
4. **Drag the entire `web` folder** onto Netlify
5. Wait for upload (1-2 minutes)

### 2.4 Get Your Frontend URL

Once upload completes:

- Netlify gives you a URL like: `https://random-name-12345.netlify.app`
- **📝 Write this URL down!**

### 2.5 (Optional) Change Site Name

1. In Netlify dashboard, go to **Site settings**
2. Click **"Change site name"**
3. Choose a custom name, e.g.: `blowjobs-ai`
4. Your new URL: `https://blowjobs-ai.netlify.app`

### 2.6 (Optional) Set Up Auto-Deploy from GitHub

For future updates, you can connect GitHub:

1. In Netlify dashboard, click **"Add new site"** → **"Import an existing project"**
2. Connect GitHub and select your repository
3. Settings:
   - **Build command:** `cd frontend && flutter build web --release --no-tree-shake-icons --dart-define=API_URL=https://YOUR-BACKEND-URL.up.railway.app/api/v1`
   - **Publish directory:** `frontend/build/web`
4. Click **"Deploy site"**

Now every time you push to GitHub, Netlify auto-deploys!

---

## ✅ Step 3: Test Your Deployed App

### 3.1 Test Backend

Open in browser:
```
https://YOUR-BACKEND-URL.up.railway.app/health
```

Should return: `{"status":"healthy","service":"blowjobs-ai-api"}`

### 3.2 Test Frontend

Open in browser:
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

## 🔄 Step 4: Future Updates

### Update Backend

1. Make code changes
2. Push to GitHub:
   ```bash
   git add .
   git commit -m "Update backend"
   git push
   ```
3. Railway **auto-deploys** (or trigger manual deploy in dashboard)

### Update Frontend

**If using drag & drop:**
1. Make code changes
2. Rebuild:
   ```bash
   cd frontend
   flutter build web --release --no-tree-shake-icons --dart-define=API_URL=https://YOUR-BACKEND-URL.up.railway.app/api/v1
   ```
3. Drag new `build/web` folder to Netlify

**If using GitHub auto-deploy:**
1. Make code changes
2. Push to GitHub:
   ```bash
   git add .
   git commit -m "Update frontend"
   git push
   ```
3. Netlify **auto-deploys**

---

## 💰 Railway Pricing & Limits

### Free Tier ($5/month credit)

- **$5 free credit** every month
- **Resets monthly** (doesn't roll over)
- **Typical usage:**
  - Backend: ~$2-3/month
  - Database: ~$1-2/month
  - **Total: Usually under $5/month** ✅

### What Happens If You Exceed $5?

- Railway will **notify you** via email
- You can either:
  - Wait for next month (credit resets)
  - Add payment method (only charged for overages)
  - **No payment info required** to use free credit!

---

## 🐛 Troubleshooting

### Backend won't start

- Check Railway logs (in dashboard → "Deployments" → click on deployment)
- Verify `DATABASE_URL` environment variable is set correctly
- Make sure database is running (check in Railway dashboard)

### Database connection fails

- Verify `DATABASE_URL` is referenced correctly (use "Reference Variable" in Railway)
- Check database is provisioned (should show "Active" status)
- Make sure migrations ran successfully

### Frontend shows blank page

- Check browser console (F12) for errors
- Verify API URL is correct in build command
- Make sure backend is accessible (test `/health` endpoint)
- Check CORS settings (backend already allows all origins)

### CORS errors

- Backend already allows all origins (`*`)
- If issues persist, check Railway logs for errors

### Railway service keeps restarting

- Check logs for errors
- Verify all environment variables are set
- Make sure build command completes successfully

---

## 📝 Summary

**Backend:** `https://YOUR-BACKEND-URL.up.railway.app`  
**Frontend:** `https://YOUR-FRONTEND-URL.netlify.app`  
**Cost:** $0/month (free credit covers it)  
**Payment Info:** Not required! 🎉

**Share the frontend URL with your colleague - they can access it from anywhere!** 🚀

---

## 🆘 Need Help?

- Railway docs: https://docs.railway.app
- Railway Discord: https://discord.gg/railway
- Netlify docs: https://docs.netlify.com

---

**Good luck! 🚀**

