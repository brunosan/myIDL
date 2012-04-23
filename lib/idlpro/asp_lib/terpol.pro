pro terpol, tmp, whrsv
;+
;
;  interpolate linearly over pixels in tmp for indices whrsv
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 2 then begin
	print
	print, "usage:  terpol, tmp, whrsv"
	print
	print, "	Interpolate linearly over pixels in tmp for"
	print, "	indices whrsv."
	print
	return
endif
;-

;  get dimensions of input array
nx = sizeof(tmp, 1)
nx1 = nx-1
szw = sizeof(whrsv, 1)
nw1 = nwh - 1

;  start loop over segments to be interpolated
i = 0
loop1: ist = whrsv(i)
  iend = ist
  loop2: i = i + 1
    if i eq nw1 then goto,endloop2
    if whrsv(i) eq (whrsv(i-1)+1) then begin
      iend = iend + 1
      goto,loop2
    endif
  endloop2: kk = 0
; linearly interpolate over problem pixels
  if ist eq 0 then begin
    for j = ist,iend do tmp(j) = tmp(iend+1)
    tmp(j) = -1.
    goto,finis
  endif
  if iend eq nx1 then begin
    for j = ist,iend do tmp(j) = tmp(ist-1)
    tmp(j) = -1.
    goto,finis
  endif
;print,'ist,iend,tmp(ist-1:iend+1)',ist,iend,tmp(ist-1:iend+1)
    delt = (tmp(iend+1) - tmp(ist-1))/float(iend-ist+2)
    for j = ist,iend do begin
      tmp(j) = tmp(ist-1) + float(j-ist+1)*delt
;   tmp(j) = -1.
    endfor
  finis:kk = 0

  if i lt nw1 then goto,loop1

end
