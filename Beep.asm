F_Beep_Manage:
	TMR1_ON
	
	bbr5	Timer_Flag,L_Beep_rts			; 响铃的持续和间隔都是1/32秒
	rmb5	Timer_Flag						; 清掉1/32秒标志位

	lda		Beep_Serial						; 响铃序列全为0则响铃结束
	cmp		#$0
	beq		L_Beep_Over
	
	bbr0	Beep_Serial,L_No_Beep			; 判断响铃序列第1位，为1就响，为0就不响
	smb7	TMRC
	clc
	ror		Beep_Serial+1
	ror		Beep_Serial

	bra		L_Beep_rts

L_No_Beep:
	rmb7	TMRC
	clc
	ror		Beep_Serial+1
	ror		Beep_Serial

L_Beep_rts:
	rts

L_Beep_Over:								; 关闭定时器和蜂鸣输出，复位相应标志位
	TMR1_OFF
	rmb7	TMRC
	rmb2	Timer_Flag
	rmb3	Timer_Flag
	rts
