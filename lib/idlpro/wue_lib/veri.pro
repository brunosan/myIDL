;+
; NAME:
;       VERI
; PURPOSE:
;       Interactive vertical line on a plot.
; CATEGORY:
; CALLING SEQUENCE:
;       veri, [x]
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         COLOR=c set color of line.
;         LINESTYLE=s line style.
; OUTPUTS:
;       x = data X coordinate of line.      out
; COMMON BLOCKS:
; NOTES:
;       Note: Works in data coordinates so must make a plot first.
; MODIFICATION HISTORY:
;       R. Sterner, 11 Sep, 1990
;-
 
	pro veri, xdt, color=color, linestyle=linestyle, $
	  help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Interactive vertical line on a plot.'
	  print,' veri, [x]'
	  print,'   x = data X coordinate of line.      out'
	  print,' Keywords:'
	  print,'   COLOR=c set color of line.'
	  print,'   LINESTYLE=s line style.'
          print,' Note: Works in data coordinates so must make a plot first.'
	  return
	endif
 
        if (total(abs(!x.crange)) eq 0.0) then begin
          print,' Error in veri: data coordinates not yet established.'
          print,'   Must make a plot before calling veri.'
          return
        endif

	print,' '
	print,' Interactive vertical line'
	print,' Move with mouse.'
	print,' Left button:   List line X position.'
	print,' Middle button: Quit, erase line.'
	print,' Right button:  Quit, keep line.'
	print,' '
 
	flag = 0
	xl = 0
	if n_elements(color) eq 0 then color = 255
	if n_elements(linestyle) eq 0 then linestyle = 0
        tmp = [!y.range, !y.crange]
	yy = [min(tmp), max(tmp)]
        tmp = [!x.range, !x.crange]
	xx = [min(tmp), max(tmp)]
 
 
loop:	tvrdc, xdt, ydt, 0, /data	; Read data coordinates of cursor.
        xdt = xdt > xx(0) < xx(1)
        ydt = ydt > yy(0) < yy(1)
	if !err ne 0 then begin		; Button pressed?
	  if !err eq 1 then begin
	    print,' X = ',xdt
	    wait, .1
	  endif
	  if !err eq 4 then return
	  if !err eq 2 then begin
	    tv, t, xl, 0  ; Erase line on exit.
	    return
	  endif
	endif
	wait, 0				; Pause.
	todev, xdt, ydt, xdv, ydv	; Convert data to device coord.
	if flag eq 0 then t = tvrd(xdv,0,1,!d.y_size)	; col at xdv 1st time.
	if flag eq 1 then begin		; Not first time?
	  if xdv ne xl then begin	; Cursor moved?
	    tv, t, xl, 0		; Replace old column at xl.
	    t = tvrd(xdv,0,1,!d.y_size)	; Read new column at xdv.
	  endif
	endif
	flag = 1			; Set first time flag.
	xl = xdv			; Remember where column read.
	;---  Plot vertical at new = xdv. ----
	if (xdt ge xx(0)) and (xdt le xx(1)) then begin
	  plots, [xdt, xdt], yy, color=color, $
	    linestyle=linestyle
	endif
	goto, loop
	end
