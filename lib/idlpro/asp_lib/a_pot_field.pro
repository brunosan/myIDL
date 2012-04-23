pro a_pot_field, dir, dummy
;+
;
;	procedure:  a_pot_field
;
;	purpose:  in an asp directory with a_* files do the Univ of Hi
;		  potential feild calculation.  Input is the local frame
;		  mag field normal to the surface.  Output are
;		  field strength and azimuth inclination files:
;		  a_pot_fld, a_pot_azm, a_pot_psi.
;
;	author:   paul@ncar 7/94
;
;=============================================================================
;
;	Check number of parameters.
;
if n_params() gt 1 then begin
	print
	print, "usage:	a_pot_field[,dir]"
	print
	print, "	In an asp directory with a_* files do the Univ of Hi"
	print, "	potential feild calculation.  Input is the local frame"
	print, "	magnetic field normal to the surface.  The total"
	print, "	field strength is output to file a_pot_fld."
	print, "	The potential field azimuth is output to"
	print, "	a_pot_azm (-180. to 180.).  The zenith angle"
	print, "	is output to a_pot_psi (0. to 180.)."
	print
	print, "	Argument"
	print, "		dir	- directory path (string;"
	print, "			  def=use current working directory)"
	print
	return
endif
;-
;						7/6/94
;The procedure a_pot_field is in the stokes idl directory. 
;It does the University of Hawaii potential field calculation on
;an ASP directory with a_* files.
;
;It is assumed the a_* files have been disambiguated.
;Work is done in the local frame with stretched images.
;The program first computes the magnetic field component normal
;to the surface.  The normal component is input to the UH routine.
;The output is to two files.  The total magnetic field is output to
;a_pot_fld.  The azimuth is output to a_pot_azm.  The program takes
;about 8 minutes to run.
;
;The fft's may have a problem on some images.  There are steps
;where data is next to zero background.  There is background on the
;edge of stretched images and also where polarization is low.

				    ;Append directory name with / 
dty = ''
if n_elements(dir) ne 0 then  dty = dir
if dty ne '' then if strmid(dty,strlen(dty)-1,1) ne '/' then dty=dty+'/'

				    ;Read header, check for existence.
junk = read_floats( dty+'a___header', error )
if  error ne 0  then begin
	print, !err_string
	print, 'a_* files may not exit or wrong directroy path wrong'
	return
end
				    ;Read local frame field data.
psi = c_image( dty+'a_1incl', c_str=c         )
fld = c_image( dty+'a_fld',   c_str=c, /reuse )

				    ;Field strength normal to surface.
nfs = fld*cos(psi*(!pi/180.))
				    ;University of Hawaii potential field.
pot_field, 0., 0., nfs, px, py
				    ;Tolal field strength.
tfs = sqrt( nfs^2 + px^2 + py^2 )
				    ;Azimuth wrt west.
azm = atan(py,px)*(180./!pi)
				    ;Zenith angle.
zen = atan(sqrt(px^2+py^2),nfs)*(180./!pi)

				    ;Output data in vector form.
tmp = fltarr(c.nsolved)
tmp(c.vec_sxy) = tfs(c.sxy)  &  i = write_floats( dty+'a_pot_fld', tmp )
tmp(c.vec_sxy) = azm(c.sxy)  &  i = write_floats( dty+'a_pot_azm', tmp )
tmp(c.vec_sxy) = zen(c.sxy)  &  i = write_floats( dty+'a_pot_psi', tmp )
				
end
