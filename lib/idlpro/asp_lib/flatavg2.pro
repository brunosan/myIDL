pro flatavg2, infile, darksave, clearsave, x1, x2, y1, y2, $
	bads=bads, verbose=verbose, v101=v101
;+
;
;	procedure:  flatavg2
;
;	purpose:  output dark and averaged clear I spectra in IDL save files
;
;	author:  rob@ncar, 5/93
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 7 then begin
	print
	print, "usage:  flatavg2, infile, darksave, clearsave, x1,x2,y1,y2"
	print
	print, "	Output dark and averaged clear I's in IDL save files."
	print, "	The dark is obtained from scan 0; the clear is"
	print, "	obtained from the average of scans 1-8, excluding"
	print, "	bad scans (see 'bads')."
	print
	print, "	Arguments"
	print, "	    infile	- input ASP file"
	print, "	    darksave	- output dark image save file"
	print, "	    clearsave	- output clear image save file"
	print, "	    x1, x2	- column range to use (wavelength)"
	print, "	    y1, y2	- row range to use (along slit)"
	print
	print, "	Keywords"
	print, "	    bads	- optional array containing list of"
	print, "			  bad scans to exclude from clear"
	print, "			  averaging (def=use scans 1 to 8)"
	print, "	    verbose	- flag to print run-time info"
	print, "		              0 = no print (def)"
	print, "		              1 = print everything (/verbose)"
	print, "		              2 = print all but headers"
	print, "	    v101	- set to force version 101"
	print, "			  (def=use version # in op hdr)"
	print
	print
	print, "   ex:  flatavg2, '01.fa.cal', '01.fa.dark.sav', /verb, $"
	print, "		  '01.fa.clear.sav', 1, 255, 0, 228, [3,5]"
	print
	return
endif
;-
;
;	Return to caller if error.
;
on_error, 2
;
;	Set general parameters.
;
true = 1
false = 0
if n_elements(bads) ne 0 then if sizeof(bads, 0) ne 1 then $
	message, "'bads' must be a 1D array"
;
;	Save dark image.
;
avgscans_i, infile, darksave, 0, 0, $
	x1=x1, x2=x2, y1=y1, y2=y2, verbose=verbose, v101=v101
;
;	Generate and save average clear image.
;
if n_elements(bads) eq 0 then begin		; all 8 scans are good
	use_list = indgen(8) + 1

endif else begin				; there are bad scans
	first = true
	for i = 1, 8 do $
		if not in_set(bads, i) then begin
			if first then begin	; (build array of good scans)
				use_list = [i]
				first = false
			endif else begin
				use_list = [use_list, i]
			endelse
		endif
	if n_elements(use_list) eq 0 then  message, 'NO good scans for clear'
endelse
;
avgscans_i, infile, clearsave, use_list, 1, $
	x1=x1, x2=x2, y1=y1, y2=y2, verbose=verbose, v101=v101
;
;	Done.
;
end
