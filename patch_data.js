const fs = require('fs');
const path = require('path');

const puzzlesPath = path.join(__dirname, 'client', 'src', 'parsed_puzzles.json');
const dataPath = path.join(__dirname, 'client', 'src', 'data.js');

const puzzles = JSON.parse(fs.readFileSync(puzzlesPath, 'utf-8'));

// FIX: Automatically assign progressive levels so the game doesn't crash/end instantly
// because the user set all puzzles to 'lv: 1'.
let currentLv = 1;
puzzles.forEach((p, idx) => {
  if (p.id === 'L0-0') {
    p.lv = 0;
  } else {
    // Distribute 100 puzzles across 60 levels
    p.lv = Math.min(60, Math.ceil((idx + 1) / (puzzles.length / 60)));
  }
});

let dataStr = fs.readFileSync(dataPath, 'utf-8');

const startTag = 'export const PZ=[';
const endTag = '];';

const startIndex = dataStr.indexOf(startTag);
// Find the closing bracket for PZ array
let nested = 0;
let endIndex = -1;

for (let i = startIndex + startTag.length - 1; i < dataStr.length; i++) {
  if (dataStr[i] === '[') nested++;
  if (dataStr[i] === ']') {
    nested--;
    if (nested === 0) {
      endIndex = i + 1; // include the ']'
      if (dataStr[i+1] === ';') endIndex++;
      break;
    }
  }
}

if (startIndex !== -1 && endIndex !== -1) {
  const pzString = `export const PZ=${JSON.stringify(puzzles, null, 2)};`;
  const newDataStr = dataStr.substring(0, startIndex) + pzString + dataStr.substring(endIndex);
  fs.writeFileSync(dataPath, newDataStr);
  console.log('Successfully patched data.js with ' + puzzles.length + ' puzzles.');
} else {
  console.log('Failed to find PZ array boundaries.');
}
