;+
; NAME:
;       MAKEVLT
; PURPOSE:
;       Generate and load a random color table (CT).
; CATEGORY:
; CALLING SEQUENCE:
;       makevlt, [r, g, b, w, s]
; INPUTS:
;       w = smoothing window width (def = 31).          in
;       s = standard deviation (def = 64).              in
; KEYWORD PARAMETERS:
;       Keywords:
;         /WHITE forces color 255 to be white.
;         WHITE=N forces color N to be white.
;         /RAMP make a table that goes from dark to light.
;         /SAWTOOTH make a CT where colors ramp from dark to light. 8 teeth.
;         SAWTOOTH=N  A sawtooth CT with each tooth being N values long.
;         /NOLOAD inhibits CT load.
;         /GETSEED returns the random number seed use to make
;            the last CT.  The call is: makevlt, seed, /GETSEED
;         SEED=value sets the color table seed (can use to remake a CT).
;         /RANDOM  A completely random CT but with 0=black, 255=white.
; OUTPUTS:
;       r,g,b = arrays for red, green, blue.            out
; COMMON BLOCKS:
;       makevlt_com
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner.  20 May, 1986.
;-
 
	PRO MAKEVLT, R, G, B, W, S, help=h, white=wh, ramp=rmp, noload=nl,$
	  getseed=gs, seed=sd, random=rndm, sawtooth=saw
 
	common makevlt_com, ctseed, lstseed
 
	N = N_PARAMS(0)
 
	if keyword_set(h) then begin
	  print,' Generate and load a random color table (CT).'
	  print,' makevlt, [r, g, b, w, s]'
	  print,'   r,g,b = arrays for red, green, blue.            out'
	  print,'   w = smoothing window width (def = 31).          in'
	  print,'   s = standard deviation (def = 64).              in'
	  print,' Keywords:'
	  print,'   /WHITE forces color 255 to be white.'
	  print,'   WHITE=N forces color N to be white.'
	  print,'   /RAMP make a table that goes from dark to light.'
	  print,'   /SAWTOOTH make a CT where colors ramp'+$
	    ' from dark to light. 8 teeth.'
	  print,'   SAWTOOTH=N  A sawtooth CT with each '+$
	    'tooth being N values long.'
	  print,'   /NOLOAD inhibits CT load.'
	  print,'   /GETSEED returns the random number seed use to make'
	  print,'      the last CT.  The call is: makevlt, seed, '+$
	    '/GETSEED'
	  print,'   SEED=value sets the color table seed (can use to '+$
	    'remake a CT).'
	  print,'   /RANDOM  A completely random CT but with '+$
	    '0=black, 255=white.'
	  return
	endif
 
	;-----  Return last color table seed  ----------
	if keyword_set(gs) then begin
	  if n_elements(lstseed) ne 0 then r = lstseed else print,$
	    ' Seed is undefined on first call.'
	  return
	endif
 
	;-----  random color table  -------
	if keyword_set(rndm) then begin
	  r =randomu(i,256)*256 & r(0) = 0  & r(255) = 255
	  g =randomu(i,256)*256 & g(0) = 0  & g(255) = 255
	  b =randomu(i,256)*256 & b(0) = 0  & b(255) = 255
	  if not keyword_set(nl) then tvlct, r, g, b
	  return
	endif
 
	;------  Set up color table parameters  -------
	IF N LT 5 THEN S = 64.0
	IF N LT 4 THEN W = 31
	if keyword_set(rmp) then s = 450
 
	;------  Handle provided seed  ---------
	if keyword_set(sd) then ctseed = sd
 
	;------  Save seed use to generate this table  ------
	if n_elements(ctseed) ne 0 then lstseed = ctseed
 
	;------  Generate color table  --------
	R = MAKEY(256,W,128,S, ctseed)<255>0
	R(0) = 0
	G = MAKEY(256,W,128,S, ctseed)<255>0
	G(0) = 0
	B = MAKEY(256,W,128,S, ctseed)<255>0
	B(0) = 0
 
	;-----  Handle sawtooth table  ----
	if keyword_set(saw) then begin
	  sw = saw
	  if sw eq 1 then sw = 32		; Default sawtooth is 32 long.
	  t = findgen(256) mod sw		; Make sawtooth.
	  w0 = where(t eq 0)			; Find zeroes.
	  for i = 0, n_elements(w0)-1 do begin	; Brighten color
	    mx = r(w0(i))>g(w0(i))>b(w0(i))	;   Find max of r,g,b.
	    f = 255./(mx>1)				;   and set it to 255.
	    r(w0(i)) = f*r(w0(i))
	    g(w0(i)) = f*g(w0(i))
	    b(w0(i)) = f*b(w0(i))
	  endfor
	  for i = 1, sw-1 do begin		; Keep each tooth same color.
	    r(w0+i) = r(w0)
	    g(w0+i) = g(w0)
	    b(w0+i) = b(w0)
	  endfor
	  t = t/max(t)				; Normalize sawtooth.
	  r = r*t				; Now sawtooth colors.
	  g = g*t
	  b = b*t
	endif
 
	;-----  Handle 255 = white  -------
	if keyword_set(wh) then begin
	  iw = wh
	  if iw eq 1 then iw = !d.n_colors-1
	  r(iw) = !d.n_colors-1
	  g(iw) = !d.n_colors-1
	  b(iw) = !d.n_colors-1
	endif
 
	;------  Handle ramp color table --------
	if keyword_set(rmp) then begin
	  r = r/max(r)
	  g = g/max(g)
	  b = b/max(b)
	  nrmp = maken(1., 0. , 256)
	  r = 1. - nrmp*r
	  g = 1. - nrmp*g
	  b = 1. - nrmp*b
	  s = (r+g+b)/3.
	  r = r/s
	  g = g/s
	  b = b/s
	  in = indgen(256)
	  r = r*in
	  g = g*in
	  b = b*in
	endif
 
	;-----  Load color table  --------
	if not keyword_set(nl) then tvlct, r, g, b
 
	RETURN
	END
