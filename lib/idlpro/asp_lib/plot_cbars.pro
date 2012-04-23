pro plot_cbars, special, ngray, act_scan, seq_scan, 		$
	i_scl=i_scl, q_scl=q_scl, u_scl=u_scl, v_scl=v_scl
;+
;
;	procedure:  plot_cbars
;
;	purpose:  plot the color bars for aspview
;
;	author:  rob@ncar, 5/92
;
;	notes:  - i_scl, q_scl, u_scl, and v_scl are not used for
;		  'special' red/gray/blue colormap
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 4 then begin
	print
	print, "usage:  plot_cbars, special, ngray, act_scan, seq_scan"
	print
	print, "	Plot the color bars for aspview."
	print
	print, "	Arguments"
	print, "	   special	- flag if special scale/colormap used"
	print, "		   	  (0 = false; 1 = true)"
	print, "	   ngray	- size of gray region in special map"
	print, "	   act_scan	- current actual scan number"
	print, "	   seq_scan	- current sequential scan number"
	print
	print, "	Keywords"
	print, "	    i_scl,	- data value ranges used in labeling"
	print, "	    q_scl,	  I, Q, U, and V, respectively"
	print, "	    u_scl,	  (defs=use [min, max] of the data"
	print, "	    v_scl	   passed in by common blocks)"
	print
	return
endif
;-
;
;	Specify common blocks.
;
@cbars.com
@tvasp.com
@newct.com
;
;	Set up variables.
;
if special then begin			     ; special red/gray/blue colormap
	color_scan = tvasp.ix_yellow
	color = tvasp.ix_white
	min_ii = min_i
	min_qq = - qu_range
	min_uu = - qu_range
	min_vv = - v_range
	max_ii = max_i
	max_qq = qu_range
	max_uu = qu_range
	max_vv = v_range
endif else begin			     ; regular colormap
	if newct.reverse then begin
		color_scan = newct.ix_red
		color = newct.ix_black
	endif else begin
		color_scan = newct.ix_yellow
		color = newct.ix_white
	endelse
	index1_i = 0
	index2_i = newct.ix_end
	index1_quv = 0
	index2_quv = newct.ix_end

	if (n_elements(i_scl) eq 0) then begin & min_ii=min_i & max_ii=max_i
	endif else begin & min_ii=i_scl(0) & max_ii=i_scl(1) & endelse

	if (n_elements(q_scl) eq 0) then begin & min_qq=min_q & max_qq=max_q
	endif else begin & min_qq=q_scl(0) & max_qq=q_scl(1) & endelse

	if (n_elements(u_scl) eq 0) then begin & min_uu=min_u & max_uu=max_u
	endif else begin & min_uu=u_scl(0) & max_uu=u_scl(1) & endelse

	if (n_elements(v_scl) eq 0) then begin & min_vv=min_v & max_vv=max_v
	endif else begin & min_vv=v_scl(0) & max_vv=v_scl(1) & endelse
endelse
;
;	Scale Q,U,V ranges by maximum I value.
;
if (max_ii ne 0.0) then begin
	min_qq = min_qq/max_ii
	min_uu = min_uu/max_ii
	min_vv = min_vv/max_ii
	max_qq = max_qq/max_ii
	max_uu = max_uu/max_ii
	max_vv = max_vv/max_ii
endif
charsize = 2.0
ndigits = 4
;
;	Plot the color bars.
;
if special then begin
	bar = bytarr(x_bar_len, y_bar_len, /nozero)
	bar = lindgen(x_bar_len, y_bar_len)/x_bar_len
	tvasp, bar, x_i_bar,   y_i_bar,   /red, center=ngray, /gray
	tvasp, bar, x_quv_bar, y_quv_bar, /red, center=ngray
endif else begin
	displayct, index1_i, index2_i, x_i_bar, y_i_bar, x_bar_len, y_bar_len
	displayct, index1_quv, index2_quv, x_quv_bar, y_quv_bar, x_bar_len, $
		y_bar_len
endelse
;
;	Label the color bars.
;
xyouts, x_iquv_text, y_i_text1, 'I: ' + float_str(min_ii, 1), /device, $
	charsize=charsize, color=color
xyouts, x_iquv_text, y_i_text2, 'I: ' + float_str(max_ii, 1), /device, $
	charsize=charsize, color=color
;
xyouts, x_iquv_text, y_q_text1, 'Q: ' + float_str(min_qq, ndigits), /device, $
	charsize=charsize, color=color
xyouts, x_iquv_text, y_q_text2, 'Q: ' + float_str(max_qq, ndigits), /device, $
	charsize=charsize, color=color
;
xyouts, x_iquv_text, y_u_text1, 'U: ' + float_str(min_uu, ndigits), /device, $
	charsize=charsize, color=color
xyouts, x_iquv_text, y_u_text2, 'U: ' + float_str(max_uu, ndigits), /device, $
	charsize=charsize, color=color
;
xyouts, x_iquv_text, y_v_text1, 'V: ' + float_str(min_vv, ndigits), /device, $
	charsize=charsize, color=color
xyouts, x_iquv_text, y_v_text2, 'V: ' + float_str(max_vv, ndigits), /device, $
	charsize=charsize, color=color
;
y = y_i_text1 + (y_i_text2 - y_i_text1) / 2
xyouts, x_iquv_text, y, ' (raw #s)', /device, charsize=charsize, color=color
;
;------- label scan number
;
dx = 5			; print actual scan number (from scan header)
dy1 = 10
x = x_iquv_text + dx
yy1 = y + (y - y_i_text1) / 2 + dy1
s = 'SCAN ' + stringit(act_scan)
xyouts, x, yy1, s, /device, charsize=charsize, color=color_scan
;
dy2 = 15		; print sequential scan number
yy2 = yy1 - dy2
s = 'SEQ ' + stringit(seq_scan)
xyouts, x, yy2, s, /device, charsize=charsize, color=color_scan
;
x1 = x - 5		; draw box
x2 = x + 52
y1 = yy1 + 14
y2 = yy2 - 6
x_coords = [x1, x1, x2, x2, x1]
y_coords = [y1, y2, y2, y1, y1]
plots, x_coords, y_coords, /device, color=color_scan
;
;-------
;
y = y_v_text1 + (y_q_text2 - y_v_text1) / 2
xyouts, x_iquv_text, y, ' (#s/Imax)', /device, charsize=charsize, color=color
;
;	Return.
;
end
