pro b_field, dir, dummy		$
, hilight	= hilight	$
, profile	= profile	$
, b__cct	= b__cct	$
, b_fld		= b_fld		$
, b_psi		= b_psi		$
, b_azm		= b_azm		$
, b_1incl	= b_1incl	$
, b_1azm	= b_1azm	$
, b_2incl	= b_2incl	$
, b_2azm	= b_2azm	$
, b_str		= b
;+
;
;	procedure:  b_field
;
;	purpose:  read and display a_* files dumped by program "bite"
;		  expansions of *.bi files with the -x option
;
;	author:  paul@ncar, 4/93	(minor mod's by rob@ncar)
;
;==============================================================================
;
;       Check number of parameters.
;
if n_params() gt 1 then begin
	print
	print, "usage:	b_field [, dir]"
	print
	print, "	Read and display a_* files dumped by program 'bite'"
	print, "	expansions of *.bi files with the -x option."
	print
	print, "	Arguments"
	print, "		dir	- directory path (string;"
	print, "			  def=use current working directory)"
	print
	print, "	Keywords (input)"
	print, "		hilight	- highlighting flag"
	print, "			    0 = no highlighting"
	print, "			    1 = highlight reversal(def)"
	print, "			    2 = highlight ambiguous azimuth"
	print, "		profile	- if set, invoke PROFILES procedure"
	print, "			  (def=do profile)"
	print
	print, "	Keywords (output; defs=values not output)"
	print, "		b__cct	- 2D array of continuum"
	print, "		b_fld	- 2D array of magnetic field values"
	print, "			  (Gauss)"
	print, "		b_psi	- 2D array of inclination from line"
	print, "			  of sight (0. to 180.)"
	print, "		b_azm	- 2D array of azimuth ccw from normal"
	print, "			  to elevation mirror (-180. to 180.)"
	print, "		b_1incl	- 2D array of inclination from"
	print, "			  solar surface normal (0. to 180.)"
	print, "		b_1azm	- 2D array of azimuth from"
	print, "			  solar west (-180. to 180.)"
	print, "		b_2incl,- (ambigous inclination and azimuth)"
	print, "		 b_2azm"
	print, "		b_str	- structure for data and directory"
	print
	print, "  ex1:"
	print, "	; Display magnetic field in cwd."
	print, "	; Return 2D continuum array; invoke PROFILES."
	print, "	b_field, b__cct=b__cct, /profile"
	print
	print, "  ex2:"
	print, "	; Display magnetic field in directory /d/red/*5v*."
	print, "	b_field, '/d/red/*5v*'"
	print
	return
endif
;-
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			;
			;Append directory name with / 
			;
dty = ''
if n_elements(dir) ne 0 then  dty=dir
if dty ne '' then if strmid(dty,strlen(dty)-1,1) ne '/' then dty = dty+'/'
			;
			;Read data and put in 2D images.
			;
b__cct  = b_image( dty+'a__cct',  b_str=b                  )	
b__pip  = b_image( dty+'a__pip',  b_str=b, /reuse          )	
b_fld   = b_image( dty+'a_fld',   b_str=b, /reuse          )	
b_psi   = b_image( dty+'a_psi',   b_str=b, /reuse, bkg=90. )	
b_azm   = b_image( dty+'a_azm',   b_str=b, /reuse          )	
b_1azm  = b_image( dty+'a_1azm',  b_str=b, /reuse          )	
b_1incl = b_image( dty+'a_1incl', b_str=b, /reuse, bkg=90. )	
b_2azm  = b_image( dty+'a_2azm',  b_str=b, /reuse          )	
b_2incl = b_image( dty+'a_2incl', b_str=b, /reuse, bkg=90. )	
			;
			;Set where() to highlight the display.
			;
if  n_elements(hilight) eq 0  then  hilight=1
if  hilight eq 1 then  highlight = reversal( b_1incl, b__pip, b )
if  hilight eq 2 then  highlight = ambigs( b_azm, b.sxy )
			;
			;Plot magnetic field.
			;
field_scale, b.cct_min, b.cct_max
field_plot					$
, b__cct,    b_fld,     b_psi,   b_azm		$
, b_1incl,  b_1azm,   b_2incl,  b_2azm		$
, b						$
, highlight	= highlight			$
, profile	= profile
			;
end
