FUNCTION ODD,A
;+
; NAME:
;	ODD
;
; PURPOSE:
;	Search for odd numbers in A.
;
; CALLING SEQUENCE:
;	Result = ODD(A)
;
; INPUT:
;	A = array of any size and type (not strings).
;
; OUTPUT:
;	Result = an array of same size as A, filled with 1 and 0.
;		 0 means "even" and 1 means "odd".
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
;	Straightforward. An output of 1 means "odd"; 0 is "even".
;
; MODIFICATION HISTORY:
;	Written by Roberto Luis Molowny Horas, 1991.
;
;-
ON_ERROR,2

	dumb = a / 2.
	RETURN,LONG(dumb) NE dumb	;Easy algorithm.
	END