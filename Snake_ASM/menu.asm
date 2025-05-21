INCLUDE common.inc

.const
line1 BYTE "  ____                    _           ",0Ah,0
line2 BYTE " / ___|   _ __     __ _  | | __   ___ ",0Ah,0
line3 BYTE " \___ \  | '_ \   / _` | | |/ /  / _ \",0Ah,0
line4 BYTE "  ___) | | | | | | (_| | |   <  |  __/",0Ah,0
line5 BYTE " |____/  |_| |_|  \__,_| |_|\_\  \___|",0Ah,0
pad BYTE 0Ah,0
score BYTE 0Ah,0
enterMsg BYTE " ENTER: Begin Game",0Ah,0Ah,0Ah,0
quitMsg BYTE " ESC: Quit",0Ah,0

PrintStrs PROTO


.code
Menu PROC
.const
	menuStrs DWORD OFFSET line1,OFFSET line2,OFFSET line3,OFFSET line4,OFFSET line5,OFFSET PAD,OFFSET score,OFFSET PAD,OFFSET enterMSG,OFFSET quitMsg
.code
	push ebp
	mov ebp,esp
	push LENGTHOF menuStrs
	push OFFSET menuStrs
	call PrintStrs
	add esp,8
W:
	JMP W
	pop ebp
	ret
Menu ENDP
END
