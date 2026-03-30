import { css, React } from "uebersicht";

const options = {
  top: "900px",
  left: "20px",
  width: "1000px",
  remoteHost: "alex@192.168.68.118", // Remote host information
};

export const command = `ssh ${options.remoteHost} 'docker ps -a'`;

export const refreshFrequency = 50000; // Refresh every 50 seconds

export const initialState = {
  warning: false,
  containers: [],
  isLargeDisplay: true,
};

const containerClassName = css({
  color: "#FFF",
  fontFamily: "PT Mono",
  userSelect: "none",
  backgroundColor: "rgba(0, 0, 0, 0.8)",
  padding: "5px",
  boxSizing: "border-box",
  borderRadius: "5px",
  position: "absolute",
  top: options.top,
  left: options.left,
});

const largeDisplayClassName = css({
  width: options.width,
});

const smallDisplayClassName = css({
  width: "30px",
  height: "30px",
  display: "flex",
  justifyContent: "center",
  alignItems: "center",
  fontSize: "20px",
  cursor: "pointer",
});

const tableClassName = css({
  width: "100%",
  marginTop: "3px",
});

const titleClassName = css({
  textAlign: "center",
  color: "#5DADE2",
  fontWeight: "bold",
  fontSize: "14px",
});

const tableHeadingClassName = css({
  textAlign: "left",
  color: "#5DADE2",
  fontSize: "12px",
});

const tableCellClassName = css({
  paddingTop: "3px",
  paddingBottom: "3px",
  fontSize: "12px",
});

export const updateState = (event, previousState) => {
  if (event.type === 'TOGGLE_DISPLAY') {
    return { ...previousState, isLargeDisplay: !previousState.isLargeDisplay };
  }

  if (event.error) {
    return { ...previousState, warning: `Error: ${event.error}` };
  }

  const lines = event.output.split("\n");
  const containers = [];

  for (let i = 1; i < lines.length - 1; i++) {
    const line = lines[i];
    const lineParts = line.split(/[ ]{2,}/);

    if (lineParts.length >= 6) {
      containers.push({
        containerId: lineParts[0],
        image: lineParts[1],
        command: lineParts[2],
        status: lineParts[4],
        ports: lineParts.length === 7 ? lineParts[5] : "-",
        containerName: lineParts[lineParts.length - 1],
      });
    }
  }

  return {
    ...previousState,
    warning: false,
    containers: containers,
  };
};

export const render = ({ warning, containers, isLargeDisplay }, dispatch) => {
  const handleDoubleClick = () => {
    dispatch({ type: 'TOGGLE_DISPLAY' });
  };

  const commonContent = (
    <link
      rel="stylesheet"
      href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.1/css/all.min.css"
      integrity="sha512-+4zCK9k+qNFUR5X+cKL9EIR+ZOhtIloNl9GIKS57V1MyNsYpYcUrUeQc9vNfzsWfV28IaLL3i96P9sdNyeRssA=="
      crossOrigin="anonymous"
    />
  );

  if (!isLargeDisplay) {
    return (
      <div className={`${containerClassName} ${smallDisplayClassName}`} onDoubleClick={handleDoubleClick}>
        {commonContent}
        <i className="fab fa-docker"></i>
      </div>
    );
  }

  if (warning) {
    return (
      <div className={`${containerClassName} ${largeDisplayClassName}`} onDoubleClick={handleDoubleClick}>
        {commonContent}
        <div className={titleClassName}>
          <i className="fab fa-docker"></i> {warning}
        </div>
      </div>
    );
  }

  if (containers.length === 0) {
    return (
      <div className={`${containerClassName} ${largeDisplayClassName}`} onDoubleClick={handleDoubleClick}>
        {commonContent}
        <div className={titleClassName}>
          <i className="fab fa-docker"></i> No Docker containers on remote host
        </div>
      </div>
    );
  }

  return (
    <div className={`${containerClassName} ${largeDisplayClassName}`} onDoubleClick={handleDoubleClick}>
      {commonContent}
      <div className={titleClassName}>
        <i className="fab fa-docker"></i> Remote Docker Processes
      </div>
      <table className={tableClassName}>
        <thead>
          <tr>
            <th className={tableHeadingClassName}>ID</th>
            <th className={tableHeadingClassName}>Image</th>
            <th className={tableHeadingClassName}>Status</th>
            <th className={tableHeadingClassName}>Ports</th>
            <th className={tableHeadingClassName}>Name</th>
          </tr>
        </thead>
        <tbody>
          {containers.map(container => (
            <tr key={container.containerId}>
              <td className={tableCellClassName}>
                {container.containerId.substr(0, 6)}
              </td>
              <td className={tableCellClassName}>{container.image}</td>
              <td className={tableCellClassName}>{container.status}</td>
              <td className={tableCellClassName}>{container.ports}</td>
              <td className={tableCellClassName}>{container.containerName}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};