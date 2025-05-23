.386
.model flat,stdcall

INCLUDELIB ucrt.lib
INCLUDELIB legacy_stdio_definitions.lib

printf PROTO C :DWORD,:VARARG
snprintf PROTO C :DWORD,:DWORD,:DWORD,:VARARG
strlen PROTO C :DWORD
_time64 PROTO C :DWORD
srand PROTO C :DWORD
rand PROTO C
_kbhit PROTO C
_getch PROTO C


GetStdHandle PROTO :DWORD
GetConsoleCursorInfo PROTO :DWORD,:DWORD
SetConsoleCursorInfo PROTO :DWORD,:DWORD
GetConsoleScreenBufferInfo PROTO :DWORD,:DWORD
SetConsoleCursorPosition PROTO :DWORD,:DWORD
ReadConsoleInputA PROTO :DWORD,:DWORD,:DWORD,:DWORD
WriteConsoleOutputCharacterA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
WriteConsoleOutputAttribute PROTO :DWORD,:WORD,:DWORD,:DWORD,:DWORD
WriteConsoleA PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
CreateConsoleScreenBuffer PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
SetConsoleActiveScreenBuffer PROTO :DWORD
GetLastError PROTO
ExitProcess PROTO :DWORD
