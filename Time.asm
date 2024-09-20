F_Sec_Pos_Counter:
	lda		Timer_Flag
	and		#$81							; �����16hz��ʱ������һ��Ϊ1
	cmp		#$80
	bne		L_Sec_Pos_rts
	rmb7	Timer_Flag

	inc		Frame_Counter

	lda		R_Time_Sec
	cmp		#60
	beq		L_CarryToMin					; ���λ�ֶ���

	jsr		F_DisFrame_Sec_d4				; sec��λ��ʱ����

	lda		R_Time_Sec						; ���ʮλ��û�н�λ
	jsr		F_DivideBy10					; ����10�Ľ����Ϊ�㣬������Ϊ0��ִ��ʮλ�Ķ���
	cmp		#0								; ��Ϊ0��һ����ʮλ��d3�޶���
	beq		L_Sec_D3_Out
	lda		P_Temp							; ������Ϊ0Ҳ������ʮλ
	cmp		#0
	bne		L_Sec_D3_Out

	jsr		F_DisFrame_Sec_d3				; secʮλ��ʱ����

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
	beq		L_Time_Overflow					; ����99min59s��Ϊ���

	jsr		F_DisFrame_Sec_d4				; Sec��λ��ʱ����
	jsr		F_DisFrame_Sec_d3				; Secʮλ��ʱ����
	jsr		F_DisFrame_Min_d2				; Min��λ��ʱ����

	lda		R_Time_Min						; ���ʮλ��û�н�λ
	jsr		F_DivideBy10					; ����10�Ľ����Ϊ�㣬������Ϊ0��ִ��ʮλ�Ķ���
	cmp		#0								; ��Ϊ0��һ����ʮλ��d3�޶���
	beq		L_Min_D1_Out
	lda		P_Temp							; ������Ϊ0Ҳ������ʮλ
	cmp		#0
	bne		L_Min_D1_Out

	jsr		F_DisFrame_Min_d1				; Minʮλ��ʱ����

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
	lda		#$0c							; ����ʱ�������뵹��ʱ��̬ͣ
	sta		Sys_Status_Flag
	lda		#99
	sta		R_Time_Min
	lda		#59
	sta		R_Time_Sec
	jsr		F_Display_Time
	rts

; ��ʱ�����ڶ�����ʾ����
Pos_Time_Count:
	rmb1	Timer_Flag
	lda		R_Time_Sec
	cmp		#59
	beq		Count_Add_Min
	cmp		#60
	beq		Count_CarryToMin				; ���������λ������
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
	ldx		#0								; ��ʼ�� X �Ĵ���Ϊ 0��������
	sta		P_Temp							; ��ʱ��������
DivideBy10:
	cmp		#10								; ��� A �Ƿ���ڵ��� 10
	bcc		Done							; ��� A С�� 10����ת�� Done
	sec										; ���ý�λ��׼������
	sbc		#10								; A = A - 10
	inx										; X = X + 1����¼��
	bra		DivideBy10						; ���û�н�λ������ѭ��
Done:
	sta		P_Temp							; ʣ��ֵ(����)
	txa
	rts






; ����ʱ����
F_Sec_Des_Counter:
	bbs0	Timer_Flag, Is_Frame_Come		; ����Ϊ0ʱ���ж�֡
	rts
; �ж��Ƿ���Ҫ��ʱ�����ǵ����Ķ���֡
Is_Frame_Come:
	bbr1	Timer_Flag,Add_Sec_Out			; ����ʱ��־���ʱ
	dec		R_Time_Sec
	rmb1	Timer_Flag						; ����Ҫ����8֡����ʱֻ��1��
; ��16Hzû������������
Add_Sec_Out:
	bbs7	Timer_Flag, Count_Start			; ��16Hz��־����֡
	rts

Count_Start:
	lda		Frame_Counter					; �����ã�����֡������ֵ
	dec		Frame_Counter					; ֡����

	lda		R_Time_Sec						; �ж��Ƿ��н�λ
	clc
	adc		#$01
	cmp		#$00
	bne		Set_BorrowFlag_Out				; �ý�λ������־
	smb2	Frame_Flag
Set_BorrowFlag_Out:
	bbr2	Frame_Flag,Borrow_Out
	bra		L_BorrowToMin
Borrow_Out:
	jsr		F_DisFrame_Sec_d4				; sec��λ��ʱ����

	lda		R_Time_Sec						; �����ʮλ��û�н�λ
	clc
	adc		#$01							; �����Ǽ�ʱ�Ǽ�1�Ž������������1���������ĵ�ǰ����
	jsr		F_DivideBy10					; ����10�Ľ����Ϊ�㣬������Ϊ0��ִ��ʮλ�Ķ���
	cmp		#0								; ��Ϊ0��һ����ʮλ��d3�޶���
	beq		L_Sec_D3_Out_Des
	lda		P_Temp							; ������Ϊ0Ҳ������ʮλ
	cmp		#0
	bne		L_Sec_D3_Out_Des

	jsr		F_DisFrame_Sec_d3				; secʮλ��ʱ����


L_Sec_D3_Out_Des:
	lda		Frame_Counter					; �ߵ���8֡������֡����
	cmp		#$0
	beq		L_Sec_Des_Out

	ldx		#lcd_MS
	jsr		F_ClrpSymbol					; ��û���궯����ϨMS

	rmb7	Timer_Flag						; ���16Hz��־������û��16Hz���ظ����붯��

	rts

L_Sec_Des_Out:
	rmb0	Timer_Flag						; ���ж���֡�����Ϊ�����
	rmb7	Timer_Flag						; ���16Hz��־
	ldx		#lcd_MS							; ��MS������֡����
	jsr		F_DispSymbol
	lda		#$8
	sta		Frame_Counter

L_Sec_Des_rts:
	rts

L_BorrowToMin:
	smb2	Frame_Flag
	bbs1	Frame_Flag,Dec_Once_Min			; ��λ�����ӣ�����8֡����������ʱֻ��1��
	dec		R_Time_Min
	lda		#59
	sta		R_Time_Sec
	smb1	Frame_Flag
Dec_Once_Min:
	lda		R_Time_Min
	clc
	adc		#$01
	cmp		#$00
	beq		L_Time_Stop						; �Ƶ�00:00��ֹͣ

	jsr		F_DisFrame_Sec_d4				; Sec��λ��ʱ����
	jsr		F_DisFrame_Sec_d3				; Secʮλ��ʱ����
	jsr		F_DisFrame_Min_d2				; Min��λ��ʱ����

	lda		R_Time_Min						; ���ʮλ��û�н�λ
	clc
	adc		#$01
	jsr		F_DivideBy10					; ����10�Ľ����Ϊ�㣬������Ϊ0��ִ��ʮλ�Ķ���
	cmp		#0								; ��Ϊ0��һ����ʮλ��d3�޶���
	beq		L_Min_D1_Out_Des
	lda		P_Temp							; ������Ϊ0Ҳ������ʮλ
	cmp		#0
	bne		L_Min_D1_Out_Des

	jsr		F_DisFrame_Min_d1				; Minʮλ��ʱ����

L_Min_D1_Out_Des:
	lda		Frame_Counter					; �����߶�����ϨMS
	cmp		#$0
	beq		L_Min_Des_Out
	ldx		#lcd_MS
	jsr		F_ClrpSymbol
	rts

L_Min_Des_Out:
	rmb1	Frame_Flag						; ��0��ʱ��־λ�Ա��´ν�λ
	rmb2	Frame_Flag						; ���λ��־λ�������ٽ���λ����
	ldx		#lcd_MS							; �ߵ���8֡������֡����
	jsr		F_DispSymbol					; ���߶����˾���MS
	lda		#$8
	sta		Frame_Counter
	rts

L_Time_Stop:
	lda		#$01							; ����ʱ�����ص���ʼ̬
	sta		Sys_Status_Flag
	smb3	Timer_Flag						; ��ʱ��ɱ�־λ
	lda		#$07							; ������������
	sta		Beep_Serial
	lda		#$0
	sta		R_Time_Min
	sta		R_Time_Sec
	jsr		F_Display_Time
	rts
