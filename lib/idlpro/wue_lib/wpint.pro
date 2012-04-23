;+
; NAME:
;	WPINT
; PURPOSE:
;	WEIGHTEND PARABOLIC INTERPOLATION
; CATEGORY:
;	INTERPOLATION - E1
; CALLING SEQUENCE:
;	FNEW = WPINT(XOLD,FOLD,XNEW [,/NC, XSTART=XSTART] )
; INPUTS:
;	XOLD = OLD ABCISSA VECTOR
;	FOLD = OLD ORDINATE VECTOR CORRESPONDING TO XOLD
;	XNEW = NEW ABCISSA VECTOR
; OUTPUTS:
;	FNEW = NEW ORDINATE VECTOR CORRESPONDING TO XNEW
; KEYWORDS:
;	NC : UNCOMFORTABLE FAST VERSION
;	     INTERPOLATS GIVEN FUNCTION WITHOUT ANY CORRECTIONS OF LENGHT,
;	     TYPE AND ORDER OF XOLD AND XNEW. CONDITIONS:
;	     MIN(XOLD) < MIN(XNEW)
;	     MAX(XOLD) > MAX(XNEW)
;	     XOLD(I) < XNEW(I-XSTART) < XOLD(I+1) FOR EVERY XOLD(I) WITH
;	     XSTART .le. I .lt. XSTART+N_ELEMENTS(XNEW)
;	XSTART : NECESSARY FOR KEYWORD NC, XSTART = MAXPOSITION(XOLD<XNEW)
; SIDE EFFECTS:
;	IF NECESSARY, THE RANGE OF XOLD IS EXTENTED TO THE RANGE OF XNEW
;	AND THE CORRESPONDING VALUES OF FOLD ARE INTERPOLATED LINEAR.
;	THE TYPE OF XNEW IS CHANGED TO DOUBLE IF IT IS NOT THE SAME AS XOLD.
; HISTORY:
;	IDEA BY KURUCZ
;	IDL-IMPLEMENTATION BY ELMAR KOSSACK, FEBRUARY 1992
;	LAST MODIFICATION: FEB. 20. 1992
;-
function wpint,xold,fold,xnew,nc=nc,xstart=xstart
on_error,2
if keyword_set(nc) then goto, pktnc
fo=fold
xo=xold
no=n_elements(xo)
so=size(xo)
sn=size(xnew)
;
; correction of the type of xold and xnew
;
if sn(2) ne so(2) then begin
	print,'*                   WARNING FROM WPINT:                  *'
	print,'* You should better use the same type for xold and xnew! *'
	xo=double(xo)
	xnew=double(xnew)
	endif
;
; correction of the order of xo
;
xf=xo-shift(xo,1)
ind=where(xf(1:no-1) lt 0,ip)
if ip gt 0 then begin
	xf=xo
	ff=fo
	sx=sort(xo)
	for i=0,no-1 do begin
		xo(i)=xf(sx(i))
		fo(i)=ff(sx(i))
		endfor
	endif
;
; if nessecary, correction if range of xo smaller then range of xnew
;
xnewmin=min(xnew,mp)
if xo(0) gt xnewmin then begin
	xf=fltarr(no+1)
	xf(1:no)=xo
	xf(0)=xnewmin
	xo=xf
	ff=fltarr(no+1)
	ff(1:no)=fo
	ff(0)=(fo(0)-fo(1))/(xo(1)-xo(2))*(xo(0)-xo(1))+fo(0)
	fo=ff
	no=no+1
	endif
xnewmax=max(xnew,mp)
if xo(no-1) lt xnewmax then begin
	xf=fltarr(no+1)
	xf(0:no-1)=xo
	xf(no)=xnewmax
	xo=xf
	ff=fltarr(no+1)
	ff(0:no-1)=fo
	ff(no)=(fo(no-1)-fo(no-2))/(xo(no-1)-xo(no-2))*(xo(no)-xo(no-1))+fo(no-1)
	fo=ff
	no=no+1
	endif
;
; Calculation of parabolic Functions
;
xf=shift(xo,-1)
ff=shift(fo,-1)
xb=shift(xo,1)
fb=shift(fo,1)
d=(fo-fb)/(xo-xb)
c=ff/((xf-xo)*(xf-xb))+(fb/(xf-xb)-fo/(xf-xo))/(xo-xb)
b=d-(xo+xb)*c
a=fb-xb*d+xo*xb*c
cs=abs(shift(c,-1))
;
; Weighting Function
;
ind=where(cs eq 0,ip)
if ip gt 0 then cs(ind)=1
w=cs/(cs+abs(c))
if ip gt 0 then w(ind)=0
w(0)=0
w(no-1)=1
a=shift(a,-1)+w*(a-shift(a,-1))
b=shift(b,-1)+w*(b-shift(b,-1))
c=shift(c,-1)+w*(c-shift(c,-1))
;
; Calculation of fnew
;
; nnew=n_elements(xnew)
; fnew=xnew
; xf=shift(xo,-1)
; for i=0,nnew-1 do begin
; 	ind=where(xnew(i) ge xo and xnew(i) le xf)
; 	fnew(i)=a(ind(0))+(b(ind(0))+c(ind(0))*xnew(i))*xnew(i)
; 	endfor
tabinv,xo,xnew,ind
ind=fix(ind)
fnew=a(ind)+(b(ind)+c(ind)*xnew)*xnew
;
return,fnew
;
pktnc:
;
; Calculation of parabolic Functions
;
nnew=n_elements(xnew)
fo=fold(xstart:xstart+nnew)
xo=xold(xstart:xstart+nnew)
xf=shift(xo,-1)
ff=shift(fo,-1)
xb=shift(xo,1)
fb=shift(fo,1)
d=(fo-fb)/(xo-xb)
c=ff/((xf-xo)*(xf-xb))+(fb/(xf-xb)-fo/(xf-xo))/(xo-xb)
b=d-(xo+xb)*c
a=fb-xb*d+xo*xb*c
cs=abs(shift(c,-1))
;
; Weighting Function
;
ind=where(cs eq 0,ip)
if ip gt 0 then for i=0,ip-1 do cs(ind(i))=1
w=cs/(cs+abs(c))
if ip gt 0 then for i=0,ip-1 do w(ind(i))=0
w(0)=0
w(nnew)=1
a=shift(a,-1)+w*(a-shift(a,-1))
b=shift(b,-1)+w*(b-shift(b,-1))
c=shift(c,-1)+w*(c-shift(c,-1))
;
; Calculation of fnew
;
fnew=a(0:nnew-1)+(b(0:nnew-1)+c(0:nnew-1)*xnew)*xnew
;
return,fnew
;
end
