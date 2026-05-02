import React from 'react';

const LeaderboardDashboard = ({ players, totalSouls, isFullScreen }) => {
  if (!players || players.length === 0) return null;

  return (
    <div className={isFullScreen ? "leaderboard-full" : "leaderboard-overlay"}>
      <div className="leaderboard-title">=== LIVE SOULS ===</div>
      <div style={{ fontSize: '12px', color: 'var(--c4)', textAlign: 'center', marginBottom: '10px' }}>
        TOTAL CONSUMED: {totalSouls}
      </div>
      
      {isFullScreen && (
        <div className="leaderboard-header" style={{ display: 'flex', color: 'var(--c2)', fontSize: '12px', borderBottom: '1px solid var(--c4)', paddingBottom: '5px', marginBottom: '10px' }}>
          <span style={{ flex: '0 0 40px' }}>RANK</span>
          <span style={{ flex: 1 }}>AGENT ID</span>
          <span style={{ flex: '0 0 60px' }}>SCORE</span>
          <span style={{ flex: '0 0 60px' }}>LEVEL</span>
          <span style={{ flex: '0 0 60px' }}>SOLVED</span>
          <span style={{ flex: '0 0 80px' }}>CHECKPTS</span>
          <span style={{ flex: '0 0 60px' }}>STATUS</span>
        </div>
      )}

      {players.slice(0, 100).map((p, idx) => {
        let cls = "leaderboard-item";
        if (idx === 0 && p.status === 'active') cls += " top";
        if (p.status === 'dead') cls += " dead";
        if (p.status === 'won') cls += " won";

        if (isFullScreen) {
          return (
            <div key={p.id} className={cls} style={{ display: 'flex', fontSize: '14px', marginBottom: '8px', padding: '5px 0' }}>
              <span style={{ flex: '0 0 40px', color: 'var(--c4)' }}>#{idx + 1}</span>
              <span style={{ flex: 1, color: p.status === 'dead' ? 'var(--c2)' : 'var(--c1)' }}>{p.name.toUpperCase()}</span>
              <span style={{ flex: '0 0 60px', color: 'var(--c3)' }}>{p.score}</span>
              <span style={{ flex: '0 0 60px' }}>{p.maxLv}</span>
              <span style={{ flex: '0 0 60px' }}>{p.solved}</span>
              <span style={{ flex: '0 0 80px' }}>{p.cps}</span>
              <span style={{ flex: '0 0 60px', color: p.status === 'active' ? 'var(--c1)' : (p.status === 'dead' ? 'var(--c2)' : 'var(--c5)') }}>
                {p.status.toUpperCase()}
              </span>
            </div>
          );
        }

        return (
          <div key={p.id} className={cls}>
            <span className="leaderboard-rank">#{idx + 1}</span>
            <span className="leaderboard-name">{p.name.toUpperCase()}</span>
            <span className="leaderboard-score">{p.score}</span>
          </div>
        );
      })}
    </div>
  );
};

export default LeaderboardDashboard;
