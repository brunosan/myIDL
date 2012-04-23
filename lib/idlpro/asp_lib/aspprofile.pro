pro aspprofile, i, q, u, v, xi, yi, xq, yq, xu, yu, xv, yv
;+
;
;	function:  aspprofile
;
;	purpose:  do 'profiles' on aspview I,Q,U,V image
;
;	author:  rob@ncar, 2/92
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 12 then begin
	print
	print, "usage:  aspprofile, i, q, u, v, xi, yi, xq, yq, xu, yu, xv, yv"
	print
	print, "	Do 'profiles' on aspview I,Q,U,V image."
	print
	return
endif
;-
;
;	Set parameters.
;
true = 1
false = 0
done = false
ans = string(' ',format='(a1)')
;
;	Select image and do profiles.
;
again: print
read, 'Choose image for profiles:  [i, q, u, v, x=exit]  ', ans
print
;
if ans eq 'i' then begin
	profiles, i, sx=xi, sy=yi
endif else if ans eq 'q' then begin
	profiles, q, sx=xq, sy=yq
endif else if ans eq 'u' then begin
	profiles, u, sx=xu, sy=yu
endif else if ans eq 'v' then begin
	profiles, v, sx=xv, sy=yv
endif else if ans eq 'x' then begin
	done = true
endif else begin
	goto, again
endelse
;
if not done then goto, again
;
;	Done.
;
end
