PRO QFIT2,CC,CX,CY
;+
; NAME:
;	QFIT2
;
; PURPOSE:
;	Measure the position of extrem value in a 3x3 matrix.
;
; CALLING SEQUENCE:
;	QFIT2,CC,CX,CY
;
; INPUTS:
;	CC = 3x3 matrix. It must have dimensions like CC(*,*,3,3), 
;		CC(*,3,3) or CC(3,3).
;
; OUTPUTS:
;	X & Y = Position of maximum/minimum, taking CC(1,1) (or CC(*,1,1), 
;		or CC(*,*,1,1)) as reference.
;
; SIDE EFFECTS:
;	None.
;
; COMMON BLOCKS:
;	None.
;
; RESTRICTIONS:
;	None.
;
; PROCEDURE:
;	Fits 9 points in 2D:
;
;	f(x,y)	= a1*f + a2*x*f +a3*y*f + a4*x^2*f + a5*y^2*f + a6
;
;	Following FORTRAN program qfit2.fts on PE by L.J. November, 
;	NSO/SP, 1986.
;
; REFERENCES:
;	T. A. Darvann, 1991, Master Thesis, University of Oslo
;
; MODIFICATION HISTORY:
;	Redesigned for IDL by R. Molowny Horas.
;-
ON_ERROR,2

	IF N_PARAMS(0) LT 3 THEN MESSAGE,'Wrong number of parameters'
	n = SIZE(cc)
	IF n(0) LT 2 OR n(0) GT 4 THEN MESSAGE,'Wrong input array'
	IF n(n(0)-1) NE 3 OR n(n(0)) NE 3 THEN MESSAGE,$
			'Array must be CC(*,*,3,3)'
	n = n(0)
	CASE 1 OF
		n EQ 4: BEGIN
			a1 = cc(*,*,0,0)+cc(*,*,2,0)+cc(*,*,0,2)+cc(*,*,2,2)
			a2 = a1+cc(*,*,1,0)+cc(*,*,1,2)
			a1 = a1+cc(*,*,0,1)+cc(*,*,2,1)
			a3 = cc(*,*,0,0)-cc(*,*,2,0)-cc(*,*,0,2)+cc(*,*,2,2)
			a4 = -cc(*,*,0,0)+cc(*,*,2,2)
			a5 = a4-cc(*,*,1,0)-cc(*,*,2,0)+cc(*,*,0,2)+cc(*,*,1,2)
			a4 = a4+cc(*,*,2,0)-cc(*,*,0,1)+cc(*,*,2,1)-cc(*,*,0,2)
			a1 = .5*a1-cc(*,*,1,0)-cc(*,*,1,1)-cc(*,*,1,2)
			a2 = .5*a2-cc(*,*,0,1)-cc(*,*,1,1)-cc(*,*,2,1)
		END
		n EQ 3: BEGIN
			a1 = cc(*,0,0)+cc(*,2,0)+cc(*,0,2)+cc(*,2,2)
			a2 = a1+cc(*,1,0)+cc(*,1,2)
			a1 = a1+cc(*,0,1)+cc(*,2,1)
			a3 = cc(*,0,0)-cc(*,2,0)-cc(*,0,2)+cc(*,2,2)
			a4 = -cc(*,0,0)+cc(*,2,2)
			a5 = a4-cc(*,1,0)-cc(*,2,0)+cc(*,0,2)+cc(*,1,2)
			a4 = a4+cc(*,2,0)-cc(*,0,1)+cc(*,2,1)-cc(*,0,2)
			a1 = .5*a1-cc(*,1,0)-cc(*,1,1)-cc(*,1,2)
			a2 = .5*a2-cc(*,0,1)-cc(*,1,1)-cc(*,2,1)
		END
		n EQ 2: BEGIN
			a1 = cc(0,0)+cc(2,0)+cc(0,2)+cc(2,2)
			a2 = a1+cc(1,0)+cc(1,2)
			a1 = a1+cc(0,1)+cc(2,1)
			a3 = cc(0,0)-cc(2,0)-cc(0,2)+cc(2,2)
			a4 = -cc(0,0)+cc(2,2)
			a5 = a4-cc(1,0)-cc(2,0)+cc(0,2)+cc(1,2)
			a4 = a4+cc(2,0)-cc(0,1)+cc(2,1)-cc(0,2)
			a1 = .5*a1-cc(1,0)-cc(1,1)-cc(1,2)
			a2 = .5*a2-cc(0,1)-cc(1,1)-cc(2,1)
		END
	ENDCASE
	dim = (64./9.*a1*a2-a3^2)*1.5
	cx = (a3*a5-8./3.*a2*a4)/dim
	cy = (a3*a4-8./3.*a1*a5)/dim

	END
