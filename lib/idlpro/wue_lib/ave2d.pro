;+
; NAME:
;       AVE2D
; PURPOSE:
;       Average rows or columns of a 2-d array.
; CATEGORY:
; CALLING SEQUENCE:
;       b = ave2d(a, [flag, n])
; INPUTS:
;       a = 2-d array.                                     in 
;       flag = average direction (def=1).                  in 
;         1: average in x (cols), 2: average in y (rows).
;       n = group size (def=array size).                   in 
;         Average n rows or columns together. 
; KEYWORD PARAMETERS:
;	/TOTAL returns sums instead of means.
; OUTPUTS:
;       b = result.                                        out 
; COMMON BLOCKS:
; NOTES:
;       Notes: Example: Let A be a floating array of 100 by 200 elements. 
;         B = ave2d(A) gives a floating array, B, of 200 elements = 
;         averaged columns.  B = ave2d(A,2) gives B of 100 elements = 
;         averaged rows.  B = ave2d(A,1,10) gives B of 10 by 200 elements 
;         where each column of B is the average of 10 columns in A. 
;         B = ave2d(A,1,12) gives B of 8 by 200 because 12 goes into 100 
;         8 times. 
; MODIFICATION HISTORY:
;       Ray Sterner/Karl Kostoff 1/14/85
;       Johns Hopkins University Applied Physics Laboratory.
;       RES  8 Aug, 1985 --- grouping.
;       BLG 15-Nov-85 --- added capability to output double
;          when input is double
;	R. Sterner 22 Aug, 1990 --- added /TOTAL.
;-
 
	FUNCTION AVE2D,A,FLAG,N, total=tot, help=hlp
 
	if (n_params() lt 1) or keyword_set(hlp) then begin
	  print,' Average rows or columns of a 2-d array.'
	  print,' b = ave2d(a, [flag, n])'
	  print,'   a = 2-d array.                                     in'
	  print,'   flag = average direction (def=1).                  in'
	  print,'     1: average in x (cols), 2: average in y (rows).
	  print,'   n = group size (def=array size).                   in'
	  print,'     Average n rows or columns together.'
	  print,'   b = result.                                        out'
	  print,' Keywords:'
	  print,'   /TOTAL returns sums instead of means.'
	  print,' Notes: Example: Let A be a floating array of 100 by 200'
	  print,'   elements. B = ave2d(A) gives a floating array, B, of'
	  print,'   200 elements = averaged columns.  B = ave2d(A,2) gives'
	  print,'   B of 100 elements = averaged rows.  B = ave2d(A,1,10)'
	  print,'   gives B of 10 by 200 elements where each column of B is'
	  print,'   the average of 10 columns in A. B = ave2d(A,1,12) gives B'
	  print,'    of 8 by 200 because 12 goes into 100 8 times.'
	  return, -1
	endif
 
	TYP = DATATYPE(A)			; added 11/15/85
	F=1					; use default F, if
	IF N_PARAMS(0) GE 2 THEN F=FLAG		; only one parameter
	S=SIZE(A)                		; store parameter information
 
	IF S(0) NE 2 THEN BEGIN			; check number of dimensions
	  PRINT,' Error in ave2d: array must be 2 dimensional.'
	  RETURN,A
	ENDIF
	NX=S(1)     ; x size.
	NY=S(2)     ; y size.
 
        CASE F OF		; two cases: average rows, or average columns.
1:      BEGIN	; columns.
          IF N_PARAMS(0) LT 3 THEN N = NX
          IF TYP EQ 'DOU' THEN RN = 1.0D0/N ELSE RN = 1.0/N
	  if keyword_set(tot) then rn = 1.
          ND = FIX(NX/N)
          IF ND LE 0 THEN GOTO, ERR
          IF TYP EQ 'DOU' THEN T = DBLARR(ND,NY) $
	    ELSE T = FLTARR(ND,NY) ; 11/15/85
          FOR J = 0, ND-1 DO BEGIN
	    IOFF = J*N
	    T(J,0) = A(IOFF,*)
	    IF NX GT 1 THEN FOR I = 1, N-1 DO T(J,0) = T(J,*) + A(I+IOFF,*)
	    T(J,0) = T(J,*)*RN	; multiply by 1/N
          ENDFOR
        END
2:      BEGIN	; rows.
          IF N_PARAMS(0) LT 3 THEN N = NY
          IF TYP EQ 'DOU' THEN RN = 1.0D0/N ELSE RN = 1.0/N
	  if keyword_set(tot) then rn = 1.
          ND = FIX(NY/N)
          IF ND LE 0 THEN GOTO, ERR
          IF TYP EQ 'DOU' THEN T = DBLARR(NX,ND) $
	    ELSE T = FLTARR(NX,ND) ; 11/15/85
	  if nd gt 1 then begin		; Output array is more than 1 in Y.
            FOR J = 0, ND-1 DO BEGIN
   	      IOFF = J*N
	      T(0,J) = A(*,IOFF)
	      IF NY GT 1 THEN FOR I = 1, N-1 DO T(0,J) = T(*,J) + A(*,I+IOFF)
	      T(0,J) = T(*,J)*RN	; multiply by 1/N
            ENDFOR
	    endif else begin	; Output array is 1 wide in Y.  
	    t(0) = a(*,0)	; Was t =, but data type of t became same as a.
	    for i = 1, n-1 do t = t + a(*,i)
	    t = t*rn
	  endelse
        END
ELSE:   PRINT,' Error in ave2d: invalid flag value.'
        ENDCASE
 
        RETURN, t
 
ERR:    PRINT,' Error ave2d: Array too small for given group size.'
        RETURN, -1
 
	END
