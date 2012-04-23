pro newct_tvscl, im, xloc, yloc, srange=srange
;+
;
;	function:  newct_tvscl
;
;	purpose:  do tvscl with color table from 'newct, /special'
;
;	author:  rob@ncar, 8/93
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 3 then begin
	print
	print, "usage:  newct_tvscl, im, xloc, yloc"
	print
	print, "	Do tvscl with color table from 'newct, /special'."
	print, "	(Run newct sometime before this.)"
	print
	print, "	Arguments"
	print, "	      im	- input array to plot"
	print, "	    xloc, yloc	- lower left corner in pixels"
	print
	print, "	Keywords"
	print, "	    srange	- data value range to scale the output"
	print, "			  to (def=[min, max] of input data)"
	print
	return
endif
;-
;
;	Set common blocks.
;
@newct.com
;
;	Scale the image to fit the available colormap range.
;	(The '> 1.0' is there to handle zero'ed images.)
;
n_use = newct.n_colors - newct.n_special
if n_elements(srange) eq 0 then begin
	minv = min(im, max=maxv)
	image = byte( (n_use - 1.0) * (im - minv) $
			/ (float(maxv - minv) > 1.0) )
endif else begin
	minv = srange(0)
	maxv = srange(1)
	image = byte( (n_use - 1.0) * ((minv > im < maxv) - minv) $
			/ (float(maxv - minv) > 1.0) )
endelse
;
;	Display the image.
;
tv, image, xloc, yloc
;
end
