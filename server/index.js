const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');

const app = express();
app.use(cors());

const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: '*', // For dev
    methods: ['GET', 'POST']
  }
});

// Store player state.
// Map of socket.id -> { id, name, maxLv, score, solved, cps, status }
const players = new Map();
let totalSoulsConsumed = 4194303;

io.on('connection', (socket) => {
  console.log(`[+] Client connected: ${socket.id}`);
  
  // New player joins
  socket.on('join', (data) => {
    players.set(socket.id, {
      id: socket.id,
      name: data.name || 'UNKNOWN',
      maxLv: 1,
      score: 0,
      solved: 0,
      cps: 0,
      status: 'active' // 'active', 'dead', 'won'
    });
    totalSoulsConsumed++;
    
    // Broadcast updated leaderboard
    broadcastLeaderboard();
  });
  
  // Player updates their progress
  socket.on('progress', (data) => {
    const player = players.get(socket.id);
    if (player) {
      player.maxLv = data.maxLv;
      player.score = data.score;
      player.solved = data.solved;
      player.cps = data.cps;
      broadcastLeaderboard();
    }
  });
  
  // Player dies or severs
  socket.on('die', () => {
    const player = players.get(socket.id);
    if (player) {
      player.status = 'dead';
      broadcastLeaderboard();
    }
  });

  // Player wins
  socket.on('win', () => {
    const player = players.get(socket.id);
    if (player) {
      player.status = 'won';
      broadcastLeaderboard();
    }
  });
  
  socket.on('disconnect', () => {
    console.log(`[-] Client disconnected: ${socket.id}`);
    players.delete(socket.id);
    broadcastLeaderboard();
  });
});

function broadcastLeaderboard() {
  const activePlayers = Array.from(players.values());
  // Sort by score descending
  activePlayers.sort((a, b) => b.score - a.score);
  
  io.emit('leaderboard', {
    players: activePlayers,
    totalSouls: totalSoulsConsumed
  });
}

// Throttle leaderboard broadcasts
let lastBroadcast = 0;
setInterval(() => {
  if (Date.now() - lastBroadcast > 2000) {
    broadcastLeaderboard();
    lastBroadcast = Date.now();
  }
}, 2000);

const PORT = process.env.PORT || 3001;
server.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
});
