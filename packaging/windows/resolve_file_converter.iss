#define AppVersion GetStringFileInfo("C:\resolve_file_converter\build\windows\x64\runner\Release\resolve_file_converter.exe", "ProductVersion")

[Setup]
AppName=Resolve File Converter
AppVersion={#AppVersion}
AppPublisher=Resolve File Converter
AppPublisherURL=https://github.com/rsevero/resolve_file_converter
DefaultDirName={commonpf}\Resolve File Converter
DefaultGroupName=Resolve File Converter
OutputDir=C:\resolve_file_converter\build\windows-installer
OutputBaseFilename=Resolve-File-Converter-v{#AppVersion}-windows-x64
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Files]
Source: "C:\resolve_file_converter\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Resolve File Converter"; Filename: "{app}\resolve_file_converter.exe"
Name: "{group}\Uninstall Resolve File Converter"; Filename: "{uninstallexe}"

[Run]
Filename: "{app}\resolve_file_converter.exe"; Description: "Launch Resolve File Converter"; Flags: nowait postinstall skipifsilent
