function RADIAL,IM ,PARA=PARA ,ANNUL=ANNUL
;+
; NAME:
;	RADIAL
;
; PURPOSE:
;	Return a radial distribution of counts for a circular or
;	an anullar region of the input image.
;
; CALLING SEQUENCE:
;	P = RADIAL(im [, PARA, /ANNUL] )
; INPUTS:
;	IM = Inputted 2d array
;
; INPUT KER_BOARD parameter:
;	ANNUL 	If this keyword is set, a radial profile of an annular
;		region is calculated, otherwise a circular area.
;	PARA	This optional parameter gives the parameter of the 
;		defined circle.
; OUTPUTS:
;
; MODIFICATION HISTORY:
;       Zhang Yi
;       August, 1990
;-

	ON_ERROR,2

	P=DEF_CIRC(IM,para=para)
	IF KEYWORD_SET(ANNUL) THEN begin
		R0 = para(2)
		P=DEF_CIRC(IM,para=para)
	ENDIF ELSE R0=0
	X0=PARA(0)	& Y0=PARA(1)	 
	IF PARA(2) LT R0 THEN BEGIN
		R=R0	&	R0=PARA(2)
	ENDIF ELSE R=PARA(2)

	DUM=IM(X0-R:X0+R,Y0-R:Y0+R)
	U=LINDGEN(2*R+1,2*R+1)
	V=U/(2*R+1)-R	&	U=(U MOD (2*R+1))-R
	U=SQRT(U^2+V^2) &	V=0	

	N=NFIX(R-R0)
	IN=fltarr(N,2)
	IN(0,0)=FINDGEN(N)  

	FOR K=0,N-1 DO BEGIN
	  IN(K,1)=MEAN(DUM(WHERE( (U GE K+R0) AND (U LT K+1+R0 ))))
	END
	DUM=0 & U=0
	
	RETURN,IN
	END














