pro getiiii, cct, fld, azm, incl, pix_degree, op, date
;+
;
;	procedure:  getiiii
;
;	purpose:  read and set up images to plot in pltiiii.pro
;
;	author:  rob@ncar, 1/93		(mods: paul@ncar, 6/93)
;
;	returned:  cct = continuum
;		   fld = field strength
;		   azm = field azimuth
;		   incl = field inclination
;		   pix_degree = pixels/degree
;		   op = operation number
;		   date = date string for plot, e.g., '25 Mar 92'
;
;	notes: various parameters are HARDWIRED
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 7 then begin
	print
	print, "usage:  getiiii, cct, fld, azm, incl, pix_degree, op"
	print
	print, "	Read and set up images to plot in pltiiii.pro."
	print
	return
endif
;-
;
;	Set operation number and directory containing data.
;
;---------------
;
;	HARDWIRED
;
;;op = 2
;;pip_min = 0.4	; best for single spot regions
;;date = '25 Mar 92'
;;dir = '/hilo/d/asp/data/red/92.03.25/op02/'

op = 5
pip_min = 0.8	; best for active region maps
date = '25 Mar 92'
dir = '/hilo/d/asp/data/red/92.03.25/op05/'

;;op = 7
;;pip_min = 0.4	; best for single spot regions
;;date = '17 June 92'
;;dir = '/hilo/d/asp/data/red/92.06.17/op07/'
;;op = 18
;;pip_min = 0.4	; best for single spot regions
;;date = '17 June 92'
;;dir = '/chuka/d/asp/data/raw/92.06.17/op18/'

;;op = 19
;;pip_min = 0.4	; best for single spot regions
;;date = '18 June 92'
;;dir = '/swing/d1/asp/data/red/92.06.18/op19/'
;;op = 22
;;pip_min = 0.4	; best for single spot regions
;;date = '18 June 92'
;;dir = '/kenobi/d/asp/data/red/92.06.18/op22/'

;;op = 7
;;pip_min = 0.4	; best for single spot regions
;;date = '19 June 92'
;;dir = '/hilo/d/asp/data/red/92.06.19/op07/'
;;op = 9
;;pip_min = 0.4	; best for single spot regions
;;date = '19 June 92'
;;dir = '/aspen/asp/data/red/92.06.19/op09/'

;;op = 7
;;pip_min = 0.8	; best for active region maps
;;date = '19 June 92'
;;dir = '/hilo/d/asp/data/red/92.06.19/op07/'
;;pix_degree = 40.0	; number of pixels/degree

;---------------
;
;	Get the data into IDL.
;
c__cct  = c_image( dir+'a__cct',  c_str=c, pix_deg=pix_degree )
c_fld   = c_image( dir+'a_fld',   c_str=c, /reuse             )
c_1incl = c_image( dir+'a_1incl', c_str=c, /reuse             )
c_1azm  = c_image( dir+'a_1azm',  c_str=c, /reuse             )
c__pip  = c_image( dir+'a__pip',  c_str=c, /reuse             )
;
;	Set where() arrays for background locations.
;
cbkg = replicate( 1, c.xdim, c.ydim )
cbkg( c.pxy ) = 0
cbkg = where( cbkg, ncbkg )
;
fbkg = replicate( 1, c.xdim, c.ydim )
fbkg( c.sxy ) = 0
fbkg = where( fbkg, nfbkg )
;
;Get where array for magnetic field reversal.
;
reversal = reversal( c_1incl, c__pip, c, pip_min=pip_min )
ifrev = sizeof( reversal, 0 )
;
;	Set continuum image.
;
cct = (c.cct_min > c__cct < c.cct_max ) $	; scale out extreme values
      - c.cct_min
if ifrev ne 0 then   cct(reversal) = -2.0	; set contour flags
if ncbkg ne 0 then   cct(cbkg    ) = -1.0	; set no-data flags
;
;	Set field magnitude image.
;
fld = 0.0 > c_fld < 4000.0			; truncate extreme values
if ifrev ne 0 then   fld(reversal) = -3.0	; set contour flags
if nfbkg ne 0 then   fld(fbkg    ) = -1.0	; set no-data flags
;
;	Set field azimuth image.
;
azm = c_1azm
w = where(azm lt 0.0, nw)
if nw ne 0 then  azm(w) = azm(w)+360.0		; shift up negative values
if ifrev ne 0 then   azm(reversal) = -3.0	; set contour flags
if nfbkg ne 0 then   azm(fbkg    ) = -1.0	; set no-data flags
;
;	Set field inclination image.
;
incl = c_1incl
if ifrev ne 0 then  incl(reversal) = -3.0	; set contour flags
if nfbkg ne 0 then  incl(fbkg    ) = -1.0	; set no-data flags
;
end
