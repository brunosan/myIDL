;
;	Specifiy label info for I,Q,U,V.
;
common iquv_label,		$
	x_i_label, y_i_label,	$
	x_q_label, y_q_label,	$
	x_u_label, y_u_label,	$
	x_v_label, y_v_label
