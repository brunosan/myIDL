pro icross, ia, qa, ua, va, x1, x2
;;pro icross, ia, qa, ua, va, x1, x2, ksi, ksq, ksu, ksv
;+
;
;  purpose:  Determine residual i -> Q,U,V crosstalk from the continuum
;	     spectral region, then apply the inverse of that crosstalk to
;	     the data.  Crosstalk determined and applied on a row-by-row basis.
;
;  notes:  - apply *after* skew.pro
;	   - k calculation (for Andy Sku.) has been commented out
;
;==============================================================================
;
;	Check number of parameters.
;
;;if n_params() ne 10 then begin
if n_params() ne 6 then begin
	print
	print, "usage:  icross, ia, qa, ua, va, x1, x2"
;;	print, "usage:  icross, ia, qa, ua, va, x1, x2, ksi, ksq, ksu, ksv"
	print
	print, "	Determine residual i -> Q,U,V crosstalk from the"
	print, "	continuum spectral region, then apply the inverse of"
	print, "	that crosstalk to the data.  Crosstalk determined and"
	print, "	applied on a row-by-row basis."
	print
	print, "	Arguments"
	print, "		ia-va	- spectral images (all 4 are input"
	print, "			  but only qa,ua,va are modified)"
	print, "		x1, x2	- start and end wavelength indices"
	print, "			  for continuum window"
	print
	print, "	Keywords"
	print, "		(none)"
	print
	return
endif
;-
;
;	Get dimensions of arrays.
;
nx = sizeof(ia, 1)
ny = sizeof(ia, 2)
nx1 = nx-1
ny1 = ny-1
;
;	Get averages of Stokes vector in continuum window.
;
fnum = float(x2-x1+1)
ssum = fltarr(4,ny)		; zero array
for i = x1, x2 do begin
	ssum(0,*) = ssum(0,*) + ia(i,*)
	ssum(1,*) = ssum(1,*) + qa(i,*)
	ssum(2,*) = ssum(2,*) + ua(i,*)
	ssum(3,*) = ssum(3,*) + va(i,*)
endfor
ssum(*,*) = ssum(*,*)/fnum	; average value of I,Q,U,V per Y in continuum
;
;	Calculate crosstalk levels.
;
for j = 1, 3 do  ssum(j,*) = ssum(j,*)/ssum(0,*)
;
;	Debug code (Rob for Andy).
;
;;ksi = ssum(0, *)
;;ksq = ssum(1, *)
;;ksu = ssum(2, *)
;;ksv = ssum(3, *)
;
;	Subtract correction from the polarization signals.
;
for j = 0, ny1 do begin
	qa(*,j) = qa(*,j) - ssum(1,j)*ia(*,j)
	ua(*,j) = ua(*,j) - ssum(2,j)*ia(*,j)
	va(*,j) = va(*,j) - ssum(3,j)*ia(*,j)
endfor
;
end
