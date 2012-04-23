Pro BISECTOR,Nlev,Delta,CW,Smooth=Smooth
;+
; NAME:
;	BISECTOR
;
; PURPOSE:
;	Calculate the bisector of a line profile or bisectors of
;	the Nth dimension of a N-dimensional array.
;
; CALLING SEQUENCE:
;	BISECTOR, Nlev, Delta [, /Smooth]
;
; INPUTS:
;	Nlev:	Number of bisector points
;	Delta:	Delta in intensity
;
; KEYWORD:
;	Smooth:	If this keyword is set, the input array will
;		be smoothed with a boxcar average of 3 in the 
;		Nth dimension.
;	
; OUTPUTS:
;	CW:	Wavelength position of the averaged line profile, which
;		is the reference for the wavelength offsets of "BISC". 
;	See "BISC" in section "COMMON BLOCKS"
;
; COMMON BLOCKS:
; DATA	In:	Input 1-3D array
;	Bisc:	Output, with the size of the Nth dimension
;		of 2*Nlev. The terms of the Nth dimension correspond
;	     1:	      Line bottom intensity   
;	     Nlev:    Offsets of line bottom
;	     Nlev-1 to 2: Wavelength positions on blue wings corresponding
;		      to the 2nd to Nth level.   
;	     Nlev+1 to 2Nlev-1: Wavelength positions on red wings corresponding
;		      to the 2nd to Nth level.   
;
; EXAMPLE:
;	The commonds below show an typical use of BISECTOR
;
;	   COMMON DATA,IM,BISC
;	   IM=READFITS('SPEC')  ; Assuming "SPEC" is a disc file which 
;		  		  consists of a spectral image with the
;				  spectral dispersion in Y-direction.
;	   BISECTOR,5,2		;  Calcualate 5-level bisectors with a
;				  intensity increment of 2. 
;	Now if you want to have the bisector on the Ith level, 
;	   BI = BISC(*,NLEV+I) + BISC(*,NLEV-I)
;	or the line width,
;	   WI = BISC(*,NLEV+I) - BISC(*,NLEV-I)
;
; MODIFICATION HISTORY:
;       Z. Yi, 1991
;-
;
	common Data,In,Bisc
	On_error,2

	S=SIZE(In)

CASE S(0) OF
1: BEGIN
	if keyword_set(smooth) then In=CONVOL_1D(IN,3,DIM=S(0))
	dum = min(in)                                ; find minimum position
	CW = !c	

	q1=iN(CW-1)+iN(CW+1)-2.*iN(CW)          ; polynimial interpolation
	q2=(iN(CW-1)-iN(CW+1))/2.
	dv=q2/q1
        mi=IN(CW)-q2*Dv+q1*Dv*Dv/2.             ; Bottom of line profile 
	
	Bisc=intarr(2*nlev)		  ; output  
        Bisc(nlev)=nfix( 100.*dv )   	  ; offset 
	Bisc(0)=fix(100*mi)		  ; line bottom
;---------------------------------------------------------------------------
	 for L=0,nlev-2 do begin
	   iL=2                          ; find position mi+2+2*l at left
           mi=mi+Delta		;level 

	   dum = min( abs(in(2:CW+1)-mi) ) & iL=!c+2

	   if in(iL) gt mi then iL=iL+(mi-in(iL))/(in(iL+1)-in(iL)) else $
		iL=iL+(mi-in(iL-1))/(in(iL)-in(iL-1))
	   Bisc(nlev-L-1)=fix(100.*(iL-CW))        

	   dum = min( abs(in(CW-1:s(1)-2)-mi) ) & iR=!c+CW-1

	   if in(iR) lt mi then iR=iR+(mi-in(iR))/(in(iR+1)-in(iR)) else $
		iR=iR+(mi-in(iR-1))/(in(iR)-in(iR-1))
	   Bisc(nlev+L+1)=fix(100.*(iR-CW)) 
	  endfor       
END

2: BEGIN
  	dx=s(1)
	if keyword_set(smooth) then In=CONVOL_1D(IN,3,DIM=S(0))
	dum=avg(in,0)  &  dum=min(dum)  & CW=!C

	ind=0                               ; find minimum position
	for k=CW-10,CW+10 do ind=ind > (iN(*,k) ge iN(*,k+1))*k
	ind=ind+1	

	xy=dx	
	lxy=lindgen(xy)   ; index of three points around minimum
	ind2=ind*xy + lxy	&        ind1=ind2-xy   & 	ind3=ind2+xy

	q1=iN(ind1)+iN(ind3)-2.*iN(ind2)          ; polynimial interpolation
	q2=(iN(ind1)-iN(ind3))/2.
	dv=q2/q1
;	dv=(iN(ind3)-iN(ind1))/(1.*iN(ind1)+iN(ind2)+iN(ind3))  ; offsets in AA
        mi=IN(ind2)-q2*Dv+q1*Dv*Dv/2.             ; Bottom of line profile 
	
	Bisc=intarr(dx,2*nlev)		  ; output  
        Bisc(0,nlev)=nfix( 100.*(dv+ind-CW) )   	  ; offset 
	Bisc(0,0)=fix(100*mi)		  ; line bottom
;---------------------------------------------------------------------------
	q1=0 & q2=0 & ind1=0 & ind2=0 & ind3=0 & dv=0 
	
	 for L=0,nlev-2 do begin
	   iL=2                          ; find position mi+2+2*l at left
           mi=mi+Delta		;level 

	   for k=2,CW+1 do begin
	      	  q=(iN(*,k) ge mi)*k		&	  iL=iL >q <ind 
	   endfor
           q=0
	   ind1=iL*xy+lxy  & 	ind2=ind1+xy
	   iL=iL+(mi-in(ind1))/(in(ind2)-in(ind1))

	   ind1=0 & ind2=0
	   Bisc(0,nlev-L-1)=fix(100.*(iL-CW))        
	   iL=0 & q1=0 & q2=0  

	   iR=CW-1                    ; at right           
	   for k=CW-1,s(2)-2 do begin
	 	  q=(iN(*,k) le mi)*k		&	  iR=iR > q >ind
	   endfor
           q=0
       	   ind1=iR*xy+lxy   &	ind2=ind1+xy

	   iR=iR+(mi-in(ind1))/(in(ind2)-in(ind1))
	   ind1=0 & ind2=0
	   Bisc(0,nlev+L+1)=fix(100*(iR-CW))        
	 endfor

        q1=0 & q2=0 & mi=0 & iR=0 & ind=0 & lxy=0  &  in=0
END

3: BEGIN
  	dx=s(1) & dy=s(2)
	if keyword_set(smooth) then In=CONVOL_1D(IN,3,DIM=S(0))
	dum=avg(in,0) 	& 	dum=avg(dum,0)
	dum=min(dum)	& 	CW=!C
	ind=0                               ; find minimum position
	for k=CW-5,CW+5 do ind=ind > (iN(*,*,k) ge iN(*,*,k+1))*k
	ind=ind+1	

	xy=long(dx)*dy	
	lxy=lindgen(xy)   ; index of three points around minimum
	ind2=ind*xy + lxy	&        ind1=ind2-xy   & 	ind3=ind2+xy

	q1=iN(ind1)+iN(ind3)-2.*iN(ind2)          ; polynimial interpolation
	q2=(iN(ind1)-iN(ind3))/2.
	dv=q2/q1
;	dv=(iN(ind3)-iN(ind1))/(1.*iN(ind1)+iN(ind2)+iN(ind3))  ; offsets in AA
        mi=IN(ind2)-q2*Dv+q1*Dv*Dv/2.             ; Bottom of line profile 
	
	Bisc=intarr(dx,dy,2*nlev)		  ; output  
        Bisc(0,0,nlev)=nfix( 100.*(dv+ind-CW) )   	  ; offset 
	Bisc(0,0,0)=fix(100*mi)		  ; line bottom

;---------------------------------------------------------------------------
	q1=0 & q2=0 & ind1=0 & ind2=0 & ind3=0 & dv=0 
	
	 for L=0,nlev-2 do begin
	   iL=2                          ; find position mi+2+2*l at left
           mi=mi+Delta		;level 

	   for k=2,CW+1 do begin
	      	  q=(iN(*,*,k) ge mi)*k		&	  iL=iL >q <ind 
	   endfor
           q=0
	   ind1=iL*xy+lxy  & 	ind2=ind1+xy
	   iL=iL+(mi-in(ind1))/(in(ind2)-in(ind1))

	   ind1=0 & ind2=0
	   Bisc(0,0,nlev-L-1)=fix(100.*(iL-CW))        
	   iL=0 & q1=0 & q2=0  

	   iR=s(3)/2-1                    ; at right           
	   for k=CW-1,s(3)-2 do begin
	 	  q=(iN(*,*,k) le mi)*k		&	  iR=iR > q >ind
	   endfor
           q=0
       	   ind1=iR*xy+lxy   &	ind2=ind1+xy

	   iR=iR+(mi-in(ind1))/(in(ind2)-in(ind1))
	   ind1=0 & ind2=0
	   Bisc(0,0,nlev+L+1)=fix(100*(iR-CW))        
	 endfor

        q1=0 & q2=0 & mi=0 & iR=0 & ind=0 & lxy=0  &  in=0
END
ENDCASE

END





