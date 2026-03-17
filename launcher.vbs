Set WshShell = CreateObject("WScript.Shell")
WshShell.CurrentDirectory = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)
WshShell.Run "servidor.exe", 0, False
WScript.Sleep 3000
WshShell.Run "sistema_estoque.exe", 1, True
