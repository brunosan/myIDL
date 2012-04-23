pro badcol, img
;+
;
;  purpose:  interpolate over 3 (hardwired) bad columns
;
;==============================================================================

if n_params() ne 1 then begin
	print
	print, "usage:  badcol, img"
	print
	print, "	Interpolate over 3 (hardwired) bad columns."
	print
	return
endif
;-

;  define bad columns
bad = [139,171,179]

;  get dimensions of input array
nx = sizeof(img, 1)
ny = sizeof(img, 2)
nx1 = nx-1
ny1 = ny-1

;  interpolate over bad columns
for k=0,2 do begin
  for j =0,ny1 do begin
    ib = bad(k)
    img(ib,j) = 0.5*(img(ib-1,j)+img(ib+1,j))
  endfor
endfor

end
