PRO IMAGE_DISPLACE,aa,bb,xmax,ymax,$
                   MAXCC=ccmax,CC=cc,SHIFT=mm,THRESH=thresh,FLAG=flag
;
;+
; NAME:
;    IMAGE_DISPLACE   
; PURPOSE:
;	Determines the (fractional) offsets between two images by finding the
;	2-dim shift which gives maximal correlation.
;*CATEGORY:            @CAT-#  4 16@
;	Correlation Analysis , Image Processing
; CALLING SEQUENCE:
;	IMAGE_DISPLACE,img1,img2,xoff,yoff [,SHIFT=mm] [,THRESH=thresh] ...
;        ... [,MAXCC=ccmax] [,CC=cc] [,FLAG=flag]
; INPUTS:
;	img1 , img2 : the two images to be compared. Must be of same size.
; OPTIONAL INPUT PARAMETER:
;	SHIFT = max_shiftxy or SHIFT = [max_xshift, max_yshift] : 
;               the images will be shifted from -<max_shift> to +<max_shift>
;               in steps of 1 in both dimensions before computing the correla-
;               tion coefficient. Maximal shift can be specified either to be
;               identical or different for the two dimensions. 
;               Default: shift range 1/10 of size in both dimensions, at least
;                        [3,3].
;       THRESH = thresh : Image offset will be determined only if the maximal
;               correlation is >= <thresh> (0 < thresh < 1); if the maximal
;               correlation is less, zero offsets will be returned.
;               Default: thresh=0.2 .
; OUTPUTS:
;	xoff, yoff: the offsets in both dimensions which gives the maximal
;              correlation between the images. The offsets are fractional 
;              pixels. Shifting img2 by xoff,yoff gives the best correlation 
;              with img1. An object in img1 with coordinates (x1,y1) will be
;              located in img2 at (x1-xoff , y1-yoff). 
;              If no well defined maximum of the correlation matrix could be
;              determined, xoff=yoff=0 will be returned.
; OPTIONAL OUTPUTS:
;	MAXCC = maxcc : the maximal correlation within the shift range.
;       CC = cc : the correlation-matrix. The size of array cc is 
;                 [2*<max_xshift>+1 , 2*<max_yshift>+1]
;       FLAG = flag : indicator for the quality of result:
;            = -2 : formal errors, no results (xoff,yoff =0 returned);
;            = -1 : maxcc < thresh, no results (xoff,yoff =0 returned);
;            =  1 : correlation matrix has a well defined maximum.
;            >  1 : the "center-of-gravity" of the correlation matrix is more
;                   than 1.5 away from the location of max(cc); 
;                   if flag >= 2.5, xoff,yoff are derived from the location
;                   of the maximum of cc nearest to (0,0)-shift.
; COMMON BLOCKS:
;	none
; SIDE EFFECTS:
;	
; RESTRICTIONS:
;	
; PROCEDURE:
;	Calls CORREL_IMAGES (NASA-lib) to compute the 2-dim. correlation 
;       matrix for a range of image shifts (in both image dimensions) and
;       looks for the maximum in cc; in case that cc has more than one 
;       maximum, the one nearest to zero shift is token. The connected elements
;       of cc around this maximum with correlation near max(cc) are used
;       to compute the "center-of-gravity" and the corresponding fractional 
;       shift will be returned.
; MODIFICATION HISTORY:
;	nlte, 1999-03-17 
;       nlte, 2000-06-23 new minimum boundary for search2d 
;       nlte, 2000-09-07 new minimum boundary for search2d: cc-values >= 
;                        values at cc-margin to avoid truncation effects.
;       nlte, 2001-05-08 make sure that minimum boundary < maximum.
;       nlte, 2003-08-26 center-of-gravity code: make use of "dimension" in
;                        TOTAL; 
;                        maxs2 < 0.975*ccmax for c-o-g computation 
;                        (before: maxs2 < 0.95*ccmax).
;                             
;-
on_error,2
;
flag=-2
sza=size(aa) & szb=size(bb)
if sza(0) ne 2 or szb(0) ne 2 then message,$
   'first two args must be 2-dim arrays.'
if sza(1) ne szb(1) or sza(2) ne szb(2) then message,$
   'first two args not of same size.'
;
case n_elements(mm) of
  0: m=[nint(float(sza(1))/10.)>3, nint(float(sza(2))/10.)>3]
  1: m=[mm,mm]
  2: m=mm
  else: message,'SHIFT parameter must be scalar or 2-element vector.'
endcase
if n_elements(thresh) eq 0 then thresh=0.2  ; default minimum acceptable 
;                                             correlation coef.
;
;xsh=float(-m(0))+findgen(2*m(0)+1) & ysh=float(-m(1))+findgen(2*m(1)+1) 
cc=CORREL_IMAGES(aa,bb,xshift=m(0),yshift=m(1)) ; CORREL_IMAGES: NASA-lib
ccmax=MAX(cc) 
if ccmax lt thresh then begin
   xmax=0. & ymax=0. & flag=-1 & return ; no good
endif
WHERE2,cc eq ccmax,ixmx,iymx,nmx  ; WHERE2: KIS_LIB
if nmx lt 0 then begin
   xmax=0. & ymax=0. & flag=-1 & return ; (kann eigentlich nie passieren)
endif
nmx=nmx+1   ; WHERE2 returns <number of points found> -1
if nmx gt 1 then begin
   xsh=-float(m(0)+ixmx) & ysh=-float(m(1)+iymx)
   dd=sqrt(xsh^2+ysh^2) & ddmin=min(dd,iddmin)
   ixmx=ixmx(iddmin) & iymx=iymx(iddmin)  ; max cc nearest to zero shift
endif else begin
   ixmx=ixmx(0) & iymx=iymx(0)
endelse
;print,'ccmax= ',ccmax,' nmx= ',nmx,' ixymx =',ixmx,iymx
;
flag=1
;
; determine the fractional location of the correlation maximum:
i2cc=2*m(0) & j2cc=2*m(1)
s=[reform(cc((ixmx-2)>0,*)),reform(cc((ixmx+2)<i2cc,*)),$
   reform(cc(*,(iymx-2)>0)),reform(cc(*,(iymx+2)<j2cc))]
;ccmin=max([min(s),0.95*ccmax])
;ccmin=min([0.9*max(s),0.75*ccmax])
ccmin=min([max(s),0.85*ccmax])
s2=[reform(cc(*,0)),reform(cc(*,j2cc)),reform(cc(0,*)),reform(cc(i2cc,*))]
maxs2=max(s2)
;if maxs2 lt 0.95*ccmax then begin
if maxs2 lt 0.975*ccmax then begin
   ccmin=max([ccmin,maxs2])
   iimax=SEARCH2D(cc,ixmx,iymx,ccmin,ccmax) ; connected elements of cc
                                            ; around (ixmx,iymx) 
   ccsub=cc*0. & ccsub(iimax)=(cc(iimax)-ccmin)/(ccmax-ccmin)+0.5
   sw=total(ccsub)
;   xsh=0. & for i=0,2*m(0) do xsh=xsh+float(i)*total(ccsub(i,*))
   xsh=total(findgen(2*m(0)+1)*total(ccsub,2))
   xmax=xsh/sw-float(m(0))
;   ysh=0. & for j=0,2*m(1) do ysh=ysh+float(j)*total(ccsub(*,j))
   ysh=total(findgen(2*m(1)+1)*total(ccsub,1))
   ymax=ysh/sw-float(m(1))
   d=sqrt((float(ixmx-m(0))-xmax)^2+(float(iymx-m(1))-ymax)^2)
endif else d=max(m) > 2.51
;
if d gt 1.5 then flag=flag+nint(d-1.)
if d gt 2.5 then begin 
;  xmax,ymax seems not to be a good location, use the coordinates of max(cc):
   xmax=float(ixmx-m(0)) & ymax=float(iymx-m(1)) 
endif 
;
ccsub=0 & s=0 & s2=0 & iimax=0
;
end
