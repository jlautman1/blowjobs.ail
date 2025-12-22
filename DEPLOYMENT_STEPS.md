# 🚀 Quick Deployment Steps - Render + Netlify

Follow these steps to deploy your app for FREE.

---

## ✅ Step 1: Push Code to GitHub (If Not Already Done)

Make sure your code is on GitHub:

```bash
git add .
git commit -m "Add Render deployment files"
git push origin main
```

---

## 🌐 Step 2: Deploy Backend to Render

### 2.1 Sign Up / Log In to Render

1. Go to: **https://render.com**
2. Click **"Get Started for Free"** or **"Sign In"**
3. Sign up with **GitHub** (easiest)

### 2.2 Create New Blueprint

1. In Render dashboard, click **"New +"** button (top right)
2. Select **"Blueprint"**
3. Connect your GitHub account (if not already connected)
4. Select repository: **`jlautman1/blowjobs.ail`**
5. Render will detect `render.yaml` automatically
6. Click **"Apply"**

### 2.3 Wait for Deployment

- Render will:
  - Create a PostgreSQL database
  - Build your Go backend
  - Deploy everything
- **Time:** 5-10 minutes
- You'll see build logs in real-time

### 2.4 Get Your Backend URL

Once deployment completes:

1. Go to **Dashboard** → **Services**
2. Click on **"blowjobs-backend"**
3. Your backend URL is at the top, e.g.:
   - `https://blowjobs-backend.onrender.com`
4. **API endpoint:** `https://blowjobs-backend.onrender.com/api/v1`

**📝 Write this URL down!** You'll need it for the frontend.

### 2.5 Run Migrations & Seed Data

1. In Render dashboard, go to your backend service
2. Click **"Shell"** tab (or use "Manual Deploy" → "Run Command")
3. Run:

```bash
go run ./cmd/server
```

Wait for it to start (you'll see "Server starting on port..."), then press `Ctrl+C` to stop.

Then run:

```bash
go run ./cmd/seed
```

You should see messages about creating users, jobs, etc.

**Alternative:** You can also SSH into the service and run these commands.

---

## 🎨 Step 3: Deploy Frontend to Netlify

### 3.1 Build Frontend Locally

On your Windows computer, in the project folder:

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

### 3.2 Sign Up / Log In to Netlify

1. Go to: **https://app.netlify.com**
2. Click **"Sign up"** or **"Log in"**
3. Sign up with **GitHub** (easiest)

### 3.3 Deploy Frontend (Drag & Drop Method)

1. In Netlify dashboard, find the area that says:
   - **"Want to deploy a new site without connecting to Git? Drag and drop your site output folder here"**
2. Open File Explorer on Windows
3. Navigate to: `C:\Users\jlaut\OneDrive\Desktop\Projects\get-higered\frontend\build\web`
4. **Drag the entire `web` folder** onto Netlify
5. Wait for upload (1-2 minutes)

### 3.4 Get Your Frontend URL

Once upload completes:

- Netlify gives you a URL like: `https://random-name-12345.netlify.app`
- **📝 Write this URL down!**

### 3.5 (Optional) Change Site Name

1. In Netlify dashboard, go to **Site settings**
2. Click **"Change site name"**
3. Choose a custom name, e.g.: `blowjobs-ai`
4. Your new URL: `https://blowjobs-ai.netlify.app`

---

## ✅ Step 4: Test Your Deployed App

### 4.1 Test Backend

Open in browser:
```
https://YOUR-BACKEND-URL.onrender.com/health
```

Should return: `{"status":"healthy","service":"blowjobs-ai-api"}`

### 4.2 Test Frontend

Open in browser:
```
https://YOUR-FRONTEND-URL.netlify.app
```

Try logging in:
- Email: `jobseeker@demo.com`
- Password: `demo123`

### 4.3 Test on iPhone

1. Open Safari on iPhone
2. Go to: `https://YOUR-FRONTEND-URL.netlify.app`
3. Should work from anywhere! 🎉

---

## 🔄 Step 5: Future Updates

### Update Backend

1. Make code changes
2. Push to GitHub:
   ```bash
   git add .
   git commit -m "Update backend"
   git push
   ```
3. Render **auto-deploys** (or trigger manual deploy in dashboard)

### Update Frontend

1. Make code changes
2. Rebuild:
   ```bash
   cd frontend
   flutter build web --release --no-tree-shake-icons --dart-define=API_URL=https://YOUR-BACKEND-URL.onrender.com/api/v1
   ```
3. Drag new `build/web` folder to Netlify (or use GitHub integration for auto-deploy)

---

## 🐛 Troubleshooting

### Backend won't start

- Check Render logs (in dashboard)
- Make sure database is connected
- Verify `DATABASE_URL` environment variable

### Frontend shows blank page

- Check browser console (F12) for errors
- Verify API URL is correct in build command
- Make sure backend is accessible (test `/health` endpoint)

### CORS errors

- Backend already allows all origins (`*`)
- If issues persist, check Render logs

### First request is slow (30-60 seconds)

- This is normal on free tier (spins down after 15 min)
- First request "wakes up" the server
- Subsequent requests are fast
- **Solution:** Upgrade to paid tier ($7/month) for always-on

---

## 📝 Summary

**Backend:** `https://YOUR-BACKEND-URL.onrender.com`  
**Frontend:** `https://YOUR-FRONTEND-URL.netlify.app`  
**Cost:** $0/month (free tier)

**Share the frontend URL with your colleague - they can access it from anywhere!** 🚀

