# Fix Netlify Build Error

## 🐛 Problem

Netlify build is failing with:
```
bash: line 1: cd: frontend: No such file or directory
```

## ✅ Solution

The issue is that Netlify's base directory is already set to `frontend`, so the build command shouldn't include `cd frontend`.

### Option 1: Update Build Command in Netlify Dashboard (Recommended)

1. Go to https://app.netlify.com
2. Click on your site
3. Go to **Site settings** → **Build & deploy** → **Build settings**
4. Update the **Build command** to:
   ```bash
   flutter build web --release --no-tree-shake-icons --dart-define=API_URL=https://blowjobs-backend-production.up.railway.app/api/v1
   ```
   **Remove `cd frontend &&` from the beginning!**

5. Make sure **Base directory** is set to: `frontend`
6. Make sure **Publish directory** is set to: `build/web`

7. Click **Save**
8. Go to **Deploys** tab and click **Trigger deploy** → **Deploy site**

### Option 2: Use netlify.toml (Alternative)

I've created a `netlify.toml` file in the repo root. After you push it, Netlify will use these settings automatically.

**To use this:**
1. The file is already created at the repo root
2. Push it to git:
   ```bash
   git add netlify.toml
   git commit -m "fix: update netlify build configuration"
   git push
   ```
3. Netlify will automatically use these settings on the next deploy

## 📝 Correct Settings

**Base directory:** `frontend`  
**Build command:** `flutter build web --release --no-tree-shake-icons --dart-define=API_URL=https://blowjobs-backend-production.up.railway.app/api/v1`  
**Publish directory:** `build/web`

## ✅ After Fixing

1. Trigger a new deploy in Netlify
2. Wait for build to complete
3. Check your site - the new vibrant design should be live!

