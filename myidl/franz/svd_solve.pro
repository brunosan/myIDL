FUNCTION SVD_SOLVE,A,B , THRESHOLD , RESIDUAL = residual
;+
; NAME:
;	SVD_SOLVE
;
; PURPOSE:
;	Solve the linear system of equations Ax = B by the Singular Value
;	Decomposition method.
;
; CALLING SEQUENCE:
;	Result = SVD_SOLVE(A,B)
;
; INPUTS:
;	A = coefficients matrix
;
;	B = column matrix with "right-hand-side" quantities.
;
; OPTIONAL INPUT:
;	THRESHOLD = threshold to zero the small w (see Numerical Recipes).
;		IF not present, THRESHOLD is set to 1E-6
;
; KEYWORDS:
;	RESIDUAL = residual, Ax - b.
;
; OUTPUT:
;	Result = output solution vector.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	None.
;
; PROCEDURE:
;	Easy call to IDL's implemented routines SVD and SVBKSB
;
; MODIFICATION HISTORY:
;	Copied after IDL's suggestions.
;-
;
ON_ERROR,2

	IF N_PARAMS(0) LT 3 THEN threshold = 1E-6

	SVD,a,w,u,v				;Call SVD to decompose A.

	small = WHERE(w LT MAX(w)*threshold,count)	;Singular values.

	IF count NE 0 THEN w(small) = 0.0	;Zero singular values.

	SVBKSB,u,w,v,b,x			;x contains the solution.

	IF KEYWORD_SET(residual) THEN residual = TOTAL(ABS(a#x-b))

	RETURN,x

END