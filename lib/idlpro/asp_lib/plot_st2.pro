pro plot_st2, array
;+
;
;	procedure:  plot_st2
;
;	purpose:  plot results of get_st2.pro
;
;	author:  rob@ncar, 10/92
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 1 then begin
	print
	print, "usage:  plot_st2, array"
	print
	print, "	Plot results of get_st2.pro."
	print
	print
	print, "   ex:"
	print, "	get_st2, ..., results"
	print, "	plot_st2, results"
	print
	return
endif
;-
;
;	Set plotting variables.
;
lnew = 0				; solid new line
lold = 1				; dotted old line
xsize = 1100				; size of plot in pixels
ysize = 800
charsize = 2.0				; increase character size
!p.multi = [0, 3, 2, 0, 0]		; set to 3x2 plots
;
;	Get extrema, and set to plot Q and U with same Y-range.
;
minqu_min = min(array(*,0,1:2,*), max=maxqu_min)
minqu_max = min(array(*,1,1:2,*), max=maxqu_max)
;
minv_min = min(array(*,0,3,*), max=maxv_min)
minv_max = min(array(*,1,3,*), max=maxv_max)
;
yrangequ_min = [minqu_min, maxqu_min]
yrangequ_max = [minqu_max, maxqu_max]
;
yrangev_min = [minv_min, maxv_min]
yrangev_max = [minv_max, maxv_max]
;
;	Set X-axis to be azimuth.
;
x_azim = array(0, 0, 4, *)
mina = min(x_azim, max=maxa)
xrange = [mina, maxa]
;
;	Open new window.
;
title = 'St''s  vs.  Azimuth             old = dotted          new = solid'
window, xsize=xsize, ysize=ysize, /free, title=title
;
;	Plot +'s.
;
plot, x_azim, array, /nodata, yrange=yrangequ_min, xrange=xrange, $
	title='Q +', charsize=charsize
oplot, x_azim, array(0,0,1,*), line=lold
oplot, x_azim, array(1,0,1,*), line=lnew
plot, x_azim, array, /nodata, yrange=yrangequ_min, xrange=xrange, $
	title='U +', charsize=charsize
oplot, x_azim, array(0,0,2,*), line=lold
oplot, x_azim, array(1,0,2,*), line=lnew
plot, x_azim, array, /nodata, yrange=yrangev_min, xrange=xrange, $
	title='V +', charsize=charsize
oplot, x_azim, array(0,0,3,*), line=lold
oplot, x_azim, array(1,0,3,*), line=lnew
;
;	Plot -'s.
;
plot, x_azim, array, /nodata, yrange=yrangequ_max, xrange=xrange, $
	title='Q -', charsize=charsize
oplot, x_azim, array(0,1,1,*), line=lold
oplot, x_azim, array(1,1,1,*), line=lnew
plot, x_azim, array, /nodata, yrange=yrangequ_max, xrange=xrange, $
	title='U -', charsize=charsize
oplot, x_azim, array(0,1,2,*), line=lold
oplot, x_azim, array(1,1,2,*), line=lnew
plot, x_azim, array, /nodata, yrange=yrangev_max, xrange=xrange, $
	title='V -', charsize=charsize
oplot, x_azim, array(0,1,3,*), line=lold
oplot, x_azim, array(1,1,3,*), line=lnew
;
;	Reset to one plot per page.
;
!p.multi = 0
end
