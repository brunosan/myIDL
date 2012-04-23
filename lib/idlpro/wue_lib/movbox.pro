;+
; NAME:
;       MOVBOX
; PURPOSE:
;	Interactive box on image display.
; CATEGORY:
; CALLING SEQUENCE:
;       movbox, x, y, dx, dy, code
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords: 
;         /POSITION lists box position after each change. 
;         /EXITLIST lists box position on exit. 
;         /COMMANDS lists box commands on entry. 
;         /LOCKSIZE locks box size to entry size. 
;         XSIZE = factor. Mouse changes Y size only. Xsize = factor*Ysize. 
;         YSIZE = factor. Mouse changes X size only. Ysize = factor*Xsize. 
;         /NOERASE prevents last box from being erased on routine entry. 
;         /EXITERASE erases box on alternate exit. 
;         /NOMENU just does an alternate exit for middle button. 
;         /OPTIONS puts a box on the image that says options. 
;           If mouse is wiggled inside this box the options menu pops up. 
;         X_OPTION=x  sets device X coordinate for options box (def=0). 
;         Y_OPTION=y  sets device Y coordinate for options box (def=0). 
;         COLOR=clr,  box color. 
; OUTPUTS:
;       code = exit code. (2=alternate, 4=normal exit)      out 
; COMMON BLOCKS:
; NOTES:
;       Notes:
;         Commands: 
;           Left button:   Toggle bewteen move box and change size. 
;           Middle button: Option menu or alternate exit. 
;           Right button:  Normal exit (erases box). 
; MODIFICATION HISTORY:
;       R. Sterner 25 July, 1989
;       R. Sterner, 6 Jun, 1990 --- added menu.
;       R. Sterner, 13 June, 1990 --- added /nomenu
;-
 

	PRO MOVBOX, X, Y, DX, DY, CODE, position=pos, exitlist=ex, $
	  commands=cmd, help=hlp, locksize=lock, noerase=noer, xsize=xsiz, $
	  ysize=ysiz, color=clr, nomenu=nomen, exiterase=exiterase, $
	  options=options, x_option=x_option, y_option=y_option
 
	IF keyword_set(hlp) THEN begin
	  print,' Interactive box on image diaply.'
	  PRINT,' movbox, x, y, dx, dy, code'
	  PRINT,'   x,y = Device coordinates of box lower left corner.  in,out'
	  PRINT,'   dx,dy = box X and Y size in device units.           in,out'
	  PRINT,'   code = exit code. (2=alternate, 4=normal exit)      out'
	  print,' Keywords:'
	  print,'   /POSITION lists box position after each change.'
	  print,'   /EXITLIST lists box position on exit.'
	  print,'   /COMMANDS lists box commands on entry.'
	  print,'   /LOCKSIZE locks box size to entry size.'
	  print,'   XSIZE=factor. Mouse changes Y size only.'
	  print,'     Xsize = factor*Ysize.'
	  print,'   YSIZE=factor. Mouse changes X size only.'
	  print,'     Ysize = factor*Xsize.'
	  print,'   /NOERASE prevents last box from being erased on entry.'
	  print,'   /EXITERASE erases box on alternate exit.'
	  print,'   /NOMENU just does an alternate exit for middle button.'
	  print,'   /OPTIONS puts a box on the image that says options.'
	  print,'     If mouse wiggled inside this box options menu pops up.'
	  print,'   X_OPTION=x  device X coordinate for options box (def=0).'
	  print,'   Y_OPTION=y  device Y coordinate for options box (def=0).'
	  print,'   COLOR=clr,  box color.'
	  print,' Notes:
	  print,'   Commands:'
	  print,'     Left button:   Toggle bewteen move box and change size.'
	  print,'     Middle button: Option menu or alternate exit.'
	  print,'     Right button:  Normal exit (erases box).'
	  return
	endif
 
 
	;---------  Options box (click inside to pop up option menu)  -------
	if keyword_set(options) then begin
	  if n_elements(x_option) eq 0 then x_option=0	   ; Def. box pos
	  if n_elements(y_option) eq 0 then y_option=0
	  options_image = tvrd(x_option, y_option, 75,30)  ; Save img under bx.
	  tmp = bytarr(75,30)				   ; To erase opt box.
	  imgfrm, tmp, [255,0,255,0,255]		   ; Fancy border.
	  tv, tmp, x_option, y_option
	  xyouts,x_option+37.5,y_option+10,/dev,align=.5,'Options',size=1.5
	  mnox = x_option  & mxox = mnox + 74
	  mnoy = y_option  & mxoy = mnoy + 29
	  optcnt = 0	; Count # times in optns box (makes less sensitive).
	endif
 
	if keyword_set(cmd) then begin
	  print,'     Use the mouse to move a box on the screen.'
	  print,'     Left button:   Toggle bewteen move box and change size.'
	  print,'        Move mouse to change box size, '
	  print,'        then press left button to move box.'
	  if keyword_set(nomen) then begin
 	    print,'     Middle button: Alternate exit.'
	  endif else begin
	    print,'     Middle button: Options menu.'
	  endelse
	  print,'     Right button:  Normal exit (erases box).'
	  if keyword_set(options) then print,$
	    '     Wiggle mouse inside options box to pop up the options menu.'
	endif
 
	;-------  Make sure box exists and fits window  --------
	bflag = 0	; Box adjust flag.
	;------  Create box if needed  -------
	if n_elements(x) eq 0 then begin x=100 & bflag=1 & endif
	if n_elements(y) eq 0 then begin y=100 & bflag=1 & endif
	if n_elements(dx) eq 0 then begin dx=100 & bflag=1 & endif
	if n_elements(dy) eq 0 then begin dy=100 & bflag=1 & endif
	;------  Adjust box to fit in current window  ------
	if (x+dx) gt !d.x_size then begin x=(!d.x_size-dx)>0 & bflag=2 & endif
	if (y+dy) gt !d.y_size then begin y=(!d.y_size-dy)>0 & bflag=2 & endif
	if (x+dx) gt !d.x_size then begin dx=(!d.x_size-x) & bflag=2 & endif
	if (y+dy) gt !d.y_size then begin dy=(!d.y_size-y) & bflag=2 & endif
	;-----  Message  ------
	if bflag eq 2 then print,$
	  ' Warning: box size/position adjusted to fit window.'


	if n_elements(clr) eq 0 then clr=!p.color
 
	if not keyword_set(noer) then noer = 0
	tvcrs, x, y				  ; Put corner at given loc.
	TVBOX2, X, Y, DX, DY, clr, noerase=noer	  ; Draw new box.
 
	if !version.os eq 'vms' then begin
	  device, cursor_standard = 35		  ; VMS position cursor.
	endif else begin
	  DEVICE, /CURSOR_CROSS			  ; Unix cursor.
	endelse
 
LOOP:	CURSOR, X, Y, 2, /DEVICE	; Rd curs in dev units, only if moved.
 
	X = X < (!D.X_SIZE - DX - 1) > 0	  ; Restrict box to window.
	Y = Y < (!D.Y_SIZE - DY - 1) > 0
 
	if keyword_set(options) then begin
	  if (x ge mnox) and (x le mxox) and (y ge mnoy) and (y le mxoy) then $
	  begin
	    if optcnt ge 3 then goto, opt
	    optcnt = optcnt + 1		; Must count to 3 before doing options.
	  endif else begin
	    optcnt = 0			; Outside box, clear count.
	  endelse
	endif
 
	;------------  Right button = normal exit   ------------------------ 
	IF !ERR EQ 4 THEN BEGIN		  		  ; Check if exit.
	  CODE = !ERR
	  TVBOX2, X, Y, DX, DY, -1			  ; Erase.
	  if keyword_set(ex) then SHOW_BOX, X, Y, DX, DY  ; Print box size.
	  goto, done			  		  ; and return.
	ENDIF
 
	;----------  Middle button = menu  --------------------------------
	if !err eq 2 then begin				  ; Options menu.
	  if keyword_set(nomen) then begin		  ; No menu, just exit.
	    if keyword_set(exiterase) then tvbox2,x,y,dx,dy,-1	; Erase first?
	    goto, aex
	  endif
opt:	  menu = ['Box Options','  Cancel options','  List box position/size',$
		  '  Alternate exit','  Enter size','  Enter LL corner',$
	          '  Enter UR corner']
	  if keyword_set(options) then menu = [menu,'  Move options box']
	  optcnt = 0		; Clear options count.
	  in = 3
mloop:	  in = wmenu(menu, title=0, init=in)
	  if in lt 0 then begin
	    in = 3
	    goto, mloop
	  endif
	  if in eq 2 then begin				; List.
	    print,' Box size in X and Y:      '+strtrim(dx,2)+',  '+$
	      strtrim(dy,2)
	    print,' Lower left corner (X,Y):  '+strtrim(x,2)+',  '+strtrim(y,2)
	    print,' Upper right corner (X,Y): '+strtrim(x+dx-1,2)+',  '+$
	      strtrim(y+dy-1,2)
	    goto, mloop
	  endif
	  if in eq 3 then begin				; Abnormal exit.
aex:	    device, /cursor_original
	    code = 2
	    goto, done
	  endif
	  if in eq 4 then begin				; Enter size.
	    txt = ''
	    read, ' Enter box size (dx, dy): ', txt
	    if txt ne '' then begin
	      txt = repchr(txt,',')
	      dx = (getwrd(txt) + 0) > 0 < (!d.x_size - x - 1)
	      dy = (getwrd(txt,1) + 0) > 0 < (!d.y_size - y - 1)
	    endif
	  endif
	  if in eq 5 then begin				; Enter LL corner.
	    txt = ''
	    read, ' Enter lower left corner (x,y): ', txt
	    if txt ne '' then begin
	      txt = repchr(txt,',')
	      x = (getwrd(txt) + 0) > 0 < (!d.x_size - dx - 1)
	      y = (getwrd(txt,1) + 0) > 0 < (!d.y_size - dy - 1)
	    endif
	  endif
	  if in eq 6 then begin				; Enter UR corner.
	    txt = ''
	    read, ' Enter upper right corner (x,y): ', txt
	    if txt ne '' then begin
	      txt = repchr(txt,',')
	      x2 = getwrd(txt) + 0
	      y2 = getwrd(txt,1) + 0
	      dx = x2 - x + 1
	      dy = y2 - y + 1
	      dx = dx > 0 < (!d.x_size - x - 1)
	      dy = dy > 0 < (!d.y_size - y - 1)
	    endif
	  endif

	  if in eq 7 then begin				; Move options box.
	    print,' Move options box.'
	    print,' Use mouse to position options box.'
	    print,'  New box - Right button.'
	    print,'  Cancel - Middle button.'
	    ox = mnox
	    oy = mnoy
	    dox = 75
	    doy = 30
	    movbox, ox, oy, dox, doy, c, /lock, /nomenu, /exiterase
	    if c eq 4 then begin	; New box.
	      tv, options_image, x_option, y_option  ; clear old box.
	      x_option = ox
	      y_option = oy
	      options_image = tvrd(x_option, y_option, 75,30)	; Sv img.
	      tmp = bytarr(75,30)				; To erase box.
	      imgfrm, tmp, [255,0,255,0,255]			; Fancy border.
	      tv, tmp, x_option, y_option
	      xyouts,x_option+37.5,y_option+10,/dev,align=.5,'Options',size=1.5
	      mnox = x_option  & mxox = mnox + 74
	      mnoy = y_option  & mxoy = mnoy + 29
	      optcnt = 0	; # times in optns bx (to make less sensitive).
	    endif
	  endif
	  !err = 0
	  tvcrs, x, y		; Put cursor in right spot.
	endif
 
	;----------------  Left button = size  -----------------------------	
	IF !ERR EQ 1 THEN begin
	  if not keyword_set(lock) then begin
	    BOX_SIZE, X, Y, DX, DY, position=pos, xsize=xsiz, ysize=ysiz
	  endif
	endif
 
	TVBOX2, X, Y, DX, DY, clr			  ; Draw new box.
	if keyword_set(pos) then SHOW_BOX, X, Y, DX, DY	  ; Print box size.
 
	GOTO, LOOP					  ; Keep looping.
 
;----------  Clean up and exit  ------------
done:	device, /cursor_original			  ; Restore cursor.
	if keyword_set(options) then tv, options_image, x_option, y_option  
	return
 
	END	
