pro pf_next_in, unit, endfile, qualify $
, xp, yp, rgt, dec, ut, mdy $
, cct, fld, azm, psi $
, disper $
, wv, cn, c0 $
, np $
, iobs, qobs, uobs, vobs $
, iclc $
, imag, qclc, uclc, vclc $
, band
;+
;
;	procedure:  pf_next_in
;
;	purpose:  input next profile set from a *.pf file.
;
;	author:  paul@ncar, 9/94	(minor mod's by rob@ncar)
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() eq 0 then begin
	print
	print, "usage:	pf_next_in, unit, endfile, qualify $"
	print, "	, xp, yp, rgt, dec, ut, mdy $"
	print, "	, cct, fld, azm, psi $"
	print, "	, disper $"
	print, "	, wv, cn, c0 $"
	print, "	, np $"
	print, "	, iobs, qobs, uobs, vobs $"
	print, "	, iclc $"
	print, "	, imag, qclc, uclc, vclc $"
	print, "	, band"
	print
	print, "	Input next profile set from a *.pf file"
	print
	print, "	Input Argument"
	print, "		unit	- file unit."
	print
	print, "	Output Arguments"
	print, "		endfile	- 1 if endfile"
	print, "		qualify	- 1 if file qualifies as pf file"
	print, "		xp, yp	- raster point (x,y) position"
	print, "		rgt     - Arc seconds west of disk center"
	print, "		dec     - Arc seconds north of disk center"
	print, "		ut	- Universal time in hours"
	print, "		mdy	- vector [month,day,year]"
	print, "		cct	- continuum intensity"
	print, "		fld	- field strength, gauss"
	print, "		azm	- VTT azimuth, degrees"
	print, "		psi	- incline, degrees"
	print, "		disper	- dispersion, mA/pixel"
	print, "		wv	- wavelength of spectra line, A."
	print, "		cn	- calculated centers, pixel (FORTRAN)"
	print, "			  Three valued vector."
	print, "		c0	- initial centers, pixel (FORTRAN)"
	print, "			  Three valued vector"
	print, "		np	- dimension of profiles"
	print, "		iobs	- observed i profile"
	print, "		qobs	- observed q profile"
	print, "		uobs	- observed u profile"
	print, "		vobs	- observed v profile"
	print, "		iclc	- calculated i profile"
	print, "		imag	- calculated i profile magnetic"
	print, "		qclc	- calculated q profile"
	print, "		uclc	- calculated u profile"
	print, "		vclc	- calculated v profile"
	print, "		band	- np dimension array,"
	print, "			  1. for fitted points."
	print, "	Keyword"
	print, "		(none)"
	return
endif
;-
				    ;Check if file pointer is on eof.
endfile = eof(unit)
if endfile then begin
	print, "pf_next_in.pro: endfile"
	return
end
				    ;Read first two header line into string.
cccc = ''  &  readf, unit, cccc
bbbb = ''  &  readf, unit, bbbb
				    ;Qualify the header lines.
qualify = strmid(cccc,0,6) eq 'point:' and strmid(bbbb,0,8) eq '     Ic:'
if qualify eq 0 then begin
	print, "pf_next_in.pro: pf file format does not qualify"
	return
end
				    ;Set variables to take data.
lots = 1024
xp = 0L  &  yp = 0L  &  rgt = 0.  &  dec = 0.
ut = 0.  &  mdy = [0,0,0]
cct = 0. 
fld = 0.
azm = 0.
psi = 0.
disper = 0.
wv = [0.,0.,0.]
cn = [0.,0.,0.]
c0 = [0.,0.,0.]
iobs = fltarr(lots,/nozero)  &  iclc = fltarr(lots,/nozero)
qobs = fltarr(lots,/nozero)  &  qclc = fltarr(lots,/nozero)
uobs = fltarr(lots,/nozero)  &  uclc = fltarr(lots,/nozero)
vobs = fltarr(lots,/nozero)  &  vclc = fltarr(lots,/nozero)
imag = fltarr(lots,/nozero)  &  band = fltarr(lots,/nozero)

				    ;Read info from first two header line.
bb = '                                                             '
reads, cccc+bb+bb+bb, xp, yp, rgt, dec, ut, mdy $
, format = '(6x,2i5,13x,2f12.0,6x,f12.0,3(1x,i2))'
reads, bbbb+bb+bb+bb, cct, format='(8x, f12.0)'

				    ;Read rest of header.
readf, unit, fld,    format='(8x, f10.0)'
readf, unit, azm,    format='(8x, f10.0)'
readf, unit, psi,    format='(8x, f10.0)'
readf, unit, disper, format='(8x, f10.0)'
readf, unit, wv,     format='(8x,3f10.0)'
readf, unit, cn,     format='(8x,3f10.0)'
readf, unit, c0,     format='(8x,3f10.0)'

				    ;Skip column headers.
cccc = ''  &  readf, unit, cccc
				    ;Loop through reading wavelength space.
for i=0,lots do begin
				    ;Save file pointer.
	point_lun, -unit, position
				    ;Check for endfile.
	if eof(unit) then  goto, profiles_rdy

				    ;Read data line into string.
	cccc = ''
	readf, unit, cccc
				    ;Chcek if next point.
	if strmid(cccc,0,6) eq 'point:' then  goto, profiles_rdy

				    ;Read spectra.
	tmp = fltarr(11)
	reads, cccc, tmp
				    ;Move data to arrays.
	iobs(i) = tmp( 1)  &  iclc(i) = tmp( 5)
	qobs(i) = tmp( 2)  &  qclc(i) = tmp( 7)
	uobs(i) = tmp( 3)  &  uclc(i) = tmp( 8)
	vobs(i) = tmp( 4)  &  vclc(i) = tmp( 9)
	imag(i) = tmp( 6)  &  band(i) = tmp(10)

				    ;Set x dimension
	np = i+1
end
				    ;Data for raster point has been read.
profiles_rdy:
				    ;Truncate arrays.
iobs = iobs(0:np-1)  &  iclc = iclc(0:np-1)
qobs = qobs(0:np-1)  &  qclc = qclc(0:np-1)
uobs = uobs(0:np-1)  &  uclc = uclc(0:np-1)
vobs = vobs(0:np-1)  &  vclc = vclc(0:np-1)
imag = imag(0:np-1)  &  band = band(0:np-1)

				    ;Restore file pointer to last line read.
point_lun, unit, position

end
