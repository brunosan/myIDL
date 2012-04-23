function writ_op_hdr, outfile_num
;+
;
;	function:  writ_op_hdr
;
;	purpose:  write ASP op header from common into a file
;
;	author:  rob@ncar, 5/92
;
;==============================================================================
;
;	Check number of arguments.
;
if n_params() ne 1 then begin
	print
	print, "usage:  ret = writ_op_hdr(outfile_num)"
	print
	print, "	Write ASP op header from common into a file."
	print
	return, 1
endif
;-
;
;	Specify operation common block.
;
@op_hdr.com
;
;	Point to beginning of file.
;
point_lun, outfile_num, 0
;
;	Make sure tape name is 20 characters long.
;
len = strlen(tapename)
if len lt 20 then for ix = 1, 20-len do tapename = tapename + ' '
;
;	Write operation header values.
;
writeu, outfile_num, 						$
	command, head_type, year, month, day,			$
	hour, min, sec, det, demod,				$
	wavelen, optype, opnum, dem1, dem2,			$
	det1, det2, det3, det4, modhex,				$
	modix, sgain_i, sgain_p, sgain_v, sset,			$
	hexad, macro, mstepsz, nmstep, fstepsz,			$
	nfstep, cconfigs, wavelen2, activecams, tapename,	$
	accnum, dhoff, dvoff, dnumx, dnumy,			$
	bmode, dlsb, detwin,					$
	orig_nscan, input_x1, input_y1, merged,			$
	ofiller
;
;	Done.
;
return, 0
end
