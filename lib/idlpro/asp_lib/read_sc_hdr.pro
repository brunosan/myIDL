function read_sc_hdr, in_unit, out_unit, list_flag, seq_scan, $
	version=version, ignore=ignore
;+
;
;	function:  read_sc_hdr
;
;	purpose:  read ASP scan header from file into common;
;		  optionally list it to a file or stdout
;
;	author:  rob@ncar, 1/92
;
;	notes:  1) on error, error message is printed and 1 is returned; else
;		   0 is returned
;		2) configuration 'abcd'
;			a = sun		      (0-8 = 
;			b = lamp	      (0
;			c = linear polarizer  (0-8 = out,0,45,90...315 degrees)
;			d = retarder          (0-8 = out,0,45,90...315 degrees)
;
;==============================================================================
;
;	Check number of arguments.
;
if (n_params() lt 3) or (n_params() gt 4) then begin
	print
	print, "usage:  ret=read_sc_hdr(in_unit, out_unit, list_flag"
	print, "			   [, seq_scan])"
	print
	print, "	Read ASP scan header from file into common."
	print
	print, "	On error, error message is printed and 1 is returned;"
	print, "	else 0 is returned."
	print
	print, "	Arguments"
	print, "		  in_unit	- unit number of input file"
	print, "		 out_unit	- unit number of output file"
	print, "		list_flag	- 1 = list to output file;"
	print, "			          0 = do not list"
	print, "		 seq_scan	- sequential scan number,"
	print, "			          optional for listing"
	print
	print, "	Keywords"
	print, "		  version 	- version number of headers"
	print, "			          (def=100=the first version)"
	print, "		   ignore	- if set, ignore scan header"
	print, "			          error (scan header will not"
	print, "			          be printed)"
	print
	return, 1
endif
;-
;
;	Specify scan common block.
;
@scan_hdr.com
;
;	Set up to catch I/O error (i.e, goto 'ioerror' label).
;
on_ioerror, ioerror
;
;	Set version number.
;
if n_elements(version) eq 0 then version = 100
;
;	Read scan header values.
;
if version eq 100 then begin		; Version 100
	readu, in_unit, 					  $
		s_command, s_head_type, s_year, s_month, s_day,	  $
		s_hour, s_min, s_sec, s_det, s_demod,		  $
		s_wavelen, s_snum, s_see1, s_see2, s_servo1,	  $
		s_servo2, s_istep, s_config, s_iconfig,		  $
		s_posn, s_mstat, s_vfiller, s_vtt, 		  $
		s_dfiller2, s_merge, s_dfiller1

endif else begin			; Versions 101 to 106 ...
	readu, in_unit, 					  $
		s_command, s_head_type, s_year, s_month, s_day,	  $
		s_hour, s_min, s_sec, s_det, s_demod,		  $
		s_wavelen, s_snum, s_see1, s_see2, s_servo1,	  $
		s_servo2, s_istep, s_config, s_iconfig, s_ubfwav, $
		s_posn, s_mstat, s_vfiller, s_vtt,		  $
		s_vtt2, s_fmc, s_fms, s_tapef, s_merge,		  $
		s_dfiller1
endelse
;
;	Check header type.
;
if (s_head_type ne 4) and (not keyword_set(ignore)) then begin
	print, format='(/"scan header_type error"/)'
	return, 1
endif
;
;	Print header values.
;
if (list_flag eq 1) and (not keyword_set(ignore)) then begin

	printf, out_unit, format='(/"SCAN", I4, " HEADER  ", $)', s_snum
	if n_params() eq 3 then begin
		printf, out_unit, format='(62("-")/)'
	endif else begin
		printf, out_unit, $
			format='(45("-"), "  (SEQ. SCAN", I4, ")"/)', $
			seq_scan
	endelse

	printf, out_unit, $
		format='("Date:  ", I2, "/", I2.2, "/", I2.2, $)', $
		s_month, s_day, s_year

	printf, out_unit, $
		format='(4X, "Time:  ", I2, ":", I2.2, ":", I2.2, $)', $
		s_hour, s_min, s_sec

	a = strtrim(string(s_posn), 2)
	printf, out_unit, $
		format='(4X, "Tape Posn:  ", A, " kbytes", $)', a

	case s_merge of
		UNMERGED:	printf, out_unit, "  UNMERGED"
		A_AND_B:	printf, out_unit, "   A_AND_B"
		A_ONLY:		printf, out_unit, "    A_ONLY"
		B_ONLY:		printf, out_unit, "    B_ONLY"
		USED_PREV:	printf, out_unit, " USED_PREV"
		else:		printf, out_unit, "  (merge?)"
	endcase

	printf, out_unit, format='("Map Step:", I6, $)', s_istep
	printf, out_unit, format='(4X, "Config:    ", Z4.4, $)', s_config
	printf, out_unit, format='(4X, "Config#:", I7, $)', s_iconfig
	printf, out_unit, format='(4X, "Version:", I7)', version

	printf, out_unit, format='("Servo:  +/-", I4, $)', s_servo1

	if version eq 100 then begin
		printf, out_unit, format='(4X, "X See:", F9.1, $)', $
			s_see1/17.0
		printf, out_unit, format='(4X, "Y See:", F9.1)', $
			s_see2/17.0

	endif else begin
;		(from a limb seeing monitor, called "Seykora" [a person]:
;		 average seeing monitor value)
		printf, out_unit, format='(4X, "Contrast:", F6.1, $)', $
			s_see2/17.0

;		(tracker seeing: RMS residual from the R drive to the fast
;		 mirror after removing waveplate wobble)
		printf, out_unit, $
			format='(4X, "Trk See:", F7.1, $)', $
			s_see1/17.0

;		(VTT's interpretation of Seykora monitor)
		printf, out_unit, format='(4X, "VTT See:", F7.1)', $
			s_vtt2
	endelse

	printf, out_unit, format='(    "VTTAZ: ", F8.2, $)', s_vtt(0)
	printf, out_unit, format='(4X, "VTTEL: ", F8.2, $)', s_vtt(1)
	printf, out_unit, format='(4X, "TBLPOS:", F8.2, $)', s_vtt(2)
	printf, out_unit, format='(4X, "GDRAN: ", F8.2)', s_vtt(3)

	printf, out_unit, format='(    "XGDR:  ", F8.2, $)', s_vtt(4)
	printf, out_unit, format='(4X, "YGDR:  ", F8.2, $)', s_vtt(5)
	printf, out_unit, format='(4X, "SLAT:  ", F8.2, $)', s_vtt(6)
	printf, out_unit, format='(4X, "SLNG:  ", F8.2)', s_vtt(7)

	printf, out_unit, format='(    "CLNG:  ", F8.2, $)', s_vtt(8)
	printf, out_unit, format='(4X, "PAH:   ", F8.2, $)', s_vtt(9)
	printf, out_unit, format='(4X, "PAG:   ", F8.2, $)', s_vtt(10)
	printf, out_unit, format='(4X, "RV:    ", F8.2)', s_vtt(11)

	printf, out_unit, format='(    "WPLRZ: ", F8.2, $)', s_vtt(12)
	printf, out_unit, format='(4X, "TRACK: ", F8.2, $)', s_vtt(13)
	printf, out_unit, format='(4X, "OAZ:   ", F8.2, $)', s_vtt(14)
	printf, out_unit, format='(4X, "OEL:   ", F8.2)', s_vtt(15)

	printf, out_unit, format='(    "SLTAN: ", F8.2, $)', s_vtt(16)
	printf, out_unit, format='(4X, "SLRAZ: ", F8.2, $)', s_vtt(17)
	printf, out_unit, format='(4X, "SLREL: ", F8.2, $)', s_vtt(18)
	printf, out_unit, format='(4X, "PEE:   ", F8.2)', s_vtt(19)

	printf, out_unit, format='(    "BEE0:  ", F8.2, $)', s_vtt(20)
	printf, out_unit, format='(4X, "SDIAM: ", F8.2, $)', s_vtt(21)

	if version eq 100 then begin
		printf, out_unit, format='(4X, "LIGHT: ", F8.2)', s_vtt(22)
	endif else begin
		printf, out_unit, format='(4X, "LIGHT: ", F8.2, $)', $
			s_vtt(22)
		printf, out_unit, format='(4X, "UBFWAV:", F8.2)', s_ubfwav
	endelse

;;	  Convert from (1,2,4,8,16...) to (0,1,2,3,4...).
;;	  a = fix( alog(s_mstat(1,0)) / alog(2) )
;;	  a = strtrim(string(a * 45), 2)
	a = s_mstat(1,0) - 1
	a = stringit(a * 45)
	case s_mstat(1,1) of
		1:  printf, out_unit, $
			format='("Retarder ", A, ";", $)', a	; in
		2:  printf, out_unit, $
			format='("Retarder out;", $)'		; out
		else:  printf, out_unit, $
			format='("Retarder ", A, " <err>;", $)', a
	endcase

;;	  Convert from (1,2,4,8,16...) to (0,1,2,3,4...).
;;	  a = fix( alog(s_mstat(1,2)) / alog(2) )
;;	  a = strtrim(string(a * 45), 2)
	a = s_mstat(1,2) - 1
	a = stringit(a * 45)
	case s_mstat(1,3) of
		1:  printf, out_unit, $
			format='(1X, "Polarizer ", A, ";", $)', a	; in
		2:  printf, out_unit, $
			format='(1X, "Polarizer out;", $)'		; out
		else:  printf, out_unit, $
			format='(1X, "Polarizer ", A, " <err>;", $)', a
	endcase

	case s_mstat(1,4) of
		0:     printf, out_unit, format='(1X, "Lamp off;", $)'
		else:  printf, out_unit, format='(1X, "Lamp on;", $)'
	endcase

	case s_mstat(1,5) of
		1:  printf, out_unit, $
			format='(1X, "Mirror in;", $)'
		2:  printf, out_unit, $
			format='(1X, "Mirror out;", $)'
		else:  printf, out_unit, $
			format='(1X, "Mirror <err>;", $)'
	endcase

	case s_mstat(1,6) of
		1:  printf, out_unit, $
			format='(1X, "Dark Slide in")'
		2:  printf, out_unit, $
			format='(1X, "Dark Slide out")'
		else:  printf, out_unit, $
			format='(1X, "Dark Slide <err>")'
	endcase
endif
;
;	Return 0 on success, or 1 on error.
;
return, 0
ioerror: print
	 print, "*** I/O error in 'read_sc_hdr.pro' ***"
	 print
	 return, 1
end
