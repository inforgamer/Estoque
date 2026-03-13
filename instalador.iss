[Setup]
AppName=Estoque 
AppVersion=1.0
DefaultDirName={autopf}\Estoque
DefaultGroupName=Estoque
SetupIconFile=icon.ico
Compression=lzma
SolidCompression=yes

[Files]
Source: "build\windows\x64\runner\Release\sistema_estoque.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "build\windows\x64\runner\Release\*.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs
; Aqui ele busca o servidor e o .env
Source: "dist\servidor.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: ".env"; DestDir: "{app}"; Flags: ignoreversion
Source: "Estoque.bat"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{commondesktop}\Estoque "; Filename: "{app}\Estoque.bat"; IconFilename: "{app}\favicon.ico"

[Run]
Filename: "{app}\Estoque.bat"; Description: "Lançar App"; Flags: postinstall nowait