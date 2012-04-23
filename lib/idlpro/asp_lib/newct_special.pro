pro newct_special, dummy
;+
;
;	function:  newct_special
;
;	purpose:  insert special colors at end of color table
;
;	author:  rob@ncar, 8/93
;
;==============================================================================
;
;	Check number of parameters.
;
;
if n_params() ne 0 then begin
	print
	print, "usage:  @newct.com"
	print, "	@newct.set"
	print, "	..."
	print, "	newct_special"
	print
	print, "	Insert special colors at end of color table."
	print
	print, "	Arguments"
	print, "		(none)"
	print
	print, "	Keywords"
	print, "		(none)"
	print
	return
endif
;-
;
;	Set common block for RSI's (and ASP's) color routines.
;
common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr
;
;	Set common block for newct special colors.
;
@newct.com		; (contains 'newct' structure and 'n_special')
;
;	Get number of colors.
;
n_colors = n_elements(r_curr)
if n_colors lt newct.n_special then begin
	print, 'Error in colors common block.'
	traceback & stop
end
;
;	Put special colors in color table.
;
m = n_colors - newct.n_special
n = n_colors - 1
r_curr( m : n ) = [ 180,   0,   0, 255, 255, 0, 255 ]
g_curr( m : n ) = [ 180,   0, 255,   0, 255, 0, 255 ]
b_curr( m : n ) = [ 180, 255,   0,   0,   0, 0, 255 ]
;
;	Set color indices.
;
newct.ix_white  = n_colors - 1		; (default will be white text)
newct.ix_black  = n_colors - 2
newct.ix_yellow = n_colors - 3
newct.ix_red    = n_colors - 4
newct.ix_green  = n_colors - 5
newct.ix_blue   = n_colors - 6
newct.ix_gray   = n_colors - 7
newct.ix_end    = n_colors - 8
;
;	Optionally reverse order of black and white.
;
if newct.reverse then begin		; (default will be black text)
	m = n_colors - 2
	n = n_colors - 1
	newct.ix_white  = m
	newct.ix_black  = n
	r_curr( m : n ) = [ 255, 0 ]
	g_curr( m : n ) = [ 255, 0 ]
	b_curr( m : n ) = [ 255, 0 ]
endif
;
;	Load color table.
;
tvlct, r_curr, g_curr, b_curr
;
;	Done.
;
end
