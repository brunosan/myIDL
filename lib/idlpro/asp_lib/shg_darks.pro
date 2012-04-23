pro shg_darks, infile, imtype, x1, y1, x2, y2, dark, clear, $
	dark_ary, scale_vec, ha1, ha2, hb1, hb2
;+
;
;	function:  shg_darks
;
;	purpose:  prepare dark and clear images for use in shg.pro
;
;	author:  rob@ncar, 6/92
;
;	notes:  - not currently using ha1 and hb2 (see shg.pro)
;		- added the 'imtype' as a test to work off of Q, U, or V;
;		  Bruce said it should always work off of I, however, possibly
;		  'the nonlinearity' is causing it *not* to work well off of
;		  I (when doing an shg on Q, U, or V); note this procedure
;		  *does* work well to de-streak when doing an shg on I
;
;		- did NOT add 'v101' (for version 101 of scan header) parameter
;		  because scan header values are not used anyway
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 14 then begin
	print
	print, "usage:  shg_darks, infile, imtype, x1, y1, x2, y2, $"
	print, "	           dark, clear, dark_ary, scale_vec, $"
	print, "	           ha1, ha2, hb1, hb2"
	print
	print, "	Prepare dark and clear images for use in shg.pro."
	print
	print, "	Arguments"
	print, "	    [No defaults]"
	print, "	    infile	- input file name"
	print, "	    imtype	- i, q, u, or v"
	print, "	    x1,y1	- starting col,row indices"
	print, "	    x2,y2	- ending col,row indices"
	print, "	    dark	- dark scan number"
	print, "	    clear	- clear scan number"
	print, "	    dark_ary	- output dark array"
	print, "	    scale_vec	- output scale vector"
	print, "	    ha1, ha2	- y-coords of 1st hairline region"
	print, "	    hb1, hb2	- y-coords of 2nd hairline region"
	print
	return
endif
;-
;
;	Read dark and clear scans.
;
case imtype of
	'i':  begin
		readscan, infile, dark, dark_ary, q, u, v, $
			x1=x1, y1=y1, x2=x2, y2=y2
		readscan, infile, clear, clear_ary, q, u, v, $
			x1=x1, y1=y1, x2=x2, y2=y2
	      end
	'q':  begin
		readscan, infile, dark, i, dark_ary, u, v, $
			x1=x1, y1=y1, x2=x2, y2=y2
		readscan, infile, clear, i, clear_ary, u, v, $
			x1=x1, y1=y1, x2=x2, y2=y2
	      end
	'u':  begin
		readscan, infile, dark, i, q, dark_ary, v, $
			x1=x1, y1=y1, x2=x2, y2=y2
		readscan, infile, clear, i, q, clear_ary, v, $
			x1=x1, y1=y1, x2=x2, y2=y2
	      end
	'v':  begin
		readscan, infile, dark, i, q, u, dark_ary, $
			x1=x1, y1=y1, x2=x2, y2=y2
		readscan, infile, clear, i, q, u, clear_ary, $
			x1=x1, y1=y1, x2=x2, y2=y2
	      end
endcase
;
;	Subtract off dark.
;
clear_ary = clear_ary - dark_ary
;
;	Calculate means of (each of) the columns,
;	i.e., one value returned per column.
;
means = mean_col(clear_ary)
;
;	Normalize the clear array by dividing by the magnitude of the means.
;	(Actually, flip the division so I can multiply rather than divide
;	 with the scale_vec when I use it.)
;
clear_ary = row_div_ary(abs(means), clear_ary)
;
;	Average the columns to get the scale vector.
;
scale_vec = avg_col(clear_ary)

;;
;;	Set the scale vector to 1.0 around the hairlines.
;;
;;scale_vec(ha1-y1:ha2-y1) = 1.0
;;scale_vec(hb1-y1:hb2-y1) = 1.0
;
;	Set the scale vector to 1.0 from each hairline to its
;	respective maximum Y extent.
;
scale_vec(0:ha2-y1) = 1.0
scale_vec(hb1-y1:y2-y1) = 1.0

;
;	Return.
;
end
