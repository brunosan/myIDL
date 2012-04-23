;+
; NAME:
;       PLANE_INT
; PURPOSE:
;       Compute the intersection line of two planes.
; CATEGORY:
; CALLING SEQUENCE:
;       plane_int, a1, a2, a3, b1, b2, b3, p, u, flag
; INPUTS:
;       a1, a2, a3 = 3 pts in plane A (a1=(xa,ya,za),...).  in.
;       b1, b2, b3 = 3 pts in plane B (b1=(xb,yb,zb),...).  in.
; KEYWORD PARAMETERS:
; OUTPUTS:
;       p = a point on intersection line (Px,Py,Pz).        out.
;       u = Unit vector along intersection line (Ux,Uy,Uz). out.
;       flag = intersect flag.  0: none, 1: intersection.
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner. 25 Oct, 1988.
;       Johns Hopkins University Applied Physics Laboratory.
;-
 
	PRO PLANE_INT, A1, A2, A3, B1, B2, B3, P, U, flag, help=hlp
 
	IF (N_PARAMS(0) LT 8) or keyword_set(hlp) THEN BEGIN
	  PRINT,' Compute the intersection line of two planes.'
	  PRINT,' plane_int, a1, a2, a3, b1, b2, b3, p, u, flag'
	  PRINT,'   a1, a2, a3 = 3 pts in plane A (a1=(xa,ya,za),...).  in.'
	  PRINT,'   b1, b2, b3 = 3 pts in plane B (b1=(xb,yb,zb),...).  in.'
	  PRINT,'   p = a point on intersection line (Px,Py,Pz).        out.'
	  PRINT,'   u = Unit vector along intersection line (Ux,Uy,Uz). out.'
	  print,'   flag = intersect flag.  0: none, 1: intersection.'
	  RETURN
	ENDIF
 
	;-------  get equations of the two planes  ---------
	NA = CROSSP((A2-A1), (A3-A1))	; Normal to plane A.
	DA = TOTAL(NA*A1)		; Plane eq: X dot NA = DA
	NB = CROSSP((B2-B1), (B3-B1))	; Normal to plane B.
	DB = TOTAL(NB*B1)		; Plane eq: X dot NB = DB
 
	;-------  Test for parallel planes  ----------------
	CRSS = CROSSP(NA,NB)		; NA cross NB = 0 if parallel.
	DET = ABS(TOTAL(CRSS))
	IF DET LT 1E-5 THEN BEGIN
;	  PRINT,'Error: Planes are parallel or very close.'
;	  PRINT,'No intersection found.'
	  flag = 0
	  RETURN
	ENDIF
 
	;--- For non-parallel planes NA and NB are non-parallel and
	;--- with NA X NB form a basis set for R3, so any X in R3
	;--- may be written as X = a*NA + b*NB + t*(NA X NB)
	;--- Substituting into the plane equations gives:
	;--- a*abs(NA)^2 + b*(NA dot NB) = DA
	;--- a*(NA dot NB) + b*abs(NB)^2 = DB
	;--- Solve for a and B below.
	DOT = TOTAL(NA*NB)
 
	A = (DA*TOTAL(NB*NB) - DB*DOT)/DET
	B = (DB*TOTAL(NA*NA) - DA*DOT)/DET
 
	P = A*NA + B*NB		; A point common to both planes.
	U = UNIT(CRSS)		; Unit vector along line.		
 
	flag = 1
 
	RETURN
	END
