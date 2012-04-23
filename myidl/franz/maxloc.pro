FUNCTION MAXLOC,ARRAY
;+
; NAME:
;	MAXLOC
;
; PURPOSE:
;	Find the position of maximum in a two dimensional array.
;
; CALLING SEQUENCE:
;	Result = MAXLOC(ARRAY)
;
; INPUTS:
;	ARRAY = a two dimensional array.
;
; OUTPUTS:
;	Result = a vector containing the X,Y coordinates of maximum.
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
;	Written by Roberto Luis Molowny Horas, 1991.
;
;-
ON_ERROR,2

	s = SIZE(array)			;Size of input array.
	IF s(0) NE 2 THEN MESSAGE,'Input array must be two dimensional'

	dumb = MAX(array,n)	;Finds maximum.
	RETURN,[n MOD s(1),n/s(2)]	;Output as a vector.
	END