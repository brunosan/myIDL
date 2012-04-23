pro hist, array, title, $
	x1=x1, x2=x2, y1=y1, y2=y2, v1=v1, v2=v2, yr1=yr1, yr2=yr2, $
	binsize=binsize, currw=currw, noverb=noverb, warnoff=warnoff
;+
;
;	procedure:  hist
;
;	purpose:  plot a histogram of an array
;
;	author:  rob@ncar, 9/92
;
;	notes:  works for 1-D and 2-D arrays
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() lt 1 then begin
	print
	print, "usage:  hist, array [, title]"
	print
	print, "	Plot a histogram of an array."
	print
	print, "	Arguments"
	print, "		array	 - input array"
	print, "		title	 - plot title (def=none)"
	print
	print, "	Keywords"
	print, "		x1	 - starting column index (def=0)"
	print, "		x2	 - ending column index (def=last one)"
	print, "		y1	 - starting row index (def=0)"
	print, "		y2	 - ending row index (def=last one)"
	print, "		v1	 - minimum value to consider (def=min)"
	print, "		v2	 - maximum value to consider (def=max)"
	print, "		yr1	 - starting Y range for plot (def=0)"
	print, "		yr2	 - ending Y range for plot (def=~max)"
	print, "		binsize	 - size of histogram bin (def=1)"
	print, "		currw	 - if set, use current window"
	print, "			   (def=open new window)"
	print, "		noverb	 - if set, turn off run-time print"
	print, "			   (def=print run-time information)"
	print, "		warnoff	 - turn off warning message (def=on)"
	print
	return
endif
;-
;
;	Check number of dimensions of array.
;
ndim = sizeof(array, 0)
if (ndim lt 1) or (ndim gt 2) then begin
	print
	print, 'Hist array must be 1-D or 2-D.'
	print
	return
endif
;
;	Get subset of array to use.
;
nx = sizeof(array, 1)
if n_elements(x1) eq 0 then x1 = 0
if n_elements(x2) eq 0 then x2 = nx - 1
if ndim eq 1 then  a = array(x1:x2)
;
if ndim eq 2 then begin
	ny = sizeof(array, 2)
	if n_elements(y1) eq 0 then y1 = 0
	if n_elements(y2) eq 0 then y2 = ny - 1
	a = array(x1:x2, y1:y2)
endif
;
;	Set other parameters.
;
if n_elements(binsize) eq 0 then binsize = 1.0
if n_params() ne 2 then title = ''
binsize2 = binsize / 2.0
minv = min(a, max=maxv)
;
;	Set the range of values to consider for the histogram.
;
if n_elements(v1) eq 0 then v1 = minv
if n_elements(v2) eq 0 then v2 = maxv
if binsize gt (v2 - v1) then begin
	print
	print, 'binsize too large for value range'
	print, ' binsize = ', binsize, ', v1 = ', v1, ', v2 = ', v2
	print
	return
endif
;
;	Calculate histogram, the y-coords.
;
h = histogram(a, min=v1, max=v2, binsize=float(binsize))
;
;	Set the y-range for the plot.
;
if n_elements(yr1) eq 0 then yr1 = 0
if n_elements(yr2) eq 0 then yr2 = max(h)
yrange = [yr1, yr2]
;
;	Set the x-coords for the plot.
;
num = n_elements(h)
num1 = num - 1
;	(Must add half of binsize because only see half of first bin
;	 with "PLOT, PSYM=10"; actually see only half of last bin too.)
x = v1 + binsize * findgen(num) + binsize2
xr1 = min(x, max=xr2)
;	(Show the full width of the first and last bins on the X-axis, even
;	 though the curve itself will start and stop short of this range.)
xrange = [xr1-binsize2, xr2+binsize2]
;
;	Print verbose information.
;
if not keyword_set(noverb) then begin
	print
	print, 'Bin Centers (array ''x''):'
	print, x
	print
	print, 'Bin Heights (array ''h''):'
	print, h
	print
	print, '  num bins:  ' + stringit(num)
	print, '   binsize:  ' + stringit(binsize)
	print, 'minv, maxv:  ' + stringit(minv) + ', ' + stringit(maxv)
	print, '    v1, v2:  ' + stringit(v1) + ', ' + stringit(v2)
	print, '  yr1, yr2:  ' + stringit(yr1) + ', ' + stringit(yr2)
	print, ' first bin:  ' + stringit(v1) + ' <= value < ' + $
					stringit(v1 + binsize)
	print, '  last bin:  ' + stringit(xr2-binsize2) + ' <= value < ' + $
					stringit(xr2 + binsize2)
endif
print
;
;	Print warning information.
;
if not keyword_set(warnoff) then begin
	print, 'Note - only half of histogram drawn for first and last bins !'
	print
endif
;
;	Optionally open a new window.
;
if not keyword_set(currw) then  window, /free
;
;	Plot the histogram.
;
plot, x, h, xrange=xrange, yrange=yrange, psym=10, xstyle=1, $
	title=title, charsize=1.2
;
end

