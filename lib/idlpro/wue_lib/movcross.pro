;+
; NAME:
;       MOVCROSS
; PURPOSE:
;       Interactive cross-hair on a plot.
; CATEGORY:
; CALLING SEQUENCE:
;       movcross, [x, y]
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         COLOR=c set color of line.
;         LINESTYLE=s line style.
; OUTPUTS:
;       x = data X coordinate of cross-hair.      out
;       y = data Y coordinate of cross-hair.      out
; COMMON BLOCKS:
; NOTES:
;       Note: Works in data coordinates so must make a plot first.
; MODIFICATION HISTORY:
;       R. Sterner, 1 Feb, 1991
;-
 
	pro movcross, xdt, ydt, color=color, linestyle=linestyle, $
	  help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Interactive cross-hair on a plot.'
	  print,' movcross, [x, y]'
	  print,'   x = data X coordinate of cross-hair.      out'
	  print,'   y = data Y coordinate of cross-hair.      out'
	  print,' Keywords:'
	  print,'   COLOR=c set color of line.'
	  print,'   LINESTYLE=s line style.'
          print,' Note: Works in data coordinates so must make a plot first.'
	  return
	endif
 
        if (total(abs(!x.crange)) eq 0.0) then begin
          print,' Error in movcross: data coordinates not yet established.'
          print,'   Must make a plot before calling movcross.'
          return
        endif

        print,' '
        print,' Interactive cross-hair.'
        print,' Move with mouse.'
        print,' Left button:   List X,Y  position.'
        print,' Middle button: Quit, erase cross-hair.'
        print,' Right button:  Quit, keep cross-hair.'
        print,' '
 
	flag = 0
	yl = 0
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
            print,' X,Y = ',xdt,ydt
            wait, .1
          endif
          if !err eq 4 then return
          if !err eq 2 then begin
            tv, tx, xl, 0  ; Erase X line on exit.
            tv, ty, 0, yl   ; Erase Y line on exit.
            return
          endif
	endif
	wait, 0				; Pause.
	todev, xdt, ydt, xdv, ydv	; Convert data to device coord.
	if flag eq 0 then ty = tvrd(0,ydv,!d.x_size,1)   ; row at ydv 1st time.
        if flag eq 0 then tx = tvrd(xdv,0,1,!d.y_size)   ; col at xdv 1st time.
	if flag eq 1 then begin		; Not first time?
	  if (ydv ne yl) or (xdv ne xl) then begin	; Cursor moved?
            tv, tx, xl, 0                ; Replace old column at xl.
	    tv, ty, 0, yl		; Replace old row at yl.
            tx = tvrd(xdv,0,1,!d.y_size) ; Read new column at xdv.
	    ty = tvrd(0, ydv,!d.x_size,1)  ; Read new row at ydv.
	  endif
	endif
	flag = 1			; Set first time flag.
        xl = xdv                        ; Remember where column read.
	yl = ydv			; Remember where row read.
        ;---  Plot vertical at new = xdv. ----
        if (xdt ge xx(0)) and (xdt le xx(1)) then begin
          plots, [xdt, xdt], yy, color=color, $
            linestyle=linestyle
	endif
	;---  Plot horizontal at new = ydv. ----
	if (ydt ge yy(0)) and (ydt le yy(1)) then begin
	  plots, xx, [ydt, ydt], color=color, $
	    linestyle=linestyle
	endif
	goto, loop
	end
