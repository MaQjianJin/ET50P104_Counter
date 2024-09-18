L_Init_SystemRam_Prog:							; ϵͳ��ʼ��
	LDA		#0
	STA		R_Time_Sec
	STA		R_Time_Min
	STA		Key_Flag
	sta		Beep_Serial
	sta		Counter_4Hz
	sta		Counter_1Hz
	sta		Counter_16Hz
	sta		Frame_Counter
	sta		TimeCnt
	sta		CC1
	lda		#$01
	STA		Timer_Flag
	sta		Sys_Status_Flag

	RTS


F_LCD_Init:
	jsr		F_ClearScreen						; LCD��ʼ��
	CHECK_LCD

	PC45_SEG									; ����IO��ΪSEG��ģʽ
	PC67_SEG
	PD03_SEG
	PD47_SEG

	RMB0	P_LCD_COM							; ����COM������
	SMB1	P_LCD_COM

	LCD_ON
	jsr		F_ClearScreen						; ����

	rts


F_Port_Init:
	LDA		#$A4								; PA2\5\7����������
	STA		P_PA_WAKE
	STA		P_PA_IO
	LDA		#$FF
	STA		P_PA
	EN_PA_IRQ									; ��PA���ⲿ�ж�

	PB2_PWM
	PB3_PB3_COMS

	rts


F_Timer_Init:
	TMR1_CLK_512Hz								; TIM1ʱ��ԴFsub/64(512Hz)
	TMR0_CLK_FSUB								; TIM0ʱ��ԴFsub(32768Hz)
	DIV_512HZ									; DIV��Ƶ512Hz

	lda		#$0									; ��װ�ؼ�������Ϊ0
	sta		TMR0
	sta		TMR2

	lda		#$ef
	sta		TMR1

	rmb6	DIVC								; �رն�ʱ��ͬ��

	EN_TMR1_IRQ									; ����ʱ���ж�
	EN_TMR2_IRQ
	EN_TMR0_IRQ
	TMR0_ON
	TMR1_OFF
	TMR2_ON

	rts


F_Beep_Init:
	TONE_2KHZ									; ���÷���������Ƶ��
	lda		#$0
	sta		AUDCR
	lda		#$ff
	sta		P_AUD
