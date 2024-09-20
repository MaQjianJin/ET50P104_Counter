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
	TMR2_OFF
	TMR0_OFF
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
	bbs0	Timer_Flag, Is_Frame_Come		; 半秒为0时进判断帧
	rts
; 判断是否需要减时，还是单纯的动画帧
Is_Frame_Come:
	bbr1	Timer_Flag,Add_Sec_Out			; 有走时标志则减时
	dec		R_Time_Sec
	rmb1	Timer_Flag						; 动画要播放8帧，减时只减1次
; 若16Hz没到，不进动画
Add_Sec_Out:
	bbs7	Timer_Flag, Count_Start			; 无16Hz标志则不走帧
	rts

Count_Start:
	lda		Frame_Counter					; 测试用，监视帧计数的值
	dec		Frame_Counter					; 帧计数

	lda		R_Time_Sec						; 判断是否有借位
	clc
	adc		#$01
	cmp		#$00
	bne		Set_BorrowFlag_Out				; 置借位发生标志
	smb2	Frame_Flag
Set_BorrowFlag_Out:
	bbr2	Frame_Flag,Borrow_Out
	bra		L_BorrowToMin
Borrow_Out:
	jsr		F_DisFrame_Sec_d4				; sec个位走时动画

	lda		R_Time_Sec						; 检测秒十位有没有借位
	clc
	adc		#$01							; 由于是计时是减1才进动画，这里加1才是正常的当前秒数
	jsr		F_DivideBy10					; 除以10的结果不为零，且余数为0才执行十位的动画
	cmp		#0								; 商为0则一定无十位，d3无动画
	beq		L_Sec_D3_Out_Des
	lda		P_Temp							; 余数不为0也不更新十位
	cmp		#0
	bne		L_Sec_D3_Out_Des

	jsr		F_DisFrame_Sec_d3				; sec十位走时动画


L_Sec_D3_Out_Des:
	lda		Frame_Counter					; 走到第8帧就重置帧计数
	cmp		#$0
	beq		L_Sec_Des_Out

	ldx		#lcd_MS
	jsr		F_ClrpSymbol					; 若没走完动画则熄MS

	rmb7	Timer_Flag						; 清掉16Hz标志，避免没到16Hz就重复进入动画

	rts

L_Sec_Des_Out:
	rmb0	Timer_Flag						; 所有动画帧走完后即为后半秒
	rmb7	Timer_Flag						; 清掉16Hz标志
	ldx		#lcd_MS							; 亮MS并重置帧计数
	jsr		F_DispSymbol
	lda		#$8
	sta		Frame_Counter

L_Sec_Des_rts:
	rts

L_BorrowToMin:
	smb2	Frame_Flag
	bbs1	Frame_Flag,Dec_Once_Min			; 借位减分钟，播放8帧动画，但减时只减1次
	dec		R_Time_Min
	lda		#59
	sta		R_Time_Sec
	smb1	Frame_Flag
Dec_Once_Min:
	lda		R_Time_Min
	clc
	adc		#$01
	cmp		#$00
	beq		L_Time_Stop						; 计到00:00则停止

	jsr		F_DisFrame_Sec_d4				; Sec个位走时动画
	jsr		F_DisFrame_Sec_d3				; Sec十位走时动画
	jsr		F_DisFrame_Min_d2				; Min个位走时动画

	lda		R_Time_Min						; 检测十位有没有借位
	clc
	adc		#$01
	jsr		F_DivideBy10					; 除以10的结果不为零，且余数为0才执行十位的动画
	cmp		#0								; 商为0则一定无十位，d3无动画
	beq		L_Min_D1_Out_Des
	lda		P_Temp							; 余数不为0也不更新十位
	cmp		#0
	bne		L_Min_D1_Out_Des

	jsr		F_DisFrame_Min_d1				; Min十位走时动画

L_Min_D1_Out_Des:
	lda		Frame_Counter					; 还在走动画就熄MS
	cmp		#$0
	beq		L_Min_Des_Out
	ldx		#lcd_MS
	jsr		F_ClrpSymbol
	rts

L_Min_Des_Out:
	rmb1	Frame_Flag						; 置0减时标志位以便下次借位
	rmb2	Frame_Flag						; 清借位标志位，不用再进借位动画
	ldx		#lcd_MS							; 走到第8帧就重置帧计数
	jsr		F_DispSymbol					; 不走动画了就亮MS
	lda		#$8
	sta		Frame_Counter
	rts

L_Time_Stop:
	lda		#$01							; 倒计时完成则回到初始态
	sta		Sys_Status_Flag
	smb3	Timer_Flag						; 计时完成标志位
	lda		#$07							; 设置响铃序列
	sta		Beep_Serial
	lda		#$0
	sta		R_Time_Min
	sta		R_Time_Sec
	jsr		F_Display_Time
	rts
