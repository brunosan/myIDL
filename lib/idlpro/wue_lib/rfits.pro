;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; NAME:
;		RFITS
; PURPOSE:
;		Read FITS data files
; CATEGORY:
;
; CALLING SEQUENCE:
;		RFITS, filename,header,data
; INPUTS:
;		filename	: name of disk file in FITS Format
; OUTPUTS:
;		header		: some basic header information 
;				  retrieved from the FITS header
;		data		: data array as in the FITS file
; RESTRICTIONS:
;		i) to 1D and 2D data (may be easily expanded)
;		ii) to bitpix values of 8,16,32 and -32,-64
;		iii) does not read table FITS or the like.
; NOTES:
;
; EXAMPLES:
;
; MODIFICATION HISTORY:
;		written 1991 by Reinhold Kroll
;		last update 1.Apr.92 rkr
;
;-----------------------------------------------------------------------
;
pro rfits,file,header,data
;
;  read a 1 or 2 dimensional fits file (may be easily expanded for n dim.)
;  Reinhold Kroll
;  written 1991 by Reinhold Kroll
;  Last Update 20.Feb.92 Reinhold Kroll
;
on_error,2	;  return to caller if error
hd=bytarr(80,36)
header={fitsheader,simple:'F',bitpix:8,naxis:lonarr(3),origin:' ', $
                   bscale:1.,bzero:0.,crval:fltarr(3),crpix:fltarr(3), $
                   cdelt:fltarr(3),object:' ',date:' ',  $ 
		   history:strarr(200) }
get_lun,lun
openr,lun,file
ihist=0
header.bscale=1.
header.bzero=0.
	WHILE eof(lun) NE 1 DO BEGIN
	readu,lun,hd
		for j=0,35 do BEGIN
		key=string(hd(0:7,j))
                value=string(hd(10:29,j))
			case key of
			"SIMPLE  ": header.simple=string(hd(29,j))
			"BITPIX  ": header.bitpix=fix(value)
			"NAXIS   ": header.naxis(0)=long(value)
			"NAXIS1  ": header.naxis(1)=long(value)
			"NAXIS2  ": header.naxis(2)=long(value)
			"BSCALE  ": header.bscale=float(value)
			"BZERO   ": header.bzero=float(value)
			"ORIGIN  ": header.origin=string(value)
			"OBJECT  ": header.object=string(value)
			"DATE    ": header.date=string(value)
			"CRVAL1  ": header.crval(1)=float(value)
			"CRVAL2  ": header.crval(2)=float(value)
			"CRPIX1  ": header.crpix(1)=float(value)
			"CRPIX2  ": header.crpix(2)=float(value)
			"CDELT1  ": header.cdelt(1)=float(value)
			"CDELT2  ": header.cdelt(2)=float(value)
			"HISTORY ": BEGIN
				    header.history(ihist)=string(hd(8:79,j))
				    ihist=ihist+1
				    END
			"END     ": goto, data
			ELSE:
			ENDCASE
		ENDFOR
	ENDWHILE
data:
CASE header.naxis(0) OF

1: BEGIN  				; one dimensional case
	data=fltarr(header.naxis(1))    ; define data array
		CASE header.bitpix OF
		 8: idata=bytarr(header.naxis(1))
		16: idata=intarr(header.naxis(1))
		32: idata=lonarr(header.naxis(1))
               -32: idata=fltarr(header.naxis(1))
               -64: idata=dblarr(header.naxis(1))
		ENDCASE
   END

2: BEGIN				;  twodimensional case
	data=fltarr(header.naxis(1),header.naxis(2))  ; define data array
		CASE header.bitpix OF
		 8: idata=bytarr(header.naxis(1),header.naxis(2))
		16: idata=intarr(header.naxis(1),header.naxis(2))
		32: idata=lonarr(header.naxis(1),header.naxis(2))
	       -32: idata=fltarr(header.naxis(1),header.naxis(2))
	       -64: idata=dblarr(header.naxis(1),header.naxis(2))
		ENDCASE
   END
ENDCASE

readu,lun,idata
close,lun
free_lun,lun
data = idata * header.bscale + header.bzero

end
