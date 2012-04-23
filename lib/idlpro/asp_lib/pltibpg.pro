pro pltibpg, im1, im2, im3, im4, range_a, range_b
;+
;
;	Plot four images in PS -- genibpg.pro generates images.
;
;	ex:  pltibpg, im1, im2, im3, im4, range1, range
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 6 then begin
	print
	print, "usage:  pltibpg, im1, im2, im3, im4, rangea, rangeb"
	print
	print, "	Plotting code for Bruce... (see genibpg.pro)."
	print
	return
endif
;-

; ranges for color bars (pass in!)
range_c = intarr(2, 4)
range_c(0, 1) = -3500
range_c(1, 1) = 3500
range_c(0, 2) = 0
range_c(1, 2) = 180
range_c(0, 3) = 0
range_c(1, 3) = 180
;
;	Install special color table.
;
@wrap.com
newwct, 1
;
;	Convert the images to byte indices using special color table.
;
image1 = wrap_scalew(im1, 1, range_b(0, 0), range_b(1, 0))
image2 = wrap_scalew(im2, 5, range_b(0, 1), range_b(1, 1))
image3 = wrap_scalew(im3, 4, range_b(0, 2), range_b(1, 2))
image4 = wrap_scalew(im4, 3, range_b(0, 3), range_b(1, 3))
;
;	Set plotting variables.

;  overall size of image display
xlen_dev = 8.5
ylen_dev = 10.5
set_plot, 'ps'
color = 0		; grayscale
color = 1		; color
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
yoff = .17

;x-, y-offsets of second spectral image from first
x2 = .40
y2 = .42

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
plot, range_a(*, 0), range_a(*, 1), /nodata, /noerase, /ynozero, /normal, $
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
plot, range_a(*, 0), range_a(*, 1), /nodata, /noerase, /ynozero, /normal, $
	xstyle=1, ystyle=1, charsize=1.5, xticklen=.04, yticklen=.04, $
 xcharsize=.0001, ycharsize=.00001, $
	position=[x_im2_p1, y_im2_p1, x_im2_p2, y_im2_p2], xminor=1, $
        yminor=1,  charthick=1.8
x = x_im2_p1
y = y_im2_p1 - 1.6 * ylen_cbar
ix1 = ix_color3a
ix2 = ix_color3b + num_color3h - 1
displayctn, ix1, ix2, x, y, xlen_cbar, ylen_cbar, half=num_color3h
yoff_ctxt = .02
xyouts, x, y - yoff_ctxt, stringit(range_c(0,1)), $
	charsize=1.5, charthick=1.8, /normal
xyouts, x + xlen_norm, y - yoff_ctxt, stringit(range_c(1,1)), $
	charsize=1.5, charthick=1.8, /normal, align=1.0

;
;	Plot and annotate the 3rd image
;
tv, image3, x_im3_p1, y_im3_p1, xsize=xlen_norm, ysize=ylen_norm, /normal
plot, range_a(*, 0), range_a(*, 1), /nodata, /noerase, /ynozero, /normal, $
	xstyle=1, ystyle=1, charsize=1.5, xticklen=.04, yticklen=.04, $
 xcharsize=1.1, ycharsize=1.1, xtitle='!17E                        W',$
         ytitle='!17S                        N',  $
	position=[x_im3_p1, y_im3_p1, x_im3_p2, y_im3_p2], xminor=1, $
        yminor=1,  charthick=1.8
x = x_im3_p1
y = y_im3_p1 - 3.3 * ylen_cbar
ix1 = ix_color
ix2 = ix_color + num_color - 1
;;displayctn, ix1, ix2, x, y, xlen_cbar, ylen_cbar
;;xyouts, x, y - yoff_ctxt, stringit(range_c(0,2)), $
;;	charsize=1.5, charthick=1.8, /normal
;;xyouts, x + xlen_norm, y - yoff_ctxt, stringit(range_c(1,2)), $
;;	charsize=1.5, charthick=1.8, /normal, align=1.0
rad2 = 0.04
coff = 0.125
x = x_im3_p1 + 0.5 * xlen_norm - rad2
y = y_im3_p1 - coff
wrap_key, x, y, rad2, 2, 4
yy = y + 0.7*rad2
xyouts, x + rad2 * 2 + 0.01, yy, '0', charsize=1.2, /normal, align=0.0
xyouts, x - 0.01, yy, '180', charsize=1.2, /normal, align=1.0
xyouts, x + rad2, y - 0.02, '270', charsize=1.2, /normal, align=0.5
xyouts, x + rad2, y + rad2 + 0.025, '90', charsize=1.2, /normal, align=0.5

;
;	Plot and annotate the 4th image
;
tv, image4, x_im4_p1, y_im4_p1, xsize=xlen_norm, ysize=ylen_norm, /normal
plot, range_a(*, 0), range_a(*, 1), /nodata, /noerase, /ynozero, /normal, $
	xstyle=1, ystyle=1, charsize=1.5, xticklen=.04, yticklen=.04, $
 xcharsize=1.1, ycharsize=.0001, xtitle='!17E                        W',$
	position=[x_im4_p1, y_im4_p1, x_im4_p2, y_im4_p2], xminor=1, $
        yminor=1,  charthick=1.8
x = x_im4_p1
y = y_im4_p1 - 3.3 * ylen_cbar
ix1 = ix_color2
ix2 = ix_color2 + num_color2 - 1
;;displayctn, ix1, ix2, x, y, xlen_cbar, ylen_cbar
;;xyouts, x, y - yoff_ctxt, stringit(range_c(0,3)), $
;;	charsize=1.5, charthick=1.8, /normal
;;xyouts, x + xlen_norm, y - yoff_ctxt, stringit(range_c(1,3)), $
;;	charsize=1.5, charthick=1.8, /normal, align=1.0
x = x_im4_p1 + 0.5 * xlen_norm - 0.5 * rad2
y = y_im4_p1 - coff
wrap_key, x, y, rad2, 1, 3
xx = x - 0.02
xyouts, xx, y, '180', charsize=1.2, /normal, align=1.0
xyouts, xx, y+rad2*1.2, '0', charsize=1.2, /normal, align=1.0


;annotate the individual plots
xyouts,x_im1_p1+.03,y_im1_p2+.01, '!17Continuum Intensity', $
	 charsize=1.5, $
	charthick=1.8, /normal

xyouts,x_im2_p1+.03,y_im1_p2+.01, '!17Signed Field (Gauss)', $
	 charsize=1.5, $
	charthick=1.8, /normal

xyouts,x_im3_p1+.02,y_im3_p2+.01, '!17Field Azimuth (degrees)', $
	 charsize=1.5, $
	charthick=1.8, /normal

xyouts,x_im4_p1,y_im4_p2+.01, '!17Field Inclination (degrees)', $
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

