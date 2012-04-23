pro calib_res, dark_a,dark_b, filtd_a,filtd_b, gain_a,gain_b,	$
	       a_dark, a_filtd, a_gaintbl,			$
	       b_dark, b_filtd, b_gaintbl,			$
	       cameras=cameras, verbose=verbose
;+
;
;	procedure:  calib_res
;
;	purpose:  resore variables for calibrate.pro
;
;	author:  rob@ncar, 10/93
;
;	notes:  - assume error checking for 'cameras' has been done
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 12 then begin
	print
	print, "usage:  calib_res, dark_a, dark_b,		$"
	print, "		   filtd_a, filtd_b,		$"
	print, "		   gain_a, gain_b,		$"
	print, "		   a_dark, a_filtd, a_gaintbl,	$"
	print, "		   b_dark, b_filtd, b_gaintbl"
	print
	print, "	Resore variables for calibrate.pro."
	print
	print, "	Arguments"
	print, "	    dark_a,	- input dark files for both cameras"
	print, "	     dark_b	  (IDL save files)"
	print, "	    filtd_a,	- input filtd files for both cameras"
	print, "	     filtd_b	  (IDL save files)"
	print, "	    gain_a,	- input gaintbl files for both cameras"
	print, "	     gain_b	  (IDL save files)"
	print, "	    a_*, b_*	- returned variables"
	print
	print, "	Keywords"
	print, "	    cameras	- choice of cameras to process"
	print, "		             'a_only' = process only camera A"
	print, "		             'b_only' = process only camera B"
	print, "		             'both' = process both A & B (def)"
	print, "	    verbose	- if set, print run-time info"
	print, "			  (def=don't print)"
	print
	return
endif
;-
;
;	Set general variables.
;
do_verb = keyword_set(verbose)
;
;	Initialize variables for restore.
;
dark = 0
filtd = 0
gaintbl = 0
avgprof = 0
fitshft = 0
;
;	Restore Camera A variables.
;
if cameras ne 'b_only' then begin
	if do_verb then print
	restore, dark_a, verbose=do_verb		; dark
	if do_verb then print
	restore, filtd_a, verbose=do_verb		; filtd
	if do_verb then print
	restore, gain_a, verbose=do_verb		; gaintbl
	a_dark = dark
	a_filtd = filtd
	a_gaintbl = gaintbl
endif
;
;	Restore Camera B variables.
;
if cameras ne 'a_only' then begin
	if do_verb then print
	restore, dark_b, verbose=do_verb		; dark
	if do_verb then print
	restore, filtd_b, verbose=do_verb		; filtd
	if do_verb then print
	restore, gain_b, verbose=do_verb		; gaintbl
	b_dark = dark
	b_filtd = filtd
	b_gaintbl = gaintbl
endif
;
;	Done.
;
end
