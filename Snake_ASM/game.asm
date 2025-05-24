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
BlockReadKey PROTO

.data
MapSize = 25
map WORD MapSize*MapSize DUP(0)
EMPTY = 0
BORDER = 1
SNAKE = 2
FOOD = 3
scoreFmt BYTE "Score: %-5d",0
scoreMsg BYTE 50 DUP(0)
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
FOODCOLOR = 1

; for snake
snakeArr DWORD (MapSize - 2) * (MapSize - 2) DUP(0) ; save snake (x,y) x in low byte,y in high byte
snakeHead DWORD -1
; UP -FFFF0000h DOWN 1000h LEFT -1 RIGHT 1
moveDirection DWORD 1
speed DWORD 50

; for food
foodPos DWORD 10001h
foodArr DWORD (MapSize - 2) * (MapSize - 2) DUP(0) ; save food (x,y) x in low byte,y in high byte

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
	ADDSNAKE:
		cmp ecx,DWORD PTR [snakeHead]
		jg ADDDONE
		lea edx,snakeArr
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
		mov si,WORD PTR [ebp + 8] ; value
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
	pushad
	mov eax,DWORD PTR [ebp + 8] ; x
	mov ebx,DWORD PTR [ebp + 12] ; y
	sal ebx,16
	mov bx,ax
	mov eax,ebx
	mov ecx,DWORD PTR [snakeHead]
	add ecx,1
	mov DWORD PTR [snakeHead],ecx
	lea edx,snakeArr
	mov DWORD PTR [edx + ecx * 4],eax
	popad
	pop ebp
	ret
InsertSnakeNode ENDP

GenSnake PROC
	push ebp
	mov ebp,esp
	mov eax,1
	mov ebx,MapSize
	sar ebx,1
	mov ecx,3
	ADDSNAKENODE:
		push ebx
		push eax
		call InsertSnakeNode
		add esp,8
		add eax,1
		LOOP ADDSNAKENODE
	push SNAKE
	call TraversalSnake
	add esp,4
	pop ebp
	ret
GenSnake ENDP

GenFood PROC
; return 1: success 0: fail
	push ebp
	mov ebp,esp
	mov eax,offset map
	mov ebx,offset foodArr
	mov ecx,MapSize * MapSize
	ADDFOOD:
		mov dx,WORD PTR [eax]
		cmp WORD PTR [eax],EMPTY
		jne FILLED
		mov edx,eax
		mov DWORD PTR [ebx],edx
		add ebx,4
		FILLED:
		add eax,2
		LOOP ADDFOOD
	mov eax,ebx
	sub eax,offset foodArr
	sar eax,2
	push eax
	push 0
	call GetRandomFromRange
	add esp,8
	lea edx,foodArr
	mov edx,DWORD PTR [edx + eax * 4]
	mov WORD PTR [edx],FOOD
	mov eax,offset map
	sub edx,offset map
	cmp edx,0
	mov eax,0
	je NOMOREFOOD
	sar edx,1
	; use size to get the x,y
	mov eax,edx
	mov edx,0
	mov ecx,MapSize
	div ecx
	; x in edx,y in eax
	mov WORD PTR [foodPos],dx
	mov WORD PTR [foodPos + 2],ax
	mov eax,DWORD PTR [foodPos]
	mov eax,1
	NOMOREFOOD:
	pop ebp
	ret
GenFood ENDP

PrintMap PROC
	push ebp
	mov ebp,esp
	push DWORD PTR [score]
	push offset scoreFmt
	push 50
	push offset scoreMsg
	call snprintf
	add esp,16
	call SwapBuffer
	call UpdateMap
	push DWORD PTR [g_currentActiveBuffer]
	push offset pMapRawColor
	push MapSize + 2
	push offset pMapRawData
	call PrintStrs
	add esp,16
	push DWORD PTR [g_currentActiveBuffer]
	call SetConsoleActiveScreenBuffer
	pop ebp
	ret
PrintMap ENDP

WaitKey PROC
	push ebp
	mov ebp,esp
	push esi
	HASKEY:
		call _kbhit
		cmp eax,0
		je NOMOREKEY
		call _getch
		mov esi,eax
		jmp HASKEY
	NOMOREKEY:
		; W 119 S 115 A 97 D 100
		; UP 72 DOWN 80 LEFT 75 RIGHT 77
		cmp esi,119
		je CASE_UP_TRUE
		cmp esi,72
		je CASE_UP_TRUE
		jmp CASE_UP_FALSE
		CASE_UP_TRUE:
			; cmp DWORD PTR [moveDirection],0FFFF0000h
			; cmp DWORD PTR [moveDirection],10000h
			; cmp DWORD PTR [moveDirection],-1
			; cmp DWORD PTR [moveDirection],1
			cmp DWORD PTR [moveDirection],10000h
			je KEEP
			mov moveDirection,0FFFF0000h
			jmp KEEP
		CASE_UP_FALSE:
			cmp esi,115
			je CASE_DOWN_TRUE
			cmp esi,80
			je CASE_DOWN_TRUE
			jmp CASE_DOWN_FALSE
		CASE_DOWN_TRUE:
			cmp DWORD PTR [moveDirection],0FFFF0000h
			je KEEP
			mov moveDirection,10000h
			jmp KEEP
		CASE_DOWN_FALSE:
			cmp esi,97
			je CASE_LEFT_TRUE
			cmp esi,75
			je CASE_LEFT_TRUE
			jmp CASE_LEFT_FALSE
		CASE_LEFT_TRUE:
			cmp DWORD PTR [moveDirection],1
			je KEEP
			mov moveDirection,-1
			jmp KEEP
		CASE_LEFT_FALSE:
			cmp esi,100
			je CASE_RIGHT_TRUE
			cmp esi,77
			je CASE_RIGHT_TRUE
			jmp KEEP
		CASE_RIGHT_TRUE:
			cmp DWORD PTR [moveDirection],-1
			je KEEP
			mov moveDirection,1
			jmp KEEP
	KEEP:
	pop esi
	pop ebp
	ret
WaitKey ENDP

SnakeAlive PROC
; param1 (x,y)
; return 1: alive 0:die
	push ebp
	mov ebp,esp
	mov eax,DWORD PTR [ebp + 8]
	mov ebx,DWORD PTR [ebp + 8]
	and ebx,0FFFFh ; x
	mov eax,DWORD PTR [ebp + 8]
	sar eax,16 ; y
	;check map[x][y]
	mov ecx,MapSize
	mul ecx ; eax = y * MapSize
	add eax,ebx ; eax = y * MapSize + x
	sal eax,1 ; eax = 2 * y * MapSize + x
	mov edx,offset map
	add edx,eax
	mov eax,0
	cmp WORD PTR [edx],BORDER
	je DIE
	cmp WORD PTR [edx],SNAKE
	je DIE
	mov eax,1
	DIE:
	pop ebp
	ret
SnakeAlive ENDP

MoveSnake PROC
; pram1 new (x,y)
	push ebp
	mov ebp,esp
	mov eax,0
	mov ebx,offset snakeArr
	mov ecx,DWORD PTR [snakeHead]
	sub ecx ,1
	DOMOVE:
		cmp eax,ecx
		jg ENDMOVE
		mov edx,DWORD PTR [ebx + eax * 4 + 4] ; next
		mov DWORD PTR [ebx + eax * 4],edx; move
		add eax,1
		jmp DOMOVE
	ENDMOVE:
		mov edx,DWORD PTR [ebp + 8]
		mov DWORD PTR [ebx + eax * 4],edx
	push SNAKE
	call TraversalSnake
	add esp,4
	pop ebp
	ret
MoveSnake ENDP

TryMove PROC
; param1 direction
; return 2:eatfood 1: move 0: game_over
	push ebp
	mov ebp,esp
	push esi
	; get cur snake head
	mov eax,DWORD PTR [snakeHead]
	mov ebx,offset snakeArr
	mov esi,DWORD PTR [ebx + eax * 4] ; (x,y)
	add esi,DWORD PTR [ebp + 8] ; next (x,y)
	cmp esi,DWORD PTR [foodPos]
	jne MOVEOP
	mov eax,esi
	and eax,0FFFFh ; x
	mov ebx,esi
	sar ebx,16 ; y
	push ebx
	push eax
	call InsertSnakeNode
	add esp,8
	push SNAKE
	call TraversalSnake
	add esp,4
	mov ebx,offset score
	inc DWORD PTR [score]
	mov eax,2
	jmp TRYMOVEDONE
	MOVEOP:
	push esi
	call SnakeAlive
	add esp,4
	cmp eax,0
	je TRYMOVEDONE
	push EMPTY
	call TraversalSnake
	add esp,4
	push esi
	call MoveSnake
	add esp,4
	TRYMOVEDONE:
		pop esi
		pop ebp
		ret
TryMove ENDP

InitGame PROC
	push ebp
	mov ebp,esp
	mov DWORD PTR [score],0
	mov DWORD PTR [moveDirection],1
	mov eax,DWORD PTR [foodPos]
	and eax,0FFFFh ; x
	mov ebx,DWORD PTR [foodPos]
	sar ebx,16 ; y
	push ebx
	push eax
	call InsertSnakeNode
	add esp,8
	push EMPTY
	call TraversalSnake
	add esp,4
	mov DWORD PTR [snakeHead],-1
	call InitMap
	call GenSnake
	call GenFood
	call PrintMap
	pop ebp
	ret
InitGame ENDP

GameLoop PROC
	push ebp
	mov ebp,esp
	call InitGame

	DOGAME:
		call WaitKey
		mov eax,DWORD PTR [moveDirection]
		push DWORD PTR [moveDirection]
		call TryMove
		add esp,4
		cmp eax,0
		je ENDGAME
		cmp eax,2
		jne DONEXT
		call GenFood
		DONEXT:
		call PrintMap
		push DWORD PTR [speed]
		call Sleep
		jmp DOGAME
	ENDGAME:
	pop ebp
	ret
GameLoop ENDP

Game PROC
	push ebp
	mov ebp,esp
	ReStart:
		call GameLoop
		call BlockReadKey
		cmp eax,1
		je ReStart
	pop ebp
	ret
Game ENDP
END