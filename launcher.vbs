Set WshShell = CreateObject("WScript.Shell")
strPath = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)
WshShell.CurrentDirectory = strPath

WshShell.Run Chr(34) & strPath & "\servidor.exe" & Chr(34), 0, False
WScript.Sleep 3000
WshShell.Run Chr(34) & strPath & "\sistema_estoque.exe" & Chr(34), 1, True
