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
	lda		Timer_Flag
	and		#$81							; 半秒和16hz计时必须有一个为1
	cmp		#$80
	bne		L_Sec_Des_rts
	rmb7	Timer_Flag						; 每16Hz走一帧动画

	inc		Frame_Counter					; 帧计数

	lda		R_Time_Sec						; 借位
	cmp		#00
	beq		L_BorrowToMin					; 秒借位分动画

	jsr		F_DisFrame_Sec_d4				; sec个位走时动画

	lda		R_Time_Sec						; 检测秒十位有没有借位
	jsr		F_DivideBy10					; 除以10的结果不为零，且余数为0才执行十位的动画
	cmp		#0								; 商为0则一定无十位，d3无动画
	beq		L_Sec_D3_Out_Des
	lda		P_Temp							; 余数不为0也不更新十位
	cmp		#0
	bne		L_Sec_D3_Out_Des

	jsr		F_DisFrame_Sec_d3				; sec十位走时动画


L_Sec_D3_Out_Des:
	lda		Frame_Counter					; 走到第8帧就结束动画播放
	cmp		#$08
	beq		L_Sec_Des_Out

	ldx		#lcd_MS
	jsr		F_ClrpSymbol					; 若没走完动画则熄MS

	rts

L_Sec_Des_Out:
	ldx		#lcd_MS							; 亮MS并清空帧计数
	jsr		F_DispSymbol
	lda		#0
	sta		Frame_Counter

L_Sec_Des_rts:
	rts

L_BorrowToMin:
	lda		R_Time_Min
	cmp		#00
	beq		L_Time_Stop						; 计到00:00则停止

	jsr		F_DisFrame_Sec_d4				; Sec个位走时动画
	jsr		F_DisFrame_Sec_d3				; Sec十位走时动画
	jsr		F_DisFrame_Min_d2				; Min个位走时动画

	lda		R_Time_Min						; 检测十位有没有进位
	jsr		F_DivideBy10					; 除以10的结果不为零，且余数为0才执行十位的动画
	cmp		#0								; 商为0则一定无十位，d3无动画
	beq		L_Min_D1_Out_Des
	lda		P_Temp							; 余数不为0也不更新十位
	cmp		#0
	bne		L_Min_D1_Out_Des

	jsr		F_DisFrame_Min_d1				; Min十位走时动画

L_Min_D1_Out_Des:
	lda		Frame_Counter					; 还在走动画就熄MS
	cmp		#$08
	beq		L_Min_Des_Out
	ldx		#lcd_MS
	jsr		F_ClrpSymbol
	rts

L_Min_Des_Out:
	ldx		#lcd_MS							; 走到第8帧就清空帧计数
	jsr		F_DispSymbol					; 不走动画了就亮MS
	lda		#0
	sta		Frame_Counter
	rts

L_Time_Stop:
	lda		#$01							; 倒计时完成则回到初始态
	sta		Sys_Status_Flag
	smb3	Timer_Flag						; 计时完成标志位
	lda		#$0
	sta		R_Time_Min
	sta		R_Time_Sec
	jsr		F_Display_Time
	rts

; 减时独立于动画显示进行
Des_Time_Count:
	rmb1	Timer_Flag
	lda		R_Time_Sec
	cmp		#01
	beq		Count_Dec_Min					; 减到1就需要发生借位
	cmp		#00								; 因为这时播放的是1-0的动画
	beq		Count_BorrowToMin				; 秒数满则借位分钟数
	dec		R_Time_Sec
	rts
Count_BorrowToMin:
	lda		R_Time_Min
	cmp		#00
	beq		Count_Stop						; 若借位时分钟已经为0，则计数停止
	lda		#$60
	sta		R_Time_Sec
	rts
Count_Dec_Min:
	dec		R_Time_Sec
	dec		R_Time_Min
	rts
Count_Stop:		
	lda		#$0
	sta		R_Time_Sec
	sta		R_Time_Min
	rts
