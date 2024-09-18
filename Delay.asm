F_Delay_100ms:
	pha
	TMR2_ON
	lda			#$1
L_Delay_Tmp:
	bbr7		Timer_Flag,L_Delay_Tmp
	rmb7		Timer_Flag
	dea
	bne			L_Delay_Tmp

	TMR2_OFF
	pla
	rts

