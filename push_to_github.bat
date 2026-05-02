@echo off
echo Fixing GitHub connection to point to your account (GouravDulam)...
git remote set-url origin https://github.com/GouravDulam/Ouroboros.git

echo Committing and pushing all recent changes to GitHub...
git add .
git commit -m "Update Netlify config and settings"
git push -u origin main

echo.
echo Done! Netlify should start rebuilding automatically in a few seconds.
pause
