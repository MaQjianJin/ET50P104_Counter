F_Sec_Pos_Counter:
	lda		Timer_Flag
	and		#$81
	cmp		#$81								; 进动画需要同时满足有半秒和有16Hz标志
	beq		Count_Start_Pos
	rts

Count_Start_Pos:
	lda		Frame_Flag
	inc		Frame_Counter
	lda		R_Time_Sec
	cmp		#59
	bne		Set_CarryFlag_Out
	smb2	Frame_Flag							; 置借(进)位发生标志
Set_CarryFlag_Out:
	bbr2	Frame_Flag,Carry_Out				; 判断是否存在分钟进位
	bra		L_CarryToMin
Carry_Out:
	jsr		F_DisFrame_Sec_d4					; sec个位走时动画

	lda		R_Time_Sec							; 检测sec十位有无进位
	clc
	adc		#$01								; 判断下1S需不需要走十位
	jsr		F_DivideBy10
	cmp		#0									; 商为0则一定无十位，十位不走时
	beq		L_Sec_D3_Out
	lda		P_Temp								; 余数不为0也不更新十位
	cmp		#0
	bne		L_Sec_D3_Out

	jsr		F_DisFrame_Sec_d3					; sec十位走时动画

L_Sec_D3_Out:
	lda		Frame_Counter
	cmp		#$08
	beq		L_Sec_Pos_Out
	
	ldx		#lcd_MS
	jsr		F_ClrpSymbol

	rmb7	Timer_Flag							; 清16Hz，避免重复播动画

	rts

L_Sec_Pos_Out:
	rmb0	Timer_Flag							; 动画走完即为后半S
	rmb7	Timer_Flag							; 清除相关标志位避免错误进入
	inc		R_Time_Sec							; 增秒放在动画完成部分保证只增1次
	ldx		#lcd_MS
	jsr		F_DispSymbol
	lda		#0
	sta		Frame_Counter

L_Sec_Pos_rts:
	rts

L_CarryToMin:
	smb2	Frame_Flag

	lda		R_Time_Min
	cmp		#99
	beq		L_Time_Overflow						; 计到99:59停止

	jsr		F_DisFrame_Sec_d4					; Sec个位走时
	jsr		F_DisFrame_Sec_d3					; Sec十位走时
	jsr		F_DisFrame_Min_d2					; Min个位走时

	lda		R_Time_Min							; 检测Min十位有无进位
	clc
	adc		#$01								; 判断下1Min需不需要走十位
	jsr		F_DivideBy10						; 除10判断十位是否需要动画
	cmp		#0
	beq		L_Min_D1_Out_Pos
	lda		P_Temp
	cmp		#0
	bne		L_Min_D1_Out_Pos

	jsr		F_DisFrame_Min_d1					; Min十位走时动画

L_Min_D1_Out_Pos:
	lda		Frame_Counter
	cmp		#$08
	beq		L_Min_Pos_Out
	ldx		#lcd_MS
	jsr		F_ClrpSymbol
	rts

L_Min_Pos_Out:
	rmb2	Frame_Flag							; 进位动画播放完毕
	rmb0	Timer_Flag							; 清除相关的标志位
	rmb7	Timer_Flag

	lda		#$00
	sta		R_Time_Sec							; 清空秒数
	inc		R_Time_Min							; 增分

	ldx		#lcd_MS
	jsr		F_DispSymbol
	lda		#0
	sta		Frame_Counter
	rts

L_Time_Overflow:
	lda		#$1100B								; 正计时完成则回到倒计时暂停
	sta		Sys_Status_Flag
	TMR0_OFF									; 暂停态不需要时钟
	TMR2_OFF
	lda		#99
	sta		R_Time_Min
	lda		#59
	sta		R_Time_Sec

	smb0	Overflow_Flag						; 置位正计时溢出标志位

	lda		#$00
	sta		Frame_Flag							; 复位相关标志位
	rmb0	Timer_Flag
	rmb7	Timer_Flag

	jsr		F_Display_Time
	rts


F_DivideBy10:
	ldx		#0									; 初始化X寄存器为0
	sta		P_Temp								; 临时保存余数
DivideBy10:
	cmp		#10									; 检查A是否大于等于10
	bcc		Done								; 如果A小于10，跳转Done
	sec											; 设置进位，准备减法
	sbc		#10									; A=A-10
	inx											; X=X+1计算商
	bra		DivideBy10							; 如果没有借位就继续循环
Done:
	sta		P_Temp								; 余数
	txa
	rts






; 倒计时部分
F_Sec_Des_Counter:
	bbs0	Timer_Flag, Is_Frame_Come_Des		; 半秒为1时，判断帧计时
	rts
; 判断是否需要减时，还是单纯的动画帧
Is_Frame_Come_Des:
	bbr1	Timer_Flag,Add_Sec_Out_Des			; 有走时标志则减时
	dec		R_Time_Sec
	rmb1	Timer_Flag							; 动画放8帧，减秒只减一次
; 没有16Hz则不进动画
Add_Sec_Out_Des:
	bbs7	Timer_Flag, Count_Start_Des
	rts

Count_Start_Des:
	dec		Frame_Counter						; 帧计数
	lda		R_Time_Sec							; 判断是否存在分钟借位
	clc
	adc		#$01
	cmp		#$00
	bne		Set_BorrowFlag_Out					; 置借(进)位发生标志
	smb2	Frame_Flag
Set_BorrowFlag_Out:
	bbr2	Frame_Flag,Borrow_Out
	bra		L_BorrowToMin
Borrow_Out:
	jsr		F_DisFrame_Sec_d4					; sec个位走时动画

	lda		R_Time_Sec							; 检测sec十位有无借位
	clc
	adc		#$01								; 先减秒再进动画，需补偿1秒
	jsr		F_DivideBy10
	cmp		#0									; 商为0则一定无十位，十位不走时
	beq		L_Sec_D3_Out_Des
	lda		P_Temp								; 余数不为0也不更新十位
	cmp		#0
	bne		L_Sec_D3_Out_Des

	jsr		F_DisFrame_Sec_d3					; sec十位走时动画


L_Sec_D3_Out_Des:
	lda		Frame_Counter						; 第8帧重置帧计数
	cmp		#$0
	beq		L_Sec_Des_Out

	ldx		#lcd_MS
	jsr		F_ClrpSymbol						; 没走完动画则熄灭MS

	rmb7	Timer_Flag							; 清16Hz，避免重复播动画

	rts

L_Sec_Des_Out:
	rmb0	Timer_Flag							; 动画走完即为后半S
	rmb7	Timer_Flag							; 同样清16Hz
	ldx		#lcd_MS								; 亮MS并重置帧计数
	jsr		F_DispSymbol
	lda		#$8
	sta		Frame_Counter

L_Sec_Des_rts:
	rts

L_BorrowToMin:
	smb2	Frame_Flag
	bbs1	Frame_Flag,Dec_Once_Min				; 借位分钟，动画8帧但减分只减1次
	dec		R_Time_Min
	lda		#59
	sta		R_Time_Sec
	smb1	Frame_Flag
Dec_Once_Min:
	lda		R_Time_Min
	clc
	adc		#$01
	cmp		#$00
	beq		L_Time_Stop							; 计到00:00停止

	jsr		F_DisFrame_Sec_d4					; Sec个位走时
	jsr		F_DisFrame_Sec_d3					; Sec十位走时
	jsr		F_DisFrame_Min_d2					; Min个位走时

	lda		R_Time_Min							; 检测Min十位有无借位
	clc
	adc		#$01
	jsr		F_DivideBy10						; 除10判断十位是否需要动画
	cmp		#0
	beq		L_Min_D1_Out_Des
	lda		P_Temp
	cmp		#0
	bne		L_Min_D1_Out_Des

	jsr		F_DisFrame_Min_d1					; Min十位走时动画

L_Min_D1_Out_Des:
	lda		Frame_Counter						; 有动画就熄灭MS
	cmp		#$0
	beq		L_Min_Des_Out
	ldx		#lcd_MS
	jsr		F_ClrpSymbol
	rts

L_Min_Des_Out:
	rmb1	Frame_Flag							; 减分标志位
	rmb2	Frame_Flag							; 借(进)位标志位
	ldx		#lcd_MS								; 重置帧计数
	jsr		F_DispSymbol						; 无动画就亮MS
	lda		#$8
	sta		Frame_Counter
	rts

L_Time_Stop:
	lda		#10000B								; 倒计时完成则进入倒计时完成态进行响铃
	sta		Sys_Status_Flag
	
	lda		#$00
	sta		Frame_Flag							; 复位相关标志位
	sta		R_Time_Min
	sta		R_Time_Sec
	rmb0	Timer_Flag
	rmb7	Timer_Flag

	jsr		F_Display_Time
	jmp		Beep_Start


F_Des_Counter_Finish:
	bbs0	Timer_Flag,Beep_Start				; 每隔1秒进一次
	rts
Beep_Start:
	lda		CC2
	cmp		#29
	beq		Finish_Time_Out

	lda		#01001001B							; 设置响铃序列
	sta		Beep_Serial
	lda		#10B
	sta		Beep_Serial+1

	smb3	Timer_Flag							; 计时完成响铃标志位
	rmb0	Timer_Flag							; 清1秒标志防止重复进入
	inc		CC2
	rts

Finish_Time_Out:
	lda		R_SetTime_Min						; 计数重置为倒计时初始值
	sta		R_Time_Min
	lda		R_SetTime_Sec
	sta		R_Time_Sec
	jsr		F_Display_Time
	lda		#1100B								; 状态切换为倒计时暂停态
	sta		Sys_Status_Flag
	rmb7	TMRC
	TMR0_OFF
	TMR1_OFF
	TMR2_OFF
	lda		#00
	sta		CC2

	rts