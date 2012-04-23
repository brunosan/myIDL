PRO bisec_abs_lin,scan,dixc,wixc,xl,xr,ycont,ymin,xmin ,eqvw,$
                 ibisect=ycritrel,plot=ploti
;+
; NAME:
;	BISEC_ABS_LIN
; PURPOSE:
;	determines  bi-sectors & central intensity of
;        **absorption** line profile. 
;       (Version using linear interpolation of scan)
;*CATEGORY:            @CAT-# 31@
;	Spectral Analysis
; CALLING SEQUENCE:
;	BISEC_ABS_LIN,scan,dixc,wxc,xl,xr,ycont,ymin,xmin [,eqvw]
;                 [,optional keyword-params]
; INPUTS:
;	scan = 1-dim array, containing the absorption profile
;		(intensities);
;	dixc = scalar or 2-element vector: distance (pixel) line center - 
;	       1st (& 2nd) position(s) relat. to line center to determine 
;	       the continuum intensity:
;	       dixc(i) =  x_continuum(i) - x_line_center (pixel) (i=0 [,1]).
;	wixc = scalar or 2-element vector: width (pixel) of interval(s) for
;	       averaging intensities (in scan) to determine the continuum-
;              intensity; averaging is done over:
;	       x_line_center + dixc(i) +- wixc(i)/2 (i=0 [,1])
; OPTIONAL INPUT PARAMETER:
;	IBISECT=intensvector :  bi-sectors shall be obtained at relative
;	       line intensities specified in vector intensvector; values must
;	       be increasing;
;	       the actual intensities will be:
;	       ymin(1)+(ycont(2)-ymin(1))*intensvector;
;	       if keyword not specified or with intensvector "empty": 
;              procedure will set
;	       intensvector = [0.05,0.1,0.2,0.3,0.4,0.5,0.7,0.8]; this vector
;	       will be returned if IBISECT=intensvector was specified on call
;	       with an "empty" intensvector.
;	/PLOT : keyword . If set, the profile, its spline-interpolation
;		and it's parameters as determined by this routine will
;		be plotted.
; OUTPUTS:
;	xl = "left" x-positions (real, fractional indices) where
;		 normalized profile assumes one of specified intensity-values; 
;	xr   ditto for "right" x-position;
;	(xl,xr real vectors  same sizes as vector for bi-sector-intensities,
;               see key-word IBISECT).
;	ycont = vector (size=4) 
;	        maximal & "continuum" intensities (intensity-scale same as 
;               in SCAN):
;		ycont(0) = maximal value in scan,
;		ycont(1) = "continuum" intensity value at 1st position
;			   defined by dixc(0),
;		ycont(2) = "continuum" intensity value at minimum of profile,
;		ycont(3) = "continuum" intensity value at 2nd position
;			   defined by dixc(1) 
;			   (== ycont(1) if only 1 "continuum-position" 
;			   specified.
;	ymin  = vector (size=2); 
;		ymin(0) = minimal intensity of SCAN,
;		    (1) = minimum value of parabolic fit defining the
;		          "line center";
;              
;	xmin  = vector (size=2) with x-positions corresponding to 
;		    ymin(0:1) (real, fractional index).
;
;	ycritrel = vector (size=19) of relative intensities used for
;			bi-sector determination.
; OPTIONAL OUTPUTS:
;	eqvw  = if this argument is provided on call, the equivalent width 
;	        of the profile will be calculated by integrating the profile
;	        depression from
;		x_line_center + dixc(0) to x_line_center + dixc(1)
;		or x_line_center +- dixc if dixc is a single value;
;		the equivalent width is in units of (delta_lambda/pixel).
;	IBISECT=intensvector  if  variable <intensvector> was not specified
;               on call, the values set internally by the procedure will be
;               returned.
;
; COMMON BLOCKS:
;       none
; SIDE EFFECTS:
;	A plot will be produced if keyword PLOT was set.
; RESTRICTIONS:
;	SCAN must contain a well defined absorption profile (both halves
;	of profile without severe blending = blends with deeper minimum
;	than the line itself).
; PROCEDURE:
;	"continuum" intensity (YCONT), intensities near line center
;	(YMIN=SCAN(XMIN)), and positions where scan (linearely interpolated) 
;	intersects y = YMIN + [ycritrel]*(YCONT-YMIN) will be determined.
;	
; MODIFICATION HISTORY:
;	nlte, 1990-03-13 
;	nlte, 1990-03-21  (spline-version -> non-spline version,
;			   doppler shifted ycont)
;       nlte, 1990-03-27  (bug interpolation xl)
;	nlte, 1991-12-03  (input/output like spline-version,
;	                    new name BISEC_ABS_LIN)
;	nlte, 1992-02-06  (bug if wixc 2-elements, equiv.-width, no rdcrs, 
;			  indication "continuum positions" in plot)
;	nlte, 1992-07-13  (simpson -> simps)
;-
on_error,1
nparams=n_params()
if nparams lt 8 then message,$
 'Usage: BISEC_ABS_LIN,scan,dixc,wixc,xl,xr,ycont,ymin,xmin [,optional params]'
;
if keyword_set(ploti) then iplot=1 else iplot=0
;
n=n_elements(scan)
;
ycont=fltarr(4)
xmin=fltarr(2)
ymin=fltarr(2)
;
;defaults:
; relative intensities for bi-sectors:
ycritreldef=[0.05,0.1,0.2,0.3,0.4,0.5,0.7,0.8] ;relative bi-sector intensities
kminfit=1    ; fit parabola for "more accurate minimum" using profile-
;              points below ycrit(kminfit) 
stepgrob=15  ; 
if not keyword_set(ycritrel) then ycritrel=ycritreldef
nlev=n_elements(ycritrel)
if nlev lt 1 then ycritrel=ycritreldef
if nlev eq 1 and min(ycritrel) le 0 then ycritrel=ycritreldef
nlev=n_elements(ycritrel)
;
xl=fltarr(nlev) & xr=fltarr(nlev)
;
; maximal, minimal intensity of scan:
ycont(0)=max(scan)
ymin(0)=min(scan,ixmin)
xmin(0)=float(ixmin)
;
; "continuum"-intensity and normalization of scan to continuum == 1::
if n_elements(dixc) eq 1 then begin 
   ixc1=ixmin+dixc & wixc1=wixc(0)
   if dixc lt 0 then ixc1=max([0, ixc1-wixc1/2]) else $
                     ixc1=min([n-1-wixc1,ixc1-wixc1/2])
   yc1=total(scan(ixc1:ixc1+wixc1))/float(wixc1+1)
   g0=yc1 & g1=0. & contscan=replicate(g0,n)
   yint=scan/yc1
   ycont(1)=yc1 & ycont(2)=yc1 & ycont(3)=yc1 ; I_cont (x) constant
endif else begin
   if n_elements(wixc) eq 1 then begin wixc1=wixc & wixc2=wixc1 & endif $
   else begin wixc1=wixc(0) & wixc2=wixc(1) & endelse
   ixc1=ixmin+dixc(0) & ixc2=ixmin+dixc(1)
   if dixc(0) lt 0 then ixc1=max([0,ixc1-wixc1/2]) else $
                        ixc1=min([n-1-wixc1,ixc1-wixc1/2])
   yc1=total(scan(ixc1:ixc1+wixc1))/float(wixc1+1)
   ixc11=ixc1+wixc1/2
   if dixc(1) lt 0 then ixc2=max([0,ixc2-wixc2/2]) else $
                        ixc2=min([n-1-wixc2,ixc2-wixc2/2])
   yc2=total(scan(ixc2:ixc2+wixc2))/float(wixc2+1)
   ixc22=ixc2+wixc2/2
   g1=(yc2-yc1)/float(ixc22-ixc11) & g0=yc1-g1*float(ixc11)
   contscan=g0+g1*findgen(n)
   yint=scan/contscan ; I_cont (x) linear
   ycont(1)=contscan(ixc11) & ycont(2)=contscan(ixmin) 
   ycont(3)=contscan(ixc22)
endelse
;
;minimum intensity of spline thru normalized intensities:
ymin(0)=min(yint,ixmin)   ; relative value
xmin(0)=float(ixmin)
if iplot gt 0 then begin
   plot,yint,yrange=[0.,1.1],tit='bi-sectors from linear fit'
   oplot,ixc1+indgen(wixc1+1),replicate(1.05,wixc1+1),thick=4.
   if n_elements(dixc) gt 1 then $
      oplot,ixc2+indgen(wixc2+1),replicate(1.05,wixc2+1),thick=4.
endif
;
;x-positions where profile assumes specified intensity values:
dy=1.-ymin(0)
ycrit=ymin(0)+ycritrel*dy
;
i11=-1 & i22=-1 & ikl=0 & ikr=n-1
for k=nlev-1,0,-1 do begin
yc=ycrit(k)
; "left" intersection:
ii=where(yint(ikl:ixmin) ge yc, ni)
if ni gt 0 then begin
   i1=ii(ni-1)+ikl & i2=i1+1 & ikl=i1
   xl(k)=float(i2)+(yc-yint(i2))/(yint(i2)-yint(i1))
endif else begin xl(k)=-float(n) & i1=-1 & endelse
; "right" intersection:
ii=where(yint(ixmin:ikr) ge yc, ni)
if ni gt 0 then begin
   i4=ii(0)+ixmin & i3=i4-1 & ikr=i4
   xr(k)=float(i4)+(yc-yint(i4))/(yint(i4)-yint(i3))
endif else begin xr(k)=2.*float(n) & i4=-1 & endelse
if k eq kminfit then begin i11=i1 & i22=i4 & endif
endfor
;
; more accurate x-position of intensity minimum:
;      minimum of parabola thru yint(i11...i22):
   if i11 lt 0 then i11=max([0,ixmin-stepgrob])
   if i22 lt 0 then i22=min([n-1,ixmin+stepgrob])
   c2=poly_fit(findgen(i22-i11+1),yint(i11:i22),2)
   xminp2=-0.5*c2(1)/c2(2) & xmin(1)=xminp2+float(i11)
   i1=fix(xmin(1)) & i2=i1+1
   ymin(1)=poly(xminp2,c2)  ; normalized intensity scale
   ymin=ymin*ycont(2)       ; absolute intensity scale
;
; equivalent width:
if nparams gt 8 then begin
   if n_elements(dixc) eq 1 then dixcmin=abs(dixc(0)) else $
                                 dixcmin=min(abs(dixc))
   i1=max([0,nint(xmin(1))-dixcmin]) & i2=min([n-1,nint(xmin(1))+dixcmin])
   eqvw=simps(1.-yint(i1:i2))
endif
;
if iplot gt 0 then begin
xsort=xr(sort(xr))
for k=0,nlev-1 do begin
xx=[xl(k),xr(k)]
yy=[ycrit(k),ycrit(k)]
oplot,xx,yy,line=3
xyouts,xr(k)+20.,yy(0),string(format='(''at'',f6.3,''* Icon'')',yy(0))
endfor
oplot,[0.,float(n-1)],[1.,1.],line=3
xyouts,float(n/2),1.05,$
  strcompress(string(ycont(2),form='("I_CONT = ",G10.4)')),align=0.5
if nparams gt 8 then xyouts,float(n/2),1.02,$
  strcompress(string(eqvw,form='("EQVW = ",G10.4," pix")')),align=0.5
oplot,0.5*(xl+xr),ycrit,line=3
if !d.n_colors gt 2 then colr=nint(2*!d.n_colors/3) else colr=-1
if colr gt 2 then $
   oplot,float(i11)+findgen(i22-i11+1),poly(findgen(i22-i11+1),c2),line=2,$
   thick=2.,color=colr $
else oplot,float(i11)+findgen(i22-i11+1),poly(findgen(i22-i11+1),c2),line=2,$
   thick=2.
xx=[xmin(1),xmin(1)]
yyy=ymin(1)/ycont(2) & yy=[yyy,0.]
if colr gt 2 then oplot,xx,yy,color=colr else oplot,xx,yy
xx=[i11,i22] & yy=replicate(yyy,2)
if colr gt 2 then oplot,xx,yy,color=colr else oplot,xx,yy
xx=[i11,i11] & yy=[poly(0.,c2),yyy]
if colr gt 2 then oplot,xx,yy,color=colr else oplot,xx,yy
xx=[i22,i22] & yy=[poly(float(i22-i11),c2),yyy]
if colr gt 2 then oplot,xx,yy,color=colr else oplot,xx,yy
endif
;
return
end
