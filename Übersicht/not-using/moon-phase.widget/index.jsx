// Moon Phase Widget - JSX Version
// Converted from CoffeeScript

import { React } from "uebersicht";

// Please set locale
const locale = {
  city: 'Houston',
  region: 'TX'
};

// Set preferences
const option = {
  fontName: 'Futura',
  fontSize: 18,        // scales the overall widget size
  fontColor: '#FFF',
  fontColorMuted: '#FFF',    // for RUS label; at 50% opacity
  
  iconSet: 'lit',     // pixels to be 'lit' or 'shadow' side of moon
  iconColor: '#FFF',
  
  widgetBackground: '#FFF',
  widgetOpacity: 0.00,      // percentage (0.01-1.00); 0 is transparent
  
  showCity: true,
  showCoords: true,    // latitude and longitude
  showAge: true,       // age in days
  showIllum: true,     // percentage illumination
  showRUS: true,       // w/separator, rise/upper transit/set times for today
  showClosest: true,   // w/separator, closest phase (either ahead or behind)
  showCloseDay: true,  // +-> closest phase date (iff showClosest is true)
  showAMPM: false      // default is military time
};

export const command = `moon-phase.widget/get-phase.sh "${locale.city}" "${locale.region}"`;

export const refreshFrequency = 3600000; // 1 hour (best accuracy from moon illumination data)

const iconSize = option.fontSize * 7;

export const className = `
  color: ${option.fontColor};
  text-align: center;
  font-family: ${option.fontName};
  left: 60px;
  top: 10px;
  
  background-color: rgba(${option.widgetBackground === '#FFF' ? '255, 255, 255' : '0, 0, 0'}, ${option.widgetOpacity});
  border-radius: 25px;
  line-height: 1.5;
  padding: 5px;
  padding-left: 15px;
  padding-right: 15px;
  
  @font-face {
    font-family: 'Weather';
    src: url(moon-phase.widget/moon-icons.svg) format('svg');
  }
  
  .moon {
    display: inline-block;
    position: relative;
    text-align: center;
    white-space: nowrap;
    width: 100%;
  }
  
  .current {
    display: table;
  }
  
  .icon {
    color: ${option.iconColor};
    display: table-cell;
    font-family: Weather;
    font-size: ${iconSize}px;
    vertical-align: middle;
  }
  
  .data-elements {
    display: table-cell;
    padding: ${option.fontSize}px;
    vertical-align: middle;
  }
  
  .phase {
    font-size: ${option.fontSize * 1.5}px;
    font-weight: bold;
  }
  
  .city {
    font-size: ${option.fontSize * 1.25}px;
  }
  
  .coords {
    font-size: ${option.fontSize * 0.80}px;
  }
  
  .age {
    font-size: ${option.fontSize}px;
  }
  
  .illum {
    font-size: ${option.fontSize}px;
  }
  
  .phennames {
    display: flex;
    justify-content: space-between;
  }
  
  .phennames div {
    color: rgba(${option.fontColorMuted === '#FFF' ? '255, 255, 255' : '0, 0, 0'}, 0.5);
    font-size: ${option.fontSize * 0.70}px;
    width: 30%;
  }
  
  .phentimes {
    display: flex;
    justify-content: space-between;
  }
  
  .phentimes div {
    font-size: ${option.fontSize}px;
    width: 30%;
  }
  
  .separator {
    border-top: ${option.fontSize / 7.5}px solid rgba(${option.fontColor === '#FFF' ? '255, 255, 255' : '0, 0, 0'}, 0.5);
  }
  
  .clphase {
    font-size: ${option.fontSize * 0.85}px;
  }
  
  .cldate {
    font-size: ${option.fontSize * 0.85}px;
  }
  
  .error {
    font-size: ${option.fontSize}px;
    color: #FF0000;
    background: rgba(0, 0, 0, 0.5);
  }
`;

// Icon mappings
const iconLitMapping = {
  0: "&#xf095;",
  1: "&#xf096;",
  2: "&#xf097;",
  3: "&#xf098;",
  4: "&#xf099;",
  5: "&#xf09a;",
  6: "&#xf09b;",
  7: "&#xf09c;",
  8: "&#xf09d;",
  9: "&#xf09e;",
  10: "&#xf09f;",
  11: "&#xf0a0;",
  12: "&#xf0a1;",
  13: "&#xf0a2;",
  14: "&#xf0a3;",
  15: "&#xf0a4;",
  16: "&#xf0a5;",
  17: "&#xf0a6;",
  18: "&#xf0a7;",
  19: "&#xf0a8;",
  20: "&#xf0a9;",
  21: "&#xf0aa;",
  22: "&#xf0ab;",
  23: "&#xf0ac;",
  24: "&#xf0ad;",
  25: "&#xf0ae;",
  26: "&#xf0af;",
  27: "&#xf0b0;",
  28: "&#xf095;"
};

const iconShadowMapping = {
  0: "&#xf0eb;",
  1: "&#xf0d0;",
  2: "&#xf0d1;",
  3: "&#xf0d2;",
  4: "&#xf0d3;",
  5: "&#xf0d4;",
  6: "&#xf0d5;",
  7: "&#xf0d6;",
  8: "&#xf0d7;",
  9: "&#xf0d8;",
  10: "&#xf0d9;",
  11: "&#xf0da;",
  12: "&#xf0db;",
  13: "&#xf0dc;",
  14: "&#xf0dd;",
  15: "&#xf0de;",
  16: "&#xf0df;",
  17: "&#xf0e0;",
  18: "&#xf0e1;",
  19: "&#xf0e2;",
  20: "&#xf0e3;",
  21: "&#xf0e4;",
  22: "&#xf0e5;",
  23: "&#xf0e6;",
  24: "&#xf0e7;",
  25: "&#xf0e8;",
  26: "&#xf0e9;",
  27: "&#xf0ea;",
  28: "&#xf0eb;"
};

// Helper functions
function returnAMPM(time) {
  const my_time = time.split(':');
  let hh = Number(my_time[0]);
  let mm = Number(my_time[1]);
  const time_suffix = hh >= 12 ? 'PM' : 'AM';
  if (hh > 12) hh = hh - 12;
  if (mm < 10) mm = '0' + mm;
  return `${hh}:${mm} ${time_suffix}`;
}

function returnPhenNames(code, tense) {
  // R=Rises
  if (code === "R" && tense === "prev") return "Rose Yesterday";
  if (code === "R" && tense === "curr") return "Rises";
  if (code === "R" && tense === "next") return "Rises Tomorrow";
  // U=Upper Transit
  if (code === "U" && tense === "prev") return "U.T. Yesterday";
  if (code === "U" && tense === "curr") return "Upper Transit";
  if (code === "U" && tense === "next") return "U.T. Tomorrow";
  // S=Sets
  if (code === "S" && tense === "prev") return "Set Yesterday";
  if (code === "S" && tense === "curr") return "Sets";
  if (code === "S" && tense === "next") return "Sets Tomorrow";
  return "";
}

function getIcon(code, iconSet) {
  if (iconSet === 'lit') {
    return iconLitMapping[code] || iconLitMapping[0];
  } else {
    return iconShadowMapping[code] || iconShadowMapping[0];
  }
}

// Calculate moon data
function calculateMoonData(data) {
  const today = new Date();
  
  // Calculate current phase based on known new moon, modulo 29.53
  // https://en.wikipedia.org/wiki/Lunar_phase#Calculating_phase
  const synodic_month = 29.530588853;
  
  // The most recent new moon; TODO: log last new moon seen to a file?
  const new_moon = new Date('03/09/2016 01:54 GMT');
  
  const ms_per_day = 1000 * 60 * 60 * 24;
  const days_passed = (today.getTime() - new_moon.getTime()) / ms_per_day;
  let moon_age = days_passed % synodic_month;
  
  // Only 28 days in the moon icon set (sidereal month)
  // Have icon days scaled up to 1.05 to cover the gap
  let icon_age;
  if (moon_age < 14.5) {
    icon_age = Math.round(moon_age);
  } else {
    icon_age = Math.round(moon_age / 1.05);
  }
  
  let curphase = data.curphase || data.closestphase?.phase || "New Moon";
  
  // When key phase names appear, ensure matching icons
  if (curphase === "New Moon") icon_age = 0;
  if (curphase === "First Quarter") icon_age = 7;
  if (curphase === "Full Moon") icon_age = 14;
  if (curphase === "Last Quarter") icon_age = 21;
  
  // When key illuminations appear, ensure matching phase name
  if (data.illum === "0") curphase = "New Moon";
  if (data.illum === "50" && moon_age < (synodic_month / 2)) curphase = "First Quarter";
  if (data.illum === "100") curphase = "Full Moon";
  if (data.illum === "50" && moon_age > (synodic_month / 2)) curphase = "Last Quarter";
  
  moon_age = moon_age.toFixed(1);
  
  // Format coordinates
  let coords = null;
  if (option.showCoords && data.lat !== undefined && data.lon !== undefined) {
    const latcard = data.lat > 0 ? 'N' : 'S';
    const loncard = data.lon > 0 ? 'E' : 'W';
    const lat = Math.abs(parseFloat(data.lat).toFixed(2));
    const lon = Math.abs(parseFloat(data.lon).toFixed(2));
    coords = `${lat}\u00B0${latcard} ${lon}\u00B0${loncard}`;
  }
  
  // Process RUS (Rise/Upper Transit/Set) data
  let phenNames = [];
  let phenTimes = [];
  if (option.showRUS && data.moondata) {
    const count = data.moondata.length;
    
    if (count < 3 && data.prevmoondata) {
      const phenName = returnPhenNames(data.prevmoondata[0].phen, "prev");
      phenNames.push(phenName);
      let my_time = data.prevmoondata[0].time;
      if (option.showAMPM) my_time = returnAMPM(my_time);
      phenTimes.push(my_time);
    }
    
    data.moondata.forEach(d => {
      const phenName = returnPhenNames(d.phen, "curr");
      phenNames.push(phenName);
      let my_time = option.showAMPM ? returnAMPM(d.time) : d.time;
      phenTimes.push(my_time);
    });
    
    if (count < 3 && data.nextmoondata) {
      const phenName = returnPhenNames(data.nextmoondata[0].phen, "next");
      phenNames.push(phenName);
      let my_time = data.nextmoondata[0].time;
      if (option.showAMPM) my_time = returnAMPM(my_time);
      phenTimes.push(my_time);
    }
  }
  
  // Process closest phase
  let closestPhase = null;
  let closestDate = null;
  if (option.showClosest && data.closestphase) {
    const clday = new Date(data.closestphase.date + " " + data.closestphase.time);
    const clause = clday.getTime() > today.getTime() ? 'is' : 'was';
    closestPhase = `Closest phase ${clause} ${data.closestphase.phase}`;
    
    if (option.showCloseDay) {
      let my_time = option.showAMPM ? returnAMPM(data.closestphase.time) : data.closestphase.time;
      closestDate = `on ${data.closestphase.date} at ${my_time}`;
    }
  }
  
  return {
    icon: getIcon(icon_age, option.iconSet),
    phase: curphase,
    moonAge: moon_age,
    city: data.city,
    coords: coords,
    illum: data.illum,
    phenNames: phenNames,
    phenTimes: phenTimes,
    closestPhase: closestPhase,
    closestDate: closestDate
  };
}

export const initialState = {
  error: null,
  moonData: null
};

export const updateState = (event, previousState) => {
  if (event.error) {
    return { ...previousState, error: `Error: ${event.error}`, moonData: null };
  }
  
  try {
    const data = JSON.parse(event.output);
    
    if (data.error) {
      console.error('moon-phase:', data.message);
      return { ...previousState, error: data.message, moonData: null };
    }
    
    const moonData = calculateMoonData(data);
    return { ...previousState, error: null, moonData: moonData };
  } catch (e) {
    return { ...previousState, error: `Parsing error: ${e.message}`, moonData: null };
  }
};

export const render = ({ error, moonData }) => {
  if (error) {
    return (
      <div className="moon">
        <div className="current">moon phase widget error</div>
        <div className="error">{error}</div>
      </div>
    );
  }
  
  if (!moonData) {
    return (
      <div className="moon">
        <div className="current">Loading...</div>
      </div>
    );
  }
  
  return (
    <div className="moon">
      <div className="current">
        <div className="icon" dangerouslySetInnerHTML={{ __html: moonData.icon }}></div>
        <div className="data-elements">
          <div className="phase">{moonData.phase}</div>
          {option.showCity && moonData.city && (
            <div className="city">{moonData.city}</div>
          )}
          {option.showCoords && moonData.coords && (
            <div className="coords">{moonData.coords}</div>
          )}
          {option.showAge && (
            <div className="age">{moonData.moonAge} days old</div>
          )}
          {option.showIllum && moonData.illum && (
            <div className="illum">{moonData.illum}% illumination</div>
          )}
        </div>
      </div>
      
      {option.showRUS && moonData.phenNames.length > 0 && (
        <div className="phenomena">
          <div className="separator"></div>
          <div className="phennames">
            {moonData.phenNames.map((name, idx) => (
              <div key={idx}>{name}</div>
            ))}
          </div>
          <div className="phentimes">
            {moonData.phenTimes.map((time, idx) => (
              <div key={idx}>{time}</div>
            ))}
          </div>
        </div>
      )}
      
      {option.showClosest && moonData.closestPhase && (
        <div className="closest">
          <div className="separator"></div>
          <div className="clphase">{moonData.closestPhase}</div>
          {moonData.closestDate && (
            <div className="cldate">{moonData.closestDate}</div>
          )}
        </div>
      )}
    </div>
  );
};


