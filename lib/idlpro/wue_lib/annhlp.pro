;+
; NAME:
;       ANNHLP
; PURPOSE:
;       Annotate tools overview.
; CATEGORY:
; CALLING SEQUENCE:
;       annhlp
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 21 Sep, 1990
;-
 
	pro annhlp, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Annotate tools overview.'
	  print,' annhlp'
	  print,'   Prints overview for the ann* routine.'
	  return
	endif
 
	print,' '
	print,' A set of interactive routines are available for image or plot'
	print,' annotation.  Each item put on the screen also stored in memory'
	print,' and may be saved and replotted later.'
	print,' '
	print,' There are two types of routines, action and control.'
	print,' Action routines:'
	print,'   anncrv - draw lines and curves.'
	print,'   anntxt - write text.'
	print,'   annply - draw polygons.'
	print,'   annbox - draw boxes.'
	print,'   anncrc - draw circles.'
	print,'   annarr - draw arrows.'
	print,' Control routines.'
	print,'   annres - clear memory.'
	print,'   annexe - display everything in memory.'
	print,'   annedt - display and/or remove items in memory.'
	print,'   annput - save memory in a file.'
	print,'   annget - load memory from a file.'
	print,' '
	txt = ''
	read,' Press RETURN to continue', txt
	print,' '
	print,' The routine ann does all the above using menu selections.'
	print,' For PostScript ann cannot be used for plot annotation.'
	print,' Use annexe instead.'
	print,' '
	print,' For some tools box labeled options appears on the screen.'
	print,' To activate options (to set box size or position) wiggle'
	print,' the cursor inside the options box.'
	print,' '
	print,' If annotating on the screen and then transfering to'
	print,' PostScript the keyword position is needed to force the'
	print,' two plots to occur at the same normalized position.'
	print,'The routine subnormal may also be needed.  See subnormal ?.'
	print,' '
	return
 
	end
