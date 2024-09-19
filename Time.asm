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
	lda		Timer_Flag
	and		#$81							; �����16hz��ʱ������һ��Ϊ1
	cmp		#$80
	bne		L_Sec_Des_rts
	rmb7	Timer_Flag						; ÿ16Hz��һ֡����

	inc		Frame_Counter					; ֡����

	lda		R_Time_Sec						; ��λ
	cmp		#00
	beq		L_BorrowToMin					; ���λ�ֶ���

	jsr		F_DisFrame_Sec_d4				; sec��λ��ʱ����

	lda		R_Time_Sec						; �����ʮλ��û�н�λ
	jsr		F_DivideBy10					; ����10�Ľ����Ϊ�㣬������Ϊ0��ִ��ʮλ�Ķ���
	cmp		#0								; ��Ϊ0��һ����ʮλ��d3�޶���
	beq		L_Sec_D3_Out_Des
	lda		P_Temp							; ������Ϊ0Ҳ������ʮλ
	cmp		#0
	bne		L_Sec_D3_Out_Des

	jsr		F_DisFrame_Sec_d3				; secʮλ��ʱ����


L_Sec_D3_Out_Des:
	lda		Frame_Counter					; �ߵ���8֡�ͽ�����������
	cmp		#$08
	beq		L_Sec_Des_Out

	ldx		#lcd_MS
	jsr		F_ClrpSymbol					; ��û���궯����ϨMS

	rts

L_Sec_Des_Out:
	ldx		#lcd_MS							; ��MS�����֡����
	jsr		F_DispSymbol
	lda		#0
	sta		Frame_Counter

L_Sec_Des_rts:
	rts

L_BorrowToMin:
	lda		R_Time_Min
	cmp		#00
	beq		L_Time_Stop						; �Ƶ�00:00��ֹͣ

	jsr		F_DisFrame_Sec_d4				; Sec��λ��ʱ����
	jsr		F_DisFrame_Sec_d3				; Secʮλ��ʱ����
	jsr		F_DisFrame_Min_d2				; Min��λ��ʱ����

	lda		R_Time_Min						; ���ʮλ��û�н�λ
	jsr		F_DivideBy10					; ����10�Ľ����Ϊ�㣬������Ϊ0��ִ��ʮλ�Ķ���
	cmp		#0								; ��Ϊ0��һ����ʮλ��d3�޶���
	beq		L_Min_D1_Out_Des
	lda		P_Temp							; ������Ϊ0Ҳ������ʮλ
	cmp		#0
	bne		L_Min_D1_Out_Des

	jsr		F_DisFrame_Min_d1				; Minʮλ��ʱ����

L_Min_D1_Out_Des:
	lda		Frame_Counter					; �����߶�����ϨMS
	cmp		#$08
	beq		L_Min_Des_Out
	ldx		#lcd_MS
	jsr		F_ClrpSymbol
	rts

L_Min_Des_Out:
	ldx		#lcd_MS							; �ߵ���8֡�����֡����
	jsr		F_DispSymbol					; ���߶����˾���MS
	lda		#0
	sta		Frame_Counter
	rts

L_Time_Stop:
	lda		#$01							; ����ʱ�����ص���ʼ̬
	sta		Sys_Status_Flag
	smb3	Timer_Flag						; ��ʱ��ɱ�־λ
	lda		#$0
	sta		R_Time_Min
	sta		R_Time_Sec
	jsr		F_Display_Time
	rts

; ��ʱ�����ڶ�����ʾ����
Des_Time_Count:
	rmb1	Timer_Flag
	lda		R_Time_Sec
	cmp		#01
	beq		Count_Dec_Min					; ����1����Ҫ������λ
	cmp		#00								; ��Ϊ��ʱ���ŵ���1-0�Ķ���
	beq		Count_BorrowToMin				; ���������λ������
	dec		R_Time_Sec
	rts
Count_BorrowToMin:
	lda		R_Time_Min
	cmp		#00
	beq		Count_Stop						; ����λʱ�����Ѿ�Ϊ0�������ֹͣ
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
