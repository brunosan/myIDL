FUNCTION SIGN,ARRAY
;+
; NAME:
;	SIGN
;
; PURPOSE:
;	Return the sign (-1 or +1) of the elements in ARRAY.
;
; CALLING SEQUENCE:
;	Result = SIGN(ARRAY)
;
; INPUT:
;	ARRAY = number, vector or array of any type.
;
; OUTPUT:
;	Result = integer array with signs, +/-1.
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
;	Straightforward. It is indeed a waste of memory resources
;	to create an integer array, but expressing SIGN as +/-1 is
;	more useful than a convention like, say, [0,1] for plus and
;	minus.
;
; MODIFICATION HISTORY:
;	Written by Roberto Luis Molowny Horas, 1991.
;-
ON_ERROR,2

	RETURN,2 * (array GE 0) - 1
	END