INCLUDE common.inc

PrintStrs PROTO
extern g_inputHandle :DWORD

.const
CRLF BYTE 0Ah,0Dh,0
line1 BYTE "  ____                    _           ",0
line2 BYTE " / ___|   _ __     __ _  | | __   ___ ",0
line3 BYTE " \___ \  | '_ \   / _` | | |/ /  / _ \",0
line4 BYTE "  ___) | | | | | | (_| | |   <  |  __/",0
line5 BYTE " |____/  |_| |_|  \__,_| |_|\_\  \___|",0
pad BYTE 0
score BYTE 0
enterMsg BYTE " ENTER: Begin Game",0
quitMsg BYTE " ESC: Quit",0



.code
Menu PROC
; return 1: begin game 0: quit
.const
	menuStrs DWORD OFFSET line1,OFFSET line2,OFFSET line3,OFFSET line4,OFFSET line5,OFFSET PAD,OFFSET score,OFFSET PAD,OFFSET enterMSG,OFFSET quitMsg
.code
	push ebp
	mov ebp,esp
	sub esp,210
	push LENGTHOF menuStrs
	push OFFSET menuStrs
	call PrintStrs
	add esp,8
	; read key
	push edi
	push esi
	mov edi,0
READKEY:
	mov eax,ebp
	sub eax,210
	push eax; numberOfReads
	push 10; nlength
	add eax,10
	push eax ; buffer
	push DWORD PTR [g_inputHandle] ; console handle
	call ReadConsoleInputA
	; buffer in ebp - 200
	lea esi,DWORD PTR [ebp - 200]
	mov edi,0
	FINDKEY:
		cmp edi,DWORD PTR [ebp - 210]
		JAE ReadKey
		xor edx,edx
		mov dx,WORD PTR [esi]
		cmp edx,1; KEY_EVENT
		; ignore KEY_RELEASE or KEY_PRESS, only check VT_RETURN and VT_ESCAPE
		jne NOTEXPECT
		mov dx,WORD PTR [esi + 10]
		mov eax,1
		cmp edx,0Dh
		je QUIT
		mov eax,0
		cmp edx,1Bh
		je QUIT
		; get virtual key code
		NOTEXPECT:
			sub esi,20
			inc edi
	jmp READKEY
Quit:
	pop esi
	pop edi
	add esp,210
	pop ebp
	ret
Menu ENDP
END