function read_op_hdr, infile_num, outfile_num, list_flag
;+
;
;	function:  read_op_hdr
;
;	purpose:  read ASP operation header from file into common;
;		  optionally list it to a file or stdout
;
;	author:  rob@ncar, 1/92
;
;==============================================================================
;
;	Check number of arguments.
;
if n_params() lt 3 then begin
	print
	print, "usage:  ret=read_op_hdr(infile_num, outfile_num, list_flag)"
	print
	print, "	Read ASP op header from file into common;"
	print, "	optionally list to a file or stdout."
	print
	print, "	Arguments"
	print, "		infile_num	- input unit"
	print, "		outfile_num	- output unit"
	print, "		list_flag	- 0 = false = no list"
	print, "		           	  1 = true = list"
	print, "		        	  2 = list only (no read)"
	print, "	Keywords"
	print, "		(none)"
	print
	print, "	On error, error message is printed and 1 is returned;"
	print, "	else 0 is returned."
	print
	return, 1
endif
;-
;
;	Specify operation common block.
;
@op_hdr.com
;
;	Set up to catch I/O error (i.e, goto 'ioerror' label).
;
on_ioerror, ioerror
;
;	Point to beginning of file.
;
if list_flag ne 2 then point_lun, infile_num, 0
;
;	Read operation header values.
;
if list_flag ne 2 then readu, infile_num,			$
	command, head_type, year, month, day,			$
	hour, min, sec, det, demod,				$
	wavelen, optype, opnum, dem1, dem2,			$
	det1, det2, det3, det4, modhex,				$
	modix, sgain_i, sgain_p, sgain_v, sset,			$
	hexad, macro, mstepsz, nmstep, fstepsz,			$
	nfstep, cconfigs, wavelen2, activecams, tapename,	$
	accnum, dhoff, dvoff, dnumx, dnumy,			$
	bmode, dlsb, detwin, 					$
	orig_nscan, input_x1, input_y1, merged, ofiller

;
;	Check header type.
;
if head_type ne 2 then begin
	print, format='(/"operation header_type error"/)'
	return, 1
endif
;
;	Make sure tapename is 20 characters long.
;
diff = 20 - strlen(tapename)
if diff gt 0 then for i = 1,diff do tapename = tapename + ' '

;;
;;	Make sure ofiller is all zero's.
;;	This makes it easier to check for consistency with the C routines.
;;	I use part of ofiller as (orig_nscan, input_x1, and input_y1) in
;;	gainit/calibrate to pass information to Paul's inversion code.
;;
;;ofiller(*) = 0B
;;if (get_optype() ne 'Gain') and (get_optype() ne 'GainXT') then begin
;;	orig_nscan=0L	& input_x1=0L	& input_y1=0L
;;endif

;
;	Print header values.
;
if list_flag ne 0 then begin

	printf, outfile_num, format='(/"OPERATION", I4, " HEADER  ", $)', opnum
	printf, outfile_num, format='(57("=")/)'
	printf, outfile_num, format='(A, $)', get_optype()

	printf, outfile_num, format='(4X, I2, "/", I2.2, "/", I2.2, $)', $
		month, day, year

	printf, outfile_num, format='(4X, I2, ":", I2.2, ":", I2.2, $)', $
		hour, min, sec

	case det of
		0:  printf, outfile_num, format='(4X, "Det_A", $)'
		1:  printf, outfile_num, format='(4X, "Det_B", $)'
		else:	begin
			if outfile_num gt 0 then $
				printf, outfile_num, 'detector error'
			print, 'detector error'
			return, 1
			end
	endcase

	case demod of
		0:  printf, outfile_num, format='(4X, "Bert", $)'
		1:  printf, outfile_num, format='(4X, "Ernie", $)'
		else:	begin
			if outfile_num gt 0 then $
				printf, outfile_num, 'demodulator error'
			print, 'demodulator error'
			return, 1
			end
	endcase

	printf, outfile_num, format='(3X, I4, " nm", $)', wavelen

	printf, outfile_num, format='(4X, A, /)', tapename

	printf, outfile_num, format='("        Mod Hex Index: ", 2I7)', $
		modhex, modix

	printf, outfile_num, format='("     Servo I P V Gain: ", 3I7)', $
		sgain_i, sgain_p, sgain_v

	printf, outfile_num, format='("       Servo Setpoint: ", 1I7)', sset

	printf, outfile_num, format='("         Hexadecimant: ", 1I7)', hexad

	printf, outfile_num, format='("   Map Steps Stepsize: ", 1I7, F7.2)', $
		nmstep, mstepsz

;;	printf, outfile_num, format='("Filter Steps Stepsize: ", 1I7, F7.2)', $
;;		nfstep, fstepsz
	printf, outfile_num, format='("     Map Movie Frames: ", 1I7)', $
		nfstep

	printf, outfile_num, format='("   Number Cal Configs: ", 1I7)', $
		cconfigs

	printf, outfile_num, format='("        Accumulations: ", 1I7)', accnum

	printf, outfile_num, format='("     Demod Offset H V: ", 2I7)', $
		dhoff, dvoff

	printf, outfile_num, format='("        Demod Num X Y: ", 2I7)', $
		dnumx, dnumy

	case bmode of
		0:  printf, outfile_num, $
			format='("          Buffer Mode:  single")'
		1:  printf, outfile_num, $
			format='("          Buffer Mode:  double")'
		else:  printf, outfile_num, $
			format='("          Buffer Mode:  <error>")'
	endcase

	printf, outfile_num, format='("  Original # of Scans: ", I7)', $
		orig_nscan
	printf, outfile_num, format='("          Input X1 Y1: ", 2I7)', $
		input_x1, input_y1

	printf, outfile_num, format='("         Detector LSB: ", 1I7)', dlsb

	if merged eq 1 then begin
		printf, outfile_num, $
			format='(" Cameras A & B Merged:     yes")'
	endif else begin
		printf, outfile_num, $
			format='(" Cameras A & B Merged:      no")'
	endelse

	printf, outfile_num, format='("      Detector Window: ", /)'
	printf, outfile_num, format='(1X, 25(Z2.2, X))', detwin(0:24)
	printf, outfile_num, format='(1X, 25(Z2.2, X))', detwin(25:49)
	printf, outfile_num, format='(1X, 25(Z2.2, X))', detwin(50:74)
	printf, outfile_num, format='(1X, 22(Z2.2, X))', detwin(75:96)
endif
;
;	Return 0 on success, or 1 on error.
;
return, 0
ioerror: print, format='(/A/)', "*** I/O error in 'read_line.pro' ***"
	 return, 1
end
