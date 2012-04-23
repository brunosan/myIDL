;
;	File:  scan_hdr.com
;
;	Purpose:  specifiy scan header common block  (see scan_hdr.set)
;
;	Date:  11/92
;
;------------------------------------------------------------------------------
;
common scan_hdr,					$
	s_command, s_head_type, s_year, s_month, s_day,	$
	s_hour, s_min, s_sec, s_det, s_demod,		$
	s_wavelen, s_snum, s_see1, s_see2, s_servo1,	$
	s_servo2, s_istep, s_config, s_iconfig, s_posn,	$
	s_mstat, s_vfiller, s_vtt, s_dfiller1,		$
	s_dfiller2, s_vtt2, s_ubfwav, 			$ ; new w/ version 101
	s_fmc, s_fms, s_tapef,				$ ; new w/ version 101
	s_merge,				   	$ ; new w/ version 102?
	UNMERGED, A_AND_B, A_ONLY, B_ONLY, USED_PREV	  ; new w/ version 102?
