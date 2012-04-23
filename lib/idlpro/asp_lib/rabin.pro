pro rabin, dummy
;+
;
;	procedure:  rabin
;
;	purpose:  generate cont., field strength, fill factor, inclination,
;		  flux, azimuth images for comparison w/ Mees polarimeter data
;		  (for Magnetograph Workshop)
;
;==============================================================================

if n_params() ne 0 then begin
	print
	print, "usage:  rabin"
	print
	print, "	Program to generate info for Magnetograph Workshop."
	print
	return
endif
;-

;  continuum image
cct = b_image('a__cct')
tvwin,cct,/free,title='continuum'

;  field strength image
fld = b_image('a_fld')
tvwin,fld,/free,title='field strength'

;  fill factor from scattered light fraction
fil = b_image('a_alpha')
fil = 1.-fil
tvwin,fil,/free,title='fill fraction'

;  inclination image
psi = b_image('a_psi')
tvwin,psi,/free,title='inclination

;  flux image
flx = fld*fil*cos(psi/!radeg)
tvwin,flx,/free,title='gauss equiv. flux'

;  azimuth image
;azm = b_image('a_1azm')
;tvwin,azm,/free,title='azimuth -- local'

flb = bytscl(fld)
ccb = bytscl(cct)
flb = bytscl(flx)
psb = bytscl(psi)

stop

;save,cct,fld,fil,psi,flx,azm,filename='19.asp_18'

; save fits files
;idl_fits,cct,'7.cct_19'
;idl_fits,fld,'7.fld_19'
;idl_fits,flx,'7.flx_19'

end
