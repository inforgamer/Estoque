Set WshShell = CreateObject("WScript.Shell")

WshShell.Run "servidor.exe", 0, False

WScript.Sleep 2000

WshShell.Run "sistema_estoque.exe", 1, True