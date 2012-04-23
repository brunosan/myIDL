;  generate cont., field strength, fill factor, inclination,
;  flux, azimuth images for comparison with Mees polarimeter data

;----------------------------
;	GET DATA
;----------------------------

;  continuum image
cct = b_image('a__cct')

;  field strength image
fld = b_image('a_fld')

;  fill factor from scattered light fraction
fil = b_image('a_alpha')
fil = 1.-fil

;  inclination image
psi = b_image('a_psi')

;  flux image
flx = fld*fil*cos(psi/!radeg)

;  azimuth image
azm = b_image('a_1azm')

;----------------------------
;	PLOT DATA
;----------------------------
;
;	Set up colormap.
;
colorw					; install special colormap
ncolor = get_ncolor()
nodat = where(fld eq 0.0)		; unfitted points
;
;	Scale images for colormap.
;
cctb = scalew(cct, ncolor)
fldb = scalew(fld, ncolor, nodat)
filb = scalew(fil, ncolor, nodat)
psib = scalew(psi, ncolor, nodat)
flxb = scalew(flx, ncolor, nodat)
azmb = scalew(azm, ncolor, nodat)
;
;	Plot images.
;
xstart = 20
xpos = xstart
ypos = 650
xs = sizeof(cctb, 1)
ys = sizeof(cctb, 2)
xinc = xs + 20
yinc = ys + 50
window, /free, xsize=xs, ysize=ys, xpos=xpos, ypos=ypos, $
	title='continuum'
tv,cctb

xpos = xpos + xinc
window, /free, xsize=xs, ysize=ys, xpos=xpos, ypos=ypos, $
	title='field strength'
tv,fldb

xpos = xpos + xinc
window, /free, xsize=xs, ysize=ys, xpos=xpos, ypos=ypos, $
	title='fill fraction'
tv,filb

xpos = xstart
ypos = ypos - yinc
window, /free, xsize=xs, ysize=ys, xpos=xpos, ypos=ypos, $
	title='inclination'
tv,psib

xpos = xpos + xinc
window, /free, xsize=xs, ysize=ys, xpos=xpos, ypos=ypos, $
	title='gauss equiv. flux'
tv,flxb

xpos = xpos + xinc
window, /free, xsize=xs, ysize=ys, xpos=xpos, ypos=ypos, $
	title='azimuth -- local'
tv,azmb

;----------------------------
;	SAVE DATA
;----------------------------

;save,cct,fld,fil,psi,flx,azm,filename='19.asp_18'

; save fits files
;idl_fits,cct,'7.cct_19'
;idl_fits,fld,'7.fld_19'
;idl_fits,flx,'7.flx_19'
