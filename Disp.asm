;===========================================================
; LCD_RamAddr		.equ	0200H
;===========================================================
F_FillScreen:
	LDA		#FFH
	BNE		L_FillLcd
F_ClearScreen:
	LDA		#0
L_FillLcd:
	STA		1800H
	STA		1801H
	STA		1805H
	STA		1806H
	STA		1807H	
	STA		180BH
	STA		180CH	
	STA		180DH
	STA		1811H
	STA		1812H
	STA		1813H
	STA		1817H
	STA		1818H
	STA		1819H
	STA		181DH

	RTS
;===========================================================
;@brief		显示完整的一个数字
;@para:		A = 0~9
;			X = offset	
;@impact:	P_Temp，P_Temp+1，P_Temp+2，P_Temp+3, P_Temp+4, P_Temp+5, X，A
;===========================================================
L_Dis_21Bit_DigitDot_Prog:
;	STA		P_Temp
;	LDA		Table_Digit_Addr_Offset,X
	STX		P_Temp+3					; 偏移量暂存进P_Temp+3, 腾出X来做变址寻址
	STA		P_Temp						; 将显示的数字转换为内存偏移量
	jsr		L_Multi_24_Prog				; 乘24得到正确的偏移量

	TAX
	LDA		Table_Digit_Anim,X			; 将显示的数字通过查表找到对应的段码存进A
	STA		P_Temp						; 暂存低八位段码值到P_Temp
	INX
	LDA		Table_Digit_Anim,X			; 将显示的数字通过查表找到对应的段码存进A
	STA		P_Temp+1					; 暂存段码中8位值到P_Temp+1
	INX
	LDA		Table_Digit_Anim,X			; 将显示的数字通过查表找到对应的段码存进A
	STA		P_Temp+2					; 暂存高8位段码值到P_Temp+2

	LDX		P_Temp+3					; 将偏移量取回
	STX		P_Temp+3					; 暂存偏移量到P_Temp+3
	LDA		#21
	STA		P_Temp+4					; 设置显示段数为21
L_Judge_Dis_21Bit_DigitDot:				; 显示循环的开始
	LDX		P_Temp+3					; 取回偏移量作为索引
	LDA		Lcd_bit,X					; 查表定位目标段的bit位
	STA		P_Temp+5	
	LDA		Lcd_byte,X					; 查表定位目标段的显存地址
	TAX
	ROR		P_Temp						; 循环右移取得目标段是亮或者灭
	ROR		P_Temp+1
	ROR		P_Temp+2
	BCC		L_CLR						; 当前段的值若是0则进清点子程序
	LDA		LCD_RamAddr,X				; 将目标段的显存的特定bit位置1来打亮
	ORA		P_Temp+5
	STA		LCD_RamAddr,X
	BRA		L_Inc_Dis_Index_Prog		; 跳转到显示索引增加的子程序。
L_CLR:	
	LDA		LCD_RamAddr,X				; 加载LCD RAM的地址
	ORA		P_Temp+5					; 将COM和SEG信息与LCD RAM地址进行逻辑或操作
	EOR		P_Temp+5					; 进行异或操作，用于清除对应的段。
	STA		LCD_RamAddr,X				; 将结果写回LCD RAM，清除对应位置。
L_Inc_Dis_Index_Prog:
	INC		P_Temp+3					; 递增偏移量，处理下一个段
	DEC		P_Temp+4					; 递减剩余要显示的段数
	BNE		L_Judge_Dis_21Bit_DigitDot	; 剩余段数为0则返回
	RTS

;-----------------------------------------
;@brief:	单独的画点、清点函数,一般用于MS显示
;@para:		X = offset
;@impact:	A, X, P_Temp+2
;-----------------------------------------
F_DispSymbol:
	JSR		F_DispSymbol_Com	
	STA		LCD_RamAddr,X				; 画点
	RTS

F_ClrpSymbol:
	JSR		F_DispSymbol_Com			; 清点
	EOR		P_Temp+2
	STA		LCD_RamAddr,X
	RTS

F_DispSymbol_Com:	
	LDA		Lcd_bit,X					; 查表得知目标段的bit位
	STA		P_Temp+2	
	LDA		Lcd_byte,X					; 查表得知目标段的地址
	TAX
	LDA		LCD_RamAddr,X				; 将目标段的显存的特定bit位置1来打亮
	ORA		P_Temp+2
	RTS

;============================================================

L_Dis_21Bit_DigitFrame_Prog:
	STX		P_Temp+3					; 偏移量暂存进P_Temp+3, 腾出X来做变址寻址
	STA		P_Temp						; 将显示的数字转换为内存偏移量
	CLC
	ROL
	CLC
	ADC		P_Temp

	TAX
	LDA		Table_Digit_Anim,X			; 将显示的数字通过查表找到对应的段码存进A
	STA		P_Temp						; 暂存低八位段码值到P_Temp
	INX
	LDA		Table_Digit_Anim,X			; 将显示的数字通过查表找到对应的段码存进A
	STA		P_Temp+1					; 暂存段码中8位值到P_Temp+1
	INX
	LDA		Table_Digit_Anim,X			; 将显示的数字通过查表找到对应的段码存进A
	STA		P_Temp+2					; 暂存高8位段码值到P_Temp+2

	LDX		P_Temp+3					; 将偏移量取回

	STX		P_Temp+3					; 暂存偏移量到P_Temp+3
	LDA		#21
	STA		P_Temp+4					; 设置显示段数为21
L_Judge_Dis_21Bit_DigitFrame:				; 显示循环的开始
	LDX		P_Temp+3					; 取回偏移量作为索引
	LDA		Lcd_bit,X					; 查表定位目标段的bit位
	STA		P_Temp+5	
	LDA		Lcd_byte,X					; 查表定位目标段的显存地址
	TAX
	ROR		P_Temp						; 循环右移取得目标段是亮或者灭
	ROR		P_Temp+1
	ROR		P_Temp+2
	BCC		L_CLR_Frame					; 当前段的值若是0则进清点子程序
	LDA		LCD_RamAddr,X				; 将目标段的显存的特定bit位置1来打亮
	ORA		P_Temp+5
	STA		LCD_RamAddr,X
	BRA		L_Inc_Dis_FrameIndex_Prog		; 跳转到显示索引增加的子程序。
L_CLR_Frame:	
	LDA		LCD_RamAddr,X				; 加载LCD RAM的地址
	ORA		P_Temp+5					; 将COM和SEG信息与LCD RAM地址进行逻辑或操作
	EOR		P_Temp+5					; 进行异或操作，用于清除对应的段。
	STA		LCD_RamAddr,X				; 将结果写回LCD RAM，清除对应位置。
L_Inc_Dis_FrameIndex_Prog:
	INC		P_Temp+3					; 递增偏移量，处理下一个段
	DEC		P_Temp+4					; 递减剩余要显示的段数
	BNE		L_Judge_Dis_21Bit_DigitFrame	; 剩余段数为0则返回
	RTS

;================================================================================

L_Dis_21Bit_DigitFrame_Prog_1:
	STX		P_Temp+3					; 偏移量暂存进P_Temp+3, 腾出X来做变址寻址
	STA		P_Temp						; 将显示的数字转换为内存偏移量
	CLC
	ROL
	CLC
	ADC		P_Temp

	TAX
	LDA		Table_Digit_Anim_2,X			; 将显示的数字通过查表找到对应的段码存进A
	STA		P_Temp						; 暂存低八位段码值到P_Temp
	INX
	LDA		Table_Digit_Anim_2,X			; 将显示的数字通过查表找到对应的段码存进A
	STA		P_Temp+1					; 暂存段码中8位值到P_Temp+1
	INX
	LDA		Table_Digit_Anim_2,X			; 将显示的数字通过查表找到对应的段码存进A
	STA		P_Temp+2					; 暂存高8位段码值到P_Temp+2

	LDX		P_Temp+3					; 将偏移量取回

	STX		P_Temp+3					; 暂存偏移量到P_Temp+3
	LDA		#21
	STA		P_Temp+4					; 设置显示段数为21
L_Judge_Dis_21Bit_DigitFrame_1:				; 显示循环的开始
	LDX		P_Temp+3					; 取回偏移量作为索引
	LDA		Lcd_bit,X					; 查表定位目标段的bit位
	STA		P_Temp+5	
	LDA		Lcd_byte,X					; 查表定位目标段的显存地址
	TAX
	ROR		P_Temp						; 循环右移取得目标段是亮或者灭
	ROR		P_Temp+1
	ROR		P_Temp+2
	BCC		L_CLR_Frame_1					; 当前段的值若是0则进清点子程序
	LDA		LCD_RamAddr,X				; 将目标段的显存的特定bit位置1来打亮
	ORA		P_Temp+5
	STA		LCD_RamAddr,X
	BRA		L_Inc_Dis_FrameIndex_Prog_1		; 跳转到显示索引增加的子程序。
L_CLR_Frame_1:	
	LDA		LCD_RamAddr,X				; 加载LCD RAM的地址
	ORA		P_Temp+5					; 将COM和SEG信息与LCD RAM地址进行逻辑或操作
	EOR		P_Temp+5					; 进行异或操作，用于清除对应的段。
	STA		LCD_RamAddr,X				; 将结果写回LCD RAM，清除对应位置。
L_Inc_Dis_FrameIndex_Prog_1:
	INC		P_Temp+3					; 递增偏移量，处理下一个段
	DEC		P_Temp+4					; 递减剩余要显示的段数
	BNE		L_Judge_Dis_21Bit_DigitFrame_1	; 剩余段数为0则返回
	RTS

;============================================================

Table_Digit_Anim:
	.byte $1e, $db, $6f	;0			0
	.byte $03, $db, $6d	;0->1, 1	1
	.byte $10, $7b, $6d	;0->1, 2	2
	.byte $12, $0f, $6d ;0->1, 3	3
	.byte $12, $41, $ed ;0->1, 4	4
	.byte $12, $48, $3d ;0->1, 5	5
	.byte $12, $49, $07 ;0->1, 6	6
	.byte $12, $49, $20 ;0->1, 7	7
	.byte $12, $49, $24 ;1			8
	.byte $02, $49, $24	;1->2, 1	9
	.byte $1c, $49, $24	;1->2, 2	a
	.byte $13, $89, $24 ;1->2, 3	b
	.byte $12, $71, $24 ;1->2, 4	c
	.byte $1e, $4e, $24 ;1->2, 5	d
	.byte $07, $c9, $c4 ;1->2, 6	e
	.byte $04, $f9, $38 ;1->2, 7	f
	.byte $1c, $9f, $27 ;2			10
	.byte $03, $93, $e4	;2->3, 1	11
	.byte $1c, $72, $7c	;2->3, 2	12
	.byte $13, $8e, $4f ;2->3, 3	13
	.byte $12, $71, $c9 ;2->3, 4	14
	.byte $1e, $4e, $39 ;2->3, 5	15
	.byte $13, $c9, $c7 ;2->3, 6	16
	.byte $12, $79, $38 ;2->3, 7	17
	.byte $1e, $4f, $27 ;3			18
	.byte $03, $c9, $e4	;3->4, 1	19
	.byte $14, $79, $3c	;3->4, 2	1a
	.byte $16, $8f, $27 ;3->4, 3	1b
	.byte $16, $d1, $e4 ;3->4, 4	1c
	.byte $1e, $da, $3c ;3->4, 5	1d
	.byte $13, $db, $47 ;3->4, 6	1e
	.byte $12, $7b, $68 ;3->4, 7	1f
	.byte $12, $4f, $6d ;4			20
	.byte $02, $49, $ed	;4->5, 1	21
	.byte $1c, $49, $3d	;4->5, 2	22
	.byte $07, $89, $27 ;4->5, 3	23
	.byte $04, $f1, $24 ;4->5, 4	24
	.byte $1c, $9e, $24 ;4->5, 5	25
	.byte $13, $93, $c4 ;4->5, 6	26
	.byte $12, $72, $78 ;4->5, 7	27
	.byte $1e, $4e, $4f ;5			28
	.byte $03, $c9, $c9	;5->6, 1	29
	.byte $1c, $79, $39	;5->6, 2	2a
	.byte $07, $8f, $27 ;5->6, 3	2b
	.byte $04, $f1, $e4 ;5->6, 4	2c
	.byte $1c, $9e, $3c ;5->6, 5	2d
	.byte $17, $93, $c7 ;5->6, 6	2e
	.byte $16, $f2, $78 ;5->6, 7	2f
	.byte $1e, $de, $4f ;6			30
	.byte $03, $db, $c9	;6->7, 1	31
	.byte $1c, $7b, $79	;6->7, 2	32
	.byte $13, $8f, $6f ;6->7, 3	33
	.byte $12, $71, $ed ;6->7, 4	34
	.byte $12, $4e, $3d ;6->7, 5	35
	.byte $12, $49, $c7 ;6->7, 6	36
	.byte $12, $49, $38 ;6->7, 7	37
	.byte $12, $49, $27 ;7			38
	.byte $02, $49, $24	;7->8, 1	39
	.byte $1c, $49, $24	;7->8, 2	3a
	.byte $17, $89, $24 ;7->8, 3	3b
	.byte $16, $f1, $24 ;7->8, 4	3c
	.byte $1e, $de, $24 ;7->8, 5	3d
	.byte $17, $db, $c4 ;7->8, 6	3e
	.byte $16, $fb, $78 ;7->8, 7	3f
	.byte $1e, $df, $6f ;8			40
	.byte $03, $db, $ed	;8->9, 1	41
	.byte $1c, $7b, $7d	;8->9, 2	42
	.byte $17, $8f, $6f ;8->9, 3	43
	.byte $16, $f1, $ed ;8->9, 4	44
	.byte $1e, $de, $3d ;8->9, 5	45
	.byte $13, $db, $c4 ;8->9, 6	46
	.byte $12, $7b, $78 ;8->9, 7	47
	.byte $1e, $4f, $6f ;9			48
	.byte $03, $c9, $ed	;9->0, 1	49
	.byte $1c, $79, $3d	;9->0, 2	4a
	.byte $17, $8f, $27 ;9->0, 3	4b
	.byte $16, $f1, $e4 ;9->0, 4	4c
	.byte $16, $de, $3c ;9->0, 5	4d
	.byte $16, $db, $c7 ;9->0, 6	4e
	.byte $16, $db, $78 ;9->0, 7	4f
	.byte $1e, $db, $6f ;0			50

Table_Digit_Anim_2:
	.byte $1e, $db, $6f	;0			0
	.byte $03, $db, $6d	;0->1, 1	1
	.byte $10, $7b, $6d	;0->1, 2	2
	.byte $12, $0f, $6d ;0->1, 3	3
	.byte $12, $41, $ed ;0->1, 4	4
	.byte $12, $48, $3d ;0->1, 5	5
	.byte $12, $49, $07 ;0->1, 6	6
	.byte $12, $49, $20 ;0->1, 7	7
	.byte $12, $49, $24 ;1			8
	.byte $02, $49, $24	;1->2, 1	9
	.byte $1c, $49, $24	;1->2, 2	a
	.byte $13, $89, $24 ;1->2, 3	b
	.byte $12, $71, $24 ;1->2, 4	c
	.byte $1e, $4e, $24 ;1->2, 5	d
	.byte $07, $c9, $c4 ;1->2, 6	e
	.byte $04, $f9, $38 ;1->2, 7	f
	.byte $1c, $9f, $27 ;2			10
	.byte $03, $93, $e4	;2->3, 1	11
	.byte $1c, $72, $7c	;2->3, 2	12
	.byte $13, $8e, $4f ;2->3, 3	13
	.byte $12, $71, $c9 ;2->3, 4	14
	.byte $1e, $4e, $39 ;2->3, 5	15
	.byte $13, $c9, $c7 ;2->3, 6	16
	.byte $12, $79, $38 ;2->3, 7	17
	.byte $1e, $4f, $27 ;3			18
	.byte $03, $c9, $e4	;3->4, 1	19
	.byte $14, $79, $3c	;3->4, 2	1a
	.byte $16, $8f, $27 ;3->4, 3	1b
	.byte $16, $d1, $e4 ;3->4, 4	1c
	.byte $1e, $da, $3c ;3->4, 5	1d
	.byte $13, $db, $47 ;3->4, 6	1e
	.byte $12, $7b, $68 ;3->4, 7	1f
	.byte $12, $4f, $6d ;4			20
	.byte $02, $49, $ed	;4->5, 1	21
	.byte $1c, $49, $3d	;4->5, 2	22
	.byte $07, $89, $27 ;4->5, 3	23
	.byte $04, $f1, $24 ;4->5, 4	24
	.byte $1c, $9e, $24 ;4->5, 5	25
	.byte $13, $93, $c4 ;4->5, 6	26
	.byte $12, $72, $78 ;4->5, 7	27
	.byte $1e, $4e, $4f ;5			28
	.byte $03, $c9, $c9	;5->0, 1	29
	.byte $1c, $79, $39	;5->0, 2	2a
	.byte $17, $8f, $27 ;5->0, 3	2b
	.byte $16, $f1, $e4 ;5->0, 4	2c
	.byte $16, $de, $3c ;5->0, 5	2d
	.byte $16, $db, $c7 ;5->0, 6	2e
	.byte $16, $db, $78 ;5->0, 7	2f
	.byte $1e, $db, $6f ;0			30