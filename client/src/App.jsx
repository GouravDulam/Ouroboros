import React, { useState, useEffect, useRef } from 'react';
import { io } from 'socket.io-client';
import LeaderboardDashboard from './components/LeaderboardDashboard';
import { BOOT, THOUGHTS, ROOMS, PZ, WIN_ART, LOSE_ART, WIN_SNAKE, LOSE_SNAKE } from './data';

const PM = {};
PZ.forEach(p => { PM[p.id] = p; });

const socket = io('http://localhost:3001');

const App = () => {
  const [screen, setScreen] = useState('boot'); // boot, start, game, end
  const [bootLines, setBootLines] = useState([]);
  const [name, setName] = useState('');
  const [S, setS] = useState({
    id: 'L0-0', solved: 0, streak: 0, cps: 0, cpData: null, maxLv: 1, score: 0, path: ['L0-0'], waiting: false
  });
  
  const [leaderboard, setLeaderboard] = useState({ players: [], totalSouls: 0 });
  const [toast, setToast] = useState(null);
  const [modal, setModal] = useState(null);
  const [cpBanner, setCpBanner] = useState(false);
  const [answerInput, setAnswerInput] = useState('');
  const [accessCode, setAccessCode] = useState('');
  const [failCount, setFailCount] = useState(0);
  const [timeLeft, setTimeLeft] = useState(60);
  const [timerActive, setTimerActive] = useState(false);
  const [feedback, setFeedback] = useState({ msg: '', status: '' });
  const [hintVisible, setHintVisible] = useState(false);
  const [roomChoices, setRoomChoices] = useState([]);

  // Socket
  useEffect(() => {
    socket.on('leaderboard', (data) => {
      setLeaderboard(data);
    });
    return () => socket.off('leaderboard');
  }, []);

  // Boot Sequence
  useEffect(() => {
    if (screen === 'boot') {
      let index = 0;
      const interval = setInterval(() => {
        if (index < BOOT.length) {
          const item = BOOT[index];
          setBootLines(prev => [...prev, item]);
          index++;
        } else {
          clearInterval(interval);
          setTimeout(() => setScreen('start'), 700);
        }
      }, 100);
      return () => clearInterval(interval);
    }
  }, [screen]);

  // Sync to Server
  useEffect(() => {
    if (screen === 'game') {
      socket.emit('progress', {
        maxLv: S.maxLv,
        score: S.score,
        solved: S.solved,
        cps: S.cps
      });
    }
  }, [S.maxLv, S.score, S.solved, S.cps, screen]);

  const showToast = (msg, type) => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 2800);
  };

  const startGame = () => {
    const code = accessCode.trim().toUpperCase();
    if (code === 'ADMIN') {
      setScreen('admin');
      return;
    }

    if (!name.trim()) {
      showToast('X NAME REQUIRED', 'err');
      return;
    }
    
    if (code === 'PLAYER') {
      socket.emit('join', { name });
      setS({ id: 'L0-0', solved: 0, streak: 0, cps: 0, cpData: null, maxLv: 1, score: 0, path: ['L0-0'], waiting: false });
      setScreen('game');
      setFeedback({ msg: '', status: '' });
      setHintVisible(false);
      setRoomChoices([]);
      setAnswerInput('');
    } else {
      showToast('X INVALID ACCESS CODE', 'err');
    }
  };

  const doSubmit = () => {
    if (S.waiting) return;
    const p = PM[S.id];
    const raw = answerInput.trim().toLowerCase();
    if (!raw) return;

    const ok = p.a.some(a => raw === a.toLowerCase() || raw.includes(a.toLowerCase()) || a.toLowerCase().includes(raw));
    
    if (ok) {
      setTimerActive(false);
      setFeedback({ msg: '>> TRANSMISSION ACCEPTED. THE CYCLE DEEPENS...', status: 'ok' });
      setFailCount(0);
      let newS = { ...S, solved: S.solved + 1, streak: S.streak + 1, score: S.score + p.lv * 100 };
      if (p.lv > newS.maxLv) newS.maxLv = p.lv;
      
      if (p.lv > 0 && p.lv % 3 === 0) {
        newS.cps += 1;
        newS.score += 500;
        newS.cpData = { id: S.id, score: newS.score, solved: newS.solved, path: [...S.path] };
        setCpBanner(true);
        setTimeout(() => setCpBanner(false), 3500);
      }
      
      setS(newS);

      if (p.lv === 60) {
        setTimeout(() => endGame(true), 1200);
      } else {
        setTimeout(() => {
          const availableLevels = PZ.filter(pz => pz.lv > p.lv).map(pz => pz.lv);
          if (availableLevels.length > 0) {
            const nextLv = Math.min(...availableLevels);
            const nextPuzzles = PZ.filter(pz => pz.lv === nextLv);
            setS(prev => ({ ...prev, waiting: true }));
            const pool = [...ROOMS].sort(() => Math.random() - 0.5).slice(0, 1);
            const choices = nextPuzzles.sort(() => Math.random() - 0.5).slice(0, 1);
            setRoomChoices(choices.map((c, i) => ({ cid: c.id, room: pool[i] || ROOMS[i] })));
          } else {
            endGame(true);
          }
        }, 900);
      }
    } else {
      triggerFail('incorrect');
    }
  };

  const triggerFail = (reason = 'incorrect') => {
    setTimerActive(false);
    if (reason === 'timeout') {
      setFeedback({ msg: 'X TIME EXPIRED. THE CYCLE REJECTS YOU.', status: 'bad' });
    } else {
      setFeedback({ msg: 'X INCORRECT. THE SNAKE SWALLOWS YOU WHOLE.', status: 'bad' });
    }
    
    const nextFailCount = failCount + 1;
    setFailCount(nextFailCount);
    setS(prev => ({ ...prev, streak: 0 }));
    
    setTimeout(() => {
      if (nextFailCount >= 2) {
        setS(prev => ({ ...prev, id: 'L0-0', path: ['L0-0'], streak: 0, waiting: false }));
        setFailCount(0);
        showToast('X CONSECUTIVE FAILURE: RESET TO BEGINNING', 'err');
      } else if (S.cpData) {
        setS(prev => ({ ...prev, id: prev.cpData.id, score: prev.cpData.score, solved: prev.cpData.solved, path: [...prev.cpData.path], streak: 0, waiting: false }));
        showToast('| CHECKPOINT RESTORED', 'cp');
      } else {
        setS(prev => ({ ...prev, id: 'L0-0', path: ['L0-0'], streak: 0, waiting: false }));
        showToast('X RETURNED TO THE BEGINNING', 'err');
      }
      setFeedback({ msg: '', status: '' });
      setAnswerInput('');
      setHintVisible(false);
    }, 1400);
  };

  // Timer countdown
  useEffect(() => {
    let interval = null;
    if (timerActive && timeLeft > 0) {
      interval = setInterval(() => {
        setTimeLeft(prev => prev - 1);
      }, 1000);
    } else if (timeLeft === 0 && timerActive) {
      triggerFail('timeout');
    }
    return () => clearInterval(interval);
  }, [timerActive, timeLeft]);

  // Restart timer on puzzle change
  useEffect(() => {
    if (screen === 'game' && S.id) {
      const p = PM[S.id];
      const duration = p.lv > 30 ? 45 : 60;
      setTimeLeft(duration);
      setTimerActive(true);
    } else {
      setTimerActive(false);
    }
  }, [S.id, screen]);

  const endGame = (won) => {
    socket.emit(won ? 'win' : 'die');
    setScreen('end');
  };

  const confirmKill = () => {
    setModal({
      icon: 'X', title: 'SEVER THE CYCLE?',
      body: `AGENT ${name.toUpperCase()} -- ${S.solved} riddles solved. Level ${S.maxLv} reached. Score: ${S.score}. The snake does not forgive abandonment.`,
      btns: [
        { l: 'YES -- SEVER', c: 'btn-r', fn: () => { setModal(null); endGame(false); } },
        { l: 'CONTINUE', c: 'btn-g', fn: () => setModal(null) }
      ]
    });
  };

  const handleRoomSelect = (cid) => {
    setS(prev => ({ ...prev, path: [...prev.path, cid], id: cid, waiting: false }));
    setRoomChoices([]);
    setFeedback({ msg: '', status: '' });
    setAnswerInput('');
    setHintVisible(false);
  };

  const showHint = () => {
    setHintVisible(true);
    setS(prev => ({ ...prev, score: Math.max(0, prev.score - 50) }));
    showToast('!! HINT UNLOCKED [-50 PTS]', 'err');
  };

  const currPZ = PM[S.id];

  return (
    <>
      <div id="sfx"></div>
      <div id="drip"></div>

      <div className="ticker top">
        <div className="ttag poison">SYS</div>
        <div className="tscroll">--- THE CYCLE IS FEEDING --- SIGNAL INTEGRITY: COLLAPSING --- YOU HAVE BEEN HERE BEFORE AND YOU WILL COME HERE AGAIN ---</div>
      </div>
      <div className="ticker bot">
        <div className="ttag violet">oo</div>
        <div className="tscroll">### IN CAUDA VENENUM ### THE SNAKE BITES ITSELF SO IT CANNOT FEEL THE HUNGER ###</div>
      </div>

      {screen === 'boot' && (
        <div id="boot" className={screen === 'boot' ? '' : 'fade'}>
          <div id="bootlines">
            {bootLines.map((b, i) => (
              b ? <div key={i} className={`bl ${b.c || 'dim'}`}>{b.t || '\u00a0'}</div> : null
            ))}
          </div>
          <div><span className="bcursor"></span></div>
        </div>
      )}

      {(screen === 'game' || screen === 'end') && (
        <div id="hud" style={{ display: 'block' }}>
            <div className="hi">
              <div className="hl">| AGENT: <span>{name.toUpperCase() || 'UNKNOWN'}</span> &nbsp;-&gt;&nbsp; DEPTH: LV<span>{S.maxLv}</span>/60</div>
              <div className="hr">
                <div className={`hs ${timeLeft < 10 ? 'blood' : ''}`} style={{ border: '1px solid var(--d2)', padding: '0 8px' }}>
                  TIME: <b style={{ color: timeLeft < 10 ? 'var(--c2)' : 'var(--c5)' }}>{timeLeft}s</b>
                </div>
                <div className="hs">SCORE: <b>{S.score}</b></div>
                <div className="cpr">
                  [<div className={`cpd ${S.streak > 0 ? 'on' : ''}`}></div>
                   <div className={`cpd ${S.streak > 1 ? 'on' : ''}`}></div>
                   <div className={`cpd ${S.streak > 2 ? 'on' : ''}`}></div>]
                </div>
              </div>
            </div>
        </div>
      )}

      {screen === 'start' && (
        <div className="screen" id="startScreen">
          <div className="sw">
            <div className="dl poison">################################################################################################</div>
            <div className="oart poison" style={{fontSize:'13px',letterSpacing:'0.05em'}}>
{`⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀⣀⣀⣀⣄⣀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣴⡶⢿⣟⡛⣿⢉⣿⠛⢿⣯⡈⠙⣿⣦⡀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣠⡾⠻⣧⣬⣿⣿⣿⣿⣿⡟⠉⣠⣾⣿⠿⠿⠿⢿⣿⣦⠀⠀⠀
⠀⠀⠀⠀⣠⣾⡋⣻⣾⣿⣿⣿⠿⠟⠛⠛⠛⠀⢻⣿⡇⢀⣴⡶⡄⠈⠛⠀⠀⠀
⠀⠀⠀⣸⣿⣉⣿⣿⣿⡿⠋⠀⠀⠀⠀⠀⠀⠀⠈⢿⣇⠈⢿⣤⡿⣦⠀⠀⠀⠀
⠀⠀⢰⣿⣉⣿⣿⣿⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠦⠀⢻⣦⠾⣆⠀⠀⠀
⠀⠀⣾⣏⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⡶⢾⡀⠀⠀
⠀⠀⣿⠉⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣧⣼⡇⠀⠀
⠀⠀⣿⡛⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⣧⣼⡇⠀⠀
⠀⠀⠸⡿⢻⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣼⣿⣥⣽⠁⠀⠀
⠀⠀⠀⢻⡟⢙⣿⣿⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⣿⣧⣸⡏⠀⠀⠀
⠀⠀⠀⠀⠻⣿⡋⣻⣿⣿⣿⣦⣤⣀⣀⣀⣀⣀⣠⣴⣿⣿⢿⣥⣼⠟⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠈⠻⣯⣤⣿⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⠛⣷⣴⡿⠋⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠈⠙⠛⠾⣧⣼⣟⣉⣿⣉⣻⣧⡿⠟⠋⠁⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠉⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀`}
            </div>
            <div className="oart blood">
              !! !! !! !! !! !! !! !! !! !! !! !! !! !! !! !! !! !! !! !! !! !! !! !! !! !! !! !!<br/>
              !!            YOU ARE INSIDE THE MOUTH. YOU HAVE ALWAYS BEEN INSIDE.             !!<br/>
              !! !! !! !! !! !! !! !! !! !! !! !! !! !! !! !! !! !! !! !! !! !! !! !! !! !! !! !!
            </div>
            <div className="gtitle">OUROBOROS</div>
            <div className="gsub">-- IN CAUDA VENENUM -- THE POISON IS IN THE TAIL --</div>
            <div className="dl bright">==================================================================================</div>
            
            <div style={{display:'flex',gap:'8px',alignItems:'stretch'}}>
              <div className="oart vio" style={{flex:'0 0 auto',fontSize:'11px',display:'flex',alignItems:'center'}}>
{` ___
/o o\\
| )o(
\\___/
 | |
 +-+`}
              </div>
              <div className="sysbox vio" data-l="[ SYSTEM STATUS ]" style={{flex:1}}>
                <div className="sr">
                  <div className="si"><div className="sd c1"></div><span style={{color:'var(--c1)'}}> CYCLE: ACTIVE</span></div>
                  <div className="si"><div className="sd c2"></div><span style={{color:'var(--c2)'}}> FEEDING: TRUE</span></div>
                  <div className="si"><div className="sd c3"></div><span style={{color:'var(--c3)'}}> LOOP: INFINITE</span></div>
                  <div className="si"><div className="sd c4"></div><span style={{color:'var(--c4)'}}> EXIT: NULL</span></div>
                  <div className="si"><div className="sd c1"></div><span style={{color:'var(--d1)'}}> SIG: </span><span id="sigV" style={{color:'var(--c1)'}}>====.. 64%</span></div>
                </div>
              </div>
              <div className="oart vio" style={{flex:'0 0 auto',fontSize:'11px',display:'flex',alignItems:'center'}}>
{` ___
/o o\\
| )o(
\\___/
 | |
 +-+`}
              </div>
            </div>

            <div className="oart vio" style={{fontSize:'12px'}}>
{`+--[ THE SNAKE DOES NOT DIE. IT DIGESTS ITSELF AND IS REBORN FROM ITS OWN HUNGER ]--+
|  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  |
+------------------------------------------------------------------------------------+`}
            </div>

            <div className="namebox">
              <div className="nlabel">!! IDENTIFY YOURSELF BEFORE YOU ARE CONSUMED !!</div>
              <div className="nwrap">
                <div className="nprompt">C:\&gt;</div>
                <input className="ninput" type="text" maxLength="20" placeholder="TYPE YOUR NAME_" 
                  value={name} onChange={e => setName(e.target.value)} 
                  onKeyDown={e => { if (e.key === 'Enter') startGame(); }} />
                <div className="ncursor"></div>
              </div>
            </div>

            <div className="namebox" style={{ marginTop: '10px' }}>
              <div className="nlabel">!! ENTER ACCESS CODE !!</div>
              <div className="nwrap">
                <div className="nprompt">C:\&gt;</div>
                <input className="ninput" type="text" maxLength="20" placeholder="ACCESS CODE_" 
                  value={accessCode} onChange={e => setAccessCode(e.target.value)} 
                  onKeyDown={e => { if (e.key === 'Enter') startGame(); }} />
                <div className="ncursor"></div>
              </div>
            </div>

            <div className="sysbox" data-l="[ LAWS OF THE ETERNAL CYCLE ]">
              <div className="rp">  <span className="rh">*</span> SOLVE A RIDDLE   -&gt;   THREE NEW CHAMBERS OPEN<br/>
  <span className="rh">*</span> ANSWER WRONG     -&gt;   RETURNED TO THE BEGINNING<br/>
  <span className="rh">*</span> EVERY 3 SOLVED   -&gt;   CHECKPOINT INSCRIBED IN THE FLESH<br/>
  <span className="rh">*</span> CHECKPOINT       -&gt;   RESTORE LAST SAVE POINT<br/>
  <span className="rv">*</span> WINNER           -&gt;   DEEPEST LEVEL + MOST CHECKPOINTS<br/>
  <span className="rd">* THE SNAKE ALWAYS FINDS ITS WAY BACK TO ITS OWN MOUTH *</span></div>
            </div>

            <div className="oart dim" style={{fontSize:'12px'}}>
{` [oo][oo][oo][oo][oo][oo][oo][oo][oo][oo][oo][oo][oo][oo][oo][oo][oo][oo][oo][oo]
  ||   ||   ||   ||   ||   ||   ||   ||   ||   ||   ||   ||   ||   ||   ||   ||
  oo   oo   oo   oo   oo   oo   oo   oo   oo   oo   oo   oo   oo   oo   oo   oo`}
            </div>

            <div className="oart vio" style={{fontSize:'12px',textAlign:'center'}}>
              IT HAS BEEN WATCHING SINCE YOU OPENED THIS PAGE.
            </div>

            <div className="dl bright">==================================================================================</div>
            
            <div style={{ textAlign: 'center', marginTop: '20px' }}>
              <button className="btn btn-p" onClick={startGame}>|-- ENTER THE CYCLE --|</button>
            </div>
          </div>
          <LeaderboardDashboard players={leaderboard.players} totalSouls={leaderboard.totalSouls} />
        </div>
      )}

      {screen === 'game' && (
        <div className="screen" id="gameScreen">
          <div className="gi">
            <div className="dl poison" style={{ fontSize: '12px' }}>--------------------------------------------------------------------------------------------------</div>
            <div className="bc" id="bc">
              <span className="bc">ROOT</span>
              {S.path.slice(1).map((p, i) => (
                <React.Fragment key={i}>
                  <span style={{ color: '#330011' }}> &gt; </span>
                  <span className={`bc ${i === S.path.length - 2 ? 'cur' : ''}`}>LV{PM[p].lv}</span>
                </React.Fragment>
              ))}
            </div>

            {roomChoices.length === 0 ? (
              <div className="acard" id="pcard">
                <div className="acard-top">+========================================================================+</div>
                <div className="acard-body">
                  <div className="chdr">
                    <div className="clv">* CHAMBER DEPTH {currPZ?.lv}/60 *</div>
                    <div className="cid">SIG:{currPZ?.id}</div>
                  </div>
                  <div className="dl blood" style={{ fontSize: '12px', marginBottom: '8px' }}>------------------------------------------------------------------------</div>
                  <div className="pq">{currPZ?.q}</div>
                  <div className={`phint ${hintVisible ? 'vis' : ''}`}>HINT: {currPZ?.h}</div>
                  <div className="dl vio" style={{ fontSize: '12px', marginBottom: '8px' }}>------------------------------------------------------------------------</div>
                  <div className="aa">
                    <div className="ap">&gt;&gt;&gt;</div>
                    <input className={`ai ${feedback.status}`} type="text" placeholder="TRANSMIT ANSWER" 
                      value={answerInput} onChange={e => setAnswerInput(e.target.value)} 
                      onKeyDown={e => { if (e.key === 'Enter') doSubmit(); }} />
                    <button className="btn btn-p" onClick={doSubmit} style={{ padding: '4px 14px', fontSize: '1.1rem' }} disabled={S.waiting}>SEND&gt;</button>
                  </div>
                  <div className="cftr">
                    <div className={`fb ${feedback.status}`}>{feedback.msg}</div>
                    <button className="hbtn" onClick={showHint}>!! REVEAL HINT [-50]</button>
                  </div>
                </div>
                <div className="acard-bot">+========================================================================+</div>
              </div>
            ) : (
              <div className="rsec" id="rsec" style={{ display: 'flex' }}>
                <div className="dl bright">==================================================================================</div>
                <div className="rhdr">!! ONE NEW CHAMBER OPEN -- [PROCEED WITH CAUTION]</div>
                <div className="rgrid">
                  {roomChoices.map((choice, i) => (
                    <div key={i} className="ropt" onClick={() => handleRoomSelect(choice.cid)} style={{ maxWidth: '400px', margin: '0 auto' }}>
                      <div className="rnum">{i + 1}</div>
                      <div style={{ flex: 1 }}>
                        <div className="rname">{choice.room.name}</div>
                        <div className="rsub">{choice.room.sub}</div>
                      </div>
                      <div className="rico">{choice.room.ico}</div>
                    </div>
                  ))}
                </div>
              </div>
            )}

            <div className="dl poison" style={{ fontSize: '12px', marginTop: '20px' }}>--------------------------------------------------------------------------------------------------</div>
            <div className="dz">
              <div className="dlabel">!! SEVERING THE CYCLE WILL NOT FREE YOU !!</div>
              <button className="btn btn-r" onClick={confirmKill} style={{ fontSize: '.95rem', padding: '5px 12px' }}>X SEVER THE CYCLE</button>
            </div>
            <div className="dl poison" style={{ fontSize: '12px' }}>--------------------------------------------------------------------------------------------------</div>
          </div>
          <LeaderboardDashboard players={leaderboard.players} totalSouls={leaderboard.totalSouls} />
        </div>
      )}

      {screen === 'end' && (
        <div className="screen" id="endScreen">
          <pre className={`eart ${socket.connected ? 'win' : 'lose'}`}>{socket.connected ? WIN_ART : LOSE_ART}</pre>
          <div className={`etitle ${socket.connected ? 'win' : 'lose'}`}>{socket.connected ? 'o CYCLE BROKEN o' : 'X CONSUMED X'}</div>
          <div className="ebox">
            <div className="erow"><label>- AGENT ID</label><value>{name.toUpperCase()}</value></div>
            <div className="erow"><label>- DEEPEST LEVEL</label><value>{S.maxLv}/60</value></div>
            <div className="erow"><label>- RIDDLES SOLVED</label><value>{S.solved}</value></div>
            <div className="erow"><label>- CHECKPOINTS</label><value>{S.cps}</value></div>
            <div className="erow"><label>- FINAL SCORE</label><value><span className="sbig">{S.score + S.cps * 200}</span></value></div>
          </div>
          <pre className="eart">{socket.connected ? WIN_SNAKE : LOSE_SNAKE}</pre>
          <button className="btn btn-p" onClick={() => { socket.emit('join', { name }); setScreen('game'); setS({ id: 'L0-0', solved: 0, streak: 0, cps: 0, cpData: null, maxLv: 1, score: 0, path: ['L0-0'], waiting: false }); }}>&gt; RE-ENTER THE CYCLE &lt;</button>
          <LeaderboardDashboard players={leaderboard.players} totalSouls={leaderboard.totalSouls} />
        </div>
      )}

      {screen === 'admin' && (
        <div className="screen" id="adminScreen" style={{ padding: '20px' }}>
          <div className="gtitle" style={{ textAlign: 'center', marginBottom: '20px' }}>ADMINISTRATOR DASHBOARD</div>
          <div className="dl bright">==================================================================================</div>
          <div style={{ textAlign: 'center', marginBottom: '20px', color: 'var(--c1)' }}>
            OVERSEE THE SOULS CAUGHT IN THE CYCLE
          </div>
          <div style={{ 
            backgroundColor: 'var(--sur)', 
            padding: '20px', 
            border: '1px solid var(--c4)', 
            borderRadius: '4px',
            marginBottom: '20px'
          }}>
            <LeaderboardDashboard players={leaderboard.players} totalSouls={leaderboard.totalSouls} isFullScreen={true} />
          </div>
          <div className="dl bright">==================================================================================</div>
          <div style={{ textAlign: 'center', marginTop: '20px' }}>
            <button className="btn btn-r" onClick={() => { setScreen('start'); setAccessCode(''); }}>&lt; RETURN TO GATEWAY &lt;</button>
          </div>
        </div>
      )}

      {toast && <div id="toast" className={`show ${toast.type}`}>{toast.msg}</div>}
      <div id="cpbanner" className={cpBanner ? 'show' : ''}>| CHECKPOINT {S.cps} INSCRIBED [+500] |</div>

      {modal && (
        <div id="modal" className="show" onClick={() => setModal(null)}>
          <div className="mbox" onClick={e => e.stopPropagation()}>
            <div className="mhdr"><span>### OUROBOROS SYSTEM ###</span><span>{modal.title}</span></div>
            <div className="mbody">
              <div className="micon">{modal.icon}</div>
              <div className="mtitle">{modal.title}</div>
              <div className="mtext">{modal.body}</div>
              <div className="mbtns">
                {modal.btns.map((b, i) => (
                  <button key={i} className={`btn ${b.c}`} onClick={b.fn}>{b.l}</button>
                ))}
              </div>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default App;
