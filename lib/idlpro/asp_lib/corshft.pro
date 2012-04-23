function corshft,line1,line2
;+
;
;  function:  corshft(line1,line2)
;
;  purpose:  find the shift between line 1 and line 2 by correlation
;	     sub-pixel accuracy with polynomial interpolation
;	     adapted to do cross-correlation, not just difference
;	     tries only +/- 4 pixel shifts.  Result is the amount
;	     line2 is shifted with respect to line1, not the correction
;	     shift which should be applied, which is the negative of the
;	     result.
;
;==============================================================================


if n_params() ne 2 then begin
	print
	print, "usage:  ret = corshft(line1,line2)"
	print
	print, "	Find the shift between line 1 and line 2 by"
	print, "	correlation sub-pixel accuracy with polynomial"
	print, "	interpolation adapted to do cross-correlation, not"
	print, "	just difference tries only +/- 4 pixel shifts."
	print, "	Result is the amount line2 is shifted with respect"
	print, "	to line1, not the correction shift which should be"
	print, "	applied, which is the negative of the result."
	print
	return, 0
endif
;-

corrvec=fltarr(9)
dimen=size(line1)
dimen2=size(line2)

;  remove linear trend of vectors
x1=indgen(dimen(1))
coef1 = poly_fit(x1,line1,1,alin1)
var1 = line1-alin1
x2=indgen(dimen2(1))
coef2 = poly_fit(x2,line2,1,alin2)
var2 = line2-alin2
;var1=line1-mean(line1)
;var2=line2-mean(line2)
for i=-4,4 do corrvec(4+i)= total(var1(4:dimen(1)-5)*  $
 var2(4+i:dimen2(1)-5+i))

;  find maximum location of cross-correlation within 3 pixels of center
;  avoid first and last points to allow for correct interpolation
amax = max(corrvec(1:7),imax)

; correct index for dimension of corrvec
imax=imax+1

;  fit parabola about this point
xx=indgen(9)
coeff=poly_fit(xx(imax-1:imax+1),corrvec(imax-1:imax+1),2)
;print,'maximum at shift of',-coeff(1)/2./coeff(2)-4.

return,-coeff(1)/2./coeff(2)-4.
end
