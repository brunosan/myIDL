pro genfiltd, gainfile, darkfile, clearfile, $
	      ixst, ihst, ihend, ilo, ihi, wa1, wa2, wb1, wb2, $
	      nend=nend, savefile=savefile, run=run, verbose=verbose
;+
;
;	procedure:  genfiltd
;
;	purpose:  generate the 2nd order, low frequency, fringe multiplicative
;		  correction array (filtd) and put it in an IDL save file
;
;	history:
;		9/92 lites@ncar & rob@ncar - written.
;		8/94 rob@ncar - collapsed functionality of
;			flat_filtd/genfiltd/get_filtd/buildgn2 to
;			flat_filtd/genfiltd.
;
;	WARNING - 'ixst' assumes wavelengths have NOT been flipped !!!
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 12 then begin
	print
	print, "usage:  genfiltd, gainfile, darkfile, clearfile, $"
	print, "	          ixst, ihst, ihend, ilo, ihi, $"
	print, "	          wa1, wa2, wb1, wb2"
	print
	print, "	Generate the 2nd order gain correction array (filtd)"
	print, "	and put it in an IDL save file."
	print
	print, "	Arguments"
	print, "	    gainfile	- IDL save file of gaintable info"
	print, "			  from 'buildgn.pro'"
	print, "	    darkfile	- IDL save file of dark from CAL"
	print, "	    clearfile	- IDL save file of clear from CAL"
	print, "	    ixst	- index of first active X"
	print, "	    ihst	- Y index after 1st hairline"
	print, "	    ihend	- Y index before 2nd hairline"
	print, "	    ilo, ihi	- lower and upper limit spectrum"
	print, "			  indices for profile shift test"
	print, "	    wa1-wb2	- two portions of continuum on either"
	print, "			  end of the spectrum of avgprof"
	print
	print, "	Keywords"
	print, "	    nend	- end range for filtering (def=245)"
	print, "	    savefile	- output IDL save file name"
	print, "			  (def='filtd.save')"
	print, "	     run	- string containing the run date"
	print, "			  for run-specific processing"
	print, "			     'mar92' = March 1992"
	print, "			      other  = normal processing (def)"
	print, "	    verbose	- if set, print run-time information"
	print, "			  (def=don't print it)"
	print
	print, "   ex:  genfiltd, 'gaintable.6149', '29.fa.dark.sav', $"
	print, "		  '29.fa.clear.sav', 15, ihst, ihend,"
	print, "		  165, 195, 35, 45, 195, 205"
	print
	return
endif
;-
;
;	Set some variables.
;
true = 1
false = 0
do_verb = keyword_set(verbose)
if n_elements(savefile) eq 0 then savefile = 'filtd.save'
if n_elements(run) eq 0 then run = 'normal'
if n_elements(nend) eq 0 then nend = 245
;
;	Restore:  avgprof, fitshft, gaintbl
;
avgprof = 0  & fitshft = 0  & gaintbl = 0
if do_verb then print
restore, gainfile, verbose=do_verb
;
;	Restore:  dark and clear
;
dark = 0  & clear = 0
if do_verb then print	  & restore, darkfile,  verbose=do_verb
if do_verb then print	  & restore, clearfile, verbose=do_verb
;
;	Set dimension variables.
;
nx = sizeof(dark, 1)
ny = sizeof(dark, 2)
ny1 = ny - 1
ny2 = ny / 2
;
;	Create and zero the 2nd order, low frequency, fringe multiplicative
;	correction array (filtd), and the "line-free" cal clear port image
;	(clrsp).
;
filtd = fltarr(nx, ny)
clrsp = filtd
;
;	Dark correct.
;
temp = clear - dark
;
;	Correct for RGB variation.
;
ofstc2, temp, verbose=do_verb
;
;	Correct clear image for nonlinear pixel-pixel variation (to 'out').
;
if gncorr(temp, gaintbl, out, ixst) then $
	message, "Error running 'gncorr'."
;
;	Derive the "line-free" normalized spectral image 'clrsp'.
;
if do_verb then  message, "shsl starting...", /info
shsl, out, ilo, ihi, shft, shfit, avgprf, clrsp, ixst, ihst, ihend
;
;	Filter the "line-free" image to extract the gain table which
;	removes them.
;
nst = ixst 
if do_verb then  message, "filt starting...", /info
filt, clrsp, nst, nend, filtd, run=run
;
;	Derive the "focus change" correction along the slit, and
;	combine it with filtd.
;	(Note this is only done for March 1992 data.)
;
if run eq 'mar92' then begin

;	Prepare the mean profile correction.

	if do_verb then begin
		message, $
		   'NOTE!! THE CONTINUUM FIT TO THE AVERAGE PROFILE", /info
		message, $
		   'IS HARDWIRED TO CERTAIN WAVELENGTH POINTS !!', /info
	endif

	wam = wa1 + 0.5 * (wa2 - wa1)
	wbm = wb1 + 0.5 * (wb2 - wb1)
	av1 = mean(avgprof(wa1:wa2))
	av2 = mean(avgprof(wb1:wb2))
	cont = avgprof
	slope = (av2 - av1) / (wbm - wam)

;	Find intercept.
	xinter = av1 - slope * wam
	xx = indgen(255)
	cont = slope * xx + xinter
	xx = (cont - avgprof) / cont
	xx(0:14) = 0.0

	for j = 0, ny1 do begin
		temp = fshft(xx, fitshft(j), nst, nend)
		filtd(*, j) = filtd(*, j) * $
			( 1.0 - 0.11 * temp * float(ny2-j)/float(ny2) )
	endfor

endif
;
;	Save 'filtd' to file.
;
if do_verb then print, format='(/A/)', $
	'Saving filtd to file ' + savefile + ' ...'
save, filename=savefile, filtd
;
end
