;+
; Name: GETVIEW.PRO
; Purpose: Returns current viewport.
; Category: For LINIT.
; Calling sequence: GETVIEW, VX1, VX2, VY1, VY2
; Inputs:
; Optional input parameters:
; Outputs: VX1, VX2, VY1, VY2 = current viewport.
; Optional output parameters:
; Common blocks:
; Side effects:
; Restrictions:
; Routines used:
; Procedure:
; Modification history: R. Sterner. 11 Nov, 1988.
;	R. Sterner, 26 Feb, 1991 --- renamed from get_viewport.pro
;	Johns Hopkins University Applied Physics Laboratory.
;-

	PRO GETVIEW, VX1, VX2, VY1, VY2,help=h

	IF (N_PARAMS(0) LT 4) or (keyword_set(h)) THEN BEGIN
	  PRINT,'Return current viewport.'
	  PRINT,'GETVIEW, VX1, VX2, VY1, VY2'
	  PRINT,'  VX1, VX2, VY1, VY2 = current viewport.	out.
	  RETURN
	ENDIF

	SC1 = !SC1 & SC2 = !SC2 & SC3 = !SC3 & SC4 = !SC4

	SET_VIEWPORT, 0, 1, 0, 1
	VX1 = SC1/!SC2
	VX2 = SC2/!SC2
	VY1 = SC3/!SC4
	VY2 = SC4/!SC4

	SET_SCREEN, SC1, SC2, SC3, SC4

	RETURN
	END
