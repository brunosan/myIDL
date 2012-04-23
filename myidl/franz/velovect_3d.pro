PRO VELOVECT_3d,VX,VY,VZ,LX=LX,LY=LY,LZ=LZ,AX=AX,AZ=AZ,XTIT=XTIT,YTIT=YTIT,ZTIT=ZTIT
;
;+
; NAME:
;	VELOVECT_3D
; PURPOSE:
;	USED TO PLOT 3-D VELOCITY FIELD
; CALLING SEQUENCE:
;	VELOVECT_3D,VX,VY,VZ,[LX=LX,LY=LY,.....]
; INPUTS:
;	VX = X components of velocity field
;	VY = Y components of velocity field
;	VZ = Z components of velocity field
; INPUT KER_BOARD parameter:
;	LX = Scale of X-axis
;	LY = Scale of Y-axis
;	LZ = Scale of Z-axis
;	AX = The angle of rotation about X axis
;	AZ = The angle of rotation about Z axis
; OUTPUTS:
;
; MODIFICATION HISTORY:
;       Zhang Yi
;	August, 1992
;-
	ON_ERROR,2
	s= SIZE(VZ)
	IF N_ELEMENTS(AX) LE 0 THEN AX=30
	IF N_ELEMENTS(AZ) LE 0 THEN AZ=30	
	IF N_ELEMENTS(XTIT) LE 0 THEN !X.TITLE='' ELSE !X.TITLE=XTIT	
	IF N_ELEMENTS(YTIT) LE 0 THEN !Y.TITLE='' ELSE !Y.TITLE=YTIT	
	IF N_ELEMENTS(ZTIT) LE 0 THEN !Z.TITLE='' ELSE !Z.TITLE=ZTIT	

	
	SURFR,AX=AX,AZ=AZ
	SURFACE,VZ,/save,/nodata,/xst,/yst,/zst,/t3d

        IF N_PARAMS(0) LT 5 THEN BEGIN
         X = LINDGEN(S(1),S(2))
	 Y=FIX( X/s(1) )  & X=FIX( X MOD S(1) )
        ENDIF
	X=ROTATE(X,4)

	IF N_ELEMENTS(LX) LE 0 THEN LX = 1.0
	IF N_ELEMENTS(LY) LE 0 THEN LY = 1.0
	IF N_ELEMENTS(LZ) LE 0 THEN LZ = 1.0
	IF N_ELEMENTS(AX) LE 0 THEN AX = 30.
	IF N_ELEMENTS(AZ) LE 0 THEN AZ = 30.

	X1	= VX * LX
	Y1	= VY * LY
	Z1	= VZ * LZ


	r	= .3
	az	= z1*(1-r)

	ANG	= 22.5 * !dtor
	st	= r * SIN(ANG)
	ct	= r * COS(ANG)

	ax1	= ct * x1 - st * y1
	ax2	= ct * x1 + st * y1
	ay1	= ct * y1 + st * x1
	ay2	= ct * y1 - st * x1

	x1	= x + x1
	y1	= y + y1
	
	FOR i	= 0,S(4)-1 DO $
	  PLOTS,[x(i),x1(i),x1(i)-ax1(i),x1(i),x1(i)-ax2(i)],$
		[y(i),y1(i),y1(i)-ay1(i),y1(i),y1(i)-ay2(i)],$
		[0,z1(i),az(i),z1(i),az(i)],/t3d

END

