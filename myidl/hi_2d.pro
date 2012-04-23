function find_binsize,range
	fixbuffer = 100
	desired_nbin = 10.
	onetwofive_array = [1,2,5]
	threelogbinsize = 3*alog10(range/desired_nbin)
	fix3logbin = fix(threelogbinsize+3*fixbuffer)
	power = fix3logbin/3 - fixbuffer
	onetwofive_i = fix3logbin mod 3
	if (onetwofive_i lt 0) then onetwofive_i = onetwofive_i + 3
	binsize = onetwofive_array[onetwofive_i] * 10.^power
return,binsize
end

; -------------------------------------------------------------
pro histo_2d,x,y,xbinsize=xbinsize,ybinsize=ybinsize,_extra=extra,$
	nocolorbar=nocolorbar
; by Edwin Sirko
; 2003-11-21. Coded for Simon and Will.  (You owe me.)

; --- Example:
; npoints = 1000L
; x = randomn(seed,npoints)
; y = randomn(seed,npoints)

if n_elements(x) ne n_elements(y) then begin
	print,'argh, n(x) != n(y)'
	return
endif

if (n_elements(xbinsize) eq 0) then form_xbinsize = 1 else form_xbinsize = 0
if (n_elements(ybinsize) eq 0) then form_ybinsize = 1 else form_ybinsize = 0

; --- find region of interest for distribution function
; --- find binsize if not provided. The "10" represents the desired number
;     of bins.  By doing it in log space, we can get binsizes of 1,2,5
;     or any power of ten multiplied by that.
min_x = min(x,max=max_x)
min_y = min(y,max=max_y)
if form_xbinsize then xbinsize = find_binsize(max_x-min_x)
if form_ybinsize then ybinsize = find_binsize(max_y-min_y)
if (form_xbinsize or form_ybinsize) then $
	print,xbinsize,ybinsize,format='("xbinsize,ybinsize = ",2g10.5)'
xminbin = long(min_x/xbinsize) - (min_x lt 0.)
xmaxbin = long(max_x/xbinsize) + (max_x gt 0.)
yminbin = long(min_y/ybinsize) - (min_y lt 0.)
ymaxbin = long(max_y/ybinsize) + (max_y gt 0.)
xbins = xmaxbin - xminbin
ybins = ymaxbin - yminbin
xmin = xbinsize * xminbin
xmax = xbinsize * xmaxbin
ymin = ybinsize * yminbin
ymax = ybinsize * ymaxbin

; --- form distribution array
z = lonarr(xbins,ybins)
for i=0,xbins-1 do begin
for j=0,ybins-1 do begin
temp = where((x ge xmin+i*xbinsize) and (x lt xmin+(i+1)*xbinsize) and $
	(y ge ymin+j*ybinsize) and (y lt ymin+(j+1)*ybinsize),nz)
z[i,j] = nz
endfor
endfor

xabscissa = xmin+(indgen(xbins)+.5)*xbinsize
yabscissa = ymin+(indgen(ybins)+.5)*ybinsize
tvimg,z,xabscissa,yabscissa,/asp,_extra=extra
stop
hlp,z

return
end
