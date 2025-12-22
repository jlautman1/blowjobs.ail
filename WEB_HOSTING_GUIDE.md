# 🌐 Web Hosting Guide - Deploy BlowJobs.ai to the Internet

This guide shows how to host the BlowJobs.ai web app so it's accessible from anywhere (not just same WiFi).

**We'll cover:**
1. Hosting the **backend** (Go API + PostgreSQL)
2. Hosting the **frontend** (Flutter web app)
3. Connecting them together

**Time estimate:** 30-60 minutes

---

## 🎯 Overview: What We're Doing

```
┌─────────────────┐         ┌──────────────────┐
│  Backend API    │         │  Frontend (Web)   │
│  (Go + Postgres)│         │  (Flutter Web)    │
│  on Render/     │◄────────┤  on Netlify/      │
│  Railway/etc    │         │  Vercel/etc       │
└─────────────────┘         └──────────────────┘
     Public URL                  Public URL
  api.yourdomain.com         yourdomain.com
```

---

## Option 1: Render (Easiest - Recommended for Beginners)

Render is beginner-friendly and has a free tier.

### Part A: Host Backend on Render

#### Step 1: Prepare Backend for Deployment

1. **Create a `render.yaml` file** in the project root:

```yaml
services:
  - type: web
    name: blowjobs-backend
    env: go
    buildCommand: cd backend && go build -o server ./cmd/server
    startCommand: ./server
    envVars:
      - key: DATABASE_URL
        fromDatabase:
          name: blowjobs-db
          property: connectionString
      - key: PORT
        value: 10000
      - key: GIN_MODE
        value: release

databases:
  - name: blowjobs-db
    databaseName: blowjobs
    user: blowjobs_user
```

2. **Create a `Procfile`** in the `backend/` directory:

```
web: ./server
```

3. **Update backend to use PORT environment variable:**

In `backend/cmd/server/main.go`, make sure it reads PORT:

```go
port := os.Getenv("PORT")
if port == "" {
    port = "8080"
}
```

(It should already do this, but verify)

#### Step 2: Push to GitHub

Make sure your code is on GitHub:

```bash
git add .
git commit -m "Prepare for Render deployment"
git push origin main
```

#### Step 3: Deploy on Render

1. Go to: https://render.com
2. Sign up (free) or log in
3. Click **"New +"** → **"Blueprint"**
4. Connect your GitHub account
5. Select your repository: `jlautman1/blowjobs.ail`
6. Render will detect `render.yaml` and create services
7. Click **"Apply"**

**What happens:**
- Render creates:
  - A PostgreSQL database
  - A web service for your backend
- Build takes 5-10 minutes
- You'll get a URL like: `https://blowjobs-backend.onrender.com`

#### Step 4: Run Migrations & Seed Data

Once backend is deployed:

1. Go to your backend service in Render dashboard
2. Click **"Shell"** tab
3. Run:

```bash
cd backend
go run ./cmd/server
# Wait for migrations, then Ctrl+C
go run ./cmd/seed
```

Or use Render's **"Manual Deploy"** with a one-off command.

#### Step 5: Get Your Backend URL

In Render dashboard:
- Your backend URL is: `https://blowjobs-backend.onrender.com`
- API endpoint: `https://blowjobs-backend.onrender.com/api/v1`

**Write this down!** You'll need it for the frontend.

---

### Part B: Host Frontend on Netlify

#### Step 1: Build Frontend with Production API URL

On your computer (Windows is fine):

```bash
cd frontend
flutter build web --release --no-tree-shake-icons \
  --dart-define=API_URL=https://blowjobs-backend.onrender.com/api/v1
```

This creates `frontend/build/web/` folder.

#### Step 2: Deploy to Netlify

**Option A: Drag & Drop (Easiest)**

1. Go to: https://app.netlify.com
2. Sign up (free) or log in
3. Drag the `frontend/build/web` folder onto Netlify dashboard
4. Wait for upload (1-2 minutes)
5. You'll get a URL like: `https://random-name-12345.netlify.app`

**Option B: GitHub Integration (Better for updates)**

1. In Netlify: **"Add new site" → "Import an existing project"**
2. Connect GitHub
3. Select repository
4. Settings:
   - **Build command:** `cd frontend && flutter build web --release --no-tree-shake-icons --dart-define=API_URL=https://blowjobs-backend.onrender.com/api/v1`
   - **Publish directory:** `frontend/build/web`
5. Click **"Deploy site"**

#### Step 3: Update API URL in Netlify (If Needed)

If you used Option A (drag & drop), you need to rebuild with the correct API URL.

**Better approach:** Use environment variable in Netlify:

1. In Netlify dashboard: **Site settings → Environment variables**
2. Add: `API_URL` = `https://blowjobs-backend.onrender.com/api/v1`
3. Update build command to use it:

```bash
cd frontend && flutter build web --release --no-tree-shake-icons --dart-define=API_URL=$API_URL
```

---

## Option 2: Railway (Alternative - Also Easy)

Railway is another good option with a simple setup.

### Part A: Host Backend on Railway

1. Go to: https://railway.app
2. Sign up with GitHub
3. **"New Project" → "Deploy from GitHub repo"**
4. Select your repository
5. Railway auto-detects Go
6. Add PostgreSQL:
   - Click **"+ New"** → **"Database"** → **"PostgreSQL"**
7. Connect database to your service:
   - In your service settings, add environment variable:
     - `DATABASE_URL` = (Railway provides this automatically)
8. Deploy!

Railway gives you a URL like: `https://blowjobs-backend.up.railway.app`

### Part B: Host Frontend on Vercel

1. Go to: https://vercel.com
2. Sign up with GitHub
3. **"Add New Project"** → Import your repo
4. Settings:
   - **Framework Preset:** Other
   - **Build Command:** `cd frontend && flutter build web --release --no-tree-shake-icons --dart-define=API_URL=https://blowjobs-backend.up.railway.app/api/v1`
   - **Output Directory:** `frontend/build/web`
5. Deploy!

---

## Option 3: All-in-One on Fly.io

Fly.io can host both backend and frontend.

### Step 1: Install Fly CLI

```bash
# Windows (PowerShell)
iwr https://fly.io/install.ps1 -useb | iex

# macOS
curl -L https://fly.io/install.sh | sh
```

### Step 2: Sign Up

```bash
fly auth signup
```

### Step 3: Create Backend App

```bash
cd backend
fly launch
```

Follow prompts:
- App name: `blowjobs-backend` (or your choice)
- Region: Choose closest to you
- PostgreSQL: Yes (Fly creates it)
- Deploy: Yes

### Step 4: Create Frontend App

```bash
cd ../frontend
fly launch
```

- App name: `blowjobs-frontend`
- Build command: `flutter build web --release --no-tree-shake-icons --dart-define=API_URL=https://blowjobs-backend.fly.dev/api/v1`
- Output directory: `build/web`

---

## 🔧 Important: CORS Configuration

Your backend needs to allow requests from your frontend domain.

### Update Backend CORS Settings

In `backend/internal/api/server.go`, find CORS middleware and update:

```go
config := cors.DefaultConfig()
config.AllowOrigins = []string{
    "https://your-frontend-domain.netlify.app",
    "https://your-frontend-domain.vercel.app",
    // Add your actual frontend URL
}
config.AllowCredentials = true
```

Or for development, allow all (not recommended for production):

```go
config.AllowAllOrigins = true
```

Rebuild and redeploy backend after this change.

---

## 🧪 Testing Your Deployed App

### 1. Test Backend

Open in browser:
```
https://your-backend-url.onrender.com/health
```

Should return: `{"status":"ok"}`

### 2. Test Frontend

Open in browser:
```
https://your-frontend-url.netlify.app
```

Try logging in with demo accounts:
- `jobseeker@demo.com` / `demo123`
- `recruiter@demo.com` / `demo123`

### 3. Test on iPhone

1. Open Safari on iPhone
2. Go to: `https://your-frontend-url.netlify.app`
3. Should work from anywhere (not just same WiFi)!

---

## 🔄 Updating Your Deployed App

### Update Backend

1. Make code changes
2. Push to GitHub:
   ```bash
   git add .
   git commit -m "Update backend"
   git push
   ```
3. Render/Railway/Fly auto-deploys (or trigger manual deploy)

### Update Frontend

1. Make code changes
2. Rebuild:
   ```bash
   cd frontend
   flutter build web --release --no-tree-shake-icons \
     --dart-define=API_URL=https://your-backend-url.com/api/v1
   ```
3. **If using drag & drop:** Drag new `build/web` folder to Netlify
4. **If using GitHub:** Push changes, Netlify auto-deploys

---

## 💰 Cost Estimates

### Free Tier (Good for Testing)

- **Render:** Free tier (spins down after 15 min inactivity)
- **Netlify:** Free tier (100GB bandwidth/month)
- **Railway:** $5/month free credit
- **Vercel:** Free tier (generous limits)
- **Fly.io:** Free tier (limited resources)

**Total:** $0-5/month for testing

### Production (Recommended)

- **Render:** $7/month (always-on backend)
- **Netlify Pro:** $19/month (or stay free if low traffic)
- **Database:** Included or $7/month

**Total:** ~$15-30/month

---

## 🎯 Recommended Setup for You

**Best for beginners:**
1. **Backend:** Render (easiest setup, free tier)
2. **Frontend:** Netlify (drag & drop is simplest)

**Steps:**
1. Follow **Option 1: Render** for backend
2. Follow **Part B: Netlify** for frontend
3. Test on your iPhone from anywhere!

---

## 🐛 Troubleshooting

### "CORS error" in browser

**Solution:** Update CORS settings in backend (see CORS section above)

### Backend returns 404

**Solution:** 
- Check your API routes start with `/api/v1`
- Verify backend URL is correct in frontend build

### Database connection fails

**Solution:**
- Check `DATABASE_URL` environment variable in Render/Railway
- Make sure database is running
- Verify migrations ran

### Frontend shows blank page

**Solution:**
- Check browser console for errors
- Verify API URL is correct
- Make sure backend is accessible (test `/health` endpoint)

---

## 📝 Quick Checklist

- [ ] Backend deployed and accessible
- [ ] Database migrations run
- [ ] Demo data seeded
- [ ] Frontend built with correct API URL
- [ ] Frontend deployed
- [ ] CORS configured
- [ ] Tested on computer browser
- [ ] Tested on iPhone from different network

---

## 🆘 Need Help?

- Render docs: https://render.com/docs
- Netlify docs: https://docs.netlify.com
- Railway docs: https://docs.railway.app
- Fly.io docs: https://fly.io/docs

---

**Good luck! 🚀**

