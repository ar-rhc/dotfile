import { css } from "uebersicht"

// Replace YOUR_API_KEY with your actual OpenWeather API key
const API_KEY = '7d8c8c78b0349fddf531411d6e583c83'
const CITY = 'Auckland'

export const command = `curl -s "http://api.openweathermap.org/data/2.5/forecast?q=${CITY}&units=metric&appid=${API_KEY}"`

export const refreshFrequency = 600000 // Refresh every 10 minutes

export const initialState = {
  error: null,
  currentWeather: null,
  forecast: [],
  city: null
}

const getWeatherIcon = (condition) => {
  switch (condition.toLowerCase()) {
    case 'clear': return '☀️';
    case 'clouds': return '☁️';
    case 'rain': return '🌧️';
    case 'snow': return '❄️';
    default: return '🌤️';
  }
}

export const updateState = (event, previousState) => {
  if (event.error) {
    return { ...previousState, error: `Error: ${event.error}` };
  }

  try {
    const data = JSON.parse(event.output);
    
    if (data.cod !== "200") {
      return { ...previousState, error: `API Error: ${data.message}` };
    }

    const currentWeather = {
      temp: Math.round(data.list[0].main.temp),
      condition: data.list[0].weather[0].main
    };

    const forecast = data.list.reduce((acc, item) => {
      const date = new Date(item.dt * 1000);
      const day = date.toLocaleString('en-US', { weekday: 'short' });
      if (!acc[day]) {
        acc[day] = {
          temp_min: item.main.temp_min,
          temp_max: item.main.temp_max,
          weather: item.weather[0].main
        };
      } else {
        acc[day].temp_min = Math.min(acc[day].temp_min, item.main.temp_min);
        acc[day].temp_max = Math.max(acc[day].temp_max, item.main.temp_max);
      }
      return acc;
    }, {});

    return {
      error: null,
      currentWeather,
      forecast: Object.entries(forecast).slice(0, 5),
      city: data.city.name
    };
  } catch (e) {
    return { ...previousState, error: `Parsing error: ${e.message}` };
  }
}

/// RENDER

export const render = ({ error, currentWeather, forecast, city }) => {
  if (error) {
    return <div className={errorStyle}>{error}</div>;
  }

  if (!currentWeather || forecast.length === 0) {
    return <div className={loadingStyle}>Loading weather data...</div>;
  }

  // Calculate the overall min and max temperatures
  const allTemps = forecast.flatMap(([_, data]) => [data.temp_min, data.temp_max]);
  const overallMin = Math.min(...allTemps);
  const overallMax = Math.max(...allTemps);
  const tempRange = overallMax - overallMin;

  // Function to calculate the position and height of temperature bars
  const calculateTempBar = (min, max) => {
    const avgTemp = (min + max) / 2;
    const centerPosition = 50; // Center of the bar
    const height = ((max - min) / tempRange) * 100;
    const top = centerPosition - (height / 2);
    
    return { 
      top: `${top}%`, 
      height: `${Math.max(height, 5)}%`, // Minimum height of 5% for visibility
    };
  };

  return (
    <div className={container}>
      <div className={header}>
        <div className={location}>{city}</div>
        <div className={separator}></div>
      </div>
      <div className={content}>
        <div className={currentWeatherStyle}>
          <div className={currentTempStyle}>{currentWeather.temp}°C</div>
          <div className={currentIcon}>{getWeatherIcon(currentWeather.condition)}</div>
          <div className={weatherDescription}>{currentWeather.condition}</div>
        </div>
        <div className={forecastStyle}>
          {forecast.map(([day, data], index) => (
            <div key={index} className={dayForecast}>
              <div className={dayName}>{day}</div>
              <div className={tempBarContainer}>
                <div className={tempBar}>
                  <div 
                    className={tempRange}
                    style={calculateTempBar(data.temp_min, data.temp_max)}
                  ></div>
                </div>
              </div>
              <div className={dayTemp}>
                <span className={highTemp}>{Math.round(data.temp_max)}°</span>
                <span className={lowTemp}>{Math.round(data.temp_min)}°</span>
              </div>
              <div className={dayIcon}>{getWeatherIcon(data.weather)}</div>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}

export const className = `
  top: 10px;
  left: 10px;
  font-family: Helvetica Neue, sans-serif;
  color: white;
  background: linear-gradient(to right, #4A0E4E, #81267B);
  padding: 20px;
  border-radius: 10px;
  width: 600px;
  height: 300px;
`

const container = css`
  display: flex;
  flex-direction: column;
  height: 100%;
`

const header = css`
  height: 20%;
`

const location = css`
  font-size: 24px;
  font-weight: bold;
`

const separator = css`
  height: 1px;
  background-color: rgba(255, 255, 255, 0.3);
  margin: 10px 0;
`

const content = css`
  display: flex;
  height: 80%;
`

const currentWeatherStyle = css`
  width: 33%;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
`

const currentTempStyle = css`
  font-size: 48px;
  font-weight: bold;
`

const currentIcon = css`
  font-size: 48px;
  margin: 10px 0;
`

const weatherDescription = css`
  font-size: 18px;
`

const forecastStyle = css`
  width: 67%;
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
`

const dayForecast = css`
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 18%;
`

const dayName = css`
  font-size: 14px;
  margin-bottom: 5px;
`

// Modify the tempBarContainer style to have a fixed height
const tempBarContainer = css`
  height: 100px;
  width: 10px;
  background-color: rgba(255, 255, 255, 0.2);
  border-radius: 5px;
  position: relative;
  margin: 5px auto;
`

const tempBar = css`
  width: 100%;
  height: 100%;
  position: absolute;
  top: 0;
  left: 0;
  border-radius: 5px;
  overflow: visible;
`

const tempRange = css`
  width: 100%;
  background-color: white;
  position: absolute;
  left: 0;
  border-radius: 5px;
`

const debugInfo = css`
  font-size: 10px;
  color: yellow;
  text-align: center;
  margin-top: 5px;
`

const dayTemp = css`
  font-size: 14px;
  margin-bottom: 5px;
  display: flex;
  flex-direction: column;
  align-items: center;
`

const highTemp = css`
  font-weight: bold;
`

const lowTemp = css`
  color: rgba(255, 255, 255, 0.7);
`

const dayIcon = css`
  font-size: 24px;
`

const errorStyle = css`
  color: red;
  font-size: 16px;
  padding: 10px;
  background-color: rgba(255, 255, 255, 0.8);
  border-radius: 5px;
  position: absolute;
  top: 10px;
  left: 10px;
  right: 10px;
`

const loadingStyle = css`
  color: white;
  font-size: 16px;
  padding: 10px;
  text-align: center;
`

