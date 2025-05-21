INCLUDE common.inc

public g_handle
public g_coord

.data
g_handle DWORD 0
g_coord DWORD 0

Menu PROTO

.code
Init PROC
	push ebp
	mov ebp,esp
	sub esp,30h
	; get console handle
	push -11
	call GetStdHandle
	mov DWORD PTR [g_handle],eax
	; get console size
	mov eax,ebp
	sub eax,22
	push eax
	push DWORD PTR [g_handle]
	call GetConsoleScreenBufferInfo
	mov eax,DWORD PTR [ebp - 22]
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
	push DWORD PTR [g_handle]
	call GetConsoleCursorInfo
	mov DWORD PTR [ebp - 4],0
	mov eax,ebp
	sub eax,8
	push eax
	push DWORD PTR [g_handle]
	call SetConsoleCursorInfo
	add esp,30h
	pop ebp
	ret
Init ENDP

main PROC
	call Init
	mov eax,DWORD PTR [g_handle]
	mov ebx,DWORD PTR [g_coord]
	call Menu
	push 0
	call ExitProcess
main ENDP
END main
