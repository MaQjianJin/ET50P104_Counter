.Kdata
;***************************************
; RAM Address
;***************************************
RamStarAddr		EQU		1800H			;RAM的开始地址
LCD_RamAddr		EQU		RamStarAddr		;LCD RAM的地址
Time_Addr		EQU		RamStarAddr+Time_Str_Addr-Page0RamStarAddr ;事件相关数据的地址


;***************************************
;Time_Addr		EUQ		B0H
;***************************************
.PAGE0     ;page 0的内存布局
;***************************************
;	ORG	0098H
;---------------------------------------------------------------------
	ORG	0080H
Page0RamStarAddr		EQU		$	
LCDRAM					DS		6*6

R_Int_Backup			DS		1

Counter_1Hz				DS		1
Counter_4Hz				DS		1
Counter_16Hz			DS		1

TimeCnt					DS		1

Frame_Counter			DS		1

Beep_Serial				DS		1

Timer_Flag				DS		1
;bit0 = 1 半秒标志
;bit1 = 1 走时标志
;bit2 = 1 按键提示音标志位
;bit3 = 1 计时完成标志位
;bit4 = 1 快加标志位
;bit5 = 1 Tim1 32Hz计时标志位
;bit6 = 1 LCD 4Hz计时
;bit7 = 1 Tim0 16Hz计时

Sys_Status_Flag			DS		1
;bit0 = 1 初始状态，上电进入
;bit1 = 1 正计时态
;bit2 = 1 倒计时态
;bit3 = 1 暂停态

Key_Flag				DS		1
;bit0 = 1 扫键标志位
;bit1 = 1 首次触发
;bit2 = 1 按键处理

Frame_Flag				DS		1
;bit0 = 1 计时开始
;bit1 = 1 分钟借位


P_PA_IO_Backup      	DS	1	;B
P_PA_Backup         	DS	1	;C
P_PA_WAKE_Backup		DS	1	;D
P_PC_IO_Backup      	DS	1	;E
P_PC_Backup         	DS	1	;F
;---------------------------------------
Time_Str_Addr	EQU		$
R_Time_Sec				DS	1	;时间秒
R_Time_Min				DS	1	;时间分

;---------------------------------------       
P_Temp					DS	16	
;---------------------------------------
;---------------------------------------
;***************************************
.ENDS
;***************************************
.Udata
;---------------------------------------
	ORG		1880H
;---------------------------------------
;---------------------------------------
.ENDS

