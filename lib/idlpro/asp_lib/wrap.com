;
;	file:  wrap.com
;
;	purpose:  define common block for 'newwct' and 'wrap_scale'
;
;	author:  rob@ncar, 8/92
;
;	usage:  (see newwct)
;
;------------------------------------------------------------------------------
;
;	Specifiy wapping color table common block
;	(see wrap.set, newwct.pro, and wrap_scale.pro).
;
common wrap,							$
	num_total, num_color, num_color2,			$
	num_special, num_gray, num_color3h,			$
	ix_back, ix_color, ix_color2, ix_gray,			$
	ix_nodat, ix_nodat2, ix_cont1, ix_cont2, ix_text,	$
	ix_color3a, ix_color3b
;
