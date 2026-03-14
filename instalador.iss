[Setup]
AppName=Estoque
AppVersion=1.0
DefaultDirName={autopf}\Estoque
DefaultGroupName=Estoque
UninstallDisplayIcon={app}\sistema_estoque.exe
Compression=lzma
SolidCompression=yes
OutputDir=userdocs:Inno Setup Output

[Files]
Source: "C:\Caminho\Para\Seus\Arquivos\sistema_estoque.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Caminho\Para\Seus\Arquivos\*.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Caminho\Para\Seus\Arquivos\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs
Source: "C:\Caminho\Para\Seus\Arquivos\servidor.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Caminho\Para\Seus\Arquivos\.env"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Caminho\Para\Seus\Arquivos\launcher.vbs"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{commondesktop}\Estoque"; Filename: "wscript.exe"; Parameters: """{app}\launcher.vbs"""; IconFilename: "{app}\sistema_estoque.exe"

[Run]
Filename: "wscript.exe"; Parameters: """{app}\launcher.vbs"""; Description: "Lançar Estoque"; Flags: postinstall nowait