@echo off
echo Starting Ouroboros Server...
start "Ouroboros Server" cmd /k "cd server && npm install && node index.js"

echo Starting Ouroboros Client...
start "Ouroboros Client" cmd /k "cd client && npm install && npm run dev"

echo Development servers are starting in new windows.
