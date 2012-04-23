FUNCTION MINLOC,ARRAY,MIN_ARRAY
;+
; NAME:
;	MINLOC
;
; PURPOSE:
;	Find the position of minimum in a two dimensional array.
;
; CALLING SEQUENCE:
;	Result = MINLOC(ARRAY,MIN_ARRAY)
;
; INPUTS:
;	ARRAY = a two dimensional array.
;
; OUTPUTS:
;	Result = a vector containing the X,Y coordinates of minimum.
;
; OPTIONAL OUTPUT:
;	MIN_ARRAY = value of the array at X,Y.
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
;	Straightforward.
;
; MODIFICATION HISTORY:
;	Written by Roberto Molowny-Horas, 1991.
;	MIN_ARRAY added in March 1994, RMH
;
;-
ON_ERROR,2

	s = SIZE(array)			;Size of input array.
	IF s(0) NE 2 THEN MESSAGE,'Input array must be two dimensional'

	min_array = MIN(array,n)	;Finds maximum.
	RETURN,[n MOD s(1),n/s(1)]	;Output as a vector.
	END