PRO FIVEPOINT,CC,X,Y
;+
; NAME:
;	FIVEPOINT
;
; PURPOSE:
;	Measure the position of minimum or maximum in a 3x3 matrix.
;
; CALLING SEQUENCE:
;	FIVEPOINT,CC,X,Y
;
; INPUTS:
;	CC = Cross correlation function. It must have dimensions like
;	CC(3,3), CC(*,3,3) or CC(*,*,3,3)
;
; OUTPUTS:
;	X & Y = Position of the minimum, taking cc(*,*,1,1) as centre.
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
;	Simple interpolation with a 2-rd polynomial in X and Y.
;
; MODIFICATION HISTORY:
;	Written by Roberto Luis Molowny Horas, Institute of Theoretical
;	Astrophysics, University of Oslo. August 1991.
;-
;
ON_ERROR,2

	IF N_PARAMS(0) LT 3 THEN MESSAGE,'Wrong number of parameters.'
	n = SIZE(cc)
	IF n(0) LT 2 OR n(0) GT 4 THEN MESSAGE,'Wrong input array'
	IF n(n(0)-1) NE 3 OR n(n(0)) NE 3 THEN MESSAGE,$
		'Array must be CC(*,*,3,3)'

	CASE 1 OF
		n(0) EQ 4: BEGIN
			y =  2.*cc(*,*,1,1)
			x = (cc(*,*,0,1)-cc(*,*,2,1))/(cc(*,*,2,1)+ $
						cc(*,*,0,1)-y)*.5
			y = (cc(*,*,1,0)-cc(*,*,1,2))/(cc(*,*,1,2)+ $
						cc(*,*,1,0)-y)*.5
		END
		n(0) EQ 3: BEGIN
			y = 2.*cc(*,1,1)
			x = (cc(*,0,1)-cc(*,2,1))/(cc(*,2,1)+cc(*,0,1)-y)*.5
			y = (cc(*,1,0)-cc(*,1,2))/(cc(*,1,2)+cc(*,1,0)-y)*.5
		END
		n(0) EQ 2: BEGIN
			y = 2.*cc(1,1)
			x = (cc(0,1)-cc(2,1))/(cc(2,1)+cc(0,1)-y)*.5
			y = (cc(1,0)-cc(1,2))/(cc(1,2)+cc(1,0)-y)*.5
		END
	ENDCASE

	END