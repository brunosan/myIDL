;
;	Specifiy I,Q,U,V arrays common field.
;
common iquv,				$
	i_int, q_int, u_int, v_int,	$
	i, q, u, v
