// Moon Phase Widget - Modern JSX Version
// Converted from CoffeeScript to modern React/JSX
import { React } from "uebersicht";

// Configuration
export const refreshFrequency = 3600000; // 1 hour in milliseconds

const config = {
  locale: {
    city: 'Auckland',
    region: 'NZ'
  },
  option: {
    fontName: 'Futura',
    fontSize: 18,
    fontColor: '#FFF',
    fontColorMuted: '#FFF',
    iconSet: 'lit', // 'lit' or 'shadow'
    iconColor: '#FFF',
    widgetBackground: '#FFF',
    widgetOpacity: 0.00,
    showCity: true,
    showCoords: true,
    showAge: true,
    showIllum: true,
    showRUS: true,
    showClosest: true,
    showCloseDay: true,
    showAMPM: false
  }
};

// Shell command to get moon phase data
export const command = `moon-phase.widget/get-phase.sh "${config.locale.city}" "${config.locale.region}"`;

// Moon phase definitions (8 major phases)
const phases = [
  {name: "New Moon",        arcStart: 0,       arcEnd: 2*Math.PI, scaleX: 0,   invert: false},
  {name: "Waxing Crescent", arcStart: Math.PI, arcEnd: 2*Math.PI, scaleX: 0.7, invert: false},
  {name: "First Quarter",   arcStart: Math.PI, arcEnd: 2*Math.PI, scaleX: 0,   invert: false},
  {name: "Waxing Gibbous",  arcStart: 0,       arcEnd: Math.PI,   scaleX: 0.7, invert: true},
  {name: "Full Moon",       arcStart: 0,       arcEnd: 0,         scaleX: 0,   invert: false},
  {name: "Waning Gibbous",  arcStart: Math.PI, arcEnd: 2*Math.PI, scaleX: 0.7, invert: true},
  {name: "Last Quarter",    arcStart: 0,       arcEnd: Math.PI,   scaleX: 0,   invert: false},
  {name: "Waning Crescent", arcStart: 0,       arcEnd: Math.PI,   scaleX: 0.7, invert: false}
];

// Calculate moon phase (0-7) from moon age
const getMoonPhaseIndex = (moonAge) => {
  const synodicMonth = 29.530588853;
  const phaseLength = synodicMonth / 8;
  return Math.floor((moonAge / phaseLength) + 0.5) % 8;
};

// Generate SVG moon icon
const generateMoonSVG = (phaseIndex, size = 126, iconColor = '#FFF') => {
  const phase = phases[phaseIndex] || phases[0];
  const radius = size / 2;
  const center = size / 2;
  
  // Helper to create arc path
  const createArc = (startAngle, endAngle, r) => {
    if (startAngle === endAngle) return '';
    const start = {
      x: center + r * Math.cos(startAngle - Math.PI/2),
      y: center + r * Math.sin(startAngle - Math.PI/2)
    };
    const end = {
      x: center + r * Math.cos(endAngle - Math.PI/2),
      y: center + r * Math.sin(endAngle - Math.PI/2)
    };
    const largeArc = endAngle - startAngle > Math.PI ? 1 : 0;
    return `M ${center},${center} L ${start.x},${start.y} A ${r},${r} 0 ${largeArc} 1 ${end.x},${end.y} Z`;
  };
  
  const bgColor = phase.invert ? 'black' : iconColor;
  const fgColor = phase.invert ? iconColor : 'black';
  
  // Create ellipse for the shadow
  const ellipseWidth = radius * Math.abs(phase.scaleX);
  const ellipseTransform = phase.scaleX < 0 ? `translate(${size}, 0) scale(-1, 1)` : '';
  
  // Create arc path if needed
  const arcPath = createArc(phase.arcStart, phase.arcEnd, radius);
  
  return `
    <svg width="${size}" height="${size}" viewBox="0 0 ${size} ${size}" xmlns="http://www.w3.org/2000/svg">
      <circle cx="${center}" cy="${center}" r="${radius}" fill="${bgColor}" />
      ${phase.scaleX !== 0 ? `
        <g transform="${ellipseTransform}">
          <ellipse cx="${center}" cy="${center}" rx="${ellipseWidth}" ry="${radius}" fill="${fgColor}" />
        </g>
      ` : ''}
      ${arcPath ? `<path d="${arcPath}" fill="${fgColor}" />` : ''}
    </svg>
  `.trim();
};

const returnAMPM = (time) => {
  const [hh, mm] = time.split(':').map(Number);
  const timeSuffix = hh >= 12 ? 'PM' : 'AM';
  const hour12 = hh > 12 ? hh - 12 : (hh === 0 ? 12 : hh);
  const minute = mm < 10 ? '0' + mm : mm;
  return `${hour12}:${minute} ${timeSuffix}`;
};

const returnPhenNames = (code, tense) => {
  const mapping = {
    'R': { prev: 'Rose Yesterday', curr: 'Rises', next: 'Rises Tomorrow' },
    'U': { prev: 'U.T. Yesterday', curr: 'Upper Transit', next: 'U.T. Tomorrow' },
    'S': { prev: 'Set Yesterday', curr: 'Sets', next: 'Sets Tomorrow' }
  };
  return mapping[code]?.[tense] || code;
};

// Calculate moon age and phase
const calculateMoonData = (data) => {
  const today = new Date();
  const synodicMonth = 29.530588853;
  const newMoon = new Date('03/09/2016 01:54 GMT');
  const msPerDay = 1000 * 60 * 60 * 24;
  const daysPassed = (today.getTime() - newMoon.getTime()) / msPerDay;
  let moonAge = daysPassed % synodicMonth;

  // Calculate phase index (0-7)
  let phaseIndex = getMoonPhaseIndex(moonAge);

  // Determine current phase name
  let curphase = data.curphase || data.closestphase?.phase || phases[phaseIndex].name;

  // Adjust for key phases
  if (curphase === "New Moon") phaseIndex = 0;
  if (curphase === "First Quarter") phaseIndex = 2;
  if (curphase === "Full Moon") phaseIndex = 4;
  if (curphase === "Last Quarter" || curphase === "Third Quarter") phaseIndex = 6;

  // Adjust phase name for key illuminations
  if (data.illum === "0") {
    curphase = "New Moon";
    phaseIndex = 0;
  }
  if (data.illum === "50" && moonAge < (synodicMonth / 2)) {
    curphase = "First Quarter";
    phaseIndex = 2;
  }
  if (data.illum === "100") {
    curphase = "Full Moon";
    phaseIndex = 4;
  }
  if (data.illum === "50" && moonAge > (synodicMonth / 2)) {
    curphase = "Last Quarter";
    phaseIndex = 6;
  }

  return {
    moonAge: moonAge.toFixed(1),
    phaseIndex,
    curphase
  };
};

// Styling
export const className = {
  color: config.option.fontColor,
  textAlign: 'center',
  fontFamily: config.option.fontName,
  left: '60px',
  top: '1000px',
  backgroundColor: `rgba(255, 255, 255, ${config.option.widgetOpacity})`,
  borderRadius: '25px',
  lineHeight: '1.5',
  padding: '15px'
};

// CSS for styling
export const style = `
  .moon-widget {
    color: ${config.option.fontColor};
  }

  .moon-widget .moon-current {
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .moon-widget .moon-icon {
    margin-right: ${config.option.fontSize}px;
    line-height: 1;
    flex-shrink: 0;
  }

  .moon-widget .moon-icon svg {
    display: block;
  }

  .moon-widget .moon-data {
    text-align: left;
  }

  .moon-widget .moon-phase {
    font-size: ${config.option.fontSize * 1.5}px;
    font-weight: bold;
  }

  .moon-widget .moon-city {
    font-size: ${config.option.fontSize * 1.25}px;
  }

  .moon-widget .moon-coords {
    font-size: ${config.option.fontSize * 0.80}px;
  }

  .moon-widget .moon-age,
  .moon-widget .moon-illum {
    font-size: ${config.option.fontSize}px;
  }

  .moon-widget .moon-separator {
    border-top: ${config.option.fontSize / 7.5}px solid rgba(255, 255, 255, 0.5);
    margin: ${config.option.fontSize / 2}px 0;
  }

  .moon-widget .moon-phennames {
    display: flex;
    justify-content: space-between;
    margin-bottom: 5px;
  }

  .moon-widget .moon-phennames > div {
    color: rgba(${config.option.fontColorMuted}, 0.5);
    font-size: ${config.option.fontSize * 0.70}px;
    width: 30%;
    text-align: center;
  }

  .moon-widget .moon-phentimes {
    display: flex;
    justify-content: space-between;
  }

  .moon-widget .moon-phentimes > div {
    font-size: ${config.option.fontSize}px;
    width: 30%;
    text-align: center;
  }

  .moon-widget .moon-closest {
    font-size: ${config.option.fontSize * 0.85}px;
  }

  .moon-widget .error {
    font-size: ${config.option.fontSize}px;
    color: #FF0000;
    background: rgba(0, 0, 0, 0.5);
    padding: 10px;
    border-radius: 5px;
  }
`;

// Main render component
export const render = ({ output, error }) => {
  // Handle errors
  if (error) {
    return (
      <div className="moon-widget">
        <div className="error">
          Moon phase widget error: {String(error)}
        </div>
      </div>
    );
  }

  // Handle no output yet
  if (!output) {
    return (
      <div className="moon-widget">
        <div style={{ fontSize: config.option.fontSize }}>
          Loading moon data...
        </div>
      </div>
    );
  }

  // Handle empty output
  if (output.trim() === '') {
    return (
      <div className="moon-widget">
        <div className="error">
          No data received. Check if the shell script exists at:<br/>
          moon-phase.widget/get-phase.sh
        </div>
      </div>
    );
  }

  let data;
  try {
    data = JSON.parse(output);
  } catch (e) {
    return (
      <div className="moon-widget">
        <div className="error">
          Failed to parse moon data<br/>
          Raw output: {output.substring(0, 100)}...
        </div>
      </div>
    );
  }

  if (data?.error) {
    return (
      <div className="moon-widget">
        <div className="error">{data.message || 'Error fetching moon data'}</div>
      </div>
    );
  }

  const { moonAge, phaseIndex, curphase } = calculateMoonData(data);
  const moonSVG = generateMoonSVG(phaseIndex, config.option.fontSize * 7, config.option.iconColor);
  const opt = config.option;

  // Prepare coordinates
  let coords = '';
  if (opt.showCoords && data.lat !== undefined && data.lon !== undefined) {
    const latCard = data.lat > 0 ? 'N' : 'S';
    const lonCard = data.lon > 0 ? 'E' : 'W';
    const lat = Math.abs(data.lat.toFixed(2));
    const lon = Math.abs(data.lon.toFixed(2));
    coords = `${lat}°${latCard} ${lon}°${lonCard}`;
  }

  // Prepare phenomena data
  let phenNames = [];
  let phenTimes = [];
  if (opt.showRUS && data.moondata) {
    const count = data.moondata.length;
    
    if (count < 3 && data.prevmoondata) {
      phenNames.push(returnPhenNames(data.prevmoondata[0].phen, 'prev'));
      const time = opt.showAMPM ? returnAMPM(data.prevmoondata[0].time) : data.prevmoondata[0].time;
      phenTimes.push(time);
    }
    
    data.moondata.forEach(d => {
      phenNames.push(returnPhenNames(d.phen, 'curr'));
      const time = opt.showAMPM ? returnAMPM(d.time) : d.time;
      phenTimes.push(time);
    });
    
    if (count < 3 && data.nextmoondata) {
      phenNames.push(returnPhenNames(data.nextmoondata[0].phen, 'next'));
      const time = opt.showAMPM ? returnAMPM(data.nextmoondata[0].time) : data.nextmoondata[0].time;
      phenTimes.push(time);
    }
  }

  // Prepare closest phase data
  let closestPhase = null;
  if (opt.showClosest && data.closestphase) {
    const today = new Date();
    const clday = new Date(data.closestphase.date + " " + data.closestphase.time);
    const clause = clday.getTime() > today.getTime() ? 'is' : 'was';
    const time = opt.showAMPM ? returnAMPM(data.closestphase.time) : data.closestphase.time;
    
    closestPhase = {
      text: `Closest phase ${clause} ${data.closestphase.phase}`,
      date: opt.showCloseDay ? `on ${data.closestphase.date} at ${time}` : null
    };
  }

  return (
    <div className="moon-widget">
      <div className="moon-current">
        <div className="moon-icon" dangerouslySetInnerHTML={{ __html: moonSVG }} />
        <div className="moon-data">
          <div className="moon-phase">{curphase}</div>
          {opt.showCity && data.city && (
            <div className="moon-city">{data.city}</div>
          )}
          {opt.showCoords && coords && (
            <div className="moon-coords">{coords}</div>
          )}
          {opt.showAge && (
            <div className="moon-age">{moonAge} days old</div>
          )}
          {opt.showIllum && data.illum !== undefined && (
            <div className="moon-illum">{data.illum}% illumination</div>
          )}
        </div>
      </div>

      {opt.showRUS && phenNames.length > 0 && (
        <>
          <div className="moon-separator" />
          <div className="moon-phennames">
            {phenNames.map((name, i) => (
              <div key={i}>{name}</div>
            ))}
          </div>
          <div className="moon-phentimes">
            {phenTimes.map((time, i) => (
              <div key={i}>{time}</div>
            ))}
          </div>
        </>
      )}

      {closestPhase && (
        <>
          <div className="moon-separator" />
          <div className="moon-closest">
            <div>{closestPhase.text}</div>
            {closestPhase.date && <div>{closestPhase.date}</div>}
          </div>
        </>
      )}
    </div>
  );
};