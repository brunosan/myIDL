pro skip_scan, infile_num, fscan = fscan
;+
;
;	procedure:  skip_scan
;
;	purpose:  skip to specified scan number in ASP file
;
;	author:  rob@ncar, 1/92
;
;	notes:  - common block op_hdr required for dnumx, dnumy
;		- skip_scan works for up to fscan=4092, assuming 256*256 size
;		- point_lun doesn't have a relative offset mode, just absolute
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 1 then begin
	print
	print, "usage:  skip_scan, infile_num [, fscan=n]"
	print
	print, "	Skip to specified scan number in ASP file."
	print
	print, "	     fscan default = 0  (first sequential scan)"
	print
	return
endif
;-
;
;	Check that not trying to skip too far.
;
if fscan gt 4092 then message, "trying to skip further than 4092"
;
;	Specify common block.
;
@op_hdr.com
;
;	Jump to location of first scan to list.
;
psn = 512L + long(fscan) * (512L + 4L * 2L * long(dnumx) * long(dnumy))
point_lun, infile_num, psn
;
;	Done.
;
end
