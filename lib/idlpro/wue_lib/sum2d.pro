;+
; NAME:
;       SUM2D
; PURPOSE:
;       Sum rows or columns of a 2-d array.
; CATEGORY:
; CALLING SEQUENCE:
;       b = sum2d(a, [flag, n])
; INPUTS:
;       a = 2-d array.                               in 
;       flag = sum direction (def=1).                in 
;         1: sum in x (cols), 2: sum in y (rows).
;       n = group size (def=array size).             in 
;         Sum n rows or columns together. 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       b = result.                                  out 
; COMMON BLOCKS:
; NOTES:
;       Notes: Example: Let A be a floating array of 100 by 200 elements. 
;         B = sum2d(A) gives a floating array, B, of 200 elements = 
;         summed columns.  B = sum2d(A,2) gives B of 100 elements = 
;         summed rows.  B = sum2d(A,1,10) gives B of 10 by 200 elements 
;         where each column of B is the sum of 10 columns in A. 
;         B = sum2d(A,1,12) gives B of 8 by 200 because 12 goes into 100 
;         8 times. 
; MODIFICATION HISTORY:
;       Ray Sterner/Karl Kostoff 1/14/85
;       Johns Hopkins University Applied Physics Laboratory.
;       RES  8 Aug, 1985 --- grouping.
;       BLG 15-Nov-85 --- added output double when input is double
;-
 
	FUNCTION SUM2D,A,FLAG,N, help=hlp
 
	if (n_params() lt 1) or keyword_set(hlp) then begin
	  print,' Sum rows or columns of a 2-d array.'
	  print,' b = sum2d(a, [flag, n])'
	  print,'   a = 2-d array.                              in'
	  print,'   flag = sum direction (def=1).               in'
	  print,'     1: sum in x (cols), 2: sum in y (rows).
	  print,'   n = group size (def=array size).            in'
	  print,'     Sum n rows or columns together.'
	  print,'   b = result.                                 out'
	  print,' Notes: Example: Let A be a floating array of 100 '+$
	    'by 200 elements.'
	  print,'   B = sum2d(A) gives a floating array, B, of 200 elements ='
	  print,'   summed columns.  B = sum2d(A,2) gives B of 100 elements ='
	  print,'   summed rows.  B = sum2d(A,1,10) gives B of 10 '+$
	    'by 200 elements'
	  print,'   where each column of B is the sum of 10 columns in A.'
	  print,'   B = sum2d(A,1,12) gives B of 8 by 200 because 12 '+$
	    'goes into 100'
	  print,'   8 times.'
	  return, -1
	endif
 
	TYP = DATATYPE(A)			; added 11/15/85
	F=1					; use default F, if
	IF N_PARAMS(0) GE 2 THEN F=FLAG		; only one parameter
	S=SIZE(A)                		; store parameter information
 
	IF S(0) NE 2 THEN BEGIN			; check number of dimensions
	  PRINT,' Error in sum2d: array must be 2 dimensional.'
	  RETURN,A
	ENDIF
	NX=S(1)     ; x size.
	NY=S(2)     ; y size.
 
        CASE F OF		; two cases: sum rows, or sum columns.
1:      BEGIN	; columns.
          IF N_PARAMS(0) LT 3 THEN N = NX
          ND = FIX(NX/N)
          IF ND LE 0 THEN GOTO, ERR
          IF TYP EQ 'DOU' THEN T = DBLARR(ND,NY) ELSE T = FLTARR(ND,NY)
          FOR J = 0, ND-1 DO BEGIN
	    IOFF = J*N
	    T(J,0) = A(IOFF,*)
	    IF NX GT 1 THEN FOR I = 1, N-1 DO T(J,0) = T(J,*) + A(I+IOFF,*)
          ENDFOR
        END
2:      BEGIN	; rows.
          IF N_PARAMS(0) LT 3 THEN N = NY
          ND = FIX(NY/N)
          IF ND LE 0 THEN GOTO, ERR
          IF TYP EQ 'DOU' THEN T = DBLARR(NX,ND) ELSE T = FLTARR(NX,ND)
	  if nd gt 1 then begin		; Output array is more than 1 in Y.
            FOR J = 0, ND-1 DO BEGIN
   	      IOFF = J*N
	      T(0,J) = A(*,IOFF)
	      IF NY GT 1 THEN FOR I = 1, N-1 DO T(0,J) = T(*,J) + A(*,I+IOFF)
            ENDFOR
	  endif else begin	; 1 wide in Y.  IDL removes last dimension.
	    t = a(*,0)
	    for i = 1, n-1 do t = t + a(*,i)
	  endelse
        END
ELSE:   PRINT,' Error in sum2d: invalid flag value.'
        ENDCASE
 
        RETURN, t
 
ERR:    PRINT,' Error sum2d: Array too small for given group size.'
        RETURN, -1
 
	END
