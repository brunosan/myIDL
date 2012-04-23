pro ps_asp_str, c, ps
;+
;
;	procedure:  ps_asp_str
;
;	purpose:  initialize ps structure for ps_asp.pro and azam_ps.pro
;
;	author:  paul@ncar 10/93
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() eq 0 then begin
	print
	print, "usage:  ps_asp_str, c, ps"
	print
	print, "	Initialize ps structure for ps_asp.pro & azam_ps.pro
	print
	print, "Arguments:"
	print, "    c		- input data set structure"
	print, "    ps		- returned ps structure"
	print
	return
endif
;-
					;PostScript device sizes in inches
					;for landscape mode.
xdev = 11.
ydev = 8.5
					;Margins about images in inches.
					;Title, data, op numbers, color bars,
					;etc. are done in margins.
mrg_lft = 9./16.
mrg_rgt = 1.+3./16.
mrg_top = 7./8.
mrg_btm = 5./8.
					;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
					;Initialize ps structure.
					;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
					;
ps = 					$
					;2D data array dimensions.
{ xdim		: c.xdim		$
, ydim		: c.ydim		$
					;Magnification of display image.
, t		: 2			$
					;Magnified display image dimensions.
, txdim		: 2*c.xdim		$
, tydim		: 2*c.ydim		$
					;Min max used to scale contimuum image
					;in instrument scale.
, cct_min	: c.cct_min		$
, cct_max	: c.cct_max		$
					;Pixels per solar great circle degree.
, pix_deg	: c.pix_deg		$
					;Max value used to scale magnetic
					;field in gauss.
, mxfld		: c.mxfld		$
					;Gap in gauss in flux image scale.
, gap		: 2000.			$
					;Header information from bi-file.
, head		: c.head		$
					;
, mm_per_deg	: c.mm_per_deg		$
					;Default xy image scale in mega meters
					;per inch on printer.
					;This is for one image per page format.
					;Four images per page format is less
					;than half this scale.
, mm_per_inch	: 10.			$
					;PostScript device sizes in inches
					;for landscape mode.
, xdev		: xdev			$
, ydev		: ydev			$
					;Margins about images in inches.
					;Title, data, op numbers, color bars,
					;image scales, etc. are done in margins.
, mrg_lft	: mrg_lft		$	
, mrg_rgt	: mrg_rgt		$
, mrg_top	: mrg_top		$
, mrg_btm	: mrg_btm		$
					;Sizes available for image in inches.
, x_avail	: xdev-mrg_lft-mrg_rgt	$
, y_avail	: ydev-mrg_top-mrg_btm	$
					;Length tick marks in inches used to
					;mark image x & y scale.
, ticklen	: 1./4.			$
					;Logical trues to number x & y axis.
, xnumber	: 1L			$
, ynumber	: 1L			$
					;Line thickness used with plots
					;procedure when drawing image
					;highlights.
, hithick	: 5.			$
					;Position of lower left corner or
					;lower left image in inches.
, xll		: 0.			$
, yll		: 0.			$
					;Position of lower left corner of
					;image being drawn in inches.
, xorg		: 0.			$
, yorg		: 0.			$
					;Size of image being drawn in inches.
, xinches	: 0.			$
, yinches	: 0.			$
					;Array position clicked by 
					;user for area of interest.
, xctr		: 0L			$
, yctr		: 0L			$
					;X array range to plot.
, xx0		: 0L			$
, xx1		: 0L			$
					;Y array range to plot.
, yy0		: 0L			$
, yy1		: 0L			$
					;Sizes in megameters of the portion
					;of the image being plotted.
, x_mm		: 0.			$
, y_mm		: 0.			$
					;File name extension on output files.
, cs_ext	: ''			$
					;Character string with date.
, cs_date	: ''			$
					;Character string with op number.
, cs_op		: ''			$	
					;Path to directory with a_* files.
, dty		: c.dty			$
}
					;
end
