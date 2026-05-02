# 🐍 Ouroboros Hosting Guide

This document provides instructions on how to host the Ouroboros multiplayer game. Since the project consists of a **React frontend** (Vite) and a **Node.js backend** (Socket.io), we recommend a split hosting strategy for the best performance and reliability.

## 1. Push to GitHub
I have already initialized a Git repository and made the initial commit for you. To sync it with your GitHub account:

1. Create a new **empty repository** on [GitHub](https://github.com/new) named `Ouroboros`.
2. Copy the **HTTPS URL** (e.g., `https://github.com/YOUR_USERNAME/Ouroboros.git`).
3. Run the following commands in your terminal:
   ```powershell
   git remote add origin https://github.com/YOUR_USERNAME/Ouroboros.git
   git push -u origin main
   ```

---

## 2. Host the Backend (Server)
The backend handles real-time multiplayer logic using WebSockets.

**Recommended Platform:** [Render](https://render.com/) (Web Service)

1. Sign up/Log in to Render and click **New > Web Service**.
2. Connect your GitHub repository.
3. **Configuration:**
   - **Name:** `ouroboros-server`
   - **Root Directory:** `server`
   - **Runtime:** `Node`
   - **Build Command:** `npm install`
   - **Start Command:** `node index.js`
4. **Environment Variables:**
   - Add `PORT` = `3001` (or leave as default, Render provides it).
5. Once deployed, copy your service URL (e.g., `https://ouroboros-server.onrender.com`).

---

## 3. Host the Frontend (Client)
The frontend is a Vite/React application.

**Recommended Platform:** [Vercel](https://vercel.com/) or [Render (Static Site)](https://render.com/)

### If using Vercel:
1. Sign up/Log in to Vercel and click **Add New > Project**.
2. Import your GitHub repository.
3. **Configuration:**
   - **Root Directory:** `client`
   - **Framework Preset:** `Vite`
   - **Build Command:** `npm run build`
   - **Output Directory:** `dist`
4. **CRITICAL STEP:** You must tell the client where the server is.
   - Go to `client/src/App.jsx` (or wherever you initialize socket.io).
   - Change the connection URL to your Backend URL from Step 2.
   - *Example:* `const socket = io("https://ouroboros-server.onrender.com");`

---

## 4. Local Testing
To run both locally for testing:
1. **Terminal 1 (Server):**
   ```powershell
   cd server
   npm install
   node index.js
   ```
2. **Terminal 2 (Client):**
   ```powershell
   cd client
   npm install
   npm run dev
   ```

---

## ⚡ Deployment Checklist
- [ ] Backend deployed and reachable.
- [ ] Frontend updated with the Backend's production URL.
- [ ] CORS settings in `server/index.js` updated to include your frontend domain (for security).
