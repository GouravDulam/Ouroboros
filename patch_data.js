const fs = require('fs');
const path = require('path');

const puzzlesPath = path.join(__dirname, 'client', 'src', 'parsed_puzzles.json');
const dataPath = path.join(__dirname, 'client', 'src', 'data.js');

let puzzles = JSON.parse(fs.readFileSync(puzzlesPath, 'utf-8'));

const firstPuzzle = puzzles.find(p => p.id === 'L0-0');
let otherPuzzles = puzzles.filter(p => p.id !== 'L0-0');

// Shuffle the other puzzles randomly
otherPuzzles.sort(() => Math.random() - 0.5);

// Reassemble with L0-0 at the start
puzzles = [firstPuzzle, ...otherPuzzles];

// Assign progressive levels to the randomized puzzles
puzzles.forEach((p, idx) => {
  if (p && p.id === 'L0-0') {
    p.lv = 0;
  } else if (p) {
    p.lv = Math.min(60, Math.ceil(idx / ((puzzles.length - 1) / 60)));
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
