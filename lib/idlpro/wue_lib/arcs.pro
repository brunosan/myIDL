;+
; NAME:
;       ARCS
; PURPOSE:
;       Plot specified arcs on the current plot device.
; CATEGORY:
; CALLING SEQUENCE:
;       arcs, r, a1, a2, [x0, y0]
; INPUTS:
;       r = radii of arcs to draw (data units).           in 
;       a1 = Start angle of arc (deg CCW from X axis).    in 
;       a2 = End angle of arc (deg CCW from X axis).      in 
;       [x0, y0] = optional arc center (def=0,0).         in 
; KEYWORD PARAMETERS:
;       Keywords: 
;         COLOR=c  plot color. 
;         LINESTYLE=l  linestyle. 
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: all parameters may be scalars or arrays. 
; MODIFICATION HISTORY:
;       Written by R. Sterner, 12 July, 1988.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES 15 Sep, 1989 --- converted to SUN.
;-
 
	PRO ARCS, R0, A10, A20, XX0, YY0, help=hlp,$
		 color=clr, linestyle=lstyl
 
 	NP = N_PARAMS(0)
	IF (NP LT 3) or keyword_set(hlp) THEN BEGIN
	  print,' Plot specified arcs on the current plot device.'
	  PRINT,' arcs, r, a1, a2, [x0, y0]'
	  PRINT,'   r = radii of arcs to draw (data units).           in'
	  PRINT,'   a1 = Start angle of arc (deg CCW from X axis).    in'
	  PRINT,'   a2 = End angle of arc (deg CCW from X axis).      in'
	  PRINT,'   [x0, y0] = optional arc center (def=0,0).         in'
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
 
	R = ARRAY(R0)			; Force to be arrays.
	A1 = ARRAY(A10)
	A2 = ARRAY(A20)
	XX = ARRAY(XX0)
	YY = ARRAY(YY0)
	
	NR = N_ELEMENTS(R)-1		; Array sizes.
	NA1 = N_ELEMENTS(A1)-1
	NA2 = N_ELEMENTS(A2)-1
	NXX = N_ELEMENTS(XX)-1
	NYY = N_ELEMENTS(YY)-1
	N = NR>NA1>NA2>NXX>NYY		; Overall max.
 
	FOR I = 0, N DO BEGIN   	; loop thru arcs.
	  RI  = R(I<NR)			; Get R, A1, A2.
	  A1I = A1(I<NA1)
	  A2I = A2(I<NA2)
	  XXI = XX(I<NXX)
	  YYI = YY(I<NYY)
	  A = MAKEX(A1I, A2I, 0.25*SIGN(A2I-A1I))/!RADEG
	  POLREC, RI, A, X, Y
	  OPLOT, X + XXI, Y + YYI, color=clr, linestyle=lstyl
	ENDFOR
 
	RETURN
 
	END
