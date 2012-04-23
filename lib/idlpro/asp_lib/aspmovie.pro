pro aspmovie, infile
;+
;
;	procedure:  aspmovie
;
;	purpose:  manipulate ASP movie data
;
;	author:  rob@ncar, 1/95
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() lt 1 then begin
	print
	print, "usage:  aspmovie, infile"
	print
	print, "	Manipulate ASP movie data."
	print
	print, "	Procedure currently separates a multiple-map movie"
	print, "	file into separate files, appending with .1, .2, ..."
	print
	print, "	Arguments"
	print, "		infile	 - input file name"
	print
	print, "	Keywords"
	print, "		(none)"
	print
	print
	print, "   ex:  aspmovie, '04.fa.map'"
	print, "        ; produces 04.fa.map.1, 04.fa.map.2, ..."
	print
	return
endif
;-
;
;	Find out how many maps there are.
;
@op_hdr.com
@op_hdr.set
openr, infile_unit, infile, /get_lun
if read_op_hdr(infile_unit, 0, 0) eq 1 then return
free_lun, infile_unit
print, 'There are ' + stringit(nfstep) + ' frames to separate.', format='(/A/)'
;
;	Separate out each frame.
;
for imap = 0, nfstep - 1 do begin
	outfile = infile + '.' + stringit(imap + 1)
	print, $
 '============================================================================'
	aspedit, infile, outfile, fmap1=imap, lmap1=imap
endfor
;
;	Done.
;
end
