Pro LAMBDAMETER,L_WID,D_IN,CW,Smooth=Smooth,iter=iter
;+
; NAME:
;	LAMBDAMETER
;
; PURPOSE:
;	Calculate the line shift of line profiles by so-called
;	Lambdameter method. Absorbtion line is assumed. 
;
; CALLING SEQUENCE:
;	LAMBDAMETER, L_WID, D_IN [, CW, /Smooth, Iter=]
;
; INPUTS:
;	L_WID:  The width of lambdameter from which point in the profile
;		where the full width is L_WID you measure the shift 	
;	D_IN:	Delta in intensity
;
; KEYWORD:
;	Smooth:	If this keyword is set, the input array will
;		be smoothed with a boxcar average of 3 in the 
;		Nth dimension.
;	Iter:	Number of iteration, the default is 3
;	
; OUTPUTS:
;	CW:	Wavelength position of the averaged line profile, which
;		is the reference for the wavelength offsets. 
;	See "LAMB" in section "COMMON BLOCKS"
;
; COMMON BLOCKS:
; DATA	In:	Input 1-3D array
;	LAMB:	Output, with the size of the Nth dimension
;		of 3. The terms of the Nth dimension correspond to
;	    1:	      Intensity of the chord    
;	    2:	      Wavelength position in the blue wing 
;	    3:	      Wavelength position in the red wing
;
; EXAMPLE:
;	The commonds below show an typical use of LAMBDAMETER
;
;	   COMMON DATA,IM,LAMB
;	   IM=READFITS('SPEC')  ; Assuming "SPEC" is a disc file which 
;		  		  consists of a spectral image with the
;				  spectral dispersion in Y-direction.
;	   LAMBDAMETER,5,1	;  Calcualate line shifts with a L_WID of
;				  5 points an intensity increment of 1. 
;	Now if you want to have the line shift, 
;	   V = (LAMB(*,2) + LAMB(*,1))/2
;	or the line depth,
;	   I = BISC(*,0)
;	or check the accuracy of calculation
;	V = LAMB(*,2) - LAMB(*,1)
;
; MODIFICATION HISTORY:
;       Z. Yi, 1993
;-
;
	common Data,In,lamb
	On_error,2

	S=SIZE(In)
	IF KEYWORD_SET(ITER) THEN ITER=ITER-1 ELSE ITER=2

CASE S(0) OF
1: BEGIN
	if keyword_set(smooth) then In=CONVOL_1D(IN,3,DIM=S(0))
	dum = min(in)                                ; find minimum position
	CW = !c	

	q1=iN(CW-1)+iN(CW+1)-2.*iN(CW)          ; polynimial interpolation
	q2=(iN(CW-1)-iN(CW+1))/2.
	dv=q2/q1
        mi=IN(CW)-q2*Dv+q1*Dv*Dv/2.             ; Bottom of line profile 
	
	lamb=intarr(3)		  ; output  
	lamb(0)=fix(100*mi)		  ; line bottom
;---------------------------------------------------------------------------
        mi=mi+D_IN		;level 
	LOOP=0
LAB1:
	REPEAT BEGIN		; 1st iteration
	   iL = 2
	   for k=2,CW+1 do begin
	      	  q=(iN(k) ge mi)*k		&	  iL=iL >q <CW 
	   endfor
           q=0
	   ind1=iL  & 	ind2=ind1+1
	   iL=iL+(mi-in(ind1))/(in(ind2)-in(ind1))-CW

	   iR=CW-1                    ; at right           
	   for k=CW-1,s(1)-2 do begin
	 	  q=(iN(k) le mi)*k		&	  iR=iR > q >CW
	   endfor
           q=0

       	   ind1=iR   &	ind2=ind1+1

	   iR=iR+(mi-in(ind1))/(in(ind2)-in(ind1))-CW
	   P=WHERE(iR-iL LT L_WID,M)

	   IF M LE 0 THEN GOTO,LAB11
	   MI=MI+D_IN

	 ENDREP UNTIL M LE 0
lab11:
	IF LOOP LE ITER THEN BEGIN
	  MI=MI-D_IN & D_IN=D_IN/4.
	  LOOP=LOOP+1
	  GOTO,LAB1
	ENDIF
;------------------------------------------------------------------------
	iL=2
	MI=MI-D_IN/2
	   for k=2,CW+1 do begin
	      	  q=(iN(k) ge mi)*k		&	  iL=iL >q <CW 
	   endfor
           q=0
	   ind1=iL  & 	ind2=ind1+1
	   iL=iL+(mi-in(ind1))/(in(ind2)-in(ind1))-CW

	   iR=CW-1                    ; at right           
	   for k=CW-1,s(1)-2 do begin
	 	  q=(iN(k) le mi)*k		&	  iR=iR > q >CW
	   endfor
           q=0
       	   ind1=iR   &	ind2=ind1+1
	   iR=iR+(mi-in(ind1))/(in(ind2)-in(ind1))-CW
	lamb=fltarr(3)
	lamb(0)=mi & lamb(1)=il & lamb(2)=ir
        q1=0 & q2=0 & mi=0 & iR=0 & ind=0 & lxy=0 
END


2: BEGIN
  	dx=s(1)
	if keyword_set(smooth) then In=CONVOL_1D(IN,3,DIM=S(0))
	dum=avg(in,0)  &  dum=min(dum)  & CW=!C

	ind=0                               ; find minimum position
	w1=cw-30>0 & w2=cw+30<(s(2)-1)
	for k=w1,w2 do ind=ind > (iN(*,k) ge iN(*,k+1))*k
	ind=ind+1	

	xy=dx	
	lxy=lindgen(xy)   ; index of three points around minimum
	ind2=ind*xy + lxy	&        ind1=ind2-xy   & 	ind3=ind2+xy

	q1=iN(ind1)+iN(ind3)-2.*iN(ind2)          ; polynimial interpolation
	q2=(iN(ind1)-iN(ind3))/2.
	dv=q2/q1
        mi=IN(ind2)-q2*Dv+q1*Dv*Dv/2.             ; Bottom of line profile 
	q1=0 & q2=0 & ind1=0 & ind2=0 & ind3=0 & dv=0 
;---------------------------------------------------------------------------
        mi=mi+D_IN		;level 
	LOOP=0
LAB2:
	REPEAT BEGIN		; 1st iteration
	   iL = 2
	   for k=2,CW+1 do begin
	      	  q=(iN(*,k) ge mi)*k		&	  iL=iL >q <ind 
	   endfor
           q=0
	   ind1=iL*xy+lxy  & 	ind2=ind1+xy
	   iL=iL+(mi-in(ind1))/(in(ind2)-in(ind1))-CW

	   iR=CW-1                    ; at right           
	   for k=CW-1,s(2)-2 do begin
	 	  q=(iN(*,k) le mi)*k		&	  iR=iR > q >ind
	   endfor
           q=0
       	   ind1=iR*xy+lxy   &	ind2=ind1+xy
	   iR=iR+(mi-in(ind1))/(in(ind2)-in(ind1))-CW

	   P=WHERE(iR-iL LT L_WID,M)
	   IF M LE 0 THEN GOTO,LAB21
	   MI(P)=MI(P)+D_IN
print,D_IN,m
	 ENDREP UNTIL M LE 2
lab21:
	IF LOOP LE ITER THEN BEGIN
	  MI=MI-D_IN & D_IN=D_IN/4.
	  LOOP=LOOP+1
	  GOTO,LAB2
	ENDIF
;------------------------------------------------------------------------
	iL=2
	MI=MI-D_IN/2
	   for k=2,CW+1 do begin
	      	  q=(iN(*,k) ge mi)*k		&	  iL=iL >q <ind 
	   endfor
           q=0
	   ind1=iL*xy+lxy  & 	ind2=ind1+xy
	   iL=iL+(mi-in(ind1))/(in(ind2)-in(ind1))-CW

	   iR=CW-1                    ; at right           
	   for k=CW-1,s(2)-2 do begin
	 	  q=(iN(*,k) le mi)*k		&	  iR=iR > q >ind
	   endfor
           q=0
       	   ind1=iR*xy+lxy   &	ind2=ind1+xy
	   iR=iR+(mi-in(ind1))/(in(ind2)-in(ind1))-CW
	lamb=fltarr(dx,3)
	lamb(0,0)=mi & lamb(0,1)=il & lamb(0,2)=ir
        q1=0 & q2=0 & mi=0 & iR=0 & ind=0 & lxy=0 
END

3: BEGIN
        dx=s(1) & dy=s(2)
        if keyword_set(smooth) then In=CONVOL_1D(IN,3,DIM=S(0))
        dum=avg(in,0)   &       dum=avg(dum,0)
        dum=min(dum)    &       CW=!C
        ind=0                               ; find minimum position
	w1=cw-30>0 & w2=cw+30<(s(3)-1)
        for k=w1,w2 do ind=ind > (iN(*,*,k) ge iN(*,*,k+1))*k
        ind=ind+1

        xy=long(dx)*dy
        lxy=lindgen(xy)   ; index of three points around minimum
        ind2=ind*xy + lxy       &        ind1=ind2-xy   &       ind3=ind2+xy

        q1=iN(ind1)+iN(ind3)-2.*iN(ind2)          ; polynimial interpolation
        q2=(iN(ind1)-iN(ind3))/2.
        dv=q2/q1
        mi=IN(ind2)-q2*Dv+q1*Dv*Dv/2.             ; Bottom of line profile
	q1=0 & q2=0 & ind1=0 & ind2=0 & ind3=0 & dv=0 

;---------------------------------------------------------------------------
        mi=mi+D_IN		;level 
	loop=0   
lab3:
	REPEAT BEGIN		; 1st iteration
	   iL = 2
	   for k=2,CW+1 do begin
	      	  q=(iN(*,*,k) ge mi)*k		&	  iL=iL >q <ind 
	   endfor
           q=0
	   ind1=iL*xy+lxy  & 	ind2=ind1+xy

	   iL=iL+(mi-in(ind1))/(in(ind2)-in(ind1))-CW


	   iR=CW-1                    ; at right           
	   for k=CW-1,s(3)-2 do begin
	 	  q=(iN(*,*,k) le mi)*k		&	  iR=iR > q >ind
	   endfor
           q=0
       	   ind1=iR*xy+lxy   &	ind2=ind1+xy
	   iR=iR+(mi-in(ind1))/(in(ind2)-in(ind1))-CW

	   P=WHERE(iR-iL LT L_WID,M)
	   IF M LE 2 THEN GOTO,LAB31
	   MI(P)=MI(P)+D_IN
print,m,'   ',d_IN

	 ENDREP UNTIL M LE 0
lab31:
	IF LOOP LE ITER THEN BEGIN
	  MI=MI-D_IN & D_IN=D_IN/4.
	  LOOP=LOOP+1
	  GOTO,LAB3
	ENDIF
; 
	MI=MI-D_IN/2
	iL=2
	   for k=2,CW+1 do begin
	      	  q=(iN(*,*,k) ge mi)*k		&	  iL=iL >q <ind 
	   endfor
           q=0
	   ind1=iL*xy+lxy  & 	ind2=ind1+xy
	   iL=iL+(mi-in(ind1))/(in(ind2)-in(ind1))-CW

	   iR=CW-1                    ; at right           
	   for k=CW-1,s(3)-2 do begin
	 	  q=(iN(*,*,k) le mi)*k		&	  iR=iR > q >ind
	   endfor
           q=0
       	   ind1=iR*xy+lxy   &	ind2=ind1+xy
	   iR=iR+(mi-in(ind1))/(in(ind2)-in(ind1))-CW
	lamb=fltarr(dx,dy,3)
	lamb(0,0,0)=mi & lamb(0,0,1)=il & lamb(0,0,2)=ir
        q1=0 & q2=0 & mi=0 & iR=0 & ind=0 & lxy=0 
END
ENDCASE

END








