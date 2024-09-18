F_Sec_Pos_Counter:
	lda		Timer_Flag
	and		#$81							; 半秒和16hz计时必须有一个为1
	cmp		#$80
	bne		L_Sec_Pos_rts
	rmb7	Timer_Flag

	inc		Frame_Counter

	lda		R_Time_Sec
	cmp		#60
	beq		L_CarryToMin					; 秒进位分动画

	jsr		F_DisFrame_Sec_d4				; sec个位走时动画

	lda		R_Time_Sec						; 检测十位有没有进位
	jsr		F_DivideBy10					; 除以10的结果不为零，且余数为0才执行十位的动画
	cmp		#0								; 商为0则一定无十位，d3无动画
	beq		L_Sec_D3_Out
	lda		P_Temp							; 余数不为0也不更新十位
	cmp		#0
	bne		L_Sec_D3_Out

	jsr		F_DisFrame_Sec_d3				; sec十位走时动画

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
	beq		L_Time_Overflow					; 计满99min59s则为溢出

	jsr		F_DisFrame_Sec_d4				; Sec个位走时动画
	jsr		F_DisFrame_Sec_d3				; Sec十位走时动画
	jsr		F_DisFrame_Min_d2				; Min个位走时动画

	lda		R_Time_Min						; 检测十位有没有进位
	jsr		F_DivideBy10					; 除以10的结果不为零，且余数为0才执行十位的动画
	cmp		#0								; 商为0则一定无十位，d3无动画
	beq		L_Min_D1_Out
	lda		P_Temp							; 余数不为0也不更新十位
	cmp		#0
	bne		L_Min_D1_Out

	jsr		F_DisFrame_Min_d1				; Min十位走时动画

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
	lda		#$0c							; 正计时溢出则进入倒计时暂停态
	sta		Sys_Status_Flag
	lda		#99
	sta		R_Time_Min
	lda		#59
	sta		R_Time_Sec
	jsr		F_Display_Time
	rts

; 增时独立于动画显示进行
Pos_Time_Count:
	rmb1	Timer_Flag
	lda		R_Time_Sec
	cmp		#59
	beq		Count_Add_Min
	cmp		#60
	beq		Count_CarryToMin				; 秒数满则进位分钟数
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
	rts


F_DivideBy10:
	ldx		#0								; 初始化 X 寄存器为 0，保存商
	sta		P_Temp							; 临时保存余数
DivideBy10:
	cmp		#10								; 检查 A 是否大于等于 10
	bcc		Done							; 如果 A 小于 10，跳转到 Done
	sec										; 设置进位，准备减法
	sbc		#10								; A = A - 10
	inx										; X = X + 1，记录商
	bra		DivideBy10						; 如果没有借位，继续循环
Done:
	sta		P_Temp							; 剩余值(余数)
	txa
	rts






; 倒计时部分
F_Sec_Des_Counter:
	bbs0	Timer_Flag, L_Sec_des_Out	; 若有半秒标志，说明还没到计数时候，闪MS并退出

	lda		R_Time_Sec
	cmp		#0
	beq		L_BorrowToMin
	dec		R_Time_Sec
	jsr		L_DisTimer_Sec

	ldx		#lcd_MS
	jsr		F_DispSymbol
	rmb1	Timer_Flag					; 复翻转标志位，防止重复进入
	rts

L_Sec_des_Out:
	ldx		#lcd_MS
	jsr		F_ClrpSymbol
	rts

L_BorrowToMin:
	lda		#60
	sta		R_Time_Sec

	lda		R_Time_Min
	cmp		#0
	beq		L_Counter_Over

	dec		R_Time_Min
	jsr		F_Display_Time
	rts

L_Counter_Over:
	smb3	Timer_Flag					; 倒计时完成
	lda		#$07
	sta		Beep_Serial					; 响3声
	lda		#$df
	sta		TMR1

	lda		#$0
	sta		Sys_Status_Flag				; 回到初始态
	smb0	Sys_Status_Flag
	sta		R_Time_Sec
	sta		R_Time_Min
	jsr		F_Display_Time

	rts
