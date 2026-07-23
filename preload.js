const { contextBridge, ipcRenderer } = require("electron");

contextBridge.exposeInMainWorld("desktopCursor", {
  onPosition(callback) {
    ipcRenderer.on("cursor-position", (_event, position) => callback(position));
  },
  onButton(callback) {
    ipcRenderer.on("cursor-button", (_event, button) => callback(button));
  }
});
