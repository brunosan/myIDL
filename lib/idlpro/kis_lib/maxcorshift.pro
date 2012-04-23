;+
; NAME:
;	MAXCORSHIFT
; PURPOSE:
;	returns 1-dim shift between 2 vectors wich gives maximal correlation
;*CATEGORY:            @CAT-#  4 16  0@
;	Correlation Analysis , Image Processing , Array Manipulation Routines
; CALLING SEQUENCE:
;	d=MAXCORSHIFT(a,b [,istart,iend] [,SIGNIF=sigma] [,SHIFT=m] [,FIT=k])
; INPUTS:
;	a, b = vectors to be compared;
; OPTIONAL INPUT PARAMETER:
;	istart, iend : compare vectors for index-range istart to iend only
;	           (default: istart=0, iend=max. indes of shorter vector);
;	SHIFT=m : shift vector b relat. to a from -m to +m (default =30);
;	FIT=k : take maximum of cubic fit of correl.-fct from imax-k3 to
;	        imax+k3 (k3=max(k,3)); 
;		if not specified or k < 1 : take maximum of correl-fct itself.
; OUTPUTS:
;	d : (fractional) shift where a(i+d) is maximal correlated with b(i).
; OPTIONAL OUTPUTS:
;	SIGNIF=sigma: vector (size=4)
;	            (0) = max. value of correlation coef. found,
;	            (1), (2) = correl.-coef. at 1st, last shift
;	            (3) = sigma of cubic fit to correl.-fct ( == 0 if no fit).
; SIDE EFFECTS:
;	d and sigma will be set  -999 on error.
; RESTRICTIONS:
;	
; PROCEDURE:
;	1. Subtraction of linear trends in vectors a, b (using POLY_FIT of
;	   IDL-USERLIB);
;	2. 1-dim correlation coefficients a <-> (b, shifted by -m ... +m)
;	   (using KIS_LIB function COR);
;	3. Maximum of coefs(k) (either direct or max. of fit-cube).
; MODIFICATION HISTORY:
;	nlte, 1989-11-29  PROCEDURE Y_SHIFT created
;       nlte, 1990-04-23  SHIFT, FIT as optional keyword-arguments 
;	nlte, 1991-11-14  FUNCTION MAXCORSHIFT, iy1,2 & sigma optional
;	nlte, 1993-01-07  Description for FIT=k.
;-
FUNCTION MAXCORSHIFT,a,b,iy1,iy2,signif=signif,shift=mm,fit=kk
;
on_error,2
if n_params() lt 2 or n_params() gt 4 then begin s_err= $
  'usage: MAXCORSHIFT,a,b [,istart,iend] [,SIGNIF=sigma] [,SHIFT=m] [FIT=k]'
   goto,err
endif
;
sza=size(a) & szb=size(b)
if sza(0) ne 1 or szb(0) ne 1 then begin
   s_err='a,b must be 1-dim vectors'
   goto,err
endif
;
if keyword_set(mm) then m=mm else m=30 ; shift b relative to a from -m to +m
m=max([m,1]) 
if keyword_set(kk) then k=kk else k=0  ;fit correl.-fct from imax-k to
;				        imax+k (k=0:no fit, take maximum) 
if k gt 0 then k=max([k,3])
;
if n_params() lt 4 then iy2=min([sza(1),szb(1)])-1
if n_params() eq 2 then iy1=0
if iy2-iy1 lt m or iy1 lt 0 or iy2 gt min([sza(1),szb(1)])-1 then begin
   s_err='invalid boundaries '+string(format='(i0,",",i0)',iy1,iy2)
   goto,err
endif
;
; subtraction linear trend of sub-vectors:
n=iy2-iy1+1
x=-0.5*n+findgen(n)
p=poly_fit(x,a(iy1:iy2),1,pf) 
sa=a(iy1:iy2)-pf
p=poly_fit(x,b(iy1:iy2),1,pf) 
sb=b(iy1:iy2)-pf
; correlation:
c=cor(sa,sb,m)
if c(0) lt -999. then begin
   s_err='error in COR'
   goto,err
endif
; maximum of c:
cmx=max(c,imx)
signif=[cmx,c(0),c(2*m),0.]
if k lt 3 then dy=imx-m else begin
dy0=float(imx-m)
i1=max([0,imx-k])
i2=min([2*m,imx+k])
p=poly_fit(float(-m+i1)+findgen(i2-i1+1),c(i1:i2),3,pf,yband,sig)
signif(3)=sig
dy=-p(2)/(3.*p(3))
sq=sqrt(dy^2-p(1)/(3.*p(3)))
dy1=dy-sq
dy2=dy+sq
if abs(dy1-dy0) lt abs(dy2-dy0) then dy=dy1 else dy=dy2
endelse
;print,dy,signif
goto ,ret
err:print,'MAXCORSHIFT: '+s_err
dy=-999.
signif=replicate(-999.,4)
;
ret:return,dy
end
