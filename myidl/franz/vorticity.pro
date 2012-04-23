FUNCTION VORTICITY,VX,VY
;+
; NAME:
;	VORTICITY
;
; PURPOSE:
;	Make VORTICITY of a 2-D velocity map.
;
; CALLING SEQUENCE:
;	Result = VORTICITY(VX,VY)
;
; INPUTS:
;	VX & VY = X and Y component of the 2-D velocity map.
;
; OUTPUTS:
;	Result = vorticity of velocity vector, given by:
;		D(Vy)/D(X) - D(Vx)/D(Y)
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
;	3 point lagrangian interpolation.
;
; MODIFICATION HISTORY:
;	Written by Roberto Luis Molowny Horas, March 1992.
;
;-
ON_ERROR,2
	IF N_PARAMS(0) NE 2 THEN MESSAGE,'Wrong number of input parameters'
	ss = SIZE(vx)
	IF ss(1) NE N_ELEMENTS(vy(*,0)) OR ss(2) NE N_ELEMENTS(vy(0,*)) THEN $
		MESSAGE,'Dimensions of input arrays must be equal'

	vor = SHIFT(vy,-1,0) - SHIFT(vy,1,0)
	vor(0,0) = -3.*vy(0,*) + 4.*vy(1,*) - vy(2,*)
	n = ss(1)
	vor(n-1,0) = 3.*vy(n-1,*) - 4.*vy(n-2,*) + vy(n-3,*)

	vor = vor - SHIFT(vx,0,-1) + SHIFT(vx,0,1)
	vor(0,0) = - (-3.*vx(*,0) + 4.*vx(*,1) - vx(*,2))
	n = ss(2)
	vor(0,n-1) = - (3.*vx(*,n-1) - 4.*vx(*,n-2) + vx(*,n-3))

	RETURN,vor/2.

END