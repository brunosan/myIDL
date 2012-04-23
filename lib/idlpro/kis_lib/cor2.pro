FUNCTION cor2,a,b,m,pr=iprnt
;+
; NAME:
;	COR2
; PURPOSE:
;	Correlation of 2 2-dim arrays.
;*CATEGORY:            @CAT-#  4 16@
;	Correlation Analysis , Image Processing
; CALLING SEQUENCE:
;	c = COR2(a,b,m [,/PR])
; INPUTS:
;	a = 2-dim array containing "reference" image;
;	b = 2-dim varray containing tracing to be correlated with 
;	    reference;
;	m = integer-vector size=2: shift b relative to a by
;	    -m(0) to +m(0) positions in 1st dimension and
;	    -m(1) to +m(1)  positions in 2nd dimension.
;           (2*m(0)+1)*(2*m(1)+1) correlation coefficients will 
;	    be computed.
; OUTPUTS:
;	2-dim array of (2*m(0)+1)*(2*m(1)+1) correlation-
;	coefficients.
; OPTIONAL OUTPUTS:
;	If keyword /PR set:
;       Print output of correlation coef's together with sub-array
;	boundaries for input arrays a,b.
; SIDE EFFECTS:
;	error message if invalid arguments
; RESTRICTIONS:
;	Size of a may not be smaller than size of b.
; PROCEDURE:
;	Subsequent calls to IDL procedure CORRELATE.
; MODIFICATION HISTORY:
;	nlte, 1990-Oct-26
;-
if n_params() lt 3 then message,'usage: COR2,img1,img2,shift [,/PR]'
sza=size(a)
szb=size(b)
szm=size(m)
if sza(0) ne 2 then message,'1st argument not a 2-dim array'
if szb(0) ne 2 then message,'2nd argument not a 2-dim array'
if sza(1) lt szb(1) or sza(2) lt szb(2) then $
    message,'size(a)'+string(sza(1:2))+$
            ' must be ge size(b)'+string(szb(1:2))
if szm(0) ne 1 or szm(1) lt 2 then $
   message,'shift must be a vector of size 2'  
;
mx=abs(m(0))
my=abs(m(1))
c=fltarr(2*mx+1,2*my+1)
nxa=sza(1)-1
nxb=szb(1)-1
nya=sza(2)-1
nyb=szb(2)-1
;
for ky=-my,my do begin
  ja1=max([ky,0])
  ja2=min([nyb+ky,nya])
  jb1=max([-ky,0])
  jb2=jb1+ja2-ja1
  if keyword_set(iprnt) then print,ky,ja1,ja2,jb1,jb2,$
      format='("k_y=",I0," y-bound. image ",I0,":",I0," reference ",I0,":",I0)'
  for kx=-mx,mx do begin
      ia1=max([kx,0])
      ia2=min([nxb+kx,nxa])
      ib1=max([-kx,0])
      ib2=ib1+ia2-ia1
      c(kx+mx,ky+my)=correlate(a(ia1:ia2,ja1:ja2),b(ib1:ib2,jb1:jb2))
      if keyword_set(iprnt) then print,kx,ia1,ia2,ib1,ib2,c(kx+mx,ky+my),$
      format='("k_x=",I0," x-bound. image ",I0,":",I0," reference ",I0,":",I0," corr= ",E)'
   endfor
endfor
;
return,c
end
