pro rem_clouds, n1, n2, noplot=noplot
;+
;
;	function:  rem_clouds
;
;	purpose:  get rid of clouds
;
;	author:  vmp@ncar, 10/94	(minor mod's by rob@ncar, 11/94)
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 2 then begin
	print
	print, "usage:  rem_clouds, n1, n2"
	print
	print, "	Get rid of clouds."
	print
	print, "	Must have file 'a__cct' in the current directory;"
	print, "	writes a file called 'a__cct_nc'."
	print
	print, "	Arguments"
	print, "		n1, n2	- rows that have no spot signatures"
	print, "			  between them; if n1 > n2, the output"
	print, "			  will be a copy of the input"
	print
	print, "	Keywords"
	print, "		noplot	- if set, do not make plots (def=plot)"
	print
	return
endif
;-
;

cct = b_image('a__cct', b_str=b)

if n1 gt n2 then begin
	cctn = cct

endif else begin
	averc = avg_row(cct, 0, sizeof(cct, 1)-1, n1, n2)
	cctn = cct
	for i = 0, sizeof(cct, 2)-1 do  cctn(*,i) = averc(*)
	cctn = cct / cctn
	if not keyword_set(noplot) then begin
		tvwin, cct, /free,  title='clouds'
		tvwin, cctn, /free, title='no clouds'
	endif
endelse

err = write_floats('a__cct_nc', cctn(b.pxy))

end
