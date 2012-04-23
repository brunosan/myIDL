PRO CURS_LAB,X,Y,DATA=DATA,size=size
;+
; NAME:
;       CURS_LAB
;
; PURPOSE:
;       Print the cordinate of the current cursor position on the
;	display device.
;
; CALLING SEQUENCE:
;       CURS_LAB [x, y, /data, size= ]
; INPUTS:
;       None
;
; INPUT KER_BOARD parameter:
;       DATA:   If this keyword is set, the coordinate system
;               will be established by the most recent PLOT, CONTOUR,
;               or SURFACE, otherwise the coordinate system will
;               be based on the physical coodinate system of the
;               selected plotting device.
;
;	SIZE:	Choose the size of cursor.
;
; OUTPUTS:
;       X, Y: The coordinate of the cursor position.
;
; MODIFICATION HISTORY:
;       Z. Yi, 1993
;-

	ON_ERROR,2

	if keyword_set(size) then sz=size else sz=.8

IF N_ELEMENTS(X) LE 0 THEN BEGIN 	
	X=INTARR(100) & Y=X
	PRINT,'USING LEFT  BUTTON TO SELECT POINT'
	PRINT,'USING RIGHT BUTTON TO EXIT'

	N=0
	IF KEYWORD_SET(DATA) THEN BEGIN
         dx=(!x.crange(1)-!x.crange(0))/40 & dy=(!y.crange(1)-!y.crange(0))/200
         CURSOR,X1,Y1,3,/DATA
         WHILE !ERR NE 4 DO BEGIN
           X(N)=X1 & Y(N)=Y1
           PLOTS,[X1,X1],[Y1,Y1],PSYM=1
           XYOUTS,X1+dx,Y1-dy,'('+STRCOMPRESS(X1)+','+STRCOMPRESS(Y1)+')',CHARSIZE=sz
           CURSOR,X1,Y1,3,/DATA
	   N=N+1
         END
        ENDIF ELSE BEGIN
         xs=!d.x_vsize     &	ys=!d.y_vsize  & !x.ticks=1 & !y.ticks=1
         plot,[0,xs],[0,ys],/nodata,/xst,/yst,charsize=.0000001,/noerase 
         CURSOR,X1,Y1,3,/dev
         WHILE !ERR NE 4 DO BEGIN
           X(n)=X1 & Y(n)=Y1
           PLOTS,[X1-2,X1+2,X1,X1,X1],[Y1,Y1,Y1,Y1-2,Y1+2]
           XYOUTS,X1+3,Y1-3,'('+STRCOMPRESS(X1)+','+STRCOMPRESS(Y1)+')',CHARSIZE=sz
           CURSOR,X1,Y1,3,/dev
	   N=N+1
         END
	ENDELSE
	X(N)=XS & Y(N)=YS
	X=X(0:N) & Y=Y(0:N)
;==============================================================================
ENDIF ELSE BEGIN
	N=N_ELEMENTS(X)-2
	IF KEYWORD_SET(DATA) THEN BEGIN
         dx=(!x.crange(1)-!x.crange(0))/40 & dy=(!y.crange(1)-!y.crange(0))/200
	 FOR K=0,N DO BEGIN
	   X1=X(K) & Y1=Y(K)
           PLOTS,[X1-DY,X1+DY,X1,X1,X1],[Y1,Y1,Y1,Y1-DY,Y1+DY],/DATA
           XYOUTS,X(K)+dx,Y(K)-dy,'('+STRCOMPRESS(X(K))+','+STRCOMPRESS(Y(K))+')',CHARSIZE=sz
         END
        ENDIF ELSE BEGIN
         xs=X(N+1)     &	ys=Y(N+1)  & !x.ticks=1 & !y.ticks=1
print,xs,ys
         plot,[0,xs],[0,ys],/nodata,/xst,/yst,charsize=.0000001,/noerase 
	 FOR K=0,N DO BEGIN
	   X1=X(K) & Y1=Y(K)
           PLOTS,[X1-2,X1+2,X1,X1,X1],[Y1,Y1,Y1,Y1-2,Y1+2]
           XYOUTS,X1+3,Y1-3,'('+STRCOMPRESS(X1)+','+STRCOMPRESS(Y1)+')',CHARSIZE=sz
	 END
	ENDELSE
ENDELSE



	END







