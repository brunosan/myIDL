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
;	Straightforward. An integer array is created, filled with +/- 1.
;
; MODIFICATION HISTORY:
;	Written by Roberto Luis Molowny Horas, 1991.
;-
ON_ERROR,2

	RETURN,2 * (array GE 0) - 1
	END