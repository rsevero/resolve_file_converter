# Windows installer

This project uses Inno Setup to create an installable Windows `.exe`, following the same general approach used by Mapiah.

## Output

- `Resolve-Media-Converter-v<version>-windows-x64.exe`

## Local packaging outline

1. Build the Windows release:

```bash
flutter build windows --release
```

2. Compile the installer with Inno Setup using `packaging/windows/resolve_media_converter.iss`

The GitHub Actions workflow automates these steps for tagged releases.
