;+
; NAME:
;       HORI
; PURPOSE:
;       Interactive horizontal line on a plot.
; CATEGORY:
; CALLING SEQUENCE:
;       hori, [y]
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         COLOR=c set color of line.
;         LINESTYLE=s line style.
; OUTPUTS:
;       y = data Y coordinate of line.      out
; COMMON BLOCKS:
; NOTES:
;	Note: Works in data coordinates so must make a plot first.
; MODIFICATION HISTORY:
;       R. Sterner, 11 Sep, 1990
;-
 
	pro hori, ydt, color=color, linestyle=linestyle, $
	  help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Interactive horizontal line on a plot.'
	  print,' hori, [y]'
	  print,'   y = data Y coordinate of line.      out'
	  print,' Keywords:'
	  print,'   COLOR=c set color of line.'
	  print,'   LINESTYLE=s line style.'
	  print,' Note: Works in data coordinates so must make a plot first.'
	  return
	endif
 
	if (total(abs(!x.crange)) eq 0.0) then begin
	  print,' Error in hori: data coordinates not yet established.'
	  print,'   Must make a plot before calling hori.'
	  return
	endif

        print,' '
        print,' Interactive horizontal line'
        print,' Move with mouse.'
        print,' Left button:   List line Y  position.'
        print,' Middle button: Quit, erase line.'
        print,' Right button:  Quit, keep line.'
        print,' '
 
	flag = 0
	yl = 0
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
            print,' Y = ',ydt
            wait, .1
          endif
          if !err eq 4 then return
          if !err eq 2 then begin
            tv, t, 0, yl   ; Erase line on exit.
            return
          endif
	endif
	wait, 0				; Pause.
	todev, xdt, ydt, xdv, ydv	; Convert data to device coord.
	if flag eq 0 then t = tvrd(0,ydv,!d.x_size,1)   ; row at ydv 1st time.
	if flag eq 1 then begin		; Not first time?
	  if ydv ne yl then begin	; Cursor moved?
	    tv, t, 0, yl		; Replace old row at yl.
	    t = tvrd(0, ydv,!d.x_size,1)  ; Read new row at ydv.
	  endif
	endif
	flag = 1			; Set first time flag.
	yl = ydv			; Remember where row read.
	;---  Plot horizontal at new = ydv. ----
	if (ydt ge yy(0)) and (ydt le yy(1)) then begin
	  plots, xx, [ydt, ydt], color=color, $
	    linestyle=linestyle
	endif
	goto, loop
	end
