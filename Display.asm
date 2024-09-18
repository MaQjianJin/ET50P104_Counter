F_Display_Time:
    ; 调用显示函数显示当前时间
	JSR 	F_ClearScreen
    JSR 	L_DisTimer_Sec
    JSR 	L_DisTimer_Min
    RTS
L_DisTimer_Sec:
	LDA		R_Time_Sec
	TAX
	LDA		Table_Sec_DataDot,X
	PHA
	AND		#$0F
	LDX		#lcd_d4
	JSR		L_Dis_21Bit_DigitDot_Prog
	PLA
	JSR		L_ROR_4Bit_Prog
	LDX		#lcd_d3
	JSR		L_Dis_21Bit_DigitDot_Prog
	RTS	
L_DisTimer_Min:
	LDA		R_Time_Min
	TAX
	LDA		Table_Min_DataDot,X
	PHA
	AND		#$0F
	LDX		#lcd_d2
	JSR		L_Dis_21Bit_DigitDot_Prog
	PLA
	AND		#$F0
	JSR		L_ROR_4Bit_Prog
	LDX		#lcd_d1
	JSR		L_Dis_21Bit_DigitDot_Prog
	RTS 

F_DisFrame_Sec_d4:
	lda		R_Time_Sec
	dea
	tax
	lda		Table_Sec_DataDot,X
	and		#$0f								; 个位数字
	clc
	rol											; 乘8
	rol
	rol
	clc
	adc		Frame_Counter
	ldx		#lcd_d4
	jsr		L_Dis_21Bit_DigitFrame_Prog  
	rts

F_DisFrame_Sec_d3:
	lda		R_Time_Sec
	tax
	lda		Table_Sec_DataDot,X
	and		#$f0								; 十位数字
	jsr		L_ROR_4Bit_Prog
	dea
	clc
	rol											; 乘8
	rol
	rol
	clc
	adc		Frame_Counter
	ldx		#lcd_d3
	jsr		L_Dis_21Bit_DigitFrame_Prog_1
	rts

F_DisFrame_Min_d2:
	lda		R_Time_Min
	dea
	tax
	lda		Table_Min_DataDot,X
	and		#$0f
	clc
	rol											; 乘8
	rol
	rol
	clc
	adc		Frame_Counter
	ldx		#lcd_d2
	jsr		L_Dis_21Bit_DigitFrame_Prog
	rts

F_DisFrame_Min_d1:
	lda		R_Time_Min
	tax
	lda		Table_Min_DataDot,X
	and		#$f0
	jsr		L_ROR_4Bit_Prog
	dea
	clc
	rol											; 乘8
	rol
	rol											; 右移4位再乘8,就是右移1位
	clc
	adc		Frame_Counter
	ldx		#lcd_d1
	jsr		L_Dis_21Bit_DigitFrame_Prog

	rts

L_ROR_4Bit_Prog:
	ROR		
	ROR		
	ROR		
	ROR		
	AND		#$0F
	
	RTS

;a = num
L_Multi_24_Prog:
	CLC									; 清除进位标志，确保进位为 0
	TAX									; 将 A 保存到 X 中
    ; 进行乘以 8 的操作
	ROL									; A = A * 2
	ROL									; A = A * 4
	ROL									; A = A * 8
	STA		P_Temp+1
	; 进行乘以 16 的操作
	TXA									; 恢复 X 中的原始 A 值
	CLC
	ROL									; A = A * 2
	ROL									; A = A * 4
	ROL									; A = A * 8
	ROL									; A = A * 16
	CLC
	ADC		P_Temp+1					; 乘24得到表中0-9数字
	rts
;================================================
;********************************************	
Table_Sec_DataDot:		;显示秒对应显示的16进制
	.BYTE 	00h	;0
	.BYTE 	01h	;1
	.BYTE	02h	;2
	.BYTE	03h	;3
	.BYTE	04h	;4
	.BYTE	05h	;5
	.BYTE	06h	;6
	.BYTE	07h	;7
	.BYTE	08h	;8
	.BYTE	09h	;9
	.BYTE	10h	;10
	.BYTE 	11h	;11
	.BYTE	12h	;12
	.BYTE	13h	;13
	.BYTE	14h	;14
	.BYTE	15h	;15
	.BYTE 	16h	;16
	.BYTE 	17h	;17
	.BYTE	18h	;18
	.BYTE	19h	;19
	.BYTE	20h	;20
	.BYTE	21h	;21
	.BYTE	22h	;22
	.BYTE	23h	;23
	.BYTE	24h	;24
	.BYTE	25h	;25
	.BYTE	26h	;26
	.BYTE 	27h	;27
	.BYTE	28h	;28
	.BYTE	29h	;29
	.BYTE	30h	;30
	.BYTE	31h	;31
	.BYTE 	32h	;32
	.BYTE 	33h	;33
	.BYTE	34h	;34
	.BYTE	35h	;35
	.BYTE	36h	;36
	.BYTE	37h	;37
	.BYTE	38h	;38
	.BYTE	39h	;39
	.BYTE	40h	;40
	.BYTE	41h	;41
	.BYTE	42h	;42
	.BYTE 	43h	;43
	.BYTE	44h	;44
	.BYTE	45h	;45
	.BYTE	46h	;46
	.BYTE	47h	;47
	.BYTE 	48h	;48
	.BYTE 	49h	;49
	.BYTE	50h	;50
	.BYTE	51h	;51
	.BYTE	52h	;52
	.BYTE	53h	;53
	.BYTE	54h	;54
	.BYTE	55h	;55
	.BYTE	56h	;56
	.BYTE	57h	;57
	.BYTE	58h	;58
	.BYTE 	59h	;59
	.BYTE 	60h	;60

Table_Min_DataDot:		;显示分钟对应显示的16进制
	.BYTE 	00h	;0
	.BYTE 	01h	;1
	.BYTE	02h	;2
	.BYTE	03h	;3
	.BYTE	04h	;4
	.BYTE	05h	;5
	.BYTE	06h	;6
	.BYTE	07h	;7
	.BYTE	08h	;8
	.BYTE	09h	;9
	.BYTE	10h	;10
	.BYTE 	11h	;11
	.BYTE	12h	;12
	.BYTE	13h	;13
	.BYTE	14h	;14
	.BYTE	15h	;15
	.BYTE 	16h	;16
	.BYTE 	17h	;17
	.BYTE	18h	;18
	.BYTE	19h	;19
	.BYTE	20h	;20
	.BYTE	21h	;21
	.BYTE	22h	;22
	.BYTE	23h	;23
	.BYTE	24h	;24
	.BYTE	25h	;25
	.BYTE	26h	;26
	.BYTE 	27h	;27
	.BYTE	28h	;28
	.BYTE	29h	;29
	.BYTE	30h	;30
	.BYTE	31h	;31
	.BYTE 	32h	;32
	.BYTE 	33h	;33
	.BYTE	34h	;34
	.BYTE	35h	;35
	.BYTE	36h	;36
	.BYTE	37h	;37
	.BYTE	38h	;38
	.BYTE	39h	;39
	.BYTE	40h	;40
	.BYTE	41h	;41
	.BYTE	42h	;42
	.BYTE 	43h	;43
	.BYTE	44h	;44
	.BYTE	45h	;45
	.BYTE	46h	;46
	.BYTE	47h	;47
	.BYTE 	48h	;48
	.BYTE 	49h	;49
	.BYTE	50h	;50
	.BYTE	51h	;51
	.BYTE	52h	;52
	.BYTE	53h	;53
	.BYTE	54h	;54
	.BYTE	55h	;55
	.BYTE	56h	;56
	.BYTE	57h	;57
	.BYTE	58h	;58
	.BYTE 	59h	;59
	.BYTE 	60h	;60
	.BYTE 	61h	;61
	.BYTE	62h	;62
	.BYTE	63h	;63
	.BYTE	64h	;64
	.BYTE	65h	;65
	.BYTE 	66h	;66
	.BYTE 	67h	;67
	.BYTE	68h	;68
	.BYTE	69h	;69
	.BYTE	70h	;70
	.BYTE	71h	;71
	.BYTE	72h	;72
	.BYTE	73h	;73
	.BYTE	74h	;74
	.BYTE	75h	;75
	.BYTE	76h	;76
	.BYTE 	77h	;77
	.BYTE	78h	;78
	.BYTE	79h	;79
	.BYTE	80h	;80
	.BYTE	81h	;81
	.BYTE 	82h	;82
	.BYTE 	83h	;83
	.BYTE	84h	;84
	.BYTE	85h	;85
	.BYTE	86h	;86
	.BYTE	87h	;87
	.BYTE	88h	;88
	.BYTE	89h	;89
	.BYTE	90h	;90
	.BYTE	91h	;91
	.BYTE	92h	;92
	.BYTE 	93h	;93
	.BYTE	94h	;94
	.BYTE	95h	;95
	.BYTE	96h	;96
	.BYTE	97h	;97
	.BYTE 	98h	;98
	.BYTE 	99h	;99
	.BYTE 	00h	;100
