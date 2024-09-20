F_Sec_Pos_Counter:
	bbs0	Timer_Flag, Is_Frame_Come_Pos		; 半秒为0时，判断帧计时
	rts
; 判断是否需要减时，还是单纯的动画帧
Is_Frame_Come_Pos:
	bbr1	Timer_Flag,Add_Sec_Out_Pos			; 有走时标志则减时
	inc		R_Time_Sec
	rmb1	Timer_Flag						; 动画放8帧，减秒只减一次
; 没有16Hz则不进动画
Add_Sec_Out_Pos:
	bbs7	Timer_Flag, Count_Start
	rts
	lda		Timer_Flag
	and		#$81							; ?????16hz?????????????1
	cmp		#$80
	bne		L_Sec_Pos_rts
	rmb7	Timer_Flag

	inc		Frame_Counter

	lda		R_Time_Sec
	cmp		#60
	beq		L_CarryToMin					; ???��?????

	jsr		F_DisFrame_Sec_d4				; sec??��???????

	lda		R_Time_Sec						; ????��????��?��
	jsr		F_DivideBy10					; ????10????????????????0??????��?????
	cmp		#0								; ???0????????��??d3?????
	beq		L_Sec_D3_Out
	lda		P_Temp							; ???????0????????��
	cmp		#0
	bne		L_Sec_D3_Out

	jsr		F_DisFrame_Sec_d3				; sec?��???????

L_Sec_D3_Out:
	lda		Frame_Counter
	cmp		#$08
	beq		L_Sec_Pos_Out
	
	ldx		#lcd_MS
	jsr		F_ClrpSymbol

	rts

L_Sec_Pos_Out:
	ldx		#lcd_MS
	jsr		F_DispSymbol
	lda		#0
	sta		Frame_Counter

L_Sec_Pos_rts:
	rts

L_CarryToMin:
	lda		R_Time_Min
	cmp		#100
	beq		L_Time_Overflow					; ????99min59s??????

	jsr		F_DisFrame_Sec_d4				; Sec??��???????
	jsr		F_DisFrame_Sec_d3				; Sec?��???????
	jsr		F_DisFrame_Min_d2				; Min??��???????

	lda		R_Time_Min						; ????��????��?��
	jsr		F_DivideBy10					; ????10????????????????0??????��?????
	cmp		#0								; ???0????????��??d3?????
	beq		L_Min_D1_Out
	lda		P_Temp							; ???????0????????��
	cmp		#0
	bne		L_Min_D1_Out

	jsr		F_DisFrame_Min_d1				; Min?��???????

L_Min_D1_Out:
	lda		Frame_Counter
	cmp		#$08
	beq		L_Min_Pos_Out
	ldx		#lcd_MS
	jsr		F_ClrpSymbol
	rts

L_Min_Pos_Out:
	ldx		#lcd_MS
	jsr		F_DispSymbol
	lda		#0
	sta		Frame_Counter
	rts

L_Time_Overflow:
	lda		#$0c							; ????????????????????
	sta		Sys_Status_Flag
	lda		#99
	sta		R_Time_Min
	lda		#59
	sta		R_Time_Sec
	jsr		F_Display_Time
	rts

; ???????????????????
Pos_Time_Count:
	rmb1	Timer_Flag
	lda		R_Time_Sec
	cmp		#59
	beq		Count_Add_Min
	cmp		#60
	beq		Count_CarryToMin				; ?????????��??????
	inc		R_Time_Sec
	rts
Count_CarryToMin:
	lda		R_Time_Min
	cmp		#99
	beq		Count_Overflow
	lda		#$1
	sta		R_Time_Sec
	rts
Count_Add_Min:
	inc		R_Time_Sec
	inc		R_Time_Min
	rts
Count_Overflow:
	lda		#$0
	sta		R_Time_Sec
	sta		R_Time_Min
	TMR2_OFF
	TMR0_OFF
	rts


F_DivideBy10:
	ldx		#0								; 初始化X寄存器为0
	sta		P_Temp							; 临时保存余数
DivideBy10:
	cmp		#10								; 检查A是否大于等于10
	bcc		Done							; 如果A小于10，跳转Done
	sec										; 设置进位，准备减法
	sbc		#10								; A=A-10
	inx										; X=X+1计算商
	bra		DivideBy10						; 如果没有借位就继续循环
Done:
	sta		P_Temp							; 余数
	txa
	rts






; 倒计时部分
F_Sec_Des_Counter:
	bbs0	Timer_Flag, Is_Frame_Come		; 半秒为0时，判断帧计时
	rts
; 判断是否需要减时，还是单纯的动画帧
Is_Frame_Come:
	bbr1	Timer_Flag,Add_Sec_Out			; 有走时标志则减时
	dec		R_Time_Sec
	rmb1	Timer_Flag						; 动画放8帧，减秒只减一次
; 没有16Hz则不进动画
Add_Sec_Out:
	bbs7	Timer_Flag, Count_Start
	rts

Count_Start:
	dec		Frame_Counter					; 帧计数
	lda		R_Time_Sec						; 判断是否存在分钟借位
	clc
	adc		#$01
	cmp		#$00
	bne		Set_BorrowFlag_Out				; 置借(进)位发生标志
	smb2	Frame_Flag
Set_BorrowFlag_Out:
	bbr2	Frame_Flag,Borrow_Out
	bra		L_BorrowToMin
Borrow_Out:
	jsr		F_DisFrame_Sec_d4				; sec个位走时动画

	lda		R_Time_Sec						; 检测sec十位有无借位
	clc
	adc		#$01							; 先减秒再进动画，需补偿1秒
	jsr		F_DivideBy10
	cmp		#0								; 商为0则一定无10为，十位不走时
	beq		L_Sec_D3_Out_Des
	lda		P_Temp							; 余数不为0也不更新十位
	cmp		#0
	bne		L_Sec_D3_Out_Des

	jsr		F_DisFrame_Sec_d3				; sec十位走时动画


L_Sec_D3_Out_Des:
	lda		Frame_Counter					; 第8帧重置帧计数
	cmp		#$0
	beq		L_Sec_Des_Out

	ldx		#lcd_MS
	jsr		F_ClrpSymbol					; 没走完动画则熄灭MS

	rmb7	Timer_Flag						; 清16Hz，避免重复播动画

	rts

L_Sec_Des_Out:
	rmb0	Timer_Flag						; 动画走完即为后半S
	rmb7	Timer_Flag						; 同样清16Hz
	ldx		#lcd_MS							; 亮MS并重置帧计数
	jsr		F_DispSymbol
	lda		#$8
	sta		Frame_Counter

L_Sec_Des_rts:
	rts

L_BorrowToMin:
	smb2	Frame_Flag
	bbs1	Frame_Flag,Dec_Once_Min			; 借位分钟，动画8帧但减分只减1次
	dec		R_Time_Min
	lda		#59
	sta		R_Time_Sec
	smb1	Frame_Flag
Dec_Once_Min:
	lda		R_Time_Min
	clc
	adc		#$01
	cmp		#$00
	beq		L_Time_Stop						; 计到00:00停止

	jsr		F_DisFrame_Sec_d4				; Sec个位走时
	jsr		F_DisFrame_Sec_d3				; Sec十位走时
	jsr		F_DisFrame_Min_d2				; Min个位走时

	lda		R_Time_Min						; 检测Min十位有无借位
	clc
	adc		#$01
	jsr		F_DivideBy10					; 除10判断十位是否需要动画
	cmp		#0
	beq		L_Min_D1_Out_Des
	lda		P_Temp
	cmp		#0
	bne		L_Min_D1_Out_Des

	jsr		F_DisFrame_Min_d1				; Min十位走时动画

L_Min_D1_Out_Des:
	lda		Frame_Counter					; 有动画就熄灭MS
	cmp		#$0
	beq		L_Min_Des_Out
	ldx		#lcd_MS
	jsr		F_ClrpSymbol
	rts

L_Min_Des_Out:
	rmb1	Frame_Flag						; 减分标志位
	rmb2	Frame_Flag						; 借(进)位标志位
	ldx		#lcd_MS							; 重置帧计数
	jsr		F_DispSymbol					; 无动画就亮MS
	lda		#$8
	sta		Frame_Counter
	rts

L_Time_Stop:
	lda		#$01							; 倒计时完成则回到初始态
	sta		Sys_Status_Flag
	smb3	Timer_Flag						; 计时完成标志位
	lda		#$07							; 响铃序列
	sta		Beep_Serial
	lda		#$0
	sta		R_Time_Min
	sta		R_Time_Sec
	jsr		F_Display_Time
	rts
