function azam_dir, aa
;+
;
;	function:  azam_dir
;
;	purpose:  prompt for path to directory with a_* files
;
;	author:  paul@ncar, 6/93	(minor mod's by rob@ncar)
;
;==============================================================================
;
;       Check number of parameters.
;
if n_params() ne 1 then begin
	print
	print, "usage:	dty = azam_dir(aa)"
	print
	print, "	Prompt for path to directory with a_* files."
	print, "	Return 'quit' for q entry."
	print, "	Return '' for null entry."
	print, "	Except for 'quit' & '' the path will end with /."
	print
	print, "arguments:"
	print, "	aa	-  input azam structure."
	print
	return, 0
endif
;-
				    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				    ;
while 1 do begin
				    ;
				    ;Prompt for directory path.
				    ;
	dty = azam_text_in( aa, 'Enter a_* file path (q=quit)')
				    ;
				    ;Return quit as requested.
				    ;
	if dty eq 'q' then  return, 'quit'
				    ;
				    ;Append directory name with /.
				    ;
	if  dty ne ''  then  dty = dty+'/'
				    ;
				    ;Try to read header.
				    ;
	header = read_floats( dty+'a___header', error )
				    ;
				    ;If no error return directory path.
				    ;
	if error eq 0 then  return, dty
				    ;
				    ;Print error and try agian.
				    ;
	print, !err_string
				    ;
end
				    ;
end
