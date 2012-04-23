;+
; NAME: 
;       REFRAK  
; PURPOSE:
;       calculates the (diffrential) refraction for a set of wavelength
;       in dependence of temperature, air pressure and humidity.
;*CATEGORY:            @CAT-# 24@
;       Observers Support
; CALLING SEQUENCE:
;       REFRAK,wl,refra [,press=press] [,temp=temp] [,humi=humi]
; INPUTS:
;       wl    = vector with wavelengths in Angstrom 
; OPTIONAL INPUT PARAMETER:
;       press = pressure of air in TORR (=mm Hg)
;               (default = 760 Torr)
;       temp  = temperature in Celsius (centigrades)
;               (default = 15 C) 
;       humi  = partial pressure of water vapor  
;               (default = 5.)
; OUTPUTS:
;       refra = array with refraction values in arcsecs, 
;               first index corresponds to 18 zenith distances from
;               0 to 90 degrees in steps of 5 degrees.
;               second index corresponds to wavelengths in WL.
;
; MODIFICATION HISTORY:
;       H. Balthasar,   May 1992 (FORTRAN VERSION)
;       hoba, March 1993, conversion to IDL
;       nlte, June 1993, bug when wavelength(s) entered as integer.
;-
; ****************************************************************************
;
    pro refrak,rl_in,ref,press=press,temp=temp,humi=humi
;
    on_error,1
    rl=float(rl_in)
    nl=n_elements(rl)      
;c      implicit real*8 (a-h,o-z)
    ref=fltarr(18,nl+2)
    rn0=fltarr(nl)
    rnl=fltarr(nl)
;
    fr = 0.0174532925199443
    z=-5.
    dz=5.
    f=rl(0)
    t=15.    ; default value
    p=760.   ; default value
    h=5.     ; default value
    if n_elements(temp) gt 0 then t=float(temp) 
    if n_elements(press) gt 0 then p=float(press)
    if n_elements(humi) gt 0 then h=float(humi) 
;
    for i=0,17 do begin
         z=z+dz
         rz=z * fr
         for j=0,nl-1 do begin
            rn0(j)=(6432.8+2949810./(146.-1.e8/(rl(j)*rl(j)))+25540./  $
               (41.-1.e8/(rl(j)*rl(j))))*1.e-8
            rnl(j)=(rn0(j)/(1.+0.00367*(t-15)/(1.+15.*0.00367)))*     $
               (p/760.) -  55.*1.e-9*h/(1.+0.00367*t)
            ref(i,j)=3600.*(rnl(j)*tan(rz))/fr
         endfor
     endfor
;
    return
    end






