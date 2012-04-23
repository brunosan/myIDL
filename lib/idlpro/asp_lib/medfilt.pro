pro medfilt, inima, n, sr, outima, verbose=verbose
;+
;
;	procedure:  medfilt
;
;	purpose:  Apply a median filter to an input array.
;		  n gives the size of the box for the filter:  2*n+1.
;		  sr gives the average range to apply the filter.
;		  The filter will act only if the difference between the old
;		  and the new values is larger than sr times the standard
;		  deviation of the values of the image inside the box.
;		  The smaller the value of sr the stronger the filter.
;
;	author:  Valentin Pillet @ HAO/NCAR (Feb 1993)
;		 [minor mod's by rob@ncar]
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 1 then begin
	print
	print, "usage:  medfilt, inima, n, sr, outima"
	print
	print, "	Apply a median filter to an input array."
	print, "	n gives the size of the box for the filter:  2*n+1."
	print, "	sr gives the average range to apply the filter."
	print, "	The filter will act only if the difference between"
	print, "	the old and the new values is larger than sr times"
	print, "	the standard deviation of the values of the image"
	print, "	inside the box.  The smaller the value of sr the"
	print, "	stronger the filter."
	print
	print, "	Arguments"
	print, "		inima	  - input image"
	print, "		n	  - size of the box (2*n + 1)"
	print, "		sr	  - average range to apply the filter"
	print, "		outima	  - ouput image"
	print
	print, "	Keywords"
	print, "		verbose	  - if set, print # of filtered pixels"
	print
	print, "   ex:  ; (for spike removal)"
	print, "	medfilt, clear, 3, 3, clear1	; soft filter"
	print, "        medfilt, clear, 3, 1, clear1	; hard filter"
	print
	return
endif
;-
;
;	Apply IDL median filter.
;
fi = median(inima, n)
resi = abs(inima - fi)
;
;	Find the spikes.
;
dd = where(resi gt sr*(stdev(resi)))
;
;	Substitute the spikes by the filtered values.
;
outima = inima
outima(dd) = fi(dd)
;
;	Find the total amount of filtered pixels.
;
if keyword_set(verbose) then begin
	nf = sizeof(dd, 1)
	print, 'total number of filtered pixels', nf 
endif
;
end
