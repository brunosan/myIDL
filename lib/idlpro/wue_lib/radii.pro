;+
; NAME:
;       RADII
; PURPOSE:
;       Plot specified radii on the current plot device.
; CATEGORY:
; CALLING SEQUENCE:
;       radii, r1, r2, a, [x0, y0]
; INPUTS:
;       r1 = start radius of radius to draw (data units).   in 
;       r2 = end radius of radius to draw (data units).     in 
;       a = Angle of arc (deg CCW from X axis).             in 
;       [x0, y0] = optional arc center (def=0,0).           in 
; KEYWORD PARAMETERS:
;       Keywords: 
;         COLOR=c  plot color. 
;         LINESTYLE=l  linestyle. 
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: all parameters may be scalars or arrays. 
; MODIFICATION HISTORY:
;       Written by R. Sterner, 15 Sep, 1989.
;       Johns Hopkins University Applied Physics Laboratory.
;-
 
	PRO RADII, R10, R20, A0, XX0, YY0, help=hlp,$
		 color=clr, linestyle=lstyl
 
 	NP = N_PARAMS(0)
	IF (NP LT 3) or keyword_set(hlp) THEN BEGIN
	  print,' Plot specified radii on the current plot device.'
	  PRINT,' radii, r1, r2, a, [x0, y0]'
	  PRINT,'   r1 = start radius of radius to draw (data units).   in'
	  PRINT,'   r2 = end radius of radius to draw (data units).     in'
	  PRINT,'   a = Angle of arc (deg CCW from X axis).             in'
	  PRINT,'   [x0, y0] = optional arc center (def=0,0).           in'
	  print,' Keywords:'
	  print,'   COLOR=c  plot color.'
	  print,'   LINESTYLE=l  linestyle.'
	  print,' Note: all parameters may be scalars or arrays.'
	  RETURN
	ENDIF
 
	if n_elements(clr) eq 0 then clr = !p.color
	if n_elements(lstyl) eq 0 then lstyl = !p.linestyle
 
	IF NP LT 4 THEN XX0 = 0.
	IF NP LT 5 THEN YY0 = 0.
 
	R1 = ARRAY(R10)			; Force to be arrays.
	R2 = ARRAY(R20)
	A  = ARRAY(A0)
	XX = ARRAY(XX0)
	YY = ARRAY(YY0)
	
	NR1 = N_ELEMENTS(R1)-1		; Array sizes.
	NR2 = N_ELEMENTS(R2)-1
	NA  = N_ELEMENTS(A)-1
	NXX = N_ELEMENTS(XX)-1
	NYY = N_ELEMENTS(YY)-1
	N = NR1>NR2>NA>NXX>NYY		; Overall max.
 
	FOR I = 0, N DO BEGIN   	; loop thru arcs.
	  R1I  = R1(I<NR1)		; Get R1, R2, A.
	  R2I  = R2(I<NR2)
	  AI = A(I<NA)
	  XXI = XX(I<NXX)
	  YYI = YY(I<NYY)
	  POLREC, [R1I, r2i], [ai, ai]/!radeg, X, Y
	  OPLOT, X + XXI, Y + YYI, color=clr, linestyle=lstyl
	ENDFOR
 
	RETURN
 
	END
