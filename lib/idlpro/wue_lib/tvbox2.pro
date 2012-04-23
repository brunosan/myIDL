;+
; NAME:
;       TVBOX2
; PURPOSE:
;       Draw or erase a box on the image display.
; CATEGORY:
; CALLING SEQUENCE:
;       tvbox2, x, y, dx, dy, clr
; INPUTS:
;       x = Device X coordinate of lower left corner of box.  in 
;       y = Device Y coordinate of lower left corner of box.  in 
;       dx = Box X size in device units.                      in  
;       dy = Box Y size in device units.                      in  
;       clr = box color.                                      in 
;          -1 to just erase last box (only last box, others are lost). 
; KEYWORD PARAMETERS:
;       Keywords: 
;         /NOERASE  causes last drawn box not to be erased first. 
; OUTPUTS:
; COMMON BLOCKS:
;       BOX_COM
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 25 July, 1989
;-
 
	PRO TVBOX2, X, Y, DX, DY, CLR, help=hlp, noerase=noeras 
 
	COMMON BOX_COM, XC, YC, DXC, DYC, BB, BL, BT, BR
 
	IF (N_PARAMS(0) LT 5) or keyword_set(hlp) THEN BEGIN
	  PRINT,' Draw or erase a box on the image display.'
	  PRINT,' tvbox, x, y, dx, dy, clr'
  	  PRINT,'   x = Device X coordinate of lower left corner of box.  in'
  	  PRINT,'   y = Device Y coordinate of lower left corner of box.  in'
	  PRINT,'   dx = Box X size in device units.                      in' 
	  PRINT,'   dy = Box Y size in device units.                      in' 
	  PRINT,'   clr = box color.                                      in'
	  print,'      -1 to just erase last box (only last box).'
	  print,' Keywords:'
	  print,'   /NOERASE  causes last drawn box not to be erased first.'
	  RETURN
	ENDIF
 
	if keyword_set(noeras) then goto, skip
 
	IF N_ELEMENTS(BB) NE 0 THEN BEGIN       ; Something to erase?
  	  X2 = XC + DXC - 1
	  Y2 = YC + DYC - 1
	  TV, BB, XC, YC		        ; Restore parts of image
	  TV, BL, XC, YC		        ; beneath box.
	  TV, BT, XC, Y2
	  TV, BR, X2, YC
	  IF CLR LT 0 THEN RETURN	        ; Only erase old box.
	ENDIF
 
skip:	X2 = X + DX - 1			        ; Draw new box.
	Y2 = Y + DY - 1
	BB = TVRD(X, Y, DX,1)	                ; Save image beneath box.
	BL = TVRD(X, Y, 1, DY)
	BT = TVRD(X, Y2,DX,1)
	BR = TVRD(X2,Y, 1, DY)
	XC = X & YC = Y & DXC = DX & DYC = DY   ; Save box position and size.
	PLOTS,[X,X2,X2,X,X],[Y,Y,Y2,Y2,Y],/DEVICE,COLOR=CLR
	RETURN
 
	END
