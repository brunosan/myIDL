PRO abs_prof_xy,img,dixc,wxc,xxl,xxr,int_cont,int_min,xxmin, eqvw,$
                 wdir=wdir,ibisect=ycritrel,$
                 xspline=xsplin,tens=tens,xrange=xrange,yrange=yrange,$
                 rows=yvect,step=step,avry=dy,linear=lin,plot=yplot
;+
; NAME:
;	ABS_PROF_XY
; PURPOSE:
;	Loop over image-rows (or -strips) of an image:
;	scanning along dispersion ->  line-tracings ("scans"),
;	absorption-line-parameters -> output-arrays
;*CATEGORY:            @CAT-# 16 31@
; 	Image Processing , Spectral Analysis
; CALLING SEQUENCE:
; ABS_PROF_XY,img,dixc,wxc, xl,xr,int_cont,int_min,xmin [,eqvw] ...
;             [,WDIR=1|2] [,IBISECT=intensvector] ...
;             [,XSPLINE=xspline] [,TENS=tension] ...
;             [,XRANGE=range] [,YRANGE=range] [,STEP=increment] ...
;	      [,ROWS=yvect] [AVRY=dy] [,/LINEAR] [,PLOT={'ALL' | yplot_vect} ]
; INPUTS:
;	IMG = 1- or 2-dim array containing an intensity-scan or an image.
;	DIXC = scalar or 2-element vector: 
;	       distance (pixel) x_continuum - x_line_center
;	       for one or two position(s) to determine the continuum intensity;
;	WIXC = scalar or 2-element vector: width (pixel) of interval(s) for
;	       averaging intensities (in IMG) to determine the continuum-
;              intensity; averaging is done over: 
;	       x_line_center + dixc(i) +- wixc(i)/2 (i=0 [,1]) for each scan.
; OPTIONAL INPUT PARAMETER:
;      ROWS=yvect  = 1-dim integer vector containing indices of image-rows
;	      (direction "y" along slit) for which line -center and
;	      -intensity shall be determined;
;	      !!! On return, the date in yvect will be over-stored by
;	      !!! the actual y-positions of each tracing (central row) !
;	      !!! Will be OVER-RULED by specifying YRANGE and/or STEP !
;	      !!! Must be a variable, NOT a constant!
;      WDIR= 1 or 2    the wavelength-direction ("x") is the 1st or 2nd
;	      dimension of array IMG; 
;	      default: WDIR=1 (WDIR=2 only meaningful if IMG is 2-dimensional).
;      XRANGE=[start,end]  only data within specified index-range will be
;	      used along wavelength-(x)-dimension of IMG-array;
;             0 <= start < end <= nx-1 (nx: size of IMG x-dir.);
;	      default: start=0, end=nx-1 .
;      YRANGE=[start,end]  only data within specified index-range will be
;	      used along slit-(y)-dimension of IMG-array;
;	      0 <= start < end <= ny-1 (ny: size of IMG y-dir.);
;	      only meaningful if IMG is 2-dimensional;
;	      !!! Specifying YRANGE will OVER-RULE any setting in
;	      !!! optional input parameter YVECT !
;	      Default: start=0, end=ny-1 .
;      STEP=increment   profile tracings will be taken at equidistant 
;	      steps along slit-(y)-positions with increment as specified;
;	      only meaningful if IMG is 2-dimensional;
;	      !!! Specifying STEP will OVER-RULE any setting in
;	      !!! optional input parameter YVECT !
;	      Default (if IMG is 2-dim): increment=5.
;      AVRY=dy    profile tracing at slit-(y)-position y will be 
;	      obtained by averaging from y-dy to y+dy;
;	      only meaningful if IMG is 2-dimensional;	
;	      default (if IMG is 2-dim): dy=4.
;      IBISECT=intensvector :  bi-sectors shall be obtained at relative
;             line intensities specified in vector intensvector; values must
;             be increasing;
;             the actual intensities at k-th tracing (k >= 0) will be:
;             ymin(k,1)+(ycont(k,2)-ymin(k,1))*intensvector;
;             if keyword not specified or with intensvector "empty": 
;             procedure will set
;             intensvector = [0.05,0.1,0.2,0.3,0.4,0.5,0.7,0.8]; this vector
;             will be returned if IBISECT=intensvector was specified on call
;             with an "empty" intensvector.
;      XSPLINE=xspline : vector containing positions (index-scale) of spline-
;      	      nodes; if xsplin undefined or single value, spline nodes will
;      	      be set by procedure (adjusted to line shape for each slit-
;	      position); ignored if keyword /LINEAR is set.
;      TENS=tension : "tension" used for smooth spline (default: tension=5.);
;             ignored if keyword /LINEAR is set.
;      /LINEAR : if set, the line profile points will be interpolated linearly
;             (not by spline).
;      PLOT = yplot : If set, the profile, its spline-interpolation
;      	      and it's parameters as determined by routine BISECT_ABS will
;	      be plotted for scans at y-positions specified in vector yplot;
;	      if yplot = 'all' (string!), plots will be done for all scans;
;	      (default: no plot).
; OUTPUTS:
;	xl = "left" x-positions (real, fractional indices) where smoothed
;		normalized profile assumes one of the "bisector"-intensites;
;	xr   ditto for "right" x-position; 
;	     format of xl, xr:
;	     if IMG is 1-dim:  1-dim real, size same as vector for 
;	                       bi-sector-intensities (see key-word IBISECT)
;	     if IMG is 2-dim:  2-dim real, (n_scans , n_bisects), where
;                              n_scans is number of tracings, and n_bisects =
;			       number of bi-sector-intensities.
;	int_cont = real array  size: [ n_scans, 4 ] if IMG is 2-dim
;			       and interpolation;
;                              (1-dim vector size=4 if IMG 1-dim).
;	        Maximal & "continuum" intensities (intensity-scale same as 
;               in SCAN at k-th tracing):
;		(k,0) = maximal value in scan (both interpol.-cases);
;		(k,1) = maximum of smooth spline (spline case), or
;		        "continuum" intensity value at "1st position" defined 
;			by dixc(0) (linear case);
;		(k,2) = "continuum" intensity value at minimum of smooth
;			spline xmin(k,1) (spline case), or at minimum of scan
;			(linear case);
;		(k,3) = "continuum" intensity value at "1st position"
;			defined by dixc(0) (spline case), or at "2nd position"
;			defined by dixc(1) (linear case).
;	int_min  = real array  size: [ n_scans, {4 | 2} ] if IMG is 2-dim
;			             and interpolation  {splines | linear};
;                                    (1-dim vector size {4 | 2} if IMG 1-dim).
;               Intensity-scale same as in SCAN at k-th tracing):
;		(k,0) = minimal intensity of SCAN (both interpol.-cases);
;		(k,1) = minimum of smooth spline (spline case),
;		        minimum of parabolic fit defining the "line center"
;		        (linear case);
;		(k,2) = minimum value of parabolic fit defining the
;		        "line center" (spline case only);
;               (k,3) = value of smooth spline at "line center" (spline case).
;	xmin  = real array size: [ n_scans, {4 | 2} ] if IMG is 2-dim
;			         and interpolation  {splines | linear};
;                                (1-dim vector size {4 | 2} if IMG 1-dim).
;               x-positions corresponding to int_min(k,0:3);
; OPTIONAL OUTPUTS:
;      eqvw     = real vector or real variable:
;               if this argument is provided on call, the equivalent widths 
;	        of the profiles will be calculated by integrating the profile
;	        depression of each tracing from
;		x_line_center + dixc(0) to x_line_center + dixc(1)
;		or x_line_center +- dixc if dixc is a single value;
;		the equivalent width is in units of (delta_lambda/pixel).
;      ROWS=yvect  = integer vector of y-positions (integral indices of image 
;	         rows) at which profile tracings have been obtained (will be
;		 set to 0 if IMG is 1-dim).
;      IBISECT=intensvector  | if these variables were not specified on call,
;      XSPLINE=xsplin        | the values set internally by the procedure
;      TENS=tens             | will be returned.
;      ROWS=yvect  = integer vector of y-positions (integral indices of image 
;	         rows) at which profile tracings have been obtained (will be
;		 set to 0 if IMG is 1-dim).	
; COMMON BLOCKS:
;	none
; SIDE EFFECTS:
;	Plots if keyword PLOT was set.
; RESTRICTIONS:
;	IMG must contain a well defined absorption profile (both halves
;	of profile without severe blending = blends with deeper minimum
;	than the line itself).	
; PROCEDURE:
; 	For each requested slit-position yvect(k) of IMG a line profile 
;       ("tracing") will be obtained by averaging from
;	yvect(k)-width to yvect(k)+width;
;       "approximate" line center x0 is determined by the minimum of a running-
;       box-mean of the profile;
;       Linear interpolation of "continuum"-intensity from intensity-values
;       around x1,2= x0 + dixc(0,1) +- wixc(0,1)/2 
;       (constant continuum assumed if dixc single value);
;	normalization of intensities to continuum == 1;
;	Interpolated of line profile by a smoothed spline (nodes as specified 
;	in XSPLINE=xspline or set by program (with finer steps around the
;       significant part of the line);
;	"continuum" intensities, intensities near line center, and "left" &
;	"right" positions where spline intersects
;	intens = YMIN(1) + [ycritrel]*(YCONT(1)-YMIN(1)) will be determined. 
; MODIFICATION HISTORY:
;	nlte, 1990-03-17 (predecessor of ABS_PROF_XY_ST)
;       nlte, 1992-02-06 major update (output arrays, not structure)
;       nlte, 1993-02-03 description for keyword LINEAR
;-
;
on_error,1
nparam=n_params()
if nparam lt 8 then message,$
'usage: ABS_PROF_XY,img,dixc,wxc,xl,xr,int_cont,int_min,xmin [,eqvw] [,opt. keyw-params]'
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
if n_elements(dy) eq 1 then begin
   if dy lt 0 or dy gt y2-y1 then message,'AVRY=DY invalid value'
   width=dy
endif else width=4
;
jmp2:
;
;defaults:
ycritreldef=[0.05,0.1,0.2,0.3,0.4,0.5,0.7,0.8] ;relative bi-sector intensities 
tensdef=5.   ; spline tension
;
if not keyword_set(ycritrel) then ycritrel=ycritreldef
nlev=n_elements(ycritrel)
if nlev lt 1 then ycritrel=ycritreldef
if nlev eq 1 and min(ycritrel) le 0 then ycritrel=ycritreldef
nlev=n_elements(ycritrel)
;
if n_elements(tens) le 0 then tens=tensdef  ; default tension for spline
; spline nodes (grob, not adjusted to line):
nodes=n_elements(xsplin)
if nodes le 1 or not keyword_set(xsplin) then begin
   xspl=0 & adjxspl=0 
endif else begin adjxspl=1 & xspl=xsplin & endelse
;
if simg(0) eq 2 then goto,jmp3
; +++ case 1-dim scan
s=img(x1:x2)
;
if keyword_set(yplot) then ploti=1 else ploti=0
if ploti eq 1 then print,': click right mouse button in graphics to continue!'
if keyword_set(lin) then $
   if nparam lt 9 then $
   bisec_abs_lin,s,dixc,wxc,xxl,xxr,int_cont,int_min,xxmin,$
                 ibisect=ycritrel,plot=ploti else $
   bisec_abs_lin,s,dixc,wxc,xxl,xxr,int_cont,int_min,xxmin,eqvw,$
                 ibisect=ycritrel,plot=ploti $
else  $
   if nparam lt 9 then $
   bisec_abs,s,dixc,wxc,xxl,xxr,int_cont,int_min,xxmin,ibisect=ycritrel,$
             xsplin=xspl,tens=tens,plot=ploti else $
   bisec_abs,s,dixc,wxc,xxl,xxr,int_cont,int_min,xxmin,eqvw,ibisect=ycritrel,$
             xsplin=xspl,tens=tens,plot=ploti   
xxmin=xxmin+x1
jj=where(xxl gt -0.5,n)
if n gt 0 then begin xxl(jj)=xxl(jj)+x1 & xxr(jj)=xxr(jj)+x1 & endif
yvect=0
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
if keyword_set(lin) then xxmin=fltarr(n_elements(y),2) $
                    else xxmin=fltarr(n_elements(y),4) 
int_min=xxmin & int_cont=fltarr(n_elements(y),4)
xxl=fltarr(n_elements(y),nlev) & xxr=xxl
if nparam  gt 8 then eqvw=fltarr(n_elements(y))
;
k=-1
kplot=0 & ploti=0
if keyword_set(yplot) then begin
   if (size(yplot))(0) eq 0 and (size(yplot))(1) eq 7 then $
      if strupcase(yplot) eq 'ALL' then ploti=2 else yplt=0 $
   else yplt=yplot(0)
endif else yplt=-1
;
for iy=j1,j2,jstep do begin
k=k+1 & j=y(k)
if ploti lt 2 then begin
  ploti=0 & if yplt ge 0 then if j ge yplt-jstep/2 then ploti=1 else ploti=0
endif
if wdir eq 1 then begin
; +++ case 2-dim, w-dir is 1st:
   if width eq 0 then s=img(x1:x2,j) else s=(avy_x(img,j-width,j+width))(x1:x2)
endif else begin
; +++ case 2-dim, w-dir is 2nd:
   if width eq 0 then s=img(j,x1:x2) else s=(avx_y(img,j-width,j+width))(x1:x2)
endelse
;
if keyword_set(lin) then $
   if nparam lt 9 then $
   bisec_abs_lin,s,dixc,wxc,xl,xr,icont,imin,xmin,$
                 ibisect=ycritrel,plot=ploti else $
   bisec_abs_lin,s,dixc,wxc,xl,xr,icont,imin,xmin,eqvwy,$
                 ibisect=ycritrel,plot=ploti  $  
else $
   if nparam lt 9 then $
   bisec_abs,s,dixc,wxc,xl,xr,icont,imin,xmin,ibisect=ycritrel,$
             xsplin=xspl,tens=tens,plot=ploti else $
   bisec_abs,s,dixc,wxc,xl,xr,icont,imin,xmin,eqvwy,ibisect=ycritrel,$
             xsplin=xspl,tens=tens,plot=ploti
if ploti gt 0 then begin
   if width eq 0 then text='image row '+string(j,form='(i0)') else $
                text='image rows '+string(j-width,j+width,form='(i0," - ",i0)')
   xyouts,n_elements(s)/20.,0.05,text
   if !D.name eq 'SUN' or !D.name eq 'X' then begin
     print,'click right mouse button in graphics to continue!' & rdcrs
   endif
endif
;
jj=where(xl gt -0.5,n)
if n gt 0 then begin xl(jj)=xl(jj)+x1 & xr(jj)=xr(jj)+x1 & endif
xxl(k,*)=xl & xxr(k,*)=xr & xxmin(k,*)=xmin+x1
int_cont(k,*)=icont & int_min(k,*)=imin
if nparam gt 8 then eqvw(k)=eqvwy
;
if ploti eq 1 then begin
   if n_elements(yplot) gt kplot+1 then begin 
      kplot=kplot+1 & yplt=yplot(kplot)
   endif else begin yplt=-1 & kplot=n_elements(yplot)+1 & ploti=0 & endelse
endif
;
endfor
yvect=y
;
jmpret:
end





