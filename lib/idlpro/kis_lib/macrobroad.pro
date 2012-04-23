FUNCTION macrobroad,w,r,vel,wcentr,half=ihalf,dlf=df,old=iold,dls=wf0
;+
; NAME:
; 	MACROBROAD
; PURPOSE:
; 	Returns macro-velocity -broadened line profile
;*CATEGORY:            @CAT-# 34 31  3@
; 	Stellar Atmospheres , Spectral Analysis , Convolution
; CALLING SEQUENCE:
;	r_mac = MACROBROAD(delt_lamb_vect, r_vect, v_macro, lamb_centr)
; INPUTS:
; 	delt_lamb_vect : Vector of (lambda - lamb_centr)/Angstr for input-
;	       line profile; must be monotonically increasing;
;	       if /HALF is set (case "half profile"), 1st element
;	       must be zero. Need not to be equidistant.
;	r_vect : Vector of unbroadened input- line profile (line depression)
;              I_continuum - I_line(delt_lamb_vect) (normalization of no
;	       importance); r_vect may contain either a full profile or a 
;	       "half-profile" starting at line center.
;	v_macro : Macro-velocity / km/sec; must be > 0;
;	       the line profile will be convolved with a gaussian kernel
;	       which drops to 1/e at delta_lambda = (v_macro/c)*lamb_centr.
;	lamb_centr: Absolute wavelength (Angstr.) of spectral line.
; KEYWORD PARAMETERS:
;	/HALF : If set, the input line profile is a "half profile" from
;	       which a symmetric "full" profile will be created internally.
;	DLF=step : Step-width (Angstr.) for the "fine" delta_lambda-grid
;	       used to compute the broadened profile; The input profile
;	       will be spline-interpolated onto an equidistant wavelength-
;	       grid of specified step width:
;	          delta_lamb_fine = delta_lamb_start + 
;		                    step * findgen(n_elements(r_mac))
;	       (delta_lamb_start see below, keyword DLS);
;              the broadened profile will be returned for this wavelength-
;	       grid, unless keyword /OLD was set.
;	       Default: step=0.002 ( 2mA).
;	/OLD : If set, the broadened profile will be re-interpolated onto
;	       the wavelength-grid of the input-profile (delt_lamb_vect).
; OUTPUTS:
;       Vector of broadened line profile; unless keyword /OLD was set, the
;	returned vector corresponds to the equidistant "fine" wavelength-
;	grid (see descr. of keyword DLF above); if keyword /OLD was set,
;	the returned vector corresponds to the wavelength-grid of the
;	input-profile.
; OPTIONAL OUTPUT PARAMETERS:
;       DLS=delta_lamb_start : Wavelength of 1st point of wavelength-grid
;	       for which the brodened profile is returned.
;	       delta_lamb_start == delt_lamb_vect(0) if /OLD was set or
;	                           if no /HALF was set;
;	       delta_lamb_start == -(delt_lamb_vect(*)) if /HALF was set
;	                           but not /OLD . 
; COMMON BLOCKS: 
;      none
; SIDE EFFECTS: 
;      none
; RESTRICTIONS:
;      The input profile should drop to small values so that extrapolation
;      of the wings, assuming r(x) prop x**-2 is reasonable or of no harm.
; PROCEDURE:
;      1.) If /HALF was set: input-profile is reflected around delta_lamb = 0
;          to create a symmetrical "full profile".
;      2.) The input-profile is spline-interpolated onto an equidistant
;          wavelength-grid ("fine" grid) (step-width: step, boundaries defined
;	   by input wavelength-grid delt_lamb_vect).
;      3.) A gaussian kernel is computed for the "fine" grid; the kernel drops
;          to (1/e)*kernel(0) at delta_lambda = (v_macro/c)*lamb_centr;
;	   the size of the kernel-vector is 2*im+1, im is determined such
;	   that the kernel  drops below kernel(0)*10**-6 at delta_lamb =
;          im*step.
;      4.) The "fine" grid is extended by <im> steps on both sides and the
;          profile is extrapolated assumig d_lamb**-2 -dependence of line
;          depression.
;      5.) The unbroadened profile is convolved with the kernel using IDL-
;          routine CONVOLV.
;      6.) The convolved vector is truncated by the "extensions" (see 4.).
;      7.) If /OLD was set: the convolved vector will be back-interpolated
;          onto the input-wavelength scale (spline).
; MODIFICATION HISTORY:
;      Created: 1991-Sep-23   H. S., KIS
;-
on_error,1
;
if n_params() lt 4 then message, $
   'USAGE: r_mac = MACROBROAD(delt_lamb_vect,r_vect,v_macro,lamb_centr '+$
   '[,DLF=delta_lambda_fine] [,DLS=delta_lamb_start] [,/HALF] [,/OLD] )'
;
nw=n_elements(w) & nr=n_elements(r)
if nw lt 3 or nr ne nw then message,$
   'sizes of 1st & 2nd argument too small or not the same:'+$
    string(nw,nr,format='(2(1x,i4))')
if n_elements(vel) ne 1 then message, $
   'v_macro (3rd arg) undefined or not scalar'
if n_elements(wcentr) ne 1 then message, $
   'lamb_centr (4th arg) undefined or not scalar'
if vel lt 0.01 or vel gt 1000. then message, $
   'macro-velocity (3rd arg) outside reasonable range 0.01 - 1000 km/s :'+$
   string(vel)
if wcentr lt 1000. or wcentr gt 1.e9 then message, $
   'lamb_centr (4th arg) outside reasonable range 1000 - 10**9 Angstr. :'+$
   string(wcentr)
if keyword_set(ihalf) and w(0) ne 0. then message, $
   'delta_lamb_vect (1st arg) must start with zero in case of /HALF'
if keyword_set(df) then begin 
   if df lt wcentr*1.e-8 or df gt wcentr*0.1 then message, $
   'delta_lambda_fine outside reasonable range '+string(df)
endif
k=0
for i=0,nw-2 do begin
    if w(i+1) le w(i) then begin
       k=k+1
       print,'% MACROBROAD: 1st arg delt_lamb_vect(i) >= ...(i+1) at i=',i
       print,'             delt_lamb_vect(i), (i+1):',w(i),w(i+1)
       if k eq 10 then message,'further messages truncated.'
    endif
endfor
if k gt 0 then message,'no action.'
;
if not keyword_set(df) then df=0.002
;
eps=1.e-6 ; lamb-range for macro-kernel such that kernel < eps at boundaries
fmac1=2.9979e5/vel/wcentr
fmac0=fmac1/sqrt(!pi)
;
;half-size macro-kernel:
im=1+nint(sqrt(-alog(eps))/fmac1/df)
if im lt 3 or im gt 10000 then message, $
   'size of macro-kernel lt 3 or gt 10000: '+string(im)+$
   ' values for v_macro, lamb_centr, delta_lambda_fine no good: '+$
   string(vel,wcentr,df)
;macro-kernel:
mac=fmac0*exp(-(fmac1*(findgen(im)*df))^2)
mac=[reverse(mac(1:*)),mac]
;
if keyword_set(ihalf) then begin
   r2=[reverse(r(1:*)),r]
   w2=[reverse(-w(1:*)),w]
endif else begin
   r2=r
   w2=w
endelse
;
; interpolation on "fine" w-grid:
n2=n_elements(w2)-1
nf=nint((w2(n2)-w2(0))/df)+1
rf=spline(w2,r2,w2(0)+df*findgen(nf),3.)
nf=nf-1
;
;extension of rf by im points on both sides assuming r prop dw**-2:
grad1=(r2(1)-r2(0))*df/(w2(1)-w2(0))
grad2=(r2(n2-1)-r2(n2))*df/(w2(n2-1)-w2(n2))
i01=im+2.*r2(0)/grad1
i0n=-2.*r2(n2)/grad2
rfx= $
[rf(0)*(i01-im)^2/(i01-findgen(im))^2, rf, rf(nf)*i0n^2/(i0n+1+findgen(im))^2]
;
;convolution:
rmac=(convol(rfx,mac))(im:im+nf) & rmac=rmac*df
;
if keyword_set(iold) then begin
   rmac=spline(w2(0)+df*findgen(nf+1), rmac, w, 3.)
   wf0=w(0)
endif else wf0=w2(0)
;
return,rmac
end
