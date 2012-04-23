FUNCTION GRADIENT,A
;+
; NAME:
;	GRADIENT
;
; PURPOSE:
;	Real gradient operator on image A.
;
; CALLING SEQUENCE:
;	Result = GRADIENT(A)
;
; INPUTS:
;	A = two dimensional array containing the image to which
;		gradient operator will be applied.
;
; OUTPUTS:
;	Result = divergence of A.
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
;	3 point lagrangian interpolation, and also treates the edges.
;
; MODIFICATION HISTORY:
;	Written by Roberto Luis Molowny Horas, December 1992.
;
;-
ON_ERROR,2

	s = SIZE(a)
	IF s(0) NE 2 THEN MESSAGE,'Array must be 2-dimensional'

	gra = SHIFT(FLOAT(a),-1,0) - SHIFT(a,1,0)	;Easy derivative in X.
	gra(0,0) = -3.*a(0,*) + 4.*a(1,*) - a(2,*)
	gra(s(1)-1,0) = 3.*a(s(1)-1,*) - 4.*a(s(1)-2,*) + a(s(1)-3,*)

	gra = gra + SHIFT(FLOAT(a),0,-1) - SHIFT(a,0,1)	;Derivative in Y.
	gra(0,0) = -3.*a(*,0) + 4.*a(*,1) - a(*,2)
	gra(0,s(2)-1) = 3.*a(*,s(2)-1) - 4.*a(*,s(2)-2) + a(*,s(2)-3)

	RETURN,gra

END
