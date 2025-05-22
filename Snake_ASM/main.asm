INCLUDE common.inc

public g_inputHandle
public g_coord
public g_currentActiveBuffer
public g_pendingBuffer

.data
g_inputHandle DWORD 0
g_currentActiveBuffer DWORD 0
g_pendingBuffer DWORD 0
g_coord DWORD 0

Game PROTO
Menu PROTO

.code
Init PROC
	push ebp
	mov ebp,esp
	sub esp,30h
	; get console handle
	push -10
	call GetStdHandle
	mov DWORD PTR [g_inputHandle],eax
	push -11
	call GetStdHandle
	mov DWORD PTR [g_currentActiveBuffer],eax
	; create new buffer
	push 0;
	push 1; console model
	push 0
	push 0; shared mode
	push 40000000h; desired access
	call CreateConsoleScreenBuffer
	mov DWORD PTR [g_pendingBuffer],eax
	; get console size
	mov eax,ebp
	sub eax,22
	push eax
	push DWORD PTR [g_currentActiveBuffer]
	call GetConsoleScreenBufferInfo
	mov eax,DWORD PTR [ebp - 8]
	mov DWORD PTR [g_coord],eax
	; init random seed
	push 0
	call _time64
	add esp,4
	push eax
	call srand
	add esp,4
	; close the console cursor
	mov eax,ebp
	sub eax,8
	push eax
	push DWORD PTR [g_currentActiveBuffer]
	call GetConsoleCursorInfo
	mov DWORD PTR [ebp - 4],0
	mov eax,ebp
	sub eax,8
	push eax
	push DWORD PTR [g_currentActiveBuffer]
	call SetConsoleCursorInfo
	mov eax,ebp
	sub eax,8
	push eax
	push DWORD PTR [g_pendingBuffer]
	call SetConsoleCursorInfo
	add esp,30h
	pop ebp
	ret
Init ENDP

main PROC
	call Init
	mov eax,DWORD PTR [g_currentActiveBuffer]
	mov ebx,DWORD PTR [g_pendingBuffer]
	call Menu
	cmp eax,0
	je exit
Exit:
	Call Game

W:
	jmp W
	push 0
	call ExitProcess
main ENDP
END main
