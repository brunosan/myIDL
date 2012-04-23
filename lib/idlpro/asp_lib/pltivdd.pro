pro pltivdd, im1, im2, im3, im4, range1
;+
;
;	Plot four images in PS -- genivdd.pro generates images.
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 5 then begin
	print
	print, "usage:  pltivdd, im1, im2, im3, im4, range1"
	print
	print, "	Plotting code for Bruce... (see genivdd.pro)."
	print
	return
endif
;-

;
;	Convert the images to byte indices.
;
;image2 = 255 - bytscl(im2)
;image3 = 255 - bytscl(im3)
;image4 = 255 - bytscl(im4)
;; image1 =  bytscl(im1)
;; image2 =  bytscl(im2)
;; image3 =  bytscl(im3)
;image4 =  bytscl(im4)
;

@wrap.com			; install fancy colormap
newwct, 3
image1 = wrap_scale(im1, 1)
image2 = wrap_scalew(im2, 4, 6000, 14000, /reverseit)
image3 = wrap_scalew(im3, 4, 2000, 6000) 
image4 = wrap_scalew(im4, 4, 0, 1000)
;
;	Set plotting variables.

;  overall size of image display
xlen_dev = 8.5
ylen_dev = 10.5
set_plot, 'ps'
color = 0
color = 1
device, bits_per_pixel=8, file='idl.ps', scale_factor=1.0, /inches, $
	xoffset=0.0, yoffset=0.25, xsize=xlen_dev, ysize=ylen_dev, color=color

;  determine size of input arrays
xlen_pix = sizeof(image1,1)
ylen_pix = sizeof(image1,2)

;  get rescaling factors to preserve aspect ratios
ratio1 = ylen_dev/xlen_dev
ratio2 = xlen_pix/ylen_pix
;  x-scaling slightly different to reflect difference in pixel sizes
ratio3 = 0.375/0.370

;  set width of image in units normalized to page width
ylen_norm = 0.30
xlen_norm = ylen_norm*ratio1*ratio2*ratio3

;offsets of first image in window, normalized units
xoff = .15
yoff = .15

;x-, y-offsets of second spectral image from first
x2 = .40
y2 = .44

;  set coordinate positions for images
x_im1_p1 = xoff
y_im1_p1 = yoff+y2
x_im2_p1 = x_im1_p1 + x2
y_im2_p1 = y_im1_p1
x_im3_p1 = xoff
y_im3_p1 = yoff
x_im4_p1 = x_im3_p1 + x2
y_im4_p1 = y_im3_p1
x_im1_p2 = x_im1_p1 + xlen_norm
y_im1_p2 = y_im1_p1 + ylen_norm
x_im2_p2 = x_im2_p1 + xlen_norm
y_im2_p2 = y_im2_p1 + ylen_norm
x_im3_p2 = x_im3_p1 + xlen_norm
y_im3_p2 = y_im3_p1 + ylen_norm
x_im4_p2 = x_im4_p1 + xlen_norm
y_im4_p2 = y_im4_p1 + ylen_norm


;  set character, line thickness
thick = 5.
!x.thick=thick
!y.thick=thick
charthick = 1.5
;
;	Set the device type to high-resolution PostScript.
;
set_plot, 'ps'

;
;	Plot and annotate the 1st image
;
tv, image1, x_im1_p1, y_im1_p1, xsize=xlen_norm, ysize=ylen_norm, /normal
plot, range1(*, 0), range1(*, 1), /nodata, /noerase, /ynozero, /normal, $
	xstyle=1, ystyle=1, charsize=1.5, xticklen=.04, yticklen=.04, $
 xcharsize=.0001, ycharsize=1.1, $
        title='!17 ', ytitle='!17S                        N',  $
	position=[x_im1_p1, y_im1_p1, x_im1_p2, y_im1_p2], xminor=1, $
        yminor=1,  charthick=1.8
xlen_cbar = xlen_norm
ylen_cbar = 0.03

;
;	Plot and annotate the 2nd image
;
tv, image2, x_im2_p1, y_im2_p1, xsize=xlen_norm, ysize=ylen_norm, /normal
plot, range1(*, 0), range1(*, 1), /nodata, /noerase, /ynozero, /normal, $
	xstyle=1, ystyle=1, charsize=1.5, xticklen=.04, yticklen=.04, $
 xcharsize=.0001, ycharsize=.00001, $
	position=[x_im2_p1, y_im2_p1, x_im2_p2, y_im2_p2], xminor=1, $
        yminor=1,  charthick=1.8
x = x_im2_p1
y = y_im2_p1 - 1.6 * ylen_cbar
displayctn, ix_color, ix_color + num_color - 1, x, y, xlen_cbar, ylen_cbar
yoff_ctxt = .02
xyouts, x, y - yoff_ctxt, stringit(-4), $
	charsize=1.5, charthick=1.8, /normal
xyouts, x + xlen_norm, y - yoff_ctxt, stringit(+4), $
	charsize=1.5, charthick=1.8, /normal, align=1.0

;
;	Plot and annotate the 3rd image
;
tv, image3, x_im3_p1, y_im3_p1, xsize=xlen_norm, ysize=ylen_norm, /normal
plot, range1(*, 0), range1(*, 1), /nodata, /noerase, /ynozero, /normal, $
	xstyle=1, ystyle=1, charsize=1.5, xticklen=.04, yticklen=.04, $
 xcharsize=1.1, ycharsize=1.1, xtitle='!17E                        W',$
         ytitle='!17S                        N',  $
	position=[x_im3_p1, y_im3_p1, x_im3_p2, y_im3_p2], xminor=1, $
        yminor=1,  charthick=1.8
x = x_im3_p1
y = y_im3_p1 - 3.3 * ylen_cbar
displayctn, ix_color, ix_color + num_color - 1, x, y, xlen_cbar, ylen_cbar
yoff_ctxt = .02
xyouts, x, y - yoff_ctxt, stringit(20), $
	charsize=1.5, charthick=1.8, /normal
xyouts, x + xlen_norm, y - yoff_ctxt, stringit(60), $
	charsize=1.5, charthick=1.8, /normal, align=1.0

;
;	Plot and annotate the 4th image
;
tv, image4, x_im4_p1, y_im4_p1, xsize=xlen_norm, ysize=ylen_norm, /normal
plot, range1(*, 0), range1(*, 1), /nodata, /noerase, /ynozero, /normal, $
	xstyle=1, ystyle=1, charsize=1.5, xticklen=.04, yticklen=.04, $
 xcharsize=1.1, ycharsize=.0001, xtitle='!17E                        W',$
	position=[x_im4_p1, y_im4_p1, x_im4_p2, y_im4_p2], xminor=1, $
        yminor=1,  charthick=1.8
x = x_im4_p1
y = y_im4_p1 - 3.3 * ylen_cbar
displayctn, ix_color, ix_color + num_color - 1, x, y, xlen_cbar, ylen_cbar
yoff_ctxt = .02
xyouts, x, y - yoff_ctxt, stringit(0), $
	charsize=1.5, charthick=1.8, /normal
xyouts, x + xlen_norm, y - yoff_ctxt, stringit(1), $
	charsize=1.5, charthick=1.8, /normal, align=1.0


;annotate the individual plots
xyouts,x_im1_p1+.03,y_im1_p2+.01, '!17Continuum Intensity', $
	 charsize=1.5, $
	charthick=1.8, /normal

xyouts,x_im2_p1+.03,y_im1_p2+.01, '!17Doppler Velocity (Km/s)', $
	 charsize=1.5, $
	charthick=1.8, /normal

xyouts,x_im3_p1+.02,y_im3_p2+.01, '!17   Doppler Width (mA)', $
	 charsize=1.5, $
	charthick=1.8, /normal

xyouts,x_im4_p1,y_im4_p2+.01, '!17      Damping Ratio', $
	 charsize=1.5, $
	charthick=1.8, /normal



;  annotate axes
xyouts, (xoff+.2), 0., '!17IMAGE SCALE: ARCSECONDS', $
	 charsize=1.5, $
	charthick=1.8, /normal

;  annotate the slide
xyouts,xoff+.03,.97,'!17HAO/NSO Advanced Stokes Polarimeter',charsize=2., $
  charthick=2.5, /normal
xyouts,xoff-.03,.94,'!17 25 Mar 92: NOAA AR7117, N6.8 E42.4, 15:08-15:25UT', $
  charsize=1.6, charthick=2.5, /normal

device, /close_file
set_plot, 'x'
end

