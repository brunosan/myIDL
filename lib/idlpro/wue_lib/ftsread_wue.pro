pro ftsread,data,wl,nblocks,xlam=xlam,dir=tdir,plot=iplot
;+
; NAME:
;	FTSREAD
; PURPOSE:
;	Extract spectral data from the Kitt Peak FTS-Spectral-Atlas
;	as provided by H. Neckel, Hamburg.
; CATEGORY:            @CAT-# 31 32 25@
;	Spectral Analysis , Spectral Lines Identification , Plotting
; CALLING SEQUENCE:
;	FTSREAD,data [,lambda_start , {lambda_end | nblocks}] ...
;               ... [,XLAM=xlam] [,/PLOT]
; INPUTS:
;	data    : Name of variable to store the profile
;	NBLOCKS : Number of blocks to extract (1000 mA each) or end
; 	          wavelength in Angstroem 
; OPTIONAL INPUT:
;	lambda_start  : Starting wavelength in Angstroem ( >= 3290)
;	          If not specified (only ONE non-keyword variable on call),
;		  the procedure will querry user for starting and end value.
;       lambda_end    : End wavelength in Angstroem ( <= 12510)
;          or :
;	nblocks : Number of blocks to extract (1000 mA each); this will be
;		  assumed if specified value is less than lambda_start.
; 	   If not specified,  the procedure will querry user for an end value.
;       DIR=dir : string, the directory to be used for local file. 
;	          Usefull for example if the current directory is not 
;		  mounted on daisy.
;       /PLOT   : if set, the selected part of the atlas will be plotted 
;		  on the active device.
; OUTPUTS:
;	DATA    : Array, name of variable to store the spectral data.
; 	          Stepwidth is 2mA, i.e. 500 points are 1 Angstroem.
; OPTIONAL OUTPUT:
;       XLAM=x  : x must be a named variable; the wavelength values is 
;	          returned in this variable.
; RESTRICTIONS:
; 	Environment variable SPECTRAL_DATA can be set to the
;	directory where the spectral data is stored. Otherwise
; 	/dat/daisy_2/spectral_atlas or /dat/goofy_2/spectral_atlas is used.
;       The original data in the atlas by H. Neckel span the range from 
;       3290 A to 12510 A.  They are based on Fourier-Transform-Spectra from
; 	the Kitt Peak Observatory taken by J. Brault et al.  Due to the
; 	nature of FTS-spectra (equidistancial in inverse wavenumbers),
; 	the wavelength-resolution varies from 3.66mA at 3290 A to 17.58
; 	mA at 12510 A. For this compilation, the data has been
; 	interpolated for a fixed stepwidth of 2mA. Therefore keep in
; 	mind that these data DON'T show the real resolution of the spectra.
; PROCEDURE:
;       If some input data is missing, the user is prompted to type them
; 	in.  The data is stored in an file (fortran unformatted
; 	integer), so one block (1A) equals 1000 Byte. A 'dd'-command is
; 	spawned to daisy (because /dat/daisy_2 is not mounted on all
; 	computers) with the neccessary skip- and count-numbers computed
; 	from the input wavelengths. These data are stored in a file
; 	'.tmp' either in the local directory (default) or the directory
; 	specified by the DIR-keyword.
;	DATA is read in from .tmp, then the temporary file is deleted.
; MODIFICATION HISTORY:
;	PS  (KIS)  1992-06-12
;       nlte (KIS)  1993-04-08: plot-option, atlas on DAISY or GOOFY
;				English messages.
;	ported to wuerzburg by j.hofmann 04.1993
;---

on_error,2

up=string(byte([27,91,65]))
left='            '
left=left+string(byte([27,91,68,27,91,68,27,91,68,27,91,68,27,91,68, $
   27,91,68,27,91,68,27,91,68,27,91,68,27,91,68,27,91,68,27,91,68]))

sdir=getenv('SPECTRAL_DATA')
; set the full path name of FTS-atla file::
if sdir eq '' then sdir='/tmp2/spectral_atlas'
if not keyword_set(tdir) then cd,'.',current=tdir

if n_params() lt 1 then $
   message,'usage: FTSREAD,data [,lambda_start,{lambda_end | nblocks}] [,XLAM=xlam] [,/PLOT]'

if n_params() lt 2 then begin
;  print,'Leseprogramm:'
;  print,'Extrahieren von Bloecken beliebiger Laenge aus'
  print,'Extract a wavelength range from the Kitt Peak FTS-Spectral-Atlas'
  print,'    (J. Brault et al., H.Neckel)'
  print & print
  repeat begin
    ok=0
    writeu,-1,up,'Enter starting wavelength (3290 - 12508 A)',left
    read,wl & wl=fix(wl)
  endrep until wl ge 3290 and wl lt 12509
endif
if n_params() lt 3 then begin
  print
  writeu,-1,'Enter end wavelength (3290 - 12508 A, must be > start wavel.)'
  writeu,-1,'  or number of blocks of 1 A size' 
  read,nblocks
  nblocks=fix(nblocks>1)
endif

if nblocks gt wl then nblocks=nblocks-wl

if (wl lt 3290) or (wl gt 12508) then $
  message,'Wavelength-range 3290 to 12510 A only !!'
if (wl+nblocks) gt 12509 then begin
  message,'Limit wavelength 12509 A. Cutting upper boundary...',/cont
  nblocks=12509-wl
endif

skip=fix(wl-3290)
cmd='dd if='+sdir+'/fts_cent.dat of='+tdir+ $
    '/.tmp bs=1000 skip='+strtrim(skip,1)+' count='+strtrim(nblocks,1)

print,cmd
spawn,cmd

xlam=findgen(500l*nblocks)*.002+wl
data=intarr(500l*nblocks)
openr,unit,tdir+'/.tmp',/get_lun
readu,unit,data
free_lun,unit
spawn,'rm '+tdir+'/.tmp'

if keyword_set(iplot) then begin
   if min(data) ge 8000 then imin=8000 else imin=0
   if max(data) le 2000 then imax=2000 else imax=10000
   plot,xlam,data,$
   yrange=[imin,imax],tit='Kitt Peak FTS-Spectral-Atlas',xtit='Wavelength [A]'
endif

end
