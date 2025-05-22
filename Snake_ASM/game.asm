INCLUDE common.inc

extern g_inputHandle :DWORD
extern g_coord :DWORD
extern g_currentActiveBuffer :DWORD
extern g_pendingBuffer :DWORD

PrintStrs PROTO
SwapBuffer PROTO

.data
MapSize = 25
map BYTE MapSize*MapSize DUP(0)
mapRawData BYTE MapSize DUP(2 * MapSize + 1 DUP(' '))
mapStrs DWORD MapSize DUP(0) ; char**
mapItem BYTE "¡ö",0


.code
PrintMap PROC
	push ebp
	mov ebp,esp
	call SwapBuffer
	push DWORD PTR [g_currentActiveBuffer]
	call SetConsoleActiveScreenBuffer
	push MapSize
	push offset mapStrs
	call PrintStrs
	add esp,8
	pop ebp
	ret
PrintMap ENDP

InitMap PROC
	push ebp
	mov ebp,esp
	push esi
	push edi
	sub esp,10h
	mov DWORD PTR [ebp - 4],0; mapStrs
	mov eax,OFFSET mapStrs
	mov DWORD PTR [ebp - 4],eax
	; fill map and mapRawData row
	lea esi,map ; [0][0~MapSize - 1]
	lea edi,map
	add edi,(MapSize - 1) * MapSize ; [MapSize - 1][0~MapSize - 1]
	lea eax,mapRawData ; [0][0~MapSize - 1]
	lea ebx,mapRawData
	add ebx,(MapSize - 1) * (2 * MapSize + 1) ; [MapSize - 1][0~MapSize - 1]
	mov ecx,MapSize
FILLROW:
	mov BYTE PTR [esi],1
	mov BYTE PTR [edi],1
	mov dx,WORD PTR [mapItem]
	mov WORD PTR [eax],dx
	mov WORD PTR [ebx],dx
	inc esi
	inc edi
	add eax,2
	add ebx,2
	LOOP FILLROW
	; fill map and mapRawData column
	lea esi,map; map[0~MapSize - 1][0]
	lea edi,map
	add edi,MapSize - 1 ; map[0~MapSize - 1][MapSize - 1]
	lea eax,mapRawData; mapRawData[0~MapSize - 1][0]
	lea ebx,mapRawData
	add ebx,2 * MapSize - 2 ; mapRawData[0~ 2 * MapSize - 1][MapSize - 1]
	mov ecx,MapSize
FILLCOL:
	mov BYTE PTR [esi],1
	mov BYTE PTR [edi],1
	mov dx,WORD PTR [mapItem]
	mov WORD PTR [eax],dx
	mov WORD PTR [ebx],dx
	add esi,MapSize
	add edi,MapSize
	mov edx,ebx
	add edx,2
	mov BYTE PTR [edx],0 ; add '\0'
	mov edx,DWORD PTR [ebp - 4]
	mov DWORD PTR [edx],eax
	add eax,2 * MapSize + 1
	add ebx,2 * MapSize + 1
	add DWORD PTR [ebp - 4],4
	LOOP FILLCOL
	add esp,10h
	pop edi
	pop esi
	pop ebp
	ret
InitMap ENDP

Game PROC
	; col 0,31 and row 0,31 fill 1
	push ebp
	mov ebp,esp
	call InitMap
	call PrintMap
	pop ebp
	ret
Game ENDP
END