pro plot_ps3, im1, im2, im3, range1, range2, range3
;+
;
;	Plot three images for Bruce in PS -- from his fig4.pro (see gen4.pro).
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 6 then begin
	print
	print, "usage:  plot_ps3, im1, im2, im3, range1, range2, range3"
	print
	print, "	Plot three images for Bruce in PS."
	print
	return
endif
;-

;
;	Convert the images to byte indices; also invert the indices
;	so go from white to black, i.e., reverse the grayscale.
;
image1 = 255 - bytscl(im1)
image2 = 255 - bytscl(im2)
image3 = 255 - bytscl(im3)
;
;	Set plotting variables.
;
xsize_im1 = 0.7
ysize_im1 = 0.3
xsize_im2 = xsize_im1
ysize_im2 = ysize_im1
xsize_im3 = xsize_im1
ysize_im3 = 0.15
x_im1_p1 = 0.20
y_im1_p1 = 0.12
x_im2_p1 = x_im1_p1
y_im2_p1 = 0.46
x_im3_p1 = x_im1_p1
y_im3_p1 = 0.80
x_im1_p2 = x_im1_p1 + xsize_im1
y_im1_p2 = y_im1_p1 + ysize_im1
x_im2_p2 = x_im2_p1 + xsize_im2
y_im2_p2 = y_im2_p1 + ysize_im2
x_im3_p2 = x_im3_p1 + xsize_im3
y_im3_p2 = y_im3_p1 + ysize_im3
xoff = 0.055
yoff = 0.07
xa_im1 = x_im1_p1 + xoff
ya_im1 = y_im1_p2 - yoff
xa_im2 = x_im2_p1 + xoff
ya_im2 = y_im2_p2 - yoff
thick = 7.0
charthick = 1.5
charsize = 2.0
nochar = 0.01
!p.font = 0
;
;	Set the device type to high-resolution PostScript.
;
set_plot, 'ps'
device, bits_per_pixel=8, file='idl.ps', scale_factor=1.0, /inches, $
	xoffset=0.0, yoffset=0.0, xsize=8.5, ysize=11.0, /helvetica, /bold
;
;	Plot and annotate the 1st image (Fe I).
;
tick = findgen(3) * 5.0
tv, image1, x_im1_p1, y_im1_p1, xsize=xsize_im1, ysize=ysize_im1, /normal
plot, range1(*, 0), range1(*, 1), /nodata, /noerase, /ynozero, /normal, $
	xthick=thick, ythick=thick, $
	xstyle=1, ystyle=1, xticklen=.06, yticklen=.04, $
	ytickv=tick, charsize=charsize, $
	position=[x_im1_p1, y_im1_p1, x_im1_p2, y_im1_p2], xminor=1
xyouts, xa_im1, ya_im1, 'Fe I', size=2.0, charthick=charthick, /normal
;
;	Plot and annotate the 2nd image (Ca II).
;
tv, image2, x_im2_p1, y_im2_p1, xsize=xsize_im2, ysize=ysize_im2, /normal
plot, range2(*, 0), range2(*, 1), /nodata, /noerase, /ynozero, /normal, $
	xstyle=1, ystyle=1, xticklen=.06, yticklen=.04, $
	ytickv=tick, xcharsize=nochar, ycharsize=charsize, $
	position=[x_im2_p1, y_im2_p1, x_im2_p2, y_im2_p2], xminor=1, $
	xthick=thick, ythick=thick
xyouts, xa_im2, ya_im2, 'Ca II', size=2.0, charthick=charthick, /normal
;
;	Plot and annotate the 3rd image (T-A Ca II H-Line).
;
for i =0,2 do begin
	tick(i) = - 40. + 40.*i	; change for delta lambda of 40 pm
endfor
tv, image3, x_im3_p1, y_im3_p1, xsize=xsize_im3, ysize=ysize_im3, /normal
plot, range3(*, 0), range3(*, 1), /nodata, /noerase, /ynozero, /normal, $
	xstyle=1, ystyle=1, yticklen=.04, xticklen=.1, $
	yticks=2, ytickv=tick, xcharsize=nochar, ycharsize=charsize, $
	position=[x_im3_p1, y_im3_p1, x_im3_p2, y_im3_p2], xminor=1, $
	xthick=thick, ythick=thick
;
;	Annotate more of the plot.
;
xa = 0.09
ya = y_im1_p1 + (y_im2_p2 - y_im1_p1) / 2
xyouts, xa, ya, 'FREQUENCY (mHz)', /normal, $
	orientation=90, size=2.0, charthick=charthick, align=0.5
ya = y_im3_p1 + ysize_im3 / 2
xyouts, xa, ya, '!9l!4(pm)', /normal, $
	orientation=90, size=2.0, charthick=charthick, align=0.5
xa = x_im1_p1 + xsize_im1 / 2
ya = 0.03
xyouts, xa, ya, 'DISTANCE ALONG SLIT (Mm)', /normal, $
	size=2.0, charthick=charthick, align=0.5
ya = 0.96
xyouts, xa, ya, 'Time-Averaged Ca II H-Line', /normal, $
	size=1.7, charthick=charthick, align=0.5
;
;	Flush the PS plot and return to X Windows.
;
device, /close_file
set_plot, 'x'
;
;	Done.
;
return
end
