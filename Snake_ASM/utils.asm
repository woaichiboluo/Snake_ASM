INCLUDE common.inc

extern g_handle :DWORD
extern g_coord :DWORD

.code
CalcuCenterCoord PROC
; param1 xUsedLength yUsedLength
; assert(xUsedLength <= g_coord.x)
; assert(yUsedLength <= g_coord.y)
	push ebp
	mov ebp,esp
	; solve x
	xor eax,eax
	mov ax,WORD PTR [g_coord]
	sub ax,WORD PTR [ebp + 8]
	SAR ax,1
	; solve y
	xor edx,edx
	mov dx,WORD PTR [g_coord + 2]
	sub dx,WORD PTR [ebp + 10]
	SAR dx,1
	SAL edx,16
	or edx,eax
	mov eax,edx
	pop ebp
	ret
CalcuCenterCoord ENDP

PrintStrs PROC
; param1 char** param2 length
	push ebp
	mov ebp,esp
	push esi
	push edi
	sub esp,20h
	mov esi,DWORD PTR [ebp + 8]
	mov edi,0
	mov DWORD PTR [ebp - 4],-1 ; cached length
	mov DWORD PTR [ebp - 8],-1 ; cached coord
	PRINT:
		cmp edi,DWORD PTR [ebp + 12]
		JGE QUIT
		LODSD
		mov DWORD PTR [ebp - 12],eax; char**[i]
		push DWORD PTR [ebp - 12]
		call strlen
		add esp,4
		cmp eax,DWORD PTR [ebp - 4]
		je USECACHE
		; recache
		mov DWORD PTR [ebp - 4],eax; update cached length
		mov ebx,DWORD PTR [ebp + 12] ; y length
		SAL ebx,16
		mov bx,ax; x length
		push ebx
		call CalcuCenterCoord
		add esp,4
		mov DWORD PTR [ebp - 8],eax; update cached coord
		USECACHE:
			mov eax,DWORD PTR [ebp - 8]; cached coord
			mov edx,edi
			SAL edx,16
			add eax,edx ;add y offset
			push eax; COORD
			push DWORD PTR [g_handle]; handle
			call SetConsoleCursorPosition
			; Do Printf
			push DWORD PTR [ebp - 12]
			call printf
			add esp,4
		inc edi
		JMP PRINT
	QUIT:
	add esp,20h
	pop edi
	pop esi
	pop ebp
	ret
PrintStrs ENDP
END
