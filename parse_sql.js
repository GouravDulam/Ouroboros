const fs = require('fs');
const path = require('path');

const seedSql = fs.readFileSync(path.join(__dirname, 'assets', 'ouroboros_seed.sql'), 'utf-8');
const progSql = fs.readFileSync(path.join(__dirname, 'assets', 'ouroboros_programming_puzzles.sql'), 'utf-8');

const regex = /\(\s*'([^']+(?:''[^']+)*)'\s*,\s*'([^']+)'\s*,\s*'([^']+(?:''[^']+)*)'\s*,\s*'([^']+)'\s*,\s*(\d+)/g;

const flavorPrefixes = [
  "THE SERPENT WHISPERS: ",
  "A VOICE FROM THE DARKNESS: ",
  "THE SCALES SHIFT: ",
  "A VISION IN THE BLOOD: ",
  "THE CYCLE DEMANDS: ",
  "CARVED IN BONE: ",
  "A GLITCH IN THE FLESH: "
];

const puzzles = [];
let idCounter = 1;

function processSql(sql, isProg) {
  let match;
  while ((match = regex.exec(sql)) !== null) {
    let [_, question, answer, hint, type, difficulty] = match;
    
    if (
      type === 'MORSE' || question.toUpperCase().includes('MORSE') || 
      type === 'XOR' || question.toUpperCase().includes('XOR') ||
      question.toUpperCase().includes('BOSS')
    ) {
      continue;
    }

    question = question.replace(/''/g, "'");
    hint = hint.replace(/''/g, "'");
    
    let q = question;
    if (!q.includes('FINAL BOSS') && !q.includes('MINI BOSS') && !q.includes('BOSS SUPPLEMENT')) {
       const prefix = flavorPrefixes[Math.floor(Math.random() * flavorPrefixes.length)];
       q = prefix + q;
    }
    
    let lv;
    const diff = parseInt(difficulty);
    if (isProg) {
      // Map programming difficulty 3-5 to levels 8-60
      lv = 8 + Math.floor(((diff - 3) / 2.5) * 52) + Math.floor(Math.random() * 5);
    } else {
      // Map seed difficulty 1-5 to levels 1-20
      lv = (diff - 1) * 4 + 1 + Math.floor(Math.random() * 4);
    }

    puzzles.push({
      id: `PZ-${idCounter++}`,
      lv: lv,
      q: q.toUpperCase(),
      h: hint.toUpperCase(),
      a: [answer.toUpperCase()],
      type: type
    });
  }
}

processSql(seedSql, false);
processSql(progSql, true);

// Adjust levels to ensure we have exactly 1-60 covered well
puzzles.forEach(p => {
  if (p.lv < 1) p.lv = 1;
  if (p.lv > 60) p.lv = 60;
});

// Always ensure there is a starting puzzle at level 1 with a known ID
puzzles.push({
  id: 'L0-0',
  lv: 1,
  q: "THE SERPENT HUNGERS. WHAT IS ITS TRUE NAME?",
  a: ["OUROBOROS"],
  h: "THE POISON IS IN THE TAIL.",
  type: "LORE"
});

fs.writeFileSync(path.join(__dirname, 'client', 'src', 'parsed_puzzles.json'), JSON.stringify(puzzles, null, 2));
console.log(`Parsed ${puzzles.length} puzzles.`);
