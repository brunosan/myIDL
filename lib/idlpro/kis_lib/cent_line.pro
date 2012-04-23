PRO cent_line,img,xcent,intcent,rows=yvect,xrange=xrange,yrange=yrange, $
                  step=step,avry=width,nxfit=nxfit,degfit=degfit,wdir=wdir
;+
; NAME:
;       CENT_LINE
;  PURPOSE:
;  	 x-positions (wavelength-direction) and intensities of center of
;        ABSORPTION-LINE along slit positions ("y"-direction).
;*CATEGORY:            @CAT-# 31@
;       Spectral Analysis
; CALLING SEQUENCE:
;      CENT_LINE,img,xcent [,intcent] [,ROWS=yvect] [,WDIR=i]
;	       [,XRANGE=range] [,YRANGE=range] [,STEP=increment] [,AVRY=width] 
;	       [,NXFIT=nxfit] [,DEGFIT=degree]
; INPUTS:
;      IMG     = 1-dim tracing of absorption line 
;                or 2-dim image-array containing an absorption line.
; OPTIONAL INPUT PARAMETERS:
;      ROWS=yvect  = 1-dim integer vector containing indices of image-rows
;	         (direction "y" along slit) for which line -center and
;		 -intensity shall be determined;
;		 !!! Will be OVER-RULED by specifying YRANGE and/or STEP !
;		 !!! Must be a variable, NOT a constant!
;      WDIR= 1 or 2    the wavelength-direction ("x") is the 1st or 2nd
;		 dimension of array IMG; 
;		 default: WDIR=1 (WDIR=2 only meaningful if IMG is 
;  		 2-dimensional).
;      XRANGE=[start,end]  only data within specified index-range will be
;		       used along wavelength-(x)-dimension of IMG-array;
;		       0 <= start < end <= nx-1 (nx: size of IMG x-dir.);
;		       default: start=0, end=nx-1 .
;      YRANGE=[start,end]  only data within specified index-range will be
;			used along slit-(y)-dimension of IMG-array;
;			0 <= start < end <= ny-1 (ny: size of IMG y-dir.);
;			only meaningful if IMG is 2-dimensional;
;			!!! Specifying YRANGE will OVER-RULE any setting in
;			!!! optional input parameter Y !
;			Default: start=0, end=ny-1 .
;      STEP=increment   profile tracings will be taken at equidistant 
;		        steps along slit-(y)-positions with increment as
;		        specified; only meaningful if IMG is 2-dimensional;
;			!!! Specifying STEP will OVER-RULE any setting in
;			!!! optional input parameter Y !
;		        Default (if IMG is 2-dim): increment=5.
;      AVRY=width      profile tracing at slit-(y)-position y will be 
;		       obtained by averaging from y-width to y+width;
;		       only meaningful if IMG is 2-dimensional;	
;		       default (if IMG is 2-dim): width=4.
;      NXFIT=nx	       use nx points around "approximate" line center to fit
;		       a polynom to determine "accurate" line center position;
;		       default: all points where depression of smoothed
;		       line profile is > 4/5 of maximal depression (at least
;		       11 points).
;      DEGFIT=degree   degree of polynom for fitting profile around line- 
;		       center (recommended to be even);
;		       default: degree = 2).      
;
; OUTPUTS:
;      XCENT   = real vector of x-positions (fractional indices) of line center
;                along y-direction (= position of minimum of fit-polynom); 
;                if, for the k-th y-position, the fitted polynom has no minimum
;		 within it's fit-intervall, xcent(k) = -1.
; OPTIONAL OUTPUTS:
;      INTCENT = real vector of line center intensities along y-direction 
;	         (= minimum of fit-polynom); intcent(k) = -1. if no minimum
;		 was found for the k-th y-position.
;      ROWS=yvect  = integer vector of y-positions (integral indices of image 
;	         columns) at which profile tracings have been obtained.
;
;      If IMG is a 1-dim tracing, XCENT, INTCENT will be scalars and Y = 0 .
;
; COMMON BLOCKS:
;       none
; RESTRICTIONS:
;       IMG should store a well defined absorption line within the specified
;	x-range (no blends with deeper depression).
; PROCEDURE:
;       If IMG is 2-dimensional, at each of requested slit positions yvect(k)
;       (k=0,1,...) a line profile will be obtained by averaging from
;	yvect(k)-width to yvect(k)+width;
;	in all cases, an "approximate" line center is determined by the
;	minimum of a running-box-mean of the profile; a polynom is then
;       fitted to the (unsmoothed) profile points around the "approximate" 
;       line center; the minimum of the polynom defines XCENT and INTCENT.
; MODIFICATION HISTORY:
;	nlte, 1989-08-29 : xmin=minimum of smooth spline (integral value!).
;       nlte, 1990-03-17 : minor modifications.
;	nlte, 1991-12-03 : no spline but polynom around minimum of running mean
;                          of profile;
;			   1- & 2-dim case, optional input parameters.
;       nlte, 1992-01-29 : minor update
;-
;
on_error,1
if n_params() lt 2 then message,$
     'usage: CENT_LINE,img,xcent [,intcent] [,optional keyword-params]'
simg=size(img)
if simg(0) lt 1 or simg(0) gt 2 then message,$
     '1st argument (IMG) must be 1- or 2-dim. array'
if simg(0) eq 1 then begin wdir=1 & nimgy=1 & y1=0 & y2=0 & goto,jmp1 & endif
;
if n_elements(wdir) eq 1 then begin
   if wdir lt 1 or wdir gt 2 then message,'WDIR must be 1 or 2'
endif else wdir=1
;
jmp1: 
nimgx=simg(wdir)
;
x1=0 & x2=nimgx-1 
if keyword_set(xrange) then begin
   if (size(xrange))(0) ne 1 then message,$
      'XRANGE must be vector with 2 elements'
   if (size(xrange))(1) ne 2 then message,$
      'XRANGE must be vector with 2 elements'
   if xrange(1) lt xrange(0)+10 then message,'specified XRANGE too few points'
   x1=max([0,xrange(0)]) & x2=min([xrange(1),nimgx-1])
endif
if x2-x1+1 lt 10 then message,'adjusted XRANGE too few points'
;
if simg(0) eq 1 then goto,jmp2
if wdir eq 1 then nimgy=simg(2) else nimgy=simg(1)
y1=0 & y2=nimgy-1
if n_elements(yvect) lt 1 then yspecif=0 else yspecif=1
if keyword_set(yrange) then begin
   if (size(yrange))(0) ne 1 then message,$
      'YRANGE must be vector with 2 elements'
   if (size(yrange))(1) ne 2 then message,$
      'YRANGE must be vector with 2 elements'
   if yrange(1) lt yrange(0) then message,'specified YRANGE invalid'
   y1=max([0,yrange(0)]) & y2=min([yrange(1),nimgy])
   yspecif=0 ; overruling any setting in yvect on input
endif
if y2 lt y1 then message,'adjusted YRANGE empty'
;
if n_elements(step) eq 1 then begin
   if step lt 1 or step gt y2-y1 then message,'STEP invalid value'
   yspecif=0 ; overruling any setting in yvect on input
endif else step=5
;
if n_elements(width) eq 1 then begin
   if width lt 0 or width gt y2-y1 then message,'WIDTH invalid value'
endif else width=4
;
jmp2:
if n_elements(nxfit) eq 1 then begin
   if nxfit lt 3 or nxfit gt nimgx then message,$
                 'NXFIT must be at least 3 and less than size of scan line'
endif else nxfit=-1
; 
if n_elements(degfit) eq 1 then begin
   if degfit lt 2 or degfit gt 10 then message,'DEGFIT out of range (2 - 10)'
endif else degfit=2
;
if nxfit gt 0 and nxfit le degfit then message,'NXFIT must be > DEGFIT'
;
if nxfit gt 0 then nbox=nint(nxfit/3) else nbox=min([5,nint((x2-x1+1)/50)])
nbox=max([3,nbox])
;
if simg(0) eq 2 then goto,jmp3
; +++ case 1-dim scan
s=img(x1:x2) & maxs=x2-x1
sm=run_av(s,nbox)
intcent=min(sm,ixmin)
if nxfit lt 0 then begin
   intmax=max(sm) & intcrit=intcent+(intmax-intcent)*0.2
   ii=where(sm(0:ixmin) gt intcrit,ni)
   if ni gt 0 then if1=ii(ni-1)+1 else if1=max([0,xmin-5*nbox])
   ii=where(sm(ixmin:*) gt intcrit,ni)
   if ni gt 0 then if2=ii(0)+ixmin-1 else if2=min([maxs,xmin+5*nbox])
endif else begin 
   if1=max([0,ixmin-(nxfit-1)/2]) & if2=min([maxs,ixmin+(nxfit-1)/2])
endelse
coef=poly_fit(findgen(if2-if1+1),s(if1:if2),degfit) & xextr2=float(if2-if1)
intc=poly_extr(coef,0.,xextr2,xmin)
if xmin gt 0. and xmin lt xextr2 then begin
   xcent=xmin+float(x1+if1) & intcent=intc
endif else begin
   xcent=-1. & intcent=-1.
endelse
y=0
goto,jmpret
;
jmp3:
; +++ case 2-dim image
if yspecif eq 0 then begin 
   j1=fix(y1+width) & j2=fix(y2-width) & jstep=fix(step)
   y=j1+jstep*indgen((j2-j1)/jstep +1)
endif else begin
   y=yvect>width & y=y<(nimgy-1-width)
   j1=0 & j2=n_elements(y)-1 & jstep=1
endelse
xcent=fltarr(n_elements(y)) & intcent=xcent
;
k=-1
for jj=j1,j2,jstep do begin
k=k+1
j=y(k)
if wdir eq 1 then begin
; +++ case 2-dim, w-dir is 1st:
   if width eq 0 then s=img(x1:x2,j) else s=(avy_x(img,j-width,j+width))(x1:x2)
endif else begin
; +++ case 2-dim, w-dir is 2nd:
   if width eq 0 then s=img(j,x1:x2) else s=(avx_y(img,j-width,j+width))(x1:x2)
endelse
sm=run_av(s,nbox) & maxs=x2-x1
intc=min(sm,ixmin)
if nxfit lt 0 then begin
   intmax=max(sm) & intcrit=intc+(intmax-intc)*0.2
   ii=where(sm(0:ixmin) gt intcrit,ni)
   if ni gt 0 then if1=ii(ni-1)+1 else if1=max([0,xmin-5*nbox])
   ii=where(sm(ixmin:*) gt intcrit,ni)
   if ni gt 0 then if2=ii(0)+ixmin-1 else if2=min([maxs,xmin+5*nbox])
endif else begin 
   if1=max([0,ixmin-(nxfit-1)/2]) & if2=min([maxs,ixmin+(nxfit-1)/2])
endelse
coef=poly_fit(findgen(if2-if1+1),s(if1:if2),degfit) & xextr2=float(if2-if1)
intc=poly_extr(coef,0.,xextr2,xmin)
if xmin gt 0. then begin
   xcent(k)=xmin+float(x1+if1) & intcent(k)=intc
endif else begin
   xcent(k)=-1. & intcent(k)=-1.
endelse
endfor
;
jmpret:
yvect=y
return
end
