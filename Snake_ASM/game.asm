INCLUDE common.inc

extern g_inputHandle :DWORD
extern g_coord :DWORD
extern g_currentActiveBuffer :DWORD
extern g_pendingBuffer :DWORD

PrintStrs PROTO
SwapBuffer PROTO
FillRow PROTO
FillColumn PROTO
FillBorder PROTO
GetRandomFromRange PROTO

.data
MapSize = 5
map WORD MapSize*MapSize DUP(0)
EMPTY = 0
BORDER = 1
SNAKE = 2
FOOD = 3
scoreFmt BYTE "Your score: %d",0
scoreMsg BYTE "Score:",0
mapRawData BYTE MapSize DUP(2 * (MapSize + 1) DUP(0))
mapRawColor WORD MapSize + 2 DUP(2 * MapSize DUP(6))
emptyItem BYTE "  ",0,0,0
mapItem BYTE "¡ö",0,0,0
score DWORD 0
PAD BYTE " ",0

; for print
pMapRawData DWORD offset scoreMsg, offset PAD,MapSize DUP(0) ; char**
pMapRawColor DWORD MapSize + 2 DUP(0) ; color**
EMPTYCOLOR = 1
BORDERCOLOR = 2
SNAKECOLOR = 3
FOODCOLOR = 3

; for snake
snakeArr DWORD (MapSize - 2) * (MapSize - 2) DUP(0) ; save snake (x,y) x in low byte,y in high byte
snakeHead DWORD -1

.code
InitMap PROC
	push ebp
	mov ebp,esp
	push esi
	push edi
	; fill map border
	mov eax,offset map
	push 0
	push BORDER
	push MapSize
	push MapSize
	push eax
	mov eax,offset map
	call FillBorder
	add esp,20
	; fill mapRawColor border
	; fill first line for score color
	mov eax,offset mapRawColor
	push BORDERCOLOR
	push 2 * MapSize
	push eax
	call FillRow
	add esp,12
	; init pMapRawData and pMapRawColor
	mov eax,offset mapRawData
	mov ebx,offset pMapRawData
	add ebx,8
	mov esi,offset mapRawColor
	mov edi,offset pMapRawColor
	mov ecx,MapSize
	DOINIT:
		mov DWORD PTR [ebx],eax
		add eax,2 * (MapSize + 1)
		add ebx,4
		mov DWORD PTR [edi],esi
		add esi,2 * MapSize * 2
		add edi,4
		LOOP DOINIT
	; remaining two rows
	mov DWORD PTR [edi],esi
	add esi,2 * MapSize * 2
	add edi,4
	mov DWORD PTR [edi],esi
	add esi,2 * MapSize * 2
	add edi,4
	pop edi
	pop esi
	pop ebp
	ret
InitMap ENDP

UpdateMap PROC ;updatemapRawData through map
	push ebp
	mov ebp,esp
	push esi
	sub esp,20h
	mov DWORD PTR [ebp - 4],MapSize - 1
	mov eax,offset mapRawData
	mov ebx,offset mapRawColor
	add ebx,2 * MapSize * 2 * 2
	mov ecx,0
	mov edx,offset map
	UPDATE:
		cmp ecx,MapSize * MapSize
		jae UPDATEDONE
		cmp WORD PTR [edx],EMPTY
		jne CASEBORDER
		mov si,WORD PTR [emptyItem]
		mov WORD PTR [eax],si
		mov WORD PTR [ebx],EMPTYCOLOR
		mov WORD PTR [ebx + 2],EMPTYCOLOR
		jmp DONEXT
		CASEBORDER:
			cmp WORD PTR [edx],BORDER
			jne CASESNAKE
			mov si,WORD PTR [mapItem]
			mov WORD PTR [eax],si
			mov WORD PTR [ebx],BORDERCOLOR
			mov WORD PTR [ebx + 2],BORDERCOLOR
			jmp DONEXT
		CASESNAKE:
			cmp WORD PTR [edx],SNAKE
			jne CASEFOOD
			mov si,WORD PTR [mapItem]
			mov WORD PTR [eax],si
			mov WORD PTR [ebx],SNAKECOLOR
			mov WORD PTR [ebx + 2],SNAKECOLOR
			jmp DONEXT
		CASEFOOD:
			mov si,WORD PTR [mapItem]
			mov WORD PTR [eax],si
			mov WORD PTR [ebx],FOODCOLOR
			mov WORD PTR [ebx + 2],FOODCOLOR
		DONEXT:
			cmp ecx,DWORD PTR [ebp - 4]
			jne TONEXT
			add eax,2 ; skip the \0
			add DWORD PTR [ebp - 4],MapSize
			TONEXT:
				add eax,2
				add ebx,4
				add edx,2
				inc ecx
				JMP UPDATE
	UPDATEDONE:
	add esp,20h
	pop esi
	pop ebp
	ret
UpdateMap ENDP

TraversalSnake PROC
; param1 value
	push ebp
	mov ebp,esp
	push esi
	push edi
	mov ecx,0
	lea edx,snakeArr
	ADDSNAKE:
		cmp ecx,DWORD PTR [snakeHead]
		jg ADDDONE
		mov esi,DWORD PTR [edx + ecx * 4] 
		and esi,0FFFFh ; x
		mov edi,DWORD PTR [edx + ecx * 4] 
		sar edi,16 ; y
		mov eax,edi
		mov ebx,MapSize
		mul ebx ; eax = y * MapSize
		add eax,esi ; eax = y * MapSize + x
		sal eax,1 ; eax = 2 * x * MapSize + y
		mov edx,offset map
		add edx,eax
		mov si,WORD PTR [ebp + 4] ; value
		mov WORD PTR [edx],si
		inc ecx
		jmp ADDSNAKE
	ADDDONE:
	pop edi
	pop esi
	pop ebp
	ret
TraversalSnake ENDP

InsertSnakeNode PROC
; param1 x param2 y
	push ebp
	mov ebp,esp
	mov eax,DWORD PTR [ebp + 8] ; x
	inc eax
	mov ebx,DWORD PTR [ebp + 12] ; y
	inc ebx
	sal ebx,16
	mov bx,ax
	mov eax,ebx
	mov ecx,DWORD PTR [snakeHead]
	add ecx,1
	mov DWORD PTR [snakeHead],ecx
	lea edx,snakeArr
	mov DWORD PTR [edx + ecx * 4],eax
	pop ebp
	ret
InsertSnakeNode ENDP

GenSnake PROC
	push ebp
	mov ebp,esp
	push MapSize - 2
	push 0
	call GetRandomFromRange
	add esp,8
	mov ebx,eax ; x
	push MapSize - 2
	push 0
	call GetRandomFromRange
	add esp,8
	push ebx
	push eax
	call InsertSnakeNode
	add esp,8
	push SNAKE
	call TraversalSnake
	add esp,4
	pop ebp
	ret
GenSnake ENDP

PrintMap PROC
	push ebp
	mov ebp,esp
	call UpdateMap
	call SwapBuffer
	push DWORD PTR [g_currentActiveBuffer]
	call SetConsoleActiveScreenBuffer
	push offset pMapRawColor
	push MapSize + 2
	push offset pMapRawData
	call PrintStrs
	add esp,12
	pop ebp
	ret
PrintMap ENDP

WaitKey PROC
	push ebp
	mov ebp,esp
	INFINITY:
		call _kbhit
		cmp eax,0
		je INFINITY
		call _getch
		; W 119 S 115 A 97 D 100
		; UP 72 DOWN 80 LEFT 75 RIGHT 77
		cmp eax,119
		je CASE_UP_TRUE
		cmp eax,72
		je CASE_UP_TRUE
		jmp CASE_UP_FALSE
		CASE_UP_TRUE:
			mov eax,-1
			sal eax,16
			jmp QUITWAIT
		CASE_UP_FALSE:
			cmp eax,115
			je CASE_DOWN_TRUE
			cmp eax,80
			je CASE_DOWN_TRUE
			jmp CASE_DOWN_FALSE
		CASE_DOWN_TRUE:
			mov eax,1
			sal eax,16
			jmp QUITWAIT
		CASE_DOWN_FALSE:
			cmp eax,97
			je CASE_LEFT_TRUE
			cmp eax,75
			je CASE_LEFT_TRUE
			jmp CASE_LEFT_FALSE
		CASE_LEFT_TRUE:
			mov eax,-1
			jmp QUITWAIT
		CASE_LEFT_FALSE:
			cmp eax,100
			je CASE_RIGHT_TRUE
			cmp eax,77
			je CASE_RIGHT_TRUE
			jmp INFINITY
		CASE_RIGHT_TRUE:
			mov eax,1
			jmp QUITWAIT
	QUITWAIT:
	pop ebp
	ret
WaitKey ENDP

TryMove PROC
; param1 direction
	push ebp
	mov ebp,esp
	; get cur snake head
	mov eax,DWORD PTR [snakeHead]
	mov ebx,offset snakeArr
	mov edx,DWORD PTR [ebx + eax * 4] ; (x,y)
	add edx,DWORD PTR [ebp + 8] ; next (x,y)
	pop ebp
	ret
TryMove ENDP

GameLoop PROC
	push ebp
	mov ebp,esp
	call InitMap
	call GenSnake
	call PrintMap

	DOGAME:
		call WaitKey
		push eax
		call TryMove
		cmp eax,1
		je ENDGAME
		jmp DOGAME
	ENDGAME:
	pop ebp
	ret
GameLoop ENDP

Game PROC
	; return score
	push ebp
	mov ebp,esp
	call GameLoop
	pop ebp
	ret
Game ENDP
END