PRO CROSSD,F,X,Y
;+
; NAME:
;	CROSSD
;
; PURPOSE:
;	Measure the position of a minimum or maximum in a 3x3 array.
;
; CALLING SEQUENCE:
;	CROSSD,F,X,Y
;
; INPUTS:
;	F = Cross correlation function.
;
; OUTPUTS:
;	X & Y = Position of extrem, taking f(1,1) as centre.
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
;	The algorithm is an extension of that for 5 points, interpolating
;	with a polynomial like:
;		f(x,y) = c1 + c2*x + c3*y + c4*x^2 + c5*y^2
;	but adding a term c6*x*y. The sixth coefficient is computed
;	from the cross derivative, which is obtained from the four points
;	on the corners. So, CROSSD is a sort of "3x3" interpolation.
;
; REFERENCES:
;	Yi,Z. and Molowny H.,R.: 1992, Proceeding from LEST Mini-Workshop,
;		LEST Technical Report No. 56
;
; MODIFICATION HISTORY:
;	Written by Roberto Luis Molowny Horas, August 1991.
;-
;
ON_ERROR,2

	IF N_PARAMS(0) LT 3 THEN MESSAGE,'Wrong number of parameters.'
	n = SIZE(f)
	IF n(0) LT 2 OR n(0) GT 4 THEN MESSAGE,'Wrong input array'
	IF n(n(0)-1) NE 3 OR n(n(0)) NE 3 THEN MESSAGE, $
		'Array must be CC(*,*,3,3)'

	CASE 1 OF				;Array F is FLTARR(3,3).
		n(0) EQ 2: BEGIN
			c4 = f(2,1) + f(0,1) - f(1,1)*2.
			c2 = f(2,1) - f(0,1)
			c5 = f(1,2) + f(1,0) - f(1,1)*2.
			c3 = f(1,2) - f(1,0)
			c6 = (f(2,2) - f(0,2) - f(2,0) + f(0,0))/4.
		END
		n(0) EQ 3: BEGIN		;Array F is FLTARR(*,3,3)
			c4 = f(*,2,1) + f(*,0,1) - f(*,1,1)*2.
			c2 = f(*,2,1) - f(*,0,1)
			c5 = f(*,1,2) + f(*,1,0) - f(*,1,1)*2.
			c3 = f(*,1,2) - f(*,1,0)
			c6 = (f(*,2,2) - f(*,0,2) - f(*,2,0) + f(*,0,0))/4.
		END
		n(0) EQ 4: BEGIN		;Array F is FLTARR(*,*,3,3)
			c4 = f(*,*,2,1) + f(*,*,0,1) - f(*,*,1,1)*2.
			c2 = f(*,*,2,1) - f(*,*,0,1)
			c5 = f(*,*,1,2) + f(*,*,1,0) - f(*,*,1,1)*2.
			c3 = f(*,*,1,2) - f(*,*,1,0)
			c6 = (f(*,*,2,2)-f(*,*,0,2)-f(*,*,2,0)+f(*,*,0,0))/4.
		END
	ENDCASE

	determ = .5/(c4*c5 - c6*c6)	;Computes the position of extrem.
	x = determ * (c6*c3 - c5*c2)
	y = determ * (c6*c2 - c4*c3)

	END
