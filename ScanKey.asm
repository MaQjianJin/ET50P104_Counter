F_Key_Trigger:
	bbs4	Timer_Flag,L_Quik_Add_1
	rmb0	Key_Flag
	bbr1	Key_Flag,L_Key_Wait					; 首次按键触发才需要消抖
	rmb1	Key_Flag							; 清除首次按键触发
	LDA		#$00
	STA		P_Temp
L_Delay_Trigger:								; 消抖延时循环用标签
	inc		P_Temp
	lda		P_Temp
	bne		L_Delay_Trigger						; 软件消抖

L_Key_Beep:
	lda		#10B								; 设置按键提示音的响铃序列
	sta		Beep_Serial
	lda		#$ef
	sta		TMR1
	bra		L_Quik_Add_1

L_Key_Wait:	
	lda		P_PA								; 长按时，在快加到来前，只需要判断有效按键是否存在
	and		#$a4								; 并关闭中断
	cmp		#$0
	beq		L_Quik_Add_2
	bne		L_Key_rts

L_Quik_Add_1:
	lda		P_PA								; 判断4种按键触发情况
	and		#$A4
	cmp		#$04
	bne		No_KeyM_Trigger						; 由于跳转寻址能力的问题，这里采用jmp进行跳转
	rmb0	Overflow_Flag						; 第一次按键触发后，正计时溢出都不再有效
	jmp		L_KeyM_Trigger						; M单独触发
No_KeyM_Trigger:
	cmp		#$20
	bne		No_KeyS_Trigger
	rmb0	Overflow_Flag
	jmp		L_KeyS_Trigger						; S单独触发
No_KeyS_Trigger:
	bbs4	Timer_Flag,L_Quik_Add_2				; C触发和ms触发不需要快加
	cmp		#$80
	bne		No_KeyC_Trigger
	jmp		L_KeyC_Trigger						; C单独触发
No_KeyC_Trigger:
	cmp		#$24
	bne		L_Quik_Add_2
	rmb0	Overflow_Flag
	jmp		L_KeyMS_Trigger						; M、S同时触发

L_Quik_Add_2:
	DIS_LCD_IRQ
	rmb4	Timer_Flag							; 若无有效按键组合，则清掉快加标志位
	rmb6	Timer_Flag
	lda		#$0
	sta		Counter_4Hz							; 非以上四种情况则属无效按键触发

L_Key_rts:
	rts									


L_KeyM_Trigger:
	smb2	Timer_Flag							; 按键提示音
	; 处理正、倒计时态的情况，若是这两种状态，则按键触发无效
	bbs3	Sys_Status_Flag,L_KeyM_Pause		; 若非暂停态或初始态，则状态不会改变
	bbs0	Sys_Status_Flag,L_KeyM_Pause
	bbs4	Sys_Status_Flag,L_KeyM_Finish
	rts
	; 处理初始态和暂停态的情况
L_KeyM_Pause:
	lda		#1100B
	sta		Sys_Status_Flag
	inc		R_Time_Min
	lda		R_Time_Sec
	sta		R_SetTime_Sec						; 每次M的有效都会触发一次倒计时初值的更新
	lda		R_Time_Min
	sta		R_SetTime_Min
	lda		R_Time_Min
	cmp		#100
	beq		L_Reset_Min
	jsr		L_DisTimer_Min
	rts

L_Reset_Min:
	lda		#$0
	sta		R_Time_Min
	jsr		L_DisTimer_Min
	rts

; 处理倒计时完成态的情况
L_KeyM_Finish:
	lda		R_SetTime_Min						; 计数重置为倒计时初始值
	sta		R_Time_Min
	lda		R_SetTime_Sec
	sta		R_Time_Sec
	jsr		F_Display_Time
	lda		#1100B								; 状态切换为倒计时暂停态
	sta		Sys_Status_Flag
	TMR1_OFF
	rmb7	TMRC
	rts


L_KeyS_Trigger:
	smb2	Timer_Flag							; 按键提示音
	; 处理正、倒计时态的情况，若是这两种状态，则按键触发无效
	bbs3	Sys_Status_Flag,L_KeyS_Pause		; 若非暂停态或初始态，则状态不会改变
	bbs0	Sys_Status_Flag,L_KeyS_Pause
	bbs4	Sys_Status_Flag,L_KeyS_Finish
	rts
	; 处理初始态和暂停态的情况
L_KeyS_Pause:
	lda		#1100B
	sta		Sys_Status_Flag						; 切换为倒计时暂停态
	
	inc		R_Time_Sec
	lda		R_Time_Sec
	sta		R_SetTime_Sec						; 每次S的有效都会触发一次倒计时初值的更新
	lda		R_Time_Min
	sta		R_SetTime_Min
	lda		R_Time_Sec
	cmp		#60
	beq		L_Reset_Sec
	jsr		L_DisTimer_Sec
	rts

L_Reset_Sec:									; 60溢出后回到0
	lda		#$0
	sta		R_Time_Sec
	jsr		L_DisTimer_Sec
	rts

; 处理倒计时完成态的情况
L_KeyS_Finish:
	lda		R_SetTime_Min						; 计数重置为倒计时初始值
	sta		R_Time_Min
	lda		R_SetTime_Sec
	sta		R_Time_Sec
	jsr		F_Display_Time
	lda		#1100B								; 状态切换为倒计时暂停态
	sta		Sys_Status_Flag
	TMR1_OFF
	rmb7	TMRC
	rts


L_KeyC_Trigger:
	smb2	Timer_Flag							; 按键提示音

	bbs4	Sys_Status_Flag,L_KeyC_Finish		; 倒计时完成态处理
	bbs0	Overflow_Flag,L_KeyC_Overflow		; 正计时完成时额外处理
	lda		Sys_Status_Flag						; 处于正、倒计时态，需转为对应暂停态
	cmp		#$02
	beq		L_KeyC_PosDes
	cmp		#$04
	beq		L_KeyC_PosDes

	bbs3	Sys_Status_Flag,L_KeyC_Pause		; 处于正、倒计时暂停态，需转为对应计时态
	; 处理初始态的情况
	lda		#$02								; 进入正计时态
	sta		Sys_Status_Flag
	lda		#$00
	sta		Frame_Counter
	sta		Frame_Flag
	TMR2_ON
	TMR0_ON
	smb0	Timer_Flag
	rts

	; 处理正倒计时中的情况
L_KeyC_PosDes:
	smb3	Sys_Status_Flag						; 进入正、倒计时暂停态
	jsr		F_Display_Time
	TMR2_OFF									; 关掉半秒计时和帧计时
	TMR0_OFF
	rts

	; 处理暂停态的情况
L_KeyC_Pause:
	bbs1	Sys_Status_Flag,No_Need_Des_Count	; 倒计时开始时如果是0，则转到正计时开始
	lda		R_Time_Min
	cmp		#$00
	bne		No_Need_Des_Count
	lda		R_Time_Sec
	cmp		#$00
	bne		No_Need_Des_Count
	lda		#$02
	sta		Sys_Status_Flag
No_Need_Des_Count:
	rmb3	Sys_Status_Flag						; 退出暂停态
	jsr		Init_Frame_Count					; 初始化FrameCount

	TMR2_ON										; 重新启动半秒计时和帧计时
	TMR0_ON
	rts

L_KeyC_Finish:
	lda		R_SetTime_Min						; 计数重置为倒计时初始值
	sta		R_Time_Min
	lda		R_SetTime_Sec
	sta		R_Time_Sec
	jsr		F_Display_Time
	lda		#1100B								; 状态切换为倒计时暂停态
	sta		Sys_Status_Flag
	TMR1_OFF
	rmb7	TMRC
	rts

L_KeyC_Overflow:								; 如果在正计时完成后按C
	rmb0	Overflow_Flag						; 则清空所有计数，回到初始态
	lda		#00
	sta		R_Time_Min
	sta		R_Time_Sec
	lda		#01
	sta		Sys_Status_Flag



L_KeyMS_Trigger:
	lda		#$0									; 回到初始态，全部清零
	sta		R_Time_Sec
	sta		R_Time_Min
	sta		Key_Flag
	sta		Sys_Status_Flag
	smb0	Sys_Status_Flag
	sta		Frame_Flag							; 复位相关标志位
	rmb0	Timer_Flag
	rmb7	Timer_Flag
	sta		TMR2								; 关闭半秒计时，并清空寄存器
	TMR2_OFF
	TMR0_OFF

	smb2	Timer_Flag							; 按键提示音标志位
	jsr		F_Display_Time
	rts

Init_Frame_Count:
	lda		#$00
	sta		Frame_Flag							; 复位相关标志位
	rmb0	Timer_Flag
	rmb7	Timer_Flag
	bbs1	Sys_Status_Flag, Pos_Frame_Count	; 根据目前计时状态初始化帧计数
	lda		#$08
	sta		Frame_Counter
	rts
Pos_Frame_Count:
	lda		#$00
	sta		Frame_Counter
	rts
