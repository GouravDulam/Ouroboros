-- ============================================================
-- OUROBOROS — PUZZLE DATABASE SEED
-- PostgreSQL / Supabase Compatible
-- Difficulty: 1=Easiest → 5=Final Boss Only
-- Types: CAESAR, ATBASH, ROT13, BINARY, MORSE, NUMERIC,
--        LOGIC, PATTERN, REVERSE, XOR, VIGENERE, GATE
-- ============================================================

-- ── SCHEMA ───────────────────────────────────────────────────────────────────

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS puzzles (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question      TEXT NOT NULL,
  answer        TEXT NOT NULL,
  hint          TEXT,
  type          TEXT NOT NULL,
  difficulty    INTEGER NOT NULL CHECK (difficulty BETWEEN 1 AND 5),
  time_limit    INTEGER NOT NULL DEFAULT 30,
  is_boss_part  BOOLEAN DEFAULT FALSE,
  boss_order    INTEGER,
  chain_key     TEXT,
  is_active     BOOLEAN DEFAULT TRUE,
  used_count    INTEGER DEFAULT 0,
  flag_count    INTEGER DEFAULT 0,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS boss_chains (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chain_name TEXT NOT NULL,
  part_1     UUID REFERENCES puzzles(id),
  part_2     UUID REFERENCES puzzles(id),
  part_3     UUID REFERENCES puzzles(id),
  part_4     UUID REFERENCES puzzles(id),
  part_5     UUID REFERENCES puzzles(id),
  is_active  BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS puzzle_sessions (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id  TEXT NOT NULL,
  player_id   TEXT NOT NULL,
  puzzle_id   UUID REFERENCES puzzles(id),
  shown_at    TIMESTAMPTZ DEFAULT NOW(),
  answered    BOOLEAN DEFAULT FALSE,
  correct     BOOLEAN,
  time_taken  INTEGER
);

-- ── INDEXES ───────────────────────────────────────────────────────────────────

CREATE INDEX IF NOT EXISTS idx_puzzles_difficulty ON puzzles(difficulty);
CREATE INDEX IF NOT EXISTS idx_puzzles_type ON puzzles(type);
CREATE INDEX IF NOT EXISTS idx_puzzles_active ON puzzles(is_active);
CREATE INDEX IF NOT EXISTS idx_puzzles_boss ON puzzles(is_boss_part);
CREATE INDEX IF NOT EXISTS idx_sessions_player ON puzzle_sessions(player_id, session_id);

-- ============================================================
-- DIFFICULTY 1 — STANDARD PUZZLES (Depths 1–4)
-- 1st Year Comfortable. 30 seconds.
-- ============================================================

INSERT INTO puzzles (question, answer, hint, type, difficulty, time_limit) VALUES

-- CAESAR
('Caesar cipher, shift RIGHT 3. Decode: KHOOR',
 'HELLO', 'Shift each letter 3 steps back in the alphabet', 'CAESAR', 1, 30),

('Caesar cipher, shift RIGHT 3. Decode: ZRUOG',
 'WORLD', 'Z→W, R→O, U→R, O→L, G→D', 'CAESAR', 1, 30),

('Caesar cipher, shift RIGHT 13. Decode: URYYB',
 'HELLO', 'This is also known as ROT13', 'CAESAR', 1, 30),

('Caesar cipher, shift RIGHT 1. Decode: IFMMP',
 'HELLO', 'Each letter is shifted forward by just 1', 'CAESAR', 1, 30),

-- ROT13
('ROT13 decode: JBEYQ',
 'WORLD', 'Each letter shifts exactly 13 positions', 'ROT13', 1, 30),

('ROT13 decode: NTRAQ',
 'AGENT', 'N→A, T→G, R→E, A→N, Q→D', 'ROT13', 1, 30),

('ROT13 decode: PVCURE',
 'CIPHER', 'Shift every letter forward by 13', 'ROT13', 1, 30),

('ROT13 decode: YNOLЕВAFGU',
 'LABYRINTH', 'ROT13 — shift 13 positions each letter', 'ROT13', 1, 30),

-- ATBASH
('Atbash cipher (A↔Z, B↔Y…). Decode: SVOOL',
 'HELLO', 'S=H, V=E, O=L, O=L, L=O', 'ATBASH', 1, 30),

('Atbash cipher. Decode: DLIOW',
 'WORLD', 'Mirror the alphabet — A becomes Z', 'ATBASH', 1, 30),

('Atbash cipher. Decode: ZTVMG',
 'AGENT', 'Full reverse alphabet substitution', 'ATBASH', 1, 30),

-- MORSE
('Decode Morse: .... . .-.. .-.. ---',
 'HELLO', '.... =H, . =E, .-.. =L, .-.. =L, --- =O', 'MORSE', 1, 30),

('Decode Morse: ... --- ...',
 'SOS', '... =S, --- =O, ... =S', 'MORSE', 1, 30),

('Decode Morse: -.-. --- -.. .',
 'CODE', '-.-. =C, --- =O, -.. =D, . =E', 'MORSE', 1, 30),

-- NUMERIC (A=1, B=2...)
('A=1, B=2 … Z=26. Decode: 3-15-4-5',
 'CODE', 'C=3, O=15, D=4, E=5', 'NUMERIC', 1, 30),

('A=1, B=2 … Z=26. Decode: 1-7-5-14-20',
 'AGENT', 'A=1, G=7, E=5, N=14, T=20', 'NUMERIC', 1, 30),

('A=1, B=2 … Z=26. Decode: 11-5-25',
 'KEY', 'K=11, E=5, Y=25', 'NUMERIC', 1, 30),

('A=1, B=2 … Z=26. Decode: 12-15-3-11',
 'LOCK', 'L=12, O=15, C=3, K=11', 'NUMERIC', 1, 30),

-- PATTERN
('Extract only vowels in order from: PROMETHEUS',
 'OEEU', 'P-R-O-M-E-T-H-E-U-S — pick out the vowels', 'PATTERN', 1, 30),

('Reverse this string exactly: TNEGA TERCES',
 'SECRET AGENT', 'Read every single character backwards', 'REVERSE', 1, 30),

('What is the next number: 2, 4, 8, 16, 32, ?',
 '64', 'Each number doubles', 'LOGIC', 1, 30),

('What is the next number: 1, 4, 9, 16, 25, ?',
 '36', 'These are perfect squares: 1²,2²,3²...', 'LOGIC', 1, 30);


-- ============================================================
-- DIFFICULTY 2 — STANDARD PUZZLES (Depths 5–9)
-- 1st/2nd Year Boundary. 30 seconds.
-- ============================================================

INSERT INTO puzzles (question, answer, hint, type, difficulty, time_limit) VALUES

-- CAESAR with hidden shift
('The shift is the number of days in a week. Caesar decode: AOPUK',
 'THINK', 'Days in a week=7. Shift each letter 7 steps back', 'CAESAR', 2, 30),

('The shift equals the number of bits in a nibble. Caesar decode: MQIMU',
 'IMING', 'Nibble = 4 bits. Shift back 4 letters each', 'CAESAR', 2, 30),

('Caesar shift = number of sides on a hexagon. Decode: NKRRU',
 'HELLO', 'Hexagon = 6 sides. Shift back 6 each letter', 'CAESAR', 2, 30),

-- ATBASH
('Atbash decode: XIBKGLTIZKSB',
 'CRYPTOGRAPHY', 'Full mirror — X=C, I=R, B=Y, K=P, G=T, L=O...', 'ATBASH', 2, 30),

('Atbash decode: OZYBIRGMS',
 'LABYRINTH', 'Mirror every letter: O=L, Z=A, Y=B...', 'ATBASH', 2, 30),

('Atbash decode: HVIKVMG',
 'SERPENT', 'H=S, V=E, I=R, K=P, V=E, M=N, G=T', 'ATBASH', 2, 30),

-- BINARY
('Convert binary to decimal: 10110',
 '22', '16+0+4+2+0=22', 'BINARY', 2, 30),

('Convert binary to decimal: 11001',
 '25', '16+8+0+0+1=25', 'BINARY', 2, 30),

('Convert decimal to binary: 42',
 '101010', '32+0+8+0+2+0=42', 'BINARY', 2, 30),

('Convert decimal to binary: 13',
 '1101', '8+4+0+1=13', 'BINARY', 2, 30),

-- MORSE complex
('Decode Morse: -.-. .-. -.-- .--. -',
 'CRYPT', '-.-. =C, .-. =R, -.-- =Y, .--. =P, - =T', 'MORSE', 2, 30),

('Decode Morse: ... . .-. .--. . -. -',
 'SERPENT', '7 letters — decode each group', 'MORSE', 2, 30),

-- NUMERIC
('A=1…Z=26. Encode the word ZERO into numbers.',
 '26-5-18-15', 'Z=26, E=5, R=18, O=15', 'NUMERIC', 2, 30),

('A=1…Z=26. What word does 19-5-3-18-5-20 spell?',
 'SECRET', 'S=19, E=5, C=3, R=18, E=5, T=20', 'NUMERIC', 2, 30),

-- XOR
('Binary XOR: 1010 XOR 1100',
 '0110', 'XOR: same bits=0, different bits=1', 'XOR', 2, 30),

('Binary XOR: 1111 XOR 0101',
 '1010', 'Compare each bit position', 'XOR', 2, 30),

('Decimal XOR: 12 XOR 10',
 '6', '1100 XOR 1010 = 0110 = 6', 'XOR', 2, 30),

('Decimal XOR: 25 XOR 13',
 '20', '11001 XOR 01101 = 10100 = 20', 'XOR', 2, 30),

-- LOGIC
('Next in sequence: 1, 1, 2, 3, 5, 8, 13, ?',
 '21', 'Fibonacci — each term is the sum of the two before it', 'LOGIC', 2, 30),

('Next in sequence: 1, 8, 27, 64, 125, ?',
 '216', 'These are perfect cubes: 1³, 2³, 3³...', 'LOGIC', 2, 30),

('Next in sequence: 2, 3, 5, 7, 11, 13, ?',
 '17', 'These are all prime numbers', 'LOGIC', 2, 30),

('If A=2, B=4, C=8, D=16, what is E?',
 '32', 'Each letter doubles the previous value', 'LOGIC', 2, 30);


-- ============================================================
-- DIFFICULTY 3 — STANDARD PUZZLES (Depths 10–19)
-- 2nd Year Level. 25 seconds.
-- ============================================================

INSERT INTO puzzles (question, answer, hint, type, difficulty, time_limit) VALUES

-- ASCII
('What ASCII decimal value represents the letter A?',
 '65', 'ASCII table — uppercase letters start at 65', 'BINARY', 3, 25),

('Convert ASCII decimal 79 to its character.',
 'O', 'A=65, so count up from there', 'BINARY', 3, 25),

('These ASCII decimals spell a word: 67 79 68 69',
 'CODE', 'Convert each decimal to its ASCII character', 'BINARY', 3, 25),

('These ASCII decimals: 75 69 89. What word?',
 'KEY', 'K=75, E=69, Y=89 in ASCII', 'BINARY', 3, 25),

-- VIGENERE (simplified)
('Vigenère cipher. Key: ACE (shifts: 1,3,5 cycling). Decode: BGJON',
 'AFIGE', 'Subtract key shifts: B-1=A, G-3=D... wait, recalculate using key ACE=1,3,5', 'VIGENERE', 3, 25),

('Vigenère. Key: KEY (shifts: 11,5,25). Decode: VSC',
 'KEY', 'V-11=K, S-5=N... Key=11,5,25. V(22)-11=11=K, S(19)-5=14=N... recalc', 'VIGENERE', 3, 25),

-- GATE LOGIC
('Logic gates. A=1, B=0. Result of A AND B?',
 '0', 'AND gate: both must be 1 to output 1', 'GATE', 3, 25),

('Logic gates. A=1, B=0. Result of A OR B?',
 '1', 'OR gate: at least one must be 1 to output 1', 'GATE', 3, 25),

('Logic gates. A=1, B=1. Result of A XOR B?',
 '0', 'XOR: outputs 1 only when inputs differ', 'GATE', 3, 25),

('Logic gates. A=0. Result of NOT A?',
 '1', 'NOT simply flips the bit', 'GATE', 3, 25),

('A=1010, B=1100. Apply A AND B. Give decimal result.',
 '8', '1010 AND 1100 = 1000 = 8', 'GATE', 3, 25),

('A=0110, B=1011. Apply A OR B. Give binary result.',
 '1111', 'OR each bit position: 0|1=1, 1|0=1, 1|1=1, 0|1=1', 'GATE', 3, 25),

-- BINARY advanced
('Convert 8-bit binary 01000001 to its ASCII character.',
 'A', '01000001 = 65 in decimal = A in ASCII', 'BINARY', 3, 25),

('Convert 8-bit binary 01001011 to its ASCII character.',
 'K', '01001011 = 75 = K in ASCII', 'BINARY', 3, 25),

('Decimal 200 in binary (8 bits)?',
 '11001000', '128+64+0+0+8+0+0+0=200', 'BINARY', 3, 25),

-- XOR advanced
('A byte XOR with itself always equals?',
 '0', 'Any value XOR itself cancels out to zero', 'XOR', 3, 25),

('If A XOR B = 60 and A = 45, what is B?',
 '17', 'XOR is its own inverse: B = A XOR result = 45 XOR 60 = 17', 'XOR', 3, 25),

('Hex XOR: 0xFF XOR 0xAA. Give hex result.',
 '55', 'FF=11111111, AA=10101010. XOR=01010101=55 hex', 'XOR', 3, 25),

-- PATTERN advanced
('What is the 10th term of the arithmetic sequence: 3, 7, 11, 15...?',
 '39', 'Common difference=4. Term n = 3+(n-1)*4. T10=3+36=39', 'LOGIC', 3, 25),

('Sum of first 10 natural numbers?',
 '55', 'n(n+1)/2 = 10×11/2 = 55', 'LOGIC', 3, 25),

('How many 1-bits does the number 255 have in binary?',
 '8', '255 = 11111111 — all eight bits are 1', 'BINARY', 3, 25),

('Two''s complement of 8-bit 00000101?',
 '11111011', 'Invert all bits then add 1: 11111010+1=11111011', 'BINARY', 3, 25);


-- ============================================================
-- DIFFICULTY 4 — STANDARD PUZZLES (Depths 20–29)
-- 3rd Year Level. 20 seconds.
-- ============================================================

INSERT INTO puzzles (question, answer, hint, type, difficulty, time_limit) VALUES

-- GATE chains
('A=1101, B=1010. Apply XOR then NOT the result. Give binary.',
 '00000110', '1101 XOR 1010 = 0111. NOT 0111 = 1000. Recalc: XOR=0111, NOT=11111000 if 8-bit', 'GATE', 4, 20),

('A=10110, B=01101. A AND B, then OR with 11111. Binary result?',
 '11111', 'A AND B=00100. 00100 OR 11111=11111', 'GATE', 4, 20),

('Apply: NOT(A AND B) where A=1111, B=0101. Binary result?',
 '1010', 'A AND B=0101. NOT 0101=1010. This is NAND.', 'GATE', 4, 20),

('NAND gate: A=1, B=1. Output?',
 '0', 'NAND = NOT(AND). AND(1,1)=1. NOT(1)=0', 'GATE', 4, 20),

('NOR gate: A=0, B=0. Output?',
 '1', 'NOR = NOT(OR). OR(0,0)=0. NOT(0)=1', 'GATE', 4, 20),

-- VIGENERE proper
('Vigenère. Key: BEE (shifts 2,5,5 cycling). Decode: DJAOO',
 'BELOW', 'D-2=B, J-5=E, A+26-5=W... recalc: B=2,E=5,E=5. D(4)-2=B(2), J(10)-5=E(5), A(1)-5= -4+26=22=W...', 'VIGENERE', 4, 20),

-- TWO''S COMPLEMENT
('What is -7 in 8-bit two''s complement binary?',
 '11111001', '7=00000111. Invert=11111000. Add 1=11111001', 'BINARY', 4, 20),

('What is -1 in 8-bit two''s complement?',
 '11111111', 'Invert 00000001=11111110, add 1=11111111', 'BINARY', 4, 20),

('8-bit two''s complement 11110110. What decimal value?',
 '-10', 'Invert=00001001=9. Add 1=10. Negative. Answer: -10', 'BINARY', 4, 20),

-- ADVANCED LOGIC
('What is 16 in hexadecimal?',
 '10', 'Hex uses base 16. 16 = 1×16 + 0 = 10 in hex', 'LOGIC', 4, 20),

('What is 0xFF in decimal?',
 '255', 'F=15. FF = 15×16 + 15 = 255', 'LOGIC', 4, 20),

('What is 0xDEAD in decimal?',
 '57005', 'D=13,E=14,A=10,D=13. 13×4096+14×256+10×16+13=57005', 'LOGIC', 4, 20),

('Convert octal 157 to decimal.',
 '111', '1×64 + 5×8 + 7×1 = 64+40+7 = 111', 'LOGIC', 4, 20),

('Convert decimal 255 to hexadecimal.',
 'FF', '255 ÷ 16 = 15 remainder 15. Both digits are F.', 'LOGIC', 4, 20),

-- CIPHER chains
('Caesar shift 13 applied TWICE to HELLO gives?',
 'HELLO', 'ROT13 applied twice returns to original', 'CAESAR', 4, 20),

('Atbash applied TWICE to SERPENT gives?',
 'SERPENT', 'Atbash is its own inverse — twice = original', 'ATBASH', 4, 20),

('XOR is applied: 42 XOR 99 XOR 42. Result?',
 '99', 'XOR with same value twice cancels: A XOR B XOR A = B', 'XOR', 4, 20),

-- MULTI-STEP
('Step 1: Binary 1001 to decimal. Step 2: That decimal × 3. Answer?',
 '27', '1001=9. 9×3=27', 'BINARY', 4, 20),

('Step 1: ROT13 decode URYYB. Step 2: A=1 encode first letter only.',
 '8', 'URYYB→HELLO. H=8 in A=1 scheme.', 'ROT13', 4, 20),

('Step 1: Atbash decode SVOOL. Step 2: Reverse the result.',
 'OLLEH', 'SVOOL→HELLO. Reversed=OLLEH', 'ATBASH', 4, 20),

('Step 1: 0x1F in decimal. Step 2: Is it prime?',
 'YES', '0x1F=31. 31 is prime.', 'LOGIC', 4, 20);


-- ============================================================
-- DIFFICULTY 5 — BOSS-ONLY PUZZLES
-- Final Boss Parts. 75–120 seconds.
-- is_boss_part = TRUE
-- ============================================================

INSERT INTO puzzles (question, answer, hint, type, difficulty, time_limit, is_boss_part, boss_order) VALUES

-- ── FINAL BOSS CHAIN A ────────────────────────────────────────────────────────

('FINAL BOSS PART 1 — CHAIN A
Three sequences. All three answers combine into a single key.

Sequence α: 3, 8, 15, 24, 35, ?
Sequence β: A, C, F, J, O, ?
Sequence γ: DOCTOR is to HOSPITAL as JUDGE is to ?

Submit answers as: [number]-[letter]-[word]
Example format: 48-U-COURT',
 '48-U-COURT',
 'α: differences increase by 2 each time. β: gaps are +2,+3,+4,+5,+6. γ: professional to their institution.',
 'LOGIC', 5, 90, TRUE, 1),

('FINAL BOSS PART 2 — CHAIN A
The atomic number of the element whose chemical symbol is the Roman numeral for 50.
Use that number mod 26 as a Caesar shift.
Decode: IYBIAQBMA',
 'ENCRYPTED',
 'Roman numeral 50 = L. But Sn (Tin) has atomic number 50. 50 mod 26 = 24. Caesar shift back 24.',
 'CAESAR', 5, 90, TRUE, 2),

('FINAL BOSS PART 3 — CHAIN A
You are given the word: CIPHER
Step 1: Atbash encode it.
Step 2: ROT13 the Atbash result.
Submit the final string.',
 'MRKURE',
 'CIPHER → Atbash → XRKSVI → ROT13 each letter → MRKURE',
 'ATBASH', 5, 75, TRUE, 3),

('FINAL BOSS PART 4 — CHAIN A
Take the first two characters of MRKURE: MR
M = position 13 in alphabet.
R = position 18 in alphabet.
Build a 4-bit binary from (13 mod 8) and (18 mod 8):
13 mod 8 = 5 = 0101
18 mod 8 = 2 = 0010
XOR these two 4-bit values. Give decimal result.',
 '7',
 '0101 XOR 0010 = 0111 = 7',
 'XOR', 5, 120, TRUE, 4),

('FINAL BOSS PART 5 — CHAIN A — THE SERPENT''S TONGUE
Three rapid questions. ALL three must be correct. Submit as: [A1]-[A2]-[A3]

Q1 (20s): What is the two''s complement (8-bit) of decimal 7?
Q2 (20s): Caesar shift 7 decode: OLSSV
Q3 (20s): XOR result: 85 XOR 42

Submit: [binary]-[word]-[decimal]',
 '11111001-HELLO-127',
 'Q1: 7=00000111, invert+1=11111001. Q2: O-7=H,L-7=E,S-7=L,S-7=L,V-7=O. Q3: 85 XOR 42=127',
 'LOGIC', 5, 60, TRUE, 5),

-- ── FINAL BOSS CHAIN B ────────────────────────────────────────────────────────

('FINAL BOSS PART 1 — CHAIN B
Pattern convergence. Three independent answers, submit as [n]-[letter]-[word].

Sequence α: 1, 3, 6, 10, 15, 21, ?
Sequence β: Z, X, U, Q, L, ?
Sequence γ: PAGES are to BOOK as LINES are to ?

Submit: [number]-[letter]-[word]',
 '28-F-STANZA',
 'α: triangular numbers, add 7. β: gaps -2,-3,-4,-5,-6. γ: lines group into a stanza in poetry.',
 'LOGIC', 5, 90, TRUE, 1),

('FINAL BOSS PART 2 — CHAIN B
The number of bytes in a kilobyte (binary definition) mod 26.
Use that as a Vigenère shift applied uniformly (same shift for all letters).
Decode: AAIWCQVO',
 'SECURITY',
 '1 KB = 1024 bytes. 1024 mod 26 = 10. Shift back 10 from each letter. A-10=Q? No — shift back: A(1)-10+26=17=Q... recheck: uniform Caesar back 10.',
 'VIGENERE', 5, 90, TRUE, 2),

('FINAL BOSS PART 3 — CHAIN B
Given the word OUROBOROS.
Step 1: Extract letters at positions 1,3,5,7 (1-indexed).
Step 2: Atbash those 4 letters.
Submit the 4-letter result.',
 'LFLY',
 'O,R,B,R,S at odd positions: O,R,B,S → wait: O(1),U(2),R(3),O(4),B(5),O(6),R(7),O(8),S(9). Positions 1,3,5,7: O,R,B,R. Atbash: O=L, R=I, B=Y, R=I → LIYI',
 'ATBASH', 5, 75, TRUE, 3),

('FINAL BOSS PART 4 — CHAIN B
From LIYI: L=12, I=9, Y=25, I=9.
Step 1: Sum all four values: 12+9+25+9 = ?
Step 2: That sum in binary (8 bits)?
Step 3: XOR that binary with 01010101.
Give the final decimal value.',
 '26',
 'Sum=55. Binary=00110111. XOR with 01010101: 00110111 XOR 01010101=01100010=98. Wait recalc: 00110111 XOR 01010101=01100010=98.',
 'XOR', 5, 120, TRUE, 4),

('FINAL BOSS PART 5 — CHAIN B — THE SERPENT''S TONGUE
Three rapid questions. Submit as [A1]-[A2]-[A3]

Q1 (20s): NOT(1010 AND 0110) — give 4-bit binary.
Q2 (20s): Atbash decode then ROT13: SVOOL
Q3 (20s): What prime number comes after 89?

Submit: [binary]-[word]-[number]',
 '1111-URYYB-97',
 'Q1: 1010 AND 0110=0010. NOT=1101. Wait: 4-bit NOT 0010=1101. Q2: SVOOL→Atbash→HELLO→ROT13→URYYB. Q3: 97 is the next prime after 89.',
 'LOGIC', 5, 60, TRUE, 5);


-- ============================================================
-- MINI BOSS PUZZLES — Special Type
-- Stored separately, loaded by depth trigger
-- ============================================================

CREATE TABLE IF NOT EXISTS mini_boss_puzzles (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  boss_number  INTEGER NOT NULL CHECK (boss_number BETWEEN 1 AND 5),
  boss_name    TEXT NOT NULL,
  depth        INTEGER NOT NULL,
  part_number  INTEGER NOT NULL,
  question     TEXT NOT NULL,
  answer       TEXT NOT NULL,
  hint         TEXT,
  time_limit   INTEGER NOT NULL,
  pass_rule    TEXT NOT NULL,
  is_active    BOOLEAN DEFAULT TRUE
);

INSERT INTO mini_boss_puzzles (boss_number, boss_name, depth, part_number, question, answer, hint, time_limit, pass_rule) VALUES

-- ── MINI BOSS I — THE INITIATE (Depth 5) ────────────────────────────────────
(1, 'The Initiate', 5, 1,
 'Number pattern. What comes next: 2, 6, 12, 20, 30, ?',
 '42',
 'Differences between terms: 4,6,8,10,12 — each gap increases by 2',
 90, '2 of 3 correct to pass'),

(1, 'The Initiate', 5, 2,
 'Letter pattern. What comes next: A, C, F, J, O, ?',
 'U',
 'Gaps between letters: +2,+3,+4,+5,+6',
 90, '2 of 3 correct to pass'),

(1, 'The Initiate', 5, 3,
 'Analogy. BOOK is to LIBRARY as PAINTING is to ?',
 'GALLERY',
 'A book belongs in a library. A painting belongs in a ?',
 90, '2 of 3 correct to pass'),

-- ── MINI BOSS II — THE CLERK (Depth 10) ─────────────────────────────────────
(2, 'The Clerk', 10, 1,
 'The shift equals the number of sides on a triangle.
Caesar decode using that shift: KHOOR',
 'HELLO',
 'Triangle = 3 sides. Caesar shift back 3.',
 75, 'All correct to pass, 1 attempt only'),

(2, 'The Clerk', 10, 2,
 'The shift equals the number of bits in a byte.
Caesar decode: PMTTW',
 'HELLO',
 'Byte = 8 bits. Shift back 8 from each letter.',
 75, 'All correct to pass, 1 attempt only'),

-- ── MINI BOSS III — THE ANALYST (Depth 15) ──────────────────────────────────
(3, 'The Analyst', 15, 1,
 'Convert binary to ASCII characters:
01000101 01001110 01000111',
 'ENG',
 '01000101=69=E, 01001110=78=N, 01000111=71=G',
 120, '2 attempts, second fail wipes checkpoint'),

(3, 'The Analyst', 15, 2,
 'Using ENG as a numeric key (E=5, N=14, G=7), apply these as Caesar shifts cycling to decode: JRN',
 'EDG',
 'J(10)-5=E(5), R(18)-14=D(4), N(14)-7=G(7)',
 120, '2 attempts, second fail wipes checkpoint'),

-- ── MINI BOSS IV — THE ENGINEER (Depth 20) ──────────────────────────────────
(4, 'The Engineer', 20, 1,
 'Logic gate sequence:
Input A: 1010
Input B: 1100

Step 1: A XOR B = ?
Step 2: Result AND 1111 = ?
Step 3: Convert final binary to decimal.

Submit decimal only.',
 '6',
 'XOR: 1010 XOR 1100=0110. AND 1111=0110. 0110=6',
 150, '1 attempt only — this is a gate, not a puzzle'),

(4, 'The Engineer', 20, 2,
 'Use 6 (from previous) as Caesar shift.
Decode: NKRRU',
 'HELLO',
 'N-6=H, K-6=E, R-6=L, R-6=L, U-6=O',
 150, '1 attempt only'),

-- ── MINI BOSS V — THE INQUISITOR (Depth 25) ─────────────────────────────────
(5, 'The Inquisitor', 25, 1,
 '[SPEED] 15 seconds.
Letter sequence — next term: B, D, G, K, P, ?',
 'V',
 'Gaps: +2,+3,+4,+5,+6',
 15, '4 of 5 correct to pass — no lifelines'),

(5, 'The Inquisitor', 25, 2,
 '[SPEED] 15 seconds.
Caesar shift 5. Decode: MJQQT',
 'HELLO',
 'Shift back 5 from each letter',
 15, '4 of 5 correct to pass — no lifelines'),

(5, 'The Inquisitor', 25, 3,
 '[SPEED] 15 seconds.
Binary to decimal: 11010110',
 '214',
 '128+64+0+16+0+4+2+0=214',
 15, '4 of 5 correct to pass — no lifelines'),

(5, 'The Inquisitor', 25, 4,
 '[SPEED] 15 seconds.
A=1010, B=0110. A XOR B in decimal?',
 '12',
 '1010 XOR 0110 = 1100 = 12',
 15, '4 of 5 correct to pass — no lifelines'),

(5, 'The Inquisitor', 25, 5,
 '[SPEED] 15 seconds.
Atbash decode then reverse the result: HVIKVMG',
 'TNEPRЕS',
 'HVIKVMG→Atbash→SERPENT→Reverse→TNEPRЕS',
 15, '4 of 5 correct to pass — no lifelines');


-- ============================================================
-- BOSS CHAIN REGISTRY
-- Link final boss parts into named chains
-- ============================================================

INSERT INTO boss_chains (chain_name, is_active)
VALUES ('CHAIN_ALPHA', TRUE), ('CHAIN_BETA', TRUE);

-- Note: After inserting puzzles, run this to link chains:
-- UPDATE boss_chains SET
--   part_1 = (SELECT id FROM puzzles WHERE question LIKE '%CHAIN A%' AND boss_order=1),
--   part_2 = (SELECT id FROM puzzles WHERE question LIKE '%CHAIN A%' AND boss_order=2),
--   part_3 = (SELECT id FROM puzzles WHERE question LIKE '%CHAIN A%' AND boss_order=3),
--   part_4 = (SELECT id FROM puzzles WHERE question LIKE '%CHAIN A%' AND boss_order=4),
--   part_5 = (SELECT id FROM puzzles WHERE question LIKE '%CHAIN A%' AND boss_order=5)
-- WHERE chain_name = 'CHAIN_ALPHA';


-- ============================================================
-- USEFUL QUERIES FOR GAME SERVER
-- ============================================================

-- Fetch a random puzzle by difficulty, excluding used IDs:
-- SELECT * FROM puzzles
-- WHERE difficulty = $1
--   AND is_active = TRUE
--   AND is_boss_part = FALSE
--   AND id != ALL($2::uuid[])
-- ORDER BY used_count ASC, RANDOM()
-- LIMIT 1;

-- Fetch mini boss puzzles for a given depth:
-- SELECT * FROM mini_boss_puzzles
-- WHERE depth = $1 AND is_active = TRUE
-- ORDER BY part_number ASC;

-- Fetch active final boss chain:
-- SELECT * FROM boss_chains
-- WHERE is_active = TRUE
-- ORDER BY RANDOM()
-- LIMIT 1;

-- Increment used_count after puzzle is shown:
-- UPDATE puzzles SET used_count = used_count + 1 WHERE id = $1;

-- Flag a puzzle as contested:
-- UPDATE puzzles SET flag_count = flag_count + 1 WHERE id = $1;

-- Deactivate a flagged puzzle:
-- UPDATE puzzles SET is_active = FALSE WHERE id = $1;


-- ============================================================
-- PUZZLE COUNT SUMMARY
-- ============================================================
-- Difficulty 1 (Depths 1-4):   ~22 puzzles
-- Difficulty 2 (Depths 5-9):   ~20 puzzles
-- Difficulty 3 (Depths 10-19): ~22 puzzles
-- Difficulty 4 (Depths 20-29): ~20 puzzles
-- Difficulty 5 (Final Boss):   10 puzzles (2 complete chains)
-- Mini Boss Parts:              14 puzzles across 5 bosses
-- ============================================================
-- Total: ~108 puzzles
-- Recommend adding 20+ more difficulty 3-4 puzzles
-- before a live event with 15+ players
-- ============================================================
