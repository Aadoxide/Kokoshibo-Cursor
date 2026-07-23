# Moon Breathing Cursor v1.0.0

Windows desktop build of the Moon Breathing cursor effect.

## Download

Use the release zip:

```text
Moon-Breathing-Cursor-win-x64-v1.0.0.zip
```

Extract the zip and run:

```text
Moon Breathing Cursor.exe
```

To stop the app and recover the normal cursor, run:

```text
Stop Moon Breathing Cursor.cmd
```

## Notes

- The app draws the animated cursor globally across the Windows desktop.
- The normal Windows cursor is temporarily hidden while the app runs.
- The normal cursor is restored when the app exits.
- A stop launcher is included to force-close the app and restore the normal cursor.
- If Windows cursor restoration is ever needed manually, run `npm run restore-cursor` from the source project.
