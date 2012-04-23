function writ_sc_hdr, outfile_num, version=version
;+
;
;	function:  writ_sc_hdr
;
;	purpose:  write ASP scan header from common into a file
;
;	author:  rob@ncar, 5/92
;
;==============================================================================
;
;	Check number of arguments.
;
if n_params() ne 1 then begin
	print
	print, "usage:  ret = writ_sc_hdr(outfile_num)"
	print
	print, "	Write ASP scan header from common into a file."
	print
	print, "	Arguments"
	print, "		outfile_num - unit number of output file"
	print
	print, "	Keywords"
	print, "		version     - version number of headers"
	print, "			      (def=100=the first version)"
	print
	return, 1
endif
;-
;
;	Specify scan common block.
;
@scan_hdr.com
;
;	Set version number.
;
if n_elements(version) eq 0 then version = 100
;
;	Write scan header values.
;
if version eq 100 then begin		; Version 100
	writeu, outfile_num, 					  $
		s_command, s_head_type, s_year, s_month, s_day,	  $
		s_hour, s_min, s_sec, s_det, s_demod,		  $
		s_wavelen, s_snum, s_see1, s_see2, s_servo1,	  $
		s_servo2, s_istep, s_config, s_iconfig, s_posn,	  $
		s_mstat, s_vfiller, s_vtt,			  $
		s_dfiller2, s_merge, s_dfiller1

endif else begin			; Versions 101 to 106 ...
	writeu, outfile_num, 					  $
		s_command, s_head_type, s_year, s_month, s_day,	  $
		s_hour, s_min, s_sec, s_det, s_demod,		  $
		s_wavelen, s_snum, s_see1, s_see2, s_servo1,	  $
		s_servo2, s_istep, s_config, s_iconfig, s_ubfwav, $
		s_posn, s_mstat, s_vfiller, s_vtt, s_vtt2,	  $
		s_fmc, s_fms, s_tapef, s_merge, s_dfiller1
endelse
;
;	Done.
;
return, 0
end
