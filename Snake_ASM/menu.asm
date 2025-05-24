INCLUDE common.inc

PrintStrs PROTO
FillRow PROTO
BlockReadKey PROTO
extern g_outputHandle :DWORD

.const
line1 BYTE "  ____                    _           ",0
line2 BYTE " / ___|   _ __     __ _  | | __   ___ ",0
line3 BYTE " \___ \  | '_ \   / _` | | |/ /  / _ \",0
line4 BYTE "  ___) | | | | | | (_| | |   <  |  __/",0
line5 BYTE " |____/  |_| |_|  \__,_| |_|\_\  \___|",0
pad BYTE 0
enterMsg BYTE " ENTER: Begin Game",0
quitMsg BYTE " ESC: Quit",0
menuStrs DWORD OFFSET line1,OFFSET line2,OFFSET line3,OFFSET line4,OFFSET line5,OFFSET PAD,OFFSET PAD,OFFSET PAD,OFFSET enterMSG,OFFSET quitMsg
logoColor = 10
hintColor = 2

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
		cmp ecx,8
		jae DOHINTCOLOR
		push logoColor
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

PrintMenu PROC
	push ebp
	mov ebp,esp
	call InitMenuColor
	push DWORD PTR [g_outputHandle]
	push OFFSET pMenuColor
	push LENGTHOF menuStrs
	push OFFSET menuStrs
	call PrintStrs
	add esp,16
	pop ebp
	ret
PrintMenu ENDP

Menu PROC
; return 1: begin game 0: quit
.const
.code
	push ebp
	mov ebp,esp
	call PrintMenu
	call BlockReadKey
	pop ebp
	ret
Menu ENDP
END