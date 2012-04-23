PRO CURS_FINE,im,data=data,X0,Y0
;+
; NAME:
;	CURS_FINE
;
; PURPOSE:
;	Move the cursor pixel by pixel.
;
; CALLING SEQUENCE:
;	CURS_FINE [,IM, /data]
;
; OPTIONAL INPUTS:
;	IM:	When this argument is set, the value of the 
;		image IM on the current cursor position will be 
;		printed, otherwise the value of the display 
;		subsystem's memory will be printed.
;
; INPUT KER_BOARD parameter:
;	DATA: 	If this keyword is set, the coordinate system 
;		will be established by the most recent PLOT, CONTOUR,
;		or SURFACE, otherwise the coordinate system will
;		be based on the physical coodinate system of the
;		selected plotting device.
;
; OUTPUTS:
;	X0, Y0:	The coordinate of the last cursor position.
;
; MODIFICATION HISTORY:
;       Z. Yi, 1992
;-

 	ON_ERROR,2

	PRINT,'USING ARROWS TO MOVE THE CURSOR PIXEL BY PIXEL'
	PRINT,'F1 TO EXIT'

	if n_elements(data) le 0 then begin

         CURSOR,X0,Y0,1,/DEV
	 if n_elements(im) le 0 then begin
         PRINT,' Col    Row    Byte Inten  '
         REPEAT BEGIN

                 F="($,i4,2x,i4,6x,i4,3x,a,a)"
                 KB=byte(GET_KBRD(1)+GET_KBRD(1)+GET_KBRD(1)) & kb=kb(2)
                   CASE 1 OF
                    (KB EQ 68): X0=(X0-1)>0
                    (KB EQ 67): X0=(X0+1)>0
                    (KB EQ 66): Y0=(Y0-1)>0
                    (KB EQ 65): Y0=(Y0+1)>0
		    (KB EQ 49): RETURN
		    ELSE: RETURN                    
                 ENDCASE
                 tvcrs,x0,y0,/dev
               print,form=f,x0,y0,fix(tvrd(x0,y0,1,1)),string("15b)
             ENDREP UNTIL KB EQ 0
	 ENDIF ELSE BEGIN
         PRINT,' Col    Row    Byte Inten    Value '
         REPEAT BEGIN

                 F="($,i4,2x,i4,6x,i4,3x,a,a)"
                 KB=byte(GET_KBRD(1)+GET_KBRD(1)+GET_KBRD(1)) & kb=kb(2)
                   CASE 1 OF
                    (KB EQ 68): X0=(X0-1)>0
                    (KB EQ 67): X0=(X0+1)>0
                    (KB EQ 66): Y0=(Y0-1)>0
                    (KB EQ 65): Y0=(Y0+1)>0
		    (KB EQ 49): RETURN
		    ELSE: RETURN                    
                 ENDCASE
                 tvcrs,x0,y0,/dev
               print,form=f,x0,y0,fix(tvrd(x0,y0,1,1)),im(x0,y0),string("15b)
             ENDREP UNTIL KB EQ 0
	  ENDELSE

        endif else begin
         CURSOR,X0,Y0,1,/data
	 if n_elements(im) le 0 then begin
         PRINT,' Col    Row    Byte Inten  '
         REPEAT BEGIN

                 F="($,i4,2x,i4,6x,i4,3x,a,a)"
                 KB=byte(GET_KBRD(1)+GET_KBRD(1)+GET_KBRD(1)) & kb=kb(2)
                   CASE 1 OF
                    (KB EQ 68): X0=(X0-1)>0
                    (KB EQ 67): X0=(X0+1)>0
                    (KB EQ 66): Y0=(Y0-1)>0
                    (KB EQ 65): Y0=(Y0+1)>0
		    (KB EQ 49): RETURN
		    ELSE: RETURN                    
                 ENDCASE
                 tvcrs,x0,y0,/data
               print,form=f,x0,y0,fix(tvrd(x0,y0,1,1)),string("15b)
             ENDREP UNTIL KB EQ 0
	 ENDIF ELSE BEGIN
         PRINT,' Col    Row    Byte Inten    Value '
         REPEAT BEGIN

                 F="($,i4,2x,i4,6x,i4,3x,a,a)"
                 KB=byte(GET_KBRD(1)+GET_KBRD(1)+GET_KBRD(1)) & kb=kb(2)
                   CASE 1 OF
                    (KB EQ 68): X0=(X0-1)>0
                    (KB EQ 67): X0=(X0+1)>0
                    (KB EQ 66): Y0=(Y0-1)>0
                    (KB EQ 65): Y0=(Y0+1)>0
		    (KB EQ 49): RETURN
		    ELSE: RETURN                    
                 ENDCASE
                 tvcrs,x0,y0,/data
               print,form=f,x0,y0,fix(tvrd(x0,y0,1,1)),im(x0,y0),string("15b)
             ENDREP UNTIL KB EQ 0
	  ENDELSE
        endelse


	END

