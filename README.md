# Moon Breathing Desktop Cursor

This wraps Faiz's website-only moon breathing cursor as a transparent Windows desktop overlay. The app follows the real system cursor and draws the cursor canvas effect across the whole desktop.

## Run

```powershell
npm install
npm start
```

This starts the transparent overlay and temporarily hides the normal Windows cursor.

If you want to test the overlay while keeping the normal Windows cursor visible:

```powershell
$env:MOON_CURSOR_KEEP_SYSTEM = "1"
npm start
```

The packaged `.exe` also hides the Windows cursor while it is running and restores it when it exits.

For the precompiled GitHub zip, use this file to force-stop the app and restore the cursor:

```text
Stop Moon Breathing Cursor.cmd
```

If you ever need to restore the Windows cursor manually:

```powershell
npm run restore-cursor
```

## Build the (windows) app

```powershell
npm run build:win
```

The packaged app will be created under `dist/win-unpacked`. Run `Moon Breathing Cursor.exe` from that folder.

## IMPORTANT

Electron draws the animated effect globally. On startup, the app uses Windows system cursor APIs to temporarily swap the normal cursor shapes for transparent ones. On exit, it restores them.

To exit the overlay while testing, stop it from the terminal with `Ctrl+C`.
