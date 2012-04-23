pro c_field, dir, dummy		$
, pix_deg	= pix_deg	$
, hilight	= hilight	$
, profile	= profile	$
, c__cct	= c__cct	$
, c_fld		= c_fld		$
, c_psi		= c_psi		$
, c_azm		= c_azm		$
, c_1incl	= c_1incl	$
, c_1azm	= c_1azm	$
, c_2incl	= c_2incl	$
, c_2azm	= c_2azm	$
, c_str		= c		$
, b_str		= b
;+
;
;	procedure:  c_field
;
;	purpose:  read and display stretched 2D image of a_* files
;		  dumped by program "bite" expansions of *.bi files
;		  with the -x option
;
;	author:  paul@ncar, 4/93	(minor mod's by rob@ncar)
;
;==============================================================================
;
;       Check number of parameters.
;
if n_params() gt 1 then begin
	print
	print, "usage:	c_field [, dir]"
	print
	print, "	Read and display stretched 2D image of a_* files"
	print, "	dumped by program 'bite' expansions of *.bi files"
	print, "	with the -x option."
	print
	print, "	Arguments"
	print, "		dir	- directory path (string;"
	print, "			  def=use current working directory)"
	print
	print, "	Keywords (input)"
	print, "		pix_deg	- great circle pixels per degree"
	print, "			  (use about 45 for no magnification;"
	print, "			   > 70 may not map properly; def=50.)"
	print, "		hilight	- highlighting flag"
	print, "			    0 = no highlighting"
	print, "			    1 = highlight reversal(def)"
	print, "			    2 = highlight ambiguous azimuth"
	print, "		profile	- if set, invoke PROFILES procedure"
	print, "			  (def=do profile)"
	print
	print, "	Keywords (output; defs=values not output)"
	print, "		c__cct	- 2D array of continuum"
	print, "		c_fld	- 2D array of magnetic field values
	print, "			  (Gauss)"
	print, "		c_psi	- 2D array of inclination from line"
	print, "			  of sight (0. to 180.)"
	print, "		c_azm	- 2D array of azimuth ccw from normal"
	print, "			  to elevation mirror (-180. to 180.)"
	print, "		c_1incl	- 2D array of inclination from"
	print, "			  solar surface normal (0. to 180.)"
	print, "		c_1azm	- 2D array of azimuth from"
	print, "			  solar west (-180. to 180.)"
	print, "		c_2incl,- (ambigous inclination and azimuth)"
	print, "		c_2azm"
	print, "		c_str	- structure for data and directory"
	print, "		b_str	- structure for data and directory"
	print
	print, "  ex1:"
	print, "	; Display magnetic field in cwd."
	print, "	; Return 2D continuum array; invoke PROFILES."
	print, "	c_field, c__cct=c__cct, /profile"
	print
	print, "  ex2:"
	print, "	; Display magnetic field in directory /d/red/*5v*."
	print, "	c_field, '/d/red/*5v*'"
	print
	return
endif
;-
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			;
			;Append directory name with / 
			;
dty = ''
if n_elements(dir) ne 0 then dty=dir
if dty ne '' then if strmid(dty,strlen(dty)-1,1) ne '/' then dty=dty+'/'
			;
			;Use c_image procedure to form stretched 2D images.
			;
c__cct  = c_image( dty+'a__cct',  c_str=c, b_str=b, pix_deg=pix_deg )	
c__pip  = c_image( dty+'a__pip',  c_str=c, /reuse                   )
c_fld   = c_image( dty+'a_fld',   c_str=c, /reuse                   )	
c_psi   = c_image( dty+'a_psi',   c_str=c, /reuse, bkg=90.          )
c_azm   = c_image( dty+'a_azm',   c_str=c, /reuse                   )
c_1azm  = c_image( dty+'a_1azm',  c_str=c, /reuse                   )
c_1incl = c_image( dty+'a_1incl', c_str=c, /reuse, bkg=90.          )
c_2azm  = c_image( dty+'a_2azm',  c_str=c, /reuse                   )
c_2incl = c_image( dty+'a_2incl', c_str=c, /reuse, bkg=90.          )
			;
			;Set where() to highlight.
			;
if  n_elements(hilight) eq 0  then  hilight=1
if  hilight eq 1 then  highlight = reversal( c_1incl, c__pip, c )
if  hilight eq 2 then  highlight = ambigs( c_azm, c.sxy )
			;
			;Plot magnetic field.
			;
field_scale, c.cct_min, c.cct_max
field_plot $
, c__cct, c_fld , c_psi, c_azm $
, c_1incl, c_1azm, c_2incl, c_2azm, c $
, highlight=highlight, profile=profile
			;
end
