@echo off
title Estoque Pro - Iniciando Sistemas
echo Iniciando Servidor Python...
start "" /b "servidor.exe"
timeout /t 3 /nobreak > nul
echo Abrindo Interface Flutter...
start "" "sistema_estoque.exe"
exit