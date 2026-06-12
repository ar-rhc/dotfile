// NEXT TIRI GUIDE - Übersicht Widget
// Save this as: tiri-guide.widget/index.jsx

import { React, run } from "uebersicht";

// Import configuration from config.json (create from config.example.json)
// If config.json doesn't exist, the import will fail - create it from config.example.json
import config from "./config.json";

const CALENDAR_NAME = config.CALENDAR_NAME;
const ICON_SIZE = 65;
const OBSIDIAN_VAULT_NAME = config.OBSIDIAN_VAULT_NAME;
const OBSIDIAN_NOTE_PATH = config.OBSIDIAN_NOTE_PATH;

export const command = `
/opt/homebrew/bin/icalBuddy -ic "${CALENDAR_NAME}" -n -nc -nrd -df "%Y-%m-%d" eventsFrom:today to:'today+180' 2>/dev/null | awk '
BEGIN { title = "" }
/^•/ { 
  title = $0
  next
}
/^[[:space:]]+[0-9]{4}-[0-9]{2}-[0-9]{2}/ { 
  if (tolower(title) ~ /tiritiri/) {
    match($0, /[0-9]{4}-[0-9]{2}-[0-9]{2}/)
    if (RSTART > 0) {
      print substr($0, RSTART, RLENGTH)
    }
  }
  title = ""  # Reset title after processing
}
' | sort -u | head -5
`;

export const refreshFrequency = 3600000; // 1 hour

export const className = `
  left: 20px;
  top: 50px;
  width: 200px;
  font-family: -apple-system, BlinkMacSystemFont, 'Helvetica Neue', sans-serif;
  color: #ffffff;
  user-select: none;
  -webkit-user-select: none; /* disable text selection */
  
  .widget-container {
    background-color: #1c1c1e;
    border-radius: 12px;
    padding: 12px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.5);
    position: relative;
  }
  
  .icon {
    position: absolute;
    top: 16px;
    right: 5px;
    object-fit: contain;
    background: transparent;
    border: none;
    display: block;
    cursor: pointer;
    transition: opacity 0.2s;
    z-index: 10;
  }
  
  .icon:hover {
    opacity: 0.7;
  }
  
  .main-event-section {
    cursor: pointer;
    border-radius: 8px;
    padding: 4px;
    margin: -4px;
    transition: background-color 0.2s, border-color 0.2s;
    border: 2px solid transparent;
  }
  
  .main-event-section:hover {
    background-color: rgba(255, 255, 255, 0.05);
  }
  
  .main-event-section.alert {
    border-color: rgba(255, 68, 68, 0.4);
  }
  
  .header {
    font-size: 10px;
    font-weight: 800;
    letter-spacing: 0.5px;
    color: #aaaaaa;
    margin-bottom: 4px;
  }
  
  .days-count {
    font-size: 34px;
    font-weight: 800;
    color: #ffffff;
    line-height: 1;
    margin: 4px 0;
  }
  
  .days-label {
    font-size: 24px;
    font-weight: 600;
    margin-left: 4px;
  }
  
  .main-date {
    font-size: 14px;
    color: #cccccc;
    margin-bottom: 8px;
  }
  
  .divider {
    height: 1px;
    background-color: #333333;
    margin: 8px 0;
  }
  
  .event-list {
    margin-top: 8px;
  }
  
  .event-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 6px;
    cursor: pointer;
    padding: 4px 6px;
    border-radius: 6px;
    transition: background-color 0.2s;
  }
  
  .event-item:hover {
    background-color: rgba(255, 255, 255, 0.1);
  }
  
  .date-item {
    font-size: 12px;
    font-weight: 600;
    color: #aaaaaa;
  }
  
  .days-item {
    font-size: 10px;
    color: #ffffff;
  }
  
  .no-events {
    font-size: 10px;
    color: #666666;
    font-style: italic;
  }
  
  .error {
    font-size: 9px;
    color: #ff4444;
    white-space: pre-wrap;
  }
  
  .debug {
    font-size: 8px;
    color: #888888;
    margin-top: 4px;
    white-space: pre-wrap;
  }
`;

function parseDate(line) {
  const match = line.trim().match(/^(\d{4})-(\d{2})-(\d{2})/);
  if (match) {
    return new Date(parseInt(match[1]), parseInt(match[2]) - 1, parseInt(match[3]));
  }
  return null;
}

function openCalendarToDate(date) {
  // Format: "9 January 2026"
  const day = date.getDate();
  const month = date.toLocaleDateString("en-US", { month: "long" });
  const year = date.getFullYear();
  const dateStr = `${day} ${month} ${year}`;
  
  // Simple AppleScript to open Calendar and view the date
  const script = `tell application "Calendar"
    activate
    view calendar at (date "${dateStr}")
  end tell`;
  
  const command = `osascript -e '${script.replace(/'/g, "'\\''")}'`;
  
  run(command)
    .then(() => console.log('Calendar opened successfully'))
    .catch((err) => {
      console.error('Error opening calendar:', err);
      // Fallback: just open Calendar app
      run('open -a Calendar');
    });
}

function openObsidianNote() {
  // Obsidian URL format: obsidian://open?vault=VaultName&file=path/to/file
  const encodedVault = encodeURIComponent(OBSIDIAN_VAULT_NAME);
  const encodedFile = encodeURIComponent(OBSIDIAN_NOTE_PATH);
  const obsidianUrl = `obsidian://open?vault=${encodedVault}&file=${encodedFile}`;
  
  console.log('Opening Obsidian with URL:', obsidianUrl);
  
  run(`open "${obsidianUrl}"`)
    .then(() => console.log('Obsidian opened successfully'))
    .catch((err) => {
      console.error('Error opening Obsidian:', err);
      run('open -a Obsidian');
    });
}

export const render = ({ output, error }) => {
  if (error) {
    return (
      <div className="widget-container">
        <div className="error">Error: {error}</div>
      </div>
    );
  }

  if (!output || output.trim() === '') {
    return (
      <div className="widget-container">
        <div className="no-events">No upcoming trips</div>
      </div>
    );
  }

  const lines = output.trim().split('\n').filter(l => l.trim());
  
  if (lines.length === 0) {
    return (
      <div className="widget-container">
        <div className="no-events">No upcoming trips</div>
      </div>
    );
  }

  const now = new Date();
  now.setHours(0, 0, 0, 0);
  
  const events = lines.map(line => parseDate(line)).filter(d => d !== null);
  
  if (events.length === 0) {
    return (
      <div className="widget-container">
        <div className="error">Could not parse dates</div>
        <div className="debug">Raw:\n{lines.slice(0, 3).join('\n')}</div>
      </div>
    );
  }

  const mainDate = events[0];
  const diffTime = mainDate - now;
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
  const isAlert = diffDays < 3;
  
  const dateStr = mainDate.toLocaleDateString("en-NZ", {
    weekday: "short",
    day: "numeric",
    month: "short"
  });

  return (
    <div className="widget-container">
      <img 
        src="tiri-guide.widget/icon.png"
        className="icon" 
        alt="Tiritiri Matangi" 
        onClick={(e) => {
          e.stopPropagation();
          openObsidianNote();
        }}
        style={{ 
          width: `${ICON_SIZE}px`, 
          height: `${ICON_SIZE}px`,
          backgroundColor: 'transparent',
          mixBlendMode: 'normal'
        }}
      />
      
      <div 
        className={`main-event-section ${isAlert ? 'alert' : ''}`}
        onClick={() => openCalendarToDate(mainDate)}
      >
        <div className="header">NEXT TIRI GUIDE</div>
        <div className="days-count">
          {diffDays}<span className="days-label">days</span>
        </div>
        <div className="main-date">{dateStr}</div>
      </div>
      
      {events.length > 1 ? (
        <React.Fragment>
          <div className="divider"></div>
          <div className="event-list">
            {events.slice(1).map((evtDate, idx) => {
              const dTime = evtDate - now;
              const dDays = Math.ceil(dTime / (1000 * 60 * 60 * 24));
              const dString = evtDate.toLocaleDateString("en-NZ", {
                weekday: "short",
                day: "numeric",
                month: "short"
              });
              
              return (
                <div 
                  key={idx} 
                  className="event-item"
                  onClick={() => openCalendarToDate(evtDate)}
                >
                  <div className="date-item">{dString}</div>
                  <div className="days-item">+{dDays}d</div>
                </div>
              );
            })}
          </div>
        </React.Fragment>
      ) : (
        <React.Fragment>
          <div className="divider"></div>
          <div className="no-events">No further dates</div>
        </React.Fragment>
      )}
    </div>
  );
};