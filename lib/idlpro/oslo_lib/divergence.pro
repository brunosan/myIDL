FUNCTION DIVERGENCE,VX,VY
;+
; NAME:
;	DIVERGENCE
;
; PURPOSE:
;	Make divergence of a 2-D horizontal velocity map.
;
; CALLING SEQUENCE:
;	Result = DIVERGENCE(VX,VY)
;
; INPUTS:
;	VX & VY = X and Y component of the 2-D velocity map.
;
; OUTPUTS:
;	Result = divergence of velocity vector, given by:
;
;		D(Vx)/Dx + D(Vy)/Dy
;
; RESTRICTIONS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; COMMON BLOCKS:
;	None.
;
; PROCEDURE:
;	Straightforward. It makes a numerical differentiation using a
;	3 point lagrangian interpolation, such that the derivatives are
;	also calculated at the edges.
;
; MODIFICATION HISTORY:
;	Written by Roberto Luis Molowny Horas, March 1992.
;-
;
ON_ERROR,2

	IF N_PARAMS(0) NE 2 THEN MESSAGE,'Wrong number of input parameters'

	ss = SIZE(vx)
	IF ss(1) NE N_ELEMENTS(vy(*,0)) OR ss(2) NE N_ELEMENTS(vy(0,*)) THEN $
		MESSAGE,'Dimensions of input arrays must be equal'

	div = SHIFT(vx,-1,0) - SHIFT(vx,1,0)			;Derivative in X.
	div(0,0) = -3.*vx(0,*) + 4.*vx(1,*) - vx(2,*)
	n = ss(1)
	div(n-1,0) = 3.*vx(n-1,*) - 4.*vx(n-2,*) + vx(n-3,*)

	div = TEMPORARY(div) + SHIFT(vy,0,-1) - SHIFT(vy,0,1)	;Derivative in Y.
	div(0,0) = -3.*vy(*,0) + 4.*vy(*,1) - vy(*,2)
	n = ss(2)
	div(0,n-1) = 3.*vy(*,n-1) - 4.*vy(*,n-2) + vy(*,n-3)

	div = TEMPORARY(div)/2.					;Don't forget.

	RETURN,div
	
END
