;+
; Name: NAXES.PRO
; Purpose: Find nice axis tics.
; Category: Plot.
; Calling sequence:
;	NAXES, XMN, XMX ,NX, TX1, TX2, NT, XINC, NDEC
; Inputs:
;	  XMN, XMX = Axis min and max.
;	  NX = Desired number of axis tics.
; Optional input parameters:
; Outputs:
;	  TX1, TX2 = Sugested first and last tic positions.
;	  NT = Suggested number of axis tics.
;	  XINC = Sugggested tic spacing.
;	  NDEC = Suggested number tic label decimal places.
; Optional output parameters:
; Common blocks:
; Side effects:
; Restrictions:
; Routines used:
; Procedure:
; Modification history: R. Sterner. 7 Nov, 1988.
;	Converted from FORTRAN.
;	Johns Hopkins University Applied Physics Laboratory.
;-
	PRO NAXES, DX0,DX1,NX, DRX0,DRX1,NR,DRINC,NDEC,help=h

	IF (N_PARAMS(0) LT 8) or (keyword_set(h)) THEN BEGIN
	  PRINT,'Find nice axis tics.'
	  PRINT,'NAXES, XMN, XMX ,NX, TX1, TX2, NT, XINC, NDEC
	  PRINT,'  XMN, XMX = Axis min and max.				in.
	  PRINT,'  NX = Desired number of axis tics.			in.
	  PRINT,'  TX1, TX2 = Sugested first and last tic positions.	out.
	  PRINT,'  NT = Suggested number of axis tics.			out.
	  PRINT,'  XINC = Sugggested tic spacing.			out.
	  PRINT,'  NDEC = Suggested number tic label decimal places.	out.
	  RETURN
	ENDIF

	DX = DOUBLE(DX1 - DX0)	; Axis range.

	IF DX GT 0 THEN BEGIN	;Forward axis.
	  X0 = DOUBLE(DX0)
	  X1 = DOUBLE(DX1)
	ENDIF ELSE BEGIN	; Reverse axis.
	  X0 = DOUBLE(DX1)
	  X1 = DOUBLE(DX0)
	ENDELSE

	XINC = (X1-X0)/NX	; Approx. inc size.
	P = ALOG10(XINC)	; Scale to 1 to 10.
	IF P LT 0 THEN P = P-1.
	P = FIX(P)
	POW = 10.^P
	XI = XINC/POW
	XINC = XI
;------ Set increment to a nice value -----------
	XI = 10.			; Filter scaled increment
	NDEC = 0			;   to find nice increment.
	IF XINC LT 7.07 THEN XI = 5.
	IF XINC LT 3.5 THEN XI = 2.5
	IF XINC LT 2.24 THEN XI = 2.
	IF XINC LT 1.4 THEN XI = 1.
	IF XI EQ 2.5 THEN NDEC = 1
	IF XI GE 10. THEN BEGIN
	  XI = 1.
	  P = P + 1.
	  POW = POW*10.
	ENDIF
	NDEC = NDEC - P
	IF NDEC LT 0 THEN NDEC = 0
	XI = XI*POW			; XI = true increment.
;-------------  first and last tics  -------------------
	T = X0/XI			; Number of incs to X0.
	IF T LT 0. THEN T = T - 0.05	; Adjust to be inside range.
	IF T GT 0. THEN T = T + 0.05
	RX0 = DOUBLE(LONG(T)*XI)
	T = X1/XI			; Number of incs to X1.
	IF T LT 0. THEN T = T - 0.05
	IF T GT 0. THEN T = T + 0.05
	RX1 = DOUBLE(LONG(T)*XI)
	NR = FIX((RX1-RX0)/XI + 1.5)	; Total number tics.
	RINC = DOUBLE(XI)

;-----  Axis direction  ------
	IF DX LE 0. THEN BEGIN			; Reverse axis.
	  IF DX0 LT RX1-.1*RINC THEN BEGIN	; Force first tic inside range.
	    RX1 = RX1 - RINC
	    NR = NR - 1
	  ENDIF
	  IF DX1 GT RX0+.1*RINC THEN BEGIN	; Force last tic inside range.
	    RX0 = RX0 + RINC
	    NR = NR - 1
	  ENDIF
	  DRX0 = RX1				; Values to return.
	  DRX1 = RX0
	  DRINC = -RINC
	ENDIF ELSE BEGIN			; Foward axis.
	  IF DX0 GT RX0+.1*RINC THEN BEGIN	; Force first tic inside range.
	    RX0 = RX0 + RINC
	    NR = NR - 1
	  ENDIF
	  IF DX1 LT RX1-.1*RINC THEN BEGIN	; Force last tic inside range.
	    RX1 = RX1 - RINC
	    NR = NR - 1
	  ENDIF
	  DRX0 = RX0				; Values to return.
	  DRX1 = RX1
	  DRINC = RINC
	ENDELSE

	RETURN

	END
