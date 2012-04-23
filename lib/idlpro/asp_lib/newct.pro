pro newct, pnum, dummy, noverb=noverb, special=special
;+
;
;	function:  newct
;
;	purpose:  select from one of several predefined color tables
;
;	author:  graham and rob@ncar, 1/92
;
;==============================================================================
;
;	Check number of parameters.
;
;
if n_params() gt 1 then begin
	print
	print, "usage:  newct [, pnum]"
	print
	print, "	Select from one of several predefined color tables."
	print
	print, "	Arguments"
	print, "		pnum	- palette number (from 0 to 12;"
	print, "			  def=prompt appears with ct names)"
	print
	print, "	Keywords"
	print, "		noverb	- turn off verbose (def=verbose on)"
	print, "		special	- if set, put special colors at end"
	print, "			  of colormap and in newct common"
	print, "			  (def=no special colors)"
	print
	return
endif
;-
;
;	Set common block for RSI's (and ASP's) color routines.
;
common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr
;
;	Set color palettes.
;
palettedir = '~stokes/src/palettes/'
palettes = [    'apricot.pal',		$
		'asp.pal',		$
		'aspm.pal',		$
		'aspn.pal',		$
		'aspo.pal',		$
		'aspp.pal',		$
		'default.pal',		$
		'ether.pal',		$
		'evans.pal',		$
		'fire.pal',		$
		'grey.pal',		$
		'lightness.pal',	$
		'volcano.pal'		$
	   ]
;
;	Set common block for special colors (see newct_special.pro).
;
@newct.com
@newct.set
do_special = keyword_set(special)
if not do_special then newct.n_special = 0
;
;	Set number of colors.
;
newct.n_colors = get_ncolor()			; number available
n_use = newct.n_colors - newct.n_special	; number to use now
n_use1 = n_use - 1
;
;	Set miscellaneous variables.
;
ans = string(' ',format='(a1)')
;
;	Optionally print choices and have user select a palette.
;
if n_params() eq 0 then begin
	npal = size(palettes)
	npal = npal(1)
	for i = 0, npal-1 do print, i, '  ', palettes(i)
	print
	repeat begin
		read, 'Enter table number: ', ans
		pnum = fix(ans)
	endrep until ((pnum ge 0) and (pnum le npal))
endif
;
;	Optionally print name of palette chosen.
;
if not keyword_set(noverb) then print, palettes(pnum)
;
;	Create or read color table from file.
;
if pnum eq 10 then begin			; create grayscale
	r_curr = byte(findgen(n_use) * (255./(n_use-1)) + 0.5)
	g_curr = r_curr
	b_curr = r_curr
	newct.reverse = 0
endif else if pnum eq 11 then begin		; create reverse grayscale
	r_curr = 255B - byte(findgen(n_use) * (255./(n_use-1)) + 0.5)
	g_curr = r_curr
	b_curr = r_curr
	newct.reverse = 1
endif else begin				; read table from file
	rgb = bytarr(256, 3, /nozero)
	get_lun, unit
	openr, unit, palettedir + palettes(pnum)
	readu, unit, rgb
	free_lun, unit
	m = 0
	n = n_use1
	r_curr = rgb(m:n, 0)
	g_curr = rgb(m:n, 1)
	b_curr = rgb(m:n, 2)
endelse
;
;	Optionally make room for special part.
;
if do_special then begin
	for i = 1, newct.n_special do begin
		r_curr = [r_curr, 0B]
		g_curr = [g_curr, 0B]
		b_curr = [b_curr, 0B]
	endfor
endif
;
;	Optionally insert special colors; load color table.
;
if do_special then  newct_special $
	      else  tvlct, r_curr, g_curr, b_curr
;
;	Done.
;
end
