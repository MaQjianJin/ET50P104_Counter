;--------COM------------
c0	.equ	0
c1	.equ	1
c2	.equ	2
c3	.equ	3
c4	.equ	4
;;--------SEG------------
s15	.equ	15
s14	.equ	14
s13	.equ	13
s12	.equ	12
s11	.equ	11
s10	.equ	10
s9	.equ	9
s8	.equ	8
s7	.equ	7
s6	.equ	6
s5	.equ	5
s4	.equ	4
s3	.equ	3
s2	.equ	2
s1	.equ	1
s0	.equ	0
s40	.equ	40

MS_dot .equ	1


.MACRO  db_c_s	com,seg
          .BYTE com*6+seg/8
.ENDMACRO

.MACRO  db_c_y	com,seg
	      .BYTE 1.shl.(seg-seg/8*8)
.ENDMACRO

Lcd_byte:							;¶ÎÂë<==>SEG/COM±í
lcd_table1:
lcd_d1 .equ	lcd_table1-lcd_table1
	db_c_s	c4,s0					;A1
	db_c_s	c4,s1					;A2
	db_c_s	c4,s2					;A3
	db_c_s	c3,s0					;A4
	db_c_s	c3,s1					;A5
	db_c_s	c4,s3					;A6
	db_c_s	c2,s0					;A7
	db_c_s	c3,s2					;A8
	db_c_s	c3,s3					;A9
	db_c_s	c2,s1					;A10
	db_c_s	c2,s2					;A11
	db_c_s	c2,s3					;A12
	db_c_s	c1,s0					;A13
	db_c_s	c1,s3					;A14
	db_c_s	c1,s4					;A15
	db_c_s	c1,s1					;A16
	db_c_s	c1,s2					;A17
	db_c_s	c0,s3					;A18
	db_c_s	c0,s0					;A19
	db_c_s	c0,s1					;A20
	db_c_s	c0,s2					;A21

lcd_d2	.equ lcd_d1+21
	db_c_s	c4,s5					;B1
	db_c_s	c4,s6					;B2
	db_c_s	c4,s7					;B3
	db_c_s	c4,s4					;B4
	db_c_s	c3,s6					;B5
	db_c_s	c3,s7					;B6
	db_c_s	c3,s4					;B7
	db_c_s	c3,s5					;B8
	db_c_s	c2,s8					;B9
	db_c_s	c2,s4					;B10
	db_c_s	c2,s6					;B11
	db_c_s	c2,s7					;B12
	db_c_s	c2,s5					;B13
	db_c_s	c1,s7					;B14
	db_c_s	c1,s8					;B15
	db_c_s	c1,s5					;B16
	db_c_s	c1,s6					;B17
	db_c_s	c0,s7					;B18
	db_c_s	c0,s4					;B19
	db_c_s	c0,s5					;B20
	db_c_s	c0,s6					;B21
	
lcd_d3	.equ lcd_d2+21
	db_c_s	c4,s8					;C1
	db_c_s	c4,s9					;C2
	db_c_s	c4,s10					;C3
	db_c_s	c3,s8					;C4
	db_c_s	c3,s11					;C5
	db_c_s	c4,s11					;C6
	db_c_s	c3,s9					;C7
	db_c_s	c3,s10					;C8
	db_c_s	c3,s12					;C9
	db_c_s	c2,s9					;C10
	db_c_s	c2,s10					;C11
	db_c_s	c2,s11					;C12
	db_c_s	c1,s9					;C13
	db_c_s	c1,s10					;C14
	db_c_s	c2,s12					;C15
	db_c_s	c0,s8					;C16
	db_c_s	c1,s11					;C17
	db_c_s	c1,s12					;C18
	db_c_s	c0,s9					;C19
	db_c_s	c0,s10					;C20
	db_c_s	c0,s11					;C21

lcd_d4	.equ lcd_d3+21
	db_c_s	c4,s13					;D1
	db_c_s	c4,s14					;D2
	db_c_s	c4,s15					;D3
	db_c_s	c4,s12					;D4
	db_c_s	c3,s15					;D5
	db_c_s	c3,s40					;D6
	db_c_s	c3,s13					;D7
	db_c_s	c3,s14					;D8
	db_c_s	c2,s40					;D9
	db_c_s	c2,s13					;D10
	db_c_s	c2,s14					;D11
	db_c_s	c2,s15					;D12
	db_c_s	c1,s14					;D13
	db_c_s	c1,s15					;D14
	db_c_s	c1,s40					;D15
	db_c_s	c1,s13					;D16
	db_c_s	c0,s14					;D17
	db_c_s	c0,s15					;D18
	db_c_s	c0,s12					;D19
	db_c_s	c0,s13					;D20
	db_c_s	c0,s40					;D21

lcd_dot:
lcd_MS .equ lcd_dot-lcd_table1
	db_c_s	c4,s40					;MS

;==========================================================
;==========================================================

Lcd_bit:
	db_c_y	c4,s0					;A1
	db_c_y	c4,s1					;A2
	db_c_y	c4,s2					;A3
	db_c_y	c3,s0					;A4
	db_c_y	c3,s1					;A5
	db_c_y	c4,s3					;A6
	db_c_y	c2,s0					;A7
	db_c_y	c3,s2					;A8
	db_c_y	c3,s3					;A9
	db_c_y	c2,s1					;A10
	db_c_y	c2,s2					;A11
	db_c_y	c2,s3					;A12
	db_c_y	c1,s0					;A13
	db_c_y	c1,s3					;A14
	db_c_y	c1,s4					;A15
	db_c_y	c1,s1					;A16
	db_c_y	c1,s2					;A17
	db_c_y	c0,s3					;A18
	db_c_y	c0,s0					;A19
	db_c_y	c0,s1					;A20
	db_c_y	c0,s2					;A21

	db_c_y	c4,s5					;B1
	db_c_y	c4,s6					;B2
	db_c_y	c4,s7					;B3
	db_c_y	c4,s4					;B4
	db_c_y	c3,s6					;B5
	db_c_y	c3,s7					;B6
	db_c_y	c3,s4					;B7
	db_c_y	c3,s5					;B8
	db_c_y	c2,s8					;B9
	db_c_y	c2,s4					;B10
	db_c_y	c2,s6					;B11
	db_c_y	c2,s7					;B12
	db_c_y	c2,s5					;B13
	db_c_y	c1,s7					;B14
	db_c_y	c1,s8					;B15
	db_c_y	c1,s5					;B16
	db_c_y	c1,s6					;B17
	db_c_y	c0,s7					;B18
	db_c_y	c0,s4					;B19
	db_c_y	c0,s5					;B20
	db_c_y	c0,s6					;B21

	db_c_y	c4,s8					;C1
	db_c_y	c4,s9					;C2
	db_c_y	c4,s10					;C3
	db_c_y	c3,s8					;C4
	db_c_y	c3,s11					;C5
	db_c_y	c4,s11					;C6
	db_c_y	c3,s9					;C7
	db_c_y	c3,s10					;C8
	db_c_y	c3,s12					;C9
	db_c_y	c2,s9					;C10
	db_c_y	c2,s10					;C11
	db_c_y	c2,s11					;C12
	db_c_y	c1,s9					;C13
	db_c_y	c1,s10					;C14
	db_c_y	c2,s12					;C15
	db_c_y	c0,s8					;C16
	db_c_y	c1,s11					;C17
	db_c_y	c1,s12					;C18
	db_c_y	c0,s9					;C19
	db_c_y	c0,s10					;C20
	db_c_y	c0,s11					;C21

	db_c_y	c4,s13					;D1
	db_c_y	c4,s14					;D2
	db_c_y	c4,s15					;D3
	db_c_y	c4,s12					;D4
	db_c_y	c3,s15					;D5
	db_c_y	c3,s40					;D6
	db_c_y	c3,s13					;D7
	db_c_y	c3,s14					;D8
	db_c_y	c2,s40					;D9
	db_c_y	c2,s13					;D10
	db_c_y	c2,s14					;D11
	db_c_y	c2,s15					;D12
	db_c_y	c1,s14					;D13
	db_c_y	c1,s15					;D14
	db_c_y	c1,s40					;D15
	db_c_y	c1,s13					;D16
	db_c_y	c0,s14					;D17
	db_c_y	c0,s15					;D18
	db_c_y	c0,s12					;D19
	db_c_y	c0,s13					;D20
	db_c_y	c0,s40					;D21

	db_c_y	c4,s40					;MS
;=========================================