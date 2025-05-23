INCLUDE common.inc

extern g_coord :DWORD
extern g_currentActiveBuffer :DWORD
extern g_pendingBuffer :DWORD

.code
CalcuCenterCoord PROC
; param1 xUsedLength yUsedLength
; assert(xUsedLength <= g_coord.x)
; assert(yUsedLength <= g_coord.y)
; return center coord
	push ebp
	mov ebp,esp
	mov eax,DWORD PTR [g_coord]
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

FillRow PROC
; param1 word*,param2 length,param3 word value
; not modify all registers
	push ebp
	mov ebp,esp
	pushad
	cld
	mov eax,DWORD PTR [ebp + 16]
	mov edi,DWORD PTR [ebp + 8]
	mov ecx,DWORD PTR [ebp + 12]
	REP STOSW
	popad
	pop ebp
	ret
FillRow ENDP

FillColumn PROC
; param1 word*,param2 rowLength,param3 columnLength,param4 word value
; not modify all registers
	push ebp
	mov ebp,esp
	pushad
	mov eax,DWORD PTR [ebp + 8] ; word*
	mov ebx,DWORD PTR [ebp + 16] ; columnLength
	SAL ebx,1
	mov ecx,DWORD PTR [ebp + 12] ; rowLength
	mov dx,WORD PTR [ebp + 20] ; value
	FILLC:
		mov WORD PTR [eax],dx
		add eax,ebx
		LOOP FILLC
	popad
	pop ebp
	ret
FillColumn ENDP

FillBorder PROC
; param1 word*,param2 rowLength,param3 columnLength,param4 word value,param5 columnFactor
	push ebp
	mov ebp,esp
	pushad
	; first row
	mov esi,DWORD PTR [ebp + 8] ; word*
	push DWORD PTR [ebp + 20] ; value
	push DWORD PTR [ebp + 16] ; columnLength
	push esi; word*
	call FillRow
	add esp,12
	;first column
	push DWORD PTR [ebp + 20] ; value
	mov ebx,DWORD PTR [ebp + 16]; columnLength
	add ebx,DWORD PTR [ebp + 24] ; column + columnFactor
	push ebx
	push DWORD PTR [ebp + 12] ; rowLength
	push esi; word*
	call FillColumn
	add esp,16
	;; last row
	mov eax,DWORD PTR [ebp + 12] ; rowLength
	sub eax,1; rowLength -= 1
	mov ecx,DWORD PTR [ebp + 16] ; columnLength
	add ecx,DWORD PTR [ebp + 24] ; column + columnFactor
	sal ecx,1 ; columnLength *= 2
	mul ecx ; rowLength = (rowLength - 1) * columnLength * 2
	add esi,eax
	push DWORD PTR [ebp + 20] ; value
	push DWORD PTR [ebp + 16] ; columnLength
	push esi
	call FillRow
	add esp,12
	;; last column
	mov esi,DWORD PTR [ebp + 8] ; word*
	mov eax,DWORD PTR [ebp + 16] ; columnLength
	sub eax,1; columnLength -= 1
	sal eax,1 ; columnLength *= 2
	add esi,eax
	push DWORD PTR [ebp + 20] ; value
	mov eax,DWORD PTR [ebp + 16]; columnLength
	add eax,DWORD PTR [ebp + 24] ; column + columnFactor
	push eax
	push DWORD PTR [ebp + 12] ; rowLength
	push esi
	call FillColumn
	add esp,16
	popad
	pop ebp
	ret
FillBorder ENDP

PrintStrs PROC
; param1 char** param2 length,param3 color**
	push ebp
	mov ebp,esp
	push esi
	push edi
	sub esp,20h
	mov esi,DWORD PTR [ebp + 8]
	mov edi,0
	mov DWORD PTR [ebp - 4],-1 ; cached length
	mov DWORD PTR [ebp - 8],-1 ; cached coord
	mov DWORD PTR [ebp - 12],0 ; temp
	mov DWORD PTR [ebp - 16],0; numberOfWritten
	mov ecx,DWORD PTR [ebp + 16] ; color**
	mov DWORD PTR [ebp - 20],ecx
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
			push eax ; save coord
			mov edx,ebp
			sub edx,16
			push edx; lpNumberOfCharsWritten
			push eax ; coord
			push DWORD PTR [ebp - 4] ; str length
			push DWORD PTR [ebp - 12] ; str
			push DWORD PTR [g_currentActiveBuffer] ; handle
			call WriteConsoleOutputCharacterA
			pop eax

			mov edx,ebp
			sub edx,16
			push edx; lpNumberOfCharsWritten
			push eax; coord
			push DWORD PTR [ebp - 4] ; length
			mov ecx,DWORD PTR [ebp - 20]; color**
			push DWORD PTR [ecx]; attributes  color*
			push DWORD PTR [g_currentActiveBuffer] ; handle
			call WriteConsoleOutputAttribute
			call GetLastError
		inc edi
		mov ecx,DWORD PTR [ebp - 20]; color**
		add ecx,4
		mov DWORD PTR [ebp - 20],ecx; update color**
		JMP PRINT
	QUIT:
	add esp,20h
	pop edi
	pop esi
	pop ebp
	ret
PrintStrs ENDP

SwapBuffer PROC
; no param no  return
	mov eax,DWORD PTR [g_currentActiveBuffer]
	XCHG eax,DWORD PTR [g_pendingBuffer]
	mov DWORD PTR [g_currentActiveBuffer],eax
	ret
SwapBuffer ENDP

GetRandomFromRange PROC
; param1 min param2 max ret in eax
; ret value in [min,max)
	push ebp
	mov ebp,esp
	push esi
	mov esi,DWORD PTR [ebp + 8]; min
	mov ecx,DWORD PTR [ebp + 12]; max
	sub ecx,esi
	push ecx
	call rand
	pop ecx
	xor edx,edx
	idiv ecx
	add edx,esi
	mov eax,edx
	pop esi
	pop ebp
	ret
GetRandomFromRange ENDP

END
