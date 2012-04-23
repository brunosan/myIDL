FUNCTION MAXLOC,ARRAY,MAX_ARRAY
;+
; NAME:
;	MAXLOC
;
; PURPOSE:
;	Find the position of maximum in a two dimensional array.
;
; CALLING SEQUENCE:
;	Result = MAXLOC(ARRAY,MAX_ARRAY)
;
; INPUTS:
;	ARRAY = a two dimensional array.
;
; OUTPUTS:
;	Result = a vector containing the X,Y coordinates of maximum.
;
; OPTIONAL OUTPUT:
;	MAX_ARRAY = value of the array at X,Y.
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
;	MAX_ARRAY added in March 1994, RMH
;
;-
ON_ERROR,2

	s = SIZE(array)			;Size of input array.
	IF s(0) NE 2 THEN MESSAGE,'Input array must be two dimensional'

	max_array = MAX(array,n)	;Finds maximum.
	RETURN,[n MOD s(1),n/s(1)]	;Output as a vector.
	END