.386
.model flat,stdcall

INCLUDELIB ucrt.lib
INCLUDELIB legacy_stdio_definitions.lib

printf PROTO C :DWORD,:VARARG
strlen PROTO C :DWORD
_time64 PROTO C :DWORD
srand PROTO C :DWORD
rand PROTO C


GetStdHandle PROTO :DWORD
GetConsoleCursorInfo PROTO :DWORD,:DWORD
SetConsoleCursorInfo PROTO :DWORD,:DWORD
GetConsoleScreenBufferInfo PROTO :DWORD,:DWORD
SetConsoleCursorPosition PROTO :DWORD,:DWORD
GetLastError PROTO
ExitProcess PROTO :DWORD

; CalcuCenterCoord PROTO :DWORD
