pro label_iquv, special
;+
;
;	function:  label_iquv
;
;	purpose:  label I,Q,U,V for aspview
;
;	author:  rob@ncar, 1/92
;
;	notes:  1. this is used by aspview
;		2. special is no longer used (remove it)
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 1 then begin
	print
	print, "usage:  label_iquv, special"
	print
	print, "	Label I,Q,U,V for aspview."
	print
	print, "	Arguments"
	print, "		special	 - flag if special scale/colormap used"
	print, "			   (0 = false; 1 = true)"
	print
	return
endif
;-
;
;	Specify common blocks.
;
@iquv_label.com
@tvasp.com
@newct.com
;
;	Set up variables.
;
if special then begin
	color = tvasp.ix_white
endif else begin
	if newct.reverse then begin
		color = newct.ix_black
	endif else begin
		color = newct.ix_white
	endelse
endelse
;
;	Label with I,Q,U,V.
;
xyouts, x_i_label, y_i_label, 'I', /device, charsize=2.0, alignment=0.5, $
	color=color
xyouts, x_q_label, y_q_label, 'Q', /device, charsize=2.0, alignment=0.5, $
	color=color
xyouts, x_u_label, y_u_label, 'U', /device, charsize=2.0, alignment=0.5, $
	color=color
xyouts, x_v_label, y_v_label, 'V', /device, charsize=2.0, alignment=0.5, $
	color=color
;
;	Done.
;
end
