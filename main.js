const { app, BrowserWindow, screen } = require("electron");
const { spawn, spawnSync } = require("child_process");
const path = require("path");

let overlay;
let cursorTimer;
let buttonWatcher;
let buttonBuffer = "";
let systemCursorHidden = false;

function getScriptPath(scriptName) {
  if (app.isPackaged) {
    return path.join(process.resourcesPath, "scripts", scriptName);
  }

  return path.join(__dirname, "scripts", scriptName);
}

function runCursorScript(scriptName) {
  const result = spawnSync(
    "powershell.exe",
    ["-NoProfile", "-ExecutionPolicy", "Bypass", "-File", getScriptPath(scriptName)],
    { windowsHide: true }
  );

  if (result.error || result.status !== 0) {
    const stderr = result.stderr ? result.stderr.toString() : "";
    console.error(`Failed to run ${scriptName}`, result.error || stderr);
    return false;
  }

  return true;
}

function hideSystemCursor() {
  if (process.env.MOON_CURSOR_KEEP_SYSTEM === "1") return;
  systemCursorHidden = runCursorScript("hide-windows-cursor.ps1");
}

function restoreSystemCursor() {
  if (!systemCursorHidden) return;
  runCursorScript("restore-windows-cursor.ps1");
  systemCursorHidden = false;
}

function startButtonWatcher() {
  buttonWatcher = spawn(
    "powershell.exe",
    ["-NoProfile", "-ExecutionPolicy", "Bypass", "-File", getScriptPath("watch-mouse-buttons.ps1")],
    { windowsHide: true }
  );

  buttonWatcher.stdout.on("data", (chunk) => {
    buttonBuffer += chunk.toString();
    const lines = buttonBuffer.split(/\r?\n/);
    buttonBuffer = lines.pop() || "";

    for (const line of lines) {
      if (!line.trim() || !overlay || overlay.isDestroyed()) continue;

      try {
        overlay.webContents.send("cursor-button", JSON.parse(line));
      } catch (error) {
        console.error("Failed to parse mouse button event", error);
      }
    }
  });

  buttonWatcher.stderr.on("data", (chunk) => {
    console.error(`Mouse button watcher: ${chunk}`);
  });

  buttonWatcher.on("exit", () => {
    buttonWatcher = null;
  });
}

function stopButtonWatcher() {
  if (!buttonWatcher) return;
  buttonWatcher.kill();
  buttonWatcher = null;
}

function getVirtualBounds() {
  const displays = screen.getAllDisplays();
  const left = Math.min(...displays.map((display) => display.bounds.x));
  const top = Math.min(...displays.map((display) => display.bounds.y));
  const right = Math.max(...displays.map((display) => display.bounds.x + display.bounds.width));
  const bottom = Math.max(...displays.map((display) => display.bounds.y + display.bounds.height));

  return {
    x: left,
    y: top,
    width: right - left,
    height: bottom - top
  };
}

function positionOverlay() {
  if (!overlay) return;
  overlay.setBounds(getVirtualBounds());
}

function createOverlay() {
  const bounds = getVirtualBounds();

  overlay = new BrowserWindow({
    ...bounds,
    frame: false,
    transparent: true,
    backgroundColor: "#00000000",
    hasShadow: false,
    resizable: false,
    movable: false,
    minimizable: false,
    maximizable: false,
    closable: true,
    focusable: false,
    skipTaskbar: true,
    fullscreenable: false,
    webPreferences: {
      preload: path.join(__dirname, "preload.js")
    }
  });

  overlay.setAlwaysOnTop(true, "screen-saver");
  overlay.setVisibleOnAllWorkspaces(true, { visibleOnFullScreen: true });
  overlay.setIgnoreMouseEvents(true, { forward: true });
  overlay.loadFile(path.join(__dirname, "index.html"), { query: { desktop: "1" } });

  cursorTimer = setInterval(() => {
    if (!overlay || overlay.isDestroyed()) return;
    const currentBounds = overlay.getBounds();
    const point = screen.getCursorScreenPoint();
    overlay.webContents.send("cursor-position", {
      x: point.x - currentBounds.x,
      y: point.y - currentBounds.y
    });
  }, 8);
}

app.whenReady().then(() => {
  hideSystemCursor();
  createOverlay();
  startButtonWatcher();
  screen.on("display-added", positionOverlay);
  screen.on("display-removed", positionOverlay);
  screen.on("display-metrics-changed", positionOverlay);
});

app.on("before-quit", () => {
  if (cursorTimer) clearInterval(cursorTimer);
  stopButtonWatcher();
  restoreSystemCursor();
});

app.on("window-all-closed", () => {
  app.quit();
});
