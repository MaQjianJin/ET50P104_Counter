;********************************************************************************
; PROJECT	: Time Counter(ET50P104)					*
; AUTHOR	: WYH										*
; REVISION	: 09/23/2024  V1.0							*
; High OSC CLK  : Internal RC 4.4MHz	Fcpu = Fosc/2	*
; Function	: 											*
;********************************************************************************
	.CHIP	W65C02S		;cpu的选型
	;.INCLIST	ON		;宏定义和文件
	.MACLIST	ON
;***************************************
CODE_BEG	EQU		F000H ;C000H(4K*4次)		;起始地址
;***************************************

PROG	SECTION	OFFSET	CODE_BEG				;定义代码段的偏移量从CODE_BEG开始，用于组织程序代码。

;***************************************
;*	header include								;头文件
;***************************************
	.include	50P016.h
	.INCLUDE	RAM.INC	
	.include	50P016.mac
	.INCLUDE	MACRO.MAC
;***************************************
STACK_BOT		EQU		FFH						;堆栈底部
;***************************************
	.PROG										;程序开始
V_RESET:
	NOP
	NOP
	NOP
	LDX		#STACK_BOT  
	TXS											; 使用这个值初始化堆栈指针，这通常是为了设置堆栈的底部地址，确保程序运行中堆栈的正确使用。
	LDA		#$B7								; #$07    
	STA		SYSCLK								; 设置系统时钟
	ClrAllRam									; 清RAM
	LDA		#$0
	STA		DIVC								; 分频控制器，定时器与DICV异步
	STA		IER									; 除能中断
	STA		IFR									; 初始化中断标志位
	STA		PB
	LDA		FUSE
	STA		MF									;为内部RC振荡器提供校准数据

	jsr		F_Beep_Init
	jsr		L_Init_SystemRam_Prog				;初始化系统RAM并禁用所有断电保留的RAM

	jsr		F_LCD_Init
	jsr		F_Port_Init

	lda		#$07								;系统时钟和中断使能
	sta		SYSCLK

	jsr		F_Timer_Init
	jsr		F_Display_Time

	cli		; 开总中断

	; test Code

;***********************************************************************
;***********************************************************************
MainLoop:
main:
	lda		Timer_Flag							; 判断是否需要响铃
	and		#1100B
	cmp		#$00
	beq		Beep_Out
	jsr		F_Beep_Manage

Beep_Out:
	bbs1	Key_Flag,Key_QA_Out					; 首次触发必定进扫键
	bbr6	Timer_Flag,Key_Out					; 必须有4Hz计时标志才能进扫键
	rmb6	Timer_Flag							; 清4Hz标志
	bbs4	Timer_Flag,Key_QA_Out
	inc		Counter_1Hz
	lda		Counter_1Hz
	cmp		#$8
	bcc		Key_QA_Out
	lda		#$0
	sta		Counter_1Hz
	smb4	Timer_Flag							; 长按1s就给快加标志

Key_QA_Out:
	smb0	Key_Flag							; 扫键标志位

Key_Flag_Out:
	bbr0	Key_Flag,Key_Out
	jsr		F_Key_Trigger						; 有按键按下和长按延时到了才扫键

Key_Out:
	; 判断处于那种状态，并进入对应状态的处理
	bbs0	Sys_Status_Flag, Status_Init
	bbs3	Sys_Status_Flag, Status_Pause
	bbs1	Sys_Status_Flag, Status_Pos
	bbs2	Sys_Status_Flag, Status_Des
	bbs4	Sys_Status_Flag, Status_Finish

Status_Init:
	ldx		#lcd_MS
	jsr		F_DispSymbol
	bra		MainLoop
Status_Pos:
	jsr		F_Sec_Pos_Counter
	bra		MainLoop
Status_Des:
	jsr		F_Sec_Des_Counter
	bra		MainLoop
Status_Pause:
	ldx		#lcd_MS
	jsr		F_DispSymbol
	bra		MainLoop
Status_Finish:
	jsr		F_Des_Counter_Finish

	bbr7	Timer_Flag,Blink_Out
	rmb7	Timer_Flag
	lda		CC1
	cmp		#$08
	beq		Blink_MS
	inc		CC1
	bra		MainLoop
Blink_MS:
	lda		#$00
	sta		CC1
	bbr3	Frame_Flag,Blink_DP
	rmb3	Frame_Flag
	ldx		#lcd_MS
	jsr		F_ClrpSymbol
	bra		Blink_Out
Blink_DP:
	smb3	Frame_Flag
	ldx		#lcd_MS
	jsr		F_DispSymbol

Blink_Out:
	bra		MainLoop


;***********************************************************************
;***********************************************************************
V_IRQ:
	PHA
	LDA		P_IER
	AND		P_IFR
	STA		R_Int_Backup	

	BBS6	R_Int_Backup,L_LcdIrq
	BBS3	R_Int_Backup,L_Timer2Irq
	BBS4	R_Int_Backup,L_PaIrp
	BBS0	R_Int_Backup,L_DivIrq
	BBS2	R_Int_Backup,L_Timer1Irq
	BBS1	R_Int_Backup,L_Timer0Irq
	BRA		L_EndIrq

L_DivIrq:
	CLR_DIV_IRQ_FLAG
	BRA		L_EndIrq

L_Timer2Irq:
	CLR_TMR2_IRQ_FLAG
	smb0	Timer_Flag							; 半秒标志，定时器本身是1秒
	smb1	Timer_Flag							; 走时标志，第一次进计数子程序需要走时
	bra		L_EndIrq							; 下半秒由动画完成时定义

L_Timer0Irq:
	CLR_TMR0_IRQ_FLAG
	lda		Counter_16Hz						; 帧计时
	cmp		#8
	bcc		L_16Hz_Count_Out
	lda		#0
	sta		Counter_16Hz
	smb7	Timer_Flag
	bra		L_EndIrq
L_16Hz_Count_Out:
	inc		Counter_16Hz
	BRA		L_EndIrq

L_Timer1Irq:
	CLR_TMR1_IRQ_FLAG
	smb5	Timer_Flag
	BRA		L_EndIrq

L_PaIrp:
	CLR_KEY_IRQ_FLAG

	smb0	Key_Flag
	smb1	Key_Flag							; 首次触发
	rmb4	Timer_Flag							; 快加标志位
	rmb6	Timer_Flag

	EN_LCD_IRQ

	BRA		L_EndIrq

L_LcdIrq:
	CLR_LCD_IRQ_FLAG
	lda		Counter_4Hz
	cmp		#$8
	bcc		L_LCD_4Hz_Out
	lda		#$0
	sta		Counter_4Hz
	smb6	Timer_Flag
	bra		L_EndIrq
L_LCD_4Hz_Out:
	inc		Counter_4Hz

L_EndIrq:
;	BBS3	IFR,L_Timer2Irq
	PLA
	RTI


;***********************************************************************
.INCLUDE	ScanKey.asm
.INCLUDE	Time.asm
.INCLUDE	Beep.asm
.INCLUDE	Init.asm
.INCLUDE	Disp.asm
.INCLUDE	Lcdtab.asm
.INCLUDE	Display.asm
.INCLUDE	Delay.asm
;--------------------------------------------------------	
;***********************************************************************
	.BLKB	$FFFF-$,$FF
	
	.ORG	0FFF8H
	DB		11011111B	;3DH	;AC=PA3,bit54=01,4KBRom ;BR4M ;PA上拉或悬空
	DB		11111110B	;Protect
;***********************************************************************
	.ORG	0FFFCH
	DW		V_RESET
	DW		V_IRQ
	
	.ENDS
	.END
	