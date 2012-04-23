;
;	Specifiy color bar common field for plot_cbars.
;
common cbars,						$
	x_i_bar, y_i_bar, x_quv_bar, y_quv_bar,		$
	x_iquv_text, 					$
	y_i_text1, y_i_text2, y_q_text1, y_u_text1, 	$
	y_v_text1, y_q_text2, y_u_text2, y_v_text2,	$
	min_i, max_i, min_q, max_q,			$
	min_u, max_u, min_v, max_v,			$
	qu_range, v_range,				$
	x_bar_len, y_bar_len, n_colors
;
