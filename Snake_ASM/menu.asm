INCLUDE common.inc

PrintStrs PROTO
FillRow PROTO
extern g_inputHandle :DWORD
extern g_outputHandle :DWORD

.const
line1 BYTE "  ____                    _           ",0
line2 BYTE " / ___|   _ __     __ _  | | __   ___ ",0
line3 BYTE " \___ \  | '_ \   / _` | | |/ /  / _ \",0
line4 BYTE "  ___) | | | | | | (_| | |   <  |  __/",0
line5 BYTE " |____/  |_| |_|  \__,_| |_|\_\  \___|",0
pad BYTE 0
score BYTE 0
enterMsg BYTE " ENTER: Begin Game",0
quitMsg BYTE " ESC: Quit",0
menuStrs DWORD OFFSET line1,OFFSET line2,OFFSET line3,OFFSET line4,OFFSET line5,OFFSET PAD,OFFSET score,OFFSET PAD,OFFSET enterMSG,OFFSET quitMsg
logoColor = 1
scoreColor = 1
hintColor = 1

.data
menuColor WORD 10 DUP(38 DUP(0))
pMenuColor DWORD 10 DUP(0)

.code
InitMenuColor PROC
	push ebp
	mov ebp,esp
	mov eax,offset menuColor
	mov ebx,offset pMenuColor
	mov ecx,0
	InitColor:
		mov DWORD PTR [ebx],eax
		cmp ecx,10
		jae COLORDONE
		cmp ecx,5
		jae DOSCORECOLOR
		push logoColor
		push 38
		push eax
		call FillRow
		add esp,12
		jmp NEXT
		DOSCORECOLOR:
			cmp ecx,6
			jne DOHINTCOLOR
			push scoreColor
			push 38
			push eax
			call FillRow
			add esp,12
			jmp NEXT
		DOHINTCOLOR:
			cmp ecx,8
			jb NEXT
			push hintColor
			push 38
			push eax
			call FillRow
			add esp,12
		NEXT:
			add ebx,4
			add eax,38
			inc ecx
		jmp InitColor
	COLORDONE:
	pop ebp
	ret
InitMenuColor ENDP

Menu PROC
; return 1: begin game 0: quit
.const
.code
	push ebp
	mov ebp,esp
	sub esp,210
	call InitMenuColor
	mov ebx,OFFSET menuColor
	mov eax,DWORD PTR [pMenuColor]
	push DWORD PTR [g_outputHandle]
	push OFFSET pMenuColor
	push LENGTHOF menuStrs
	push OFFSET menuStrs
	call PrintStrs
	add esp,16
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