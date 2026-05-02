@echo off
echo Committing and pushing all recent changes to GitHub...
git add .
git commit -m "Update Netlify config and settings"
git push

echo.
echo Done! Netlify should start rebuilding automatically in a few seconds.
pause
