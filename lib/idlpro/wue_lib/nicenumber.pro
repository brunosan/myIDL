;+
; NAME:
;       NICENUMBER
; PURPOSE:
;       Find a nice number close to the given number.
; CATEGORY:
; CALLING SEQUENCE:
;       n = nicenumber(x)
; INPUTS:
;       x = given number.              in 
; KEYWORD PARAMETERS:
;       Keywords: 
;         /FLOOR finds next nice number le to X. 
;         /CEIL finds the next nice number ge to X. 
; OUTPUTS:
;       n = nice number close to x.    out 
;         1, 2, 2.5, or 5 scaled to size of x. 
; COMMON BLOCKS:
; NOTES:
;       Notes: 
;         Default operation is useful for finding tick spacings: 
;         dx = nicenumber((xmx-xmn)/nticks). 
;         /FLOOR and /CEIL are useful for scaling data plots: 
;         xmn = nicenumber(min(x),/floor) 	
;         xmx = nicenumber(max(x),/ceil) 
;         plot, x, y, xrange=[xmn,xmx], . . . 
;	  /floor and /ceil may not give values related to the'
;	  step size, dx.  The following method will:'
;	  ceil(t/dx)*dx is a multiple of dx on the low side of t.'
;	  floor(t/dx)*dx  is a multiple of dx on the high side of t.'
; MODIFICATION HISTORY:
;       R. Sterner, 6 Feb, 1990
;-
 
	function nicenumber, x0, help=hlp, floor=flr, ceil=cel
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Find a nice number close to the given number.'
	  print,' n = nicenumber(x)'
	  print,'   x = given number.              in'
	  print,'   n = nice number close to x.    out'
	  print,'     1, 2, 2.5, or 5 scaled to size of x.'
	  print,' Keywords:'
	  print,'   /FLOOR finds next nice number le to X.'
	  print,'   /CEIL finds the next nice number ge to X.'
	  print,' Notes:'
	  print,'   Default operation is useful for finding tick spacings:'
	  print,'   dx = nicenumber((xmx-xmn)/nticks).'
	  print,'   /FLOOR and /CEIL are useful for scaling data plots:'
	  print,'   xmn = nicenumber(min(x),/floor)'	
	  print,'   xmx = nicenumber(max(x),/ceil)'
	  print,'   plot, x, y, xrange=[xmn,xmx], . . .'
	  print,'   /floor and /ceil may not give values related to the'
	  print,'   step size, dx.  The following method will:'
	  print,'   ceil(t/dx)*dx is a multiple of dx on the low side of t.'
	  print,'   floor(t/dx)*dx  is a multiple of dx on the high side of t.'
	  return, -1
	endif
 
	x = x0					; Copy x.
	flag = isarray(x)			; Test if array.
	x = array(x)				; Force to be an array.
	out = x*0.				; Return 0 is x eq 0.
	wnz = where(x ne 0., countnz)		; Find non-zero values.
	wgt = where(x gt 0., countgt)		; Find positive values.
	wlt = where(x lt 0., countlt)		; Find negative values.
	if countlt gt 0 then x(wlt) = -x(wlt)	; negatives -> positives.
 
	fcflag = 0				; flag: 0=close, 1=flr or cl.
	countup = 0				; Default = closest.
	countdn = 0				; Default = closest.
	if keyword_set(flr) then begin		; Floor set.
	  countup = countlt			; Number to move up.
	  countdn = countgt			; Number to move down.
	  wup = wlt				; Which to move up.
	  wdn = wgt				; Which to move down.
	  fcflag = 1				; Non-default process.
	endif
	if keyword_set(cel) then begin		; Ceil set.
	  countup = countgt			; Number to move up.
	  countdn = countlt			; Number to move down.
	  wup = wgt				; Which to move up.
	  wdn = wlt				; Which to move down.
	  fcflag = 1				; Non-default process.
	endif
 
 
	if countnz gt 0 then begin		; Only process non-0 numbers.
	  p = x*0. + 1.				; Default p = 1.
	  p(wnz) = 10.^floor(alog10(x(wnz)))	; pow of 10 to force 1<=x<=10.
	  y = x/p				; Put in range.
 
	  z = y*0. + 1.				; Filter through nice numbers.
	  ;---------  default = closest  ---------
	  if fcflag eq 0 then begin		; Default.  Find close number.
	    w = where(y gt 1.414, count)	; y>1.414 use 2.
	    if count gt 0 then z(w) = 2.
	    w = where(y gt 2.236, count)	; y>2.236 use 2.5
	    if count gt 0 then z(w) = 2.5
	    w = where(y gt 3.536, count)	; y>3.536 use 5.
	    if count gt 0 then z(w) = 5.
	    w = where(y gt 7.071, count)	; y>7.071 use 10.
	    if count gt 0 then z(w) = 10.
	  endif
	  ;---------  Up (move away from 0) ------------
	  if (fcflag gt 0) and (countup gt 0) then begin  ; Upp bnd (abs val).
	    w = where(y(wup) gt 1., count)	; y>1. use 2.
	    if count gt 0 then z(wup(w)) = 2.
	    w = where(y(wup) gt 2., count)	; y>2. use 2.5
	    if count gt 0 then z(wup(w)) = 2.5
	    w = where(y(wup) gt 2.5, count)	; y>2.5 use 5.
	    if count gt 0 then z(wup(w)) = 5.
	    w = where(y(wup) gt 5., count)	; y>5. use 10.
	    if count gt 0 then z(wup(w)) = 10.
	  endif
	  ;---------  Down (move toward 0) ------------
	  if (fcflag gt 0) and (countdn gt 0) then begin  ; Lowr bnd (abs val).
	    w = where(y(wdn) lt 10., count)	; y<10. use 5.
	    if count gt 0 then z(wdn(w)) = 5.
	    w = where(y(wdn) lt 5., count)	; y<5. use 2.5
	    if count gt 0 then z(wdn(w)) = 2.5
	    w = where(y(wdn) lt 2.5, count)	; y<2.5 use 2.
	    if count gt 0 then z(wdn(w)) = 2.
	    w = where(y(wdn) lt 2., count)	; y<2. use 1.
	    if count gt 0 then z(wdn(w)) = 1.
	  endif
 
	  out = z*p		; Scale nice numbers back to correct range.
	  if countlt gt 0 then out(wlt) = -out(wlt)	; Restore negatives.
	endif
 
	if flag eq 0 then out = out(0)			; Was scalar.
	return, out					; Return result. 
	end
