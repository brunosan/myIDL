;+
; Name: INRANGE.PRO
; Purpose: Find the two multiples of given step that are just
;   inside the given range.  Good for axis tics.
; Category: PLT support.
; Calling sequence: INRANGE,STP, X1, X2, T1, T2, [TICS]
; Inputs:
;   STP = Step size.
;   X1, X2 = Range limits.
; Optional input parameters:
; Outputs:
;   T1, T2 = Multiples of STP just inside range.
; Optional output parameters:
;   TICS = array of tic values.
; Common blocks:
; Side effects:
; Restrictions:
; Routines used:
; Procedure:
; Modification history: R. Sterner. 10 Nov, 1988.
;	Johns Hopkins University Applied Physics Laboratory.
;-

	PRO INRANGE, STP, X1, X2, T1, T2, TA,help=h

	IF (N_PARAMS(0) LT 5) or (keyword_set(h)) THEN BEGIN
	  PRINT,'Finds the two multiples of given step that are just
	  PRINT,'inside the given range (or on boundary).  Good for axis tics.
	  PRINT,'INRANGE,STP, X1, X2, T1, T2, [TICS]
	  PRINT,'  STP = Step size.				in.
	  PRINT,'  X1, X2 = Range limits.			in.
	  PRINT,'  T1, T2 = Multiples of STP just inside range.	out.
	  PRINT,'  TICS = optional array of tic values.		out.
	  RETURN
	ENDIF

	DX = X2 - X1
	IF DX EQ 0.0 THEN BEGIN
	  PRINT,'Error in INRANGE: Range must be non-zero.'
	  RETURN
	ENDIF
	S = ABS(STP)

	XMN = X1<X2
	XMX = X1>X2

	T1 = NEAREST(S, XMN) & IF T1 LT XMN THEN T1 = T1 + S
	IF T1 GT XMX THEN BEGIN
	  PRINT,'Error in INRANGE: No tics in range.'
	  RETURN
	ENDIF
	T2 = NEAREST(S, XMX) & IF T2 GT XMX THEN T2 = T2 - S
	IF T2 LT XMN THEN BEGIN
	  PRINT,'Error n INRANGE: No tics in range.'
	  RETURN
	ENDIF
	TA = MAKEX(T1, T2, S)

	IF DX LT 0 THEN BEGIN
	  T = T1
	  T1 = T2
	  T2 = T
	  TA = REVERSE(TA)
	ENDIF

	RETURN
	END
