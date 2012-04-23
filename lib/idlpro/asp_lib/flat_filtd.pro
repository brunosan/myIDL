pro flat_filtd, calfile_a, darkfile_a, clearfile_a, gainfile_a, $
		calfile_b, darkfile_b, clearfile_b, gainfile_b, $
		x1, x2, y1, y2, ixst, ihst, ihend, ilo, ihi, $
		wa1, wa2, wb1, wb2, $
		bad_a=bad_a, ffile_a=ffile_a, $
		bad_b=bad_b, ffile_b=ffile_b, $
		nend=nend, run=run, verbose=verbose, v101=v101
;+
;
;	procedure:  flat_filtd
;
;	purpose:  Run flatavg2 and genfiltd to get 'filtd' for calibrate.pro
;		  ('filtd' is the 2nd order multiplicative gain correction
;		  array).
;
;	history:
;		5/93 rob@ncar - written.
;		8/94 rob@ncar - simplified and modified to work with new
;			flatavg2 and genfiltd routines.
;
;	WARNING - 'ixst' assumes wavelengths have NOT been flipped !!!
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 21 then begin
	print
	print, "usage:  flat_filtd, $"
	print, "	     calfile_a, darkfile_a, clearfile_a, gainfile_a, $"
	print, "	     calfile_b, darkfile_b, clearfile_b, gainfile_b, $"
	print, "	     x1, x2, y1, y2, ixst, ihst, ihend, $"
	print, "	     ilo, ihi, wa1, wa2, wb1, wb2"
	print
	print, "	Run flatavg2 and genfiltd to get 'filtd' for calibrate"
	print, "	('filtd' is the 2nd order multiplicative gain"
	print, "	correction array)."
	print
	print, "	Arguments"
	print, "	     calfile_*	- input ASP calibration files"
	print, "	     darkfile_*	- IDL save files to contain 'dark'"
	print, "	     clearfile*	- IDL save files to contain 'clear'"
	print, "	     gainfile_*	- IDL save files containing 'gaintbl'"
	print, "	     x1, x2	- column range to use (wavelength)"
	print, "	     y1, y2	- row range to use (along slit)"
	print, "	     ixst	- index of first active X"
	print, "	     ihst	- Y index after 1st hairline"
	print, "	     ihend	- Y index before 2nd hairline"
	print, "	     ilo, ihi	- lower and upper limit spectrum"
	print, "			  indices for profile shift test"
	print, "	     wa1-wb2	- two portions of continuum on either"
	print, "			  end of the spectrum of avgprof"
	print
	print, "	Keywords"
	print, "	     bad_a,	- arrays containing lists of bad"
	print, "	      bad_b	  scans to exclude from clear"
	print, "			  averaging (defs=use scans 1 to 8)"
	print, "	     ffile_a,	- output filtd files for cameras a and"
	print, "	      ffile_b	  b (defs='filtd.a' and 'filtd.b')"
	print, "	     nend	- end range for genfiltd filtering"
	print, "			  (def=245)"
	print, "	     run	- string containing the run date"
	print, "			  for run-specific processing"
	print, "			     'mar92' = March 1992"
	print, "			      other  = normal processing (def)"
	print, "	     verbose	- flag to print run-time info"
	print, "		              0 = no print (def)"
	print, "		              1 = print everything (/verbose)"
	print, "		              2 = print all but headers"
	print, "	     v101	- set to force version 101"
	print, "			  (def=use version # in op hdr)"
	print
	print
	print, "   ex:  flat_filtd, $"
	print, "	'01.fa.cal','01.fa.dark.sav','01.fa.clear.sav','g.a',$"
	print, "	'01.fb.cal','01.fb.dark.sav','01.fb.clear.sav','g.b',$"
	print, "	bad_a=[3,5], 1,255,0,228,15,..., run='jun92', verb=2"
	print
	return
endif
;-
;
;	Set general parameters.
;
if n_elements(ffile_a) eq 0 then ffile_a = 'filtd.a'
if n_elements(ffile_b) eq 0 then ffile_b = 'filtd.b'
; 
;------------------------------------- 
;	flatavg2 the a-channel
;------------------------------------- 

flatavg2, calfile_a, darkfile_a, clearfile_a, x1, x2, y1, y2, $
	bads=bad_a, verbose=verbose, v101=v101

;------------------------------------- 
;	flatavg2 the b-channel
;------------------------------------- 

flatavg2, calfile_b, darkfile_b, clearfile_b, x1, x2, y1, y2, $
	bads=bad_b, verbose=verbose, v101=v101

;------------------------------------- 
;	genfiltd the a-channel
;------------------------------------- 

genfiltd, gainfile_a, darkfile_a, clearfile_a, $
	  ixst, ihst, ihend, ilo, ihi, wa1, wa2, wb1, wb2, $
	  savefile=ffile_a, nend=nend, run=run, verbose=verbose

;------------------------------------- 
;	genfiltd the b-channel
;------------------------------------- 

genfiltd, gainfile_b, darkfile_b, clearfile_b, $
	  ixst, ihst, ihend, ilo, ihi, wa1, wa2, wb1, wb2, $
	  savefile=ffile_b, nend=nend, run=run, verbose=verbose

end

