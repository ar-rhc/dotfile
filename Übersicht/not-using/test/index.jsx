import { React, styled } from "uebersicht";

// Styled components for our two display states
const LargeDisplay = styled("div")`
  width: 400px;
  height: 400px;
  background-color: black;
  position: absolute;
  top: 20px;
  left: 20px;
  cursor: pointer;
`;

const SmallDisplay = styled("div")`
  width: 10px;
  height: 10px;
  background-color: red;
  position: absolute;
  top: 20px;
  left: 20px;
  cursor: pointer;
`;

// Initial state
export const initialState = {
  isLargeDisplay: true,
};

// Command (not used in this widget, but required by Übersicht)
export const command = "echo";

// Update state function
export const updateState = (event, previousState) => {
  if (event.type === 'TOGGLE_DISPLAY') {
    return {
      ...previousState,
      isLargeDisplay: !previousState.isLargeDisplay,
    };
  }
  return previousState;
};

// Render function
export const render = ({ isLargeDisplay }, dispatch) => {
  const handleDoubleClick = () => {
    dispatch({ type: 'TOGGLE_DISPLAY' });
  };

  return isLargeDisplay ? (
    <LargeDisplay onDoubleClick={handleDoubleClick} />
  ) : (
    <SmallDisplay onDoubleClick={handleDoubleClick} />
  );
};