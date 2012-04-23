pro gauss1, x, a, f, pder

;+
;
;	procedure:  gauss1
;
;	purpose:  Gaussian function for RSI's CURVEFIT function.
;
;	author:  vmp@ncar, 10/94	minor mod's by rob@ncar
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() lt 1 then begin
	print
	print, "usage:  gauss1, x, a, f, pder"
	print
	print, "	Gaussian function for RSI's CURVEFIT function."
	print
	print, "	Arguments"
	print, "		x	- (see CURVFIT)"
	print, "		a	- (see CURVFIT)"
	print, "		f	- (see CURVFIT)"
	print, "		pder	- (see CURVFIT)"
	print
	print, "	Keywords"
	print, "		(none)"
	print
	return
endif
;-

a(2)=abs(a(2))

pder=fltarr(n_elements(x),3)
z1=fltarr(n_elements(x))
ez1=fltarr(n_elements(x))
f=fltarr(n_elements(x))
z1(*)=(x(*)-a(1))/a(2)
ez1(*)=exp(-z1(*)^2)
f(*)=a(0)*ez1(*)
pder(*,0)=ez1(*)
pder(*,1)=a(0)*ez1(*)*2.*z1(*)/a(2)
pder(*,2)=a(0)*ez1(*)*2.*z1(*)*z1(*)/a(2)

end

