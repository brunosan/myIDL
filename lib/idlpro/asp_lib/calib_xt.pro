pro calib_xt, xmats, tfile, do_skew, sslope, xc1,xc2, $
	      ii,qq,uu,vv, i_scr,q_scr,u_scr,v_scr, verbose=verbose
;+
;
;	procedure:  calib_xt
;
;	purpose:  apply Xs and T; remove skew and residual I->QUV crosstalk
;		  (for calibrate.pro)
;
;	author:  rob@ncar, 10/93
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 14 then begin
	print
	print, "usage:  calib_xt, xmats, tfile, do_skew, sslope, $"
	print, "		  xc1,xc2, ii,qq,uu,vv, $"
	print, "		  i_scr,q_scr,u_scr,v_scr"
	print
	print, "	Apply Xs and T; remove skew and residual"
	print, "	I->QUV crosstalk (for calibrate.pro)."
	print
	print, "	Arguments"
	print, "	    xmats	- X matrices for each pos'n along slit"
	print, "			  (dimensions are [y2-y1+1, 4, 4])"
	print, "	    tfile	- name of T matrix parameter file"
	print, "	    do_skew	- 1=de-skew, 0=don't de-skew"
	print, "	    sslope	- slope for use in de-skewing"
	print, "	    xc1, xc2	- X (wavelength) range for continuum"
	print, "	    ii - vv	- spectral images (input and output)"
	print, "	    *_scr 	- scratch arrays"
	print
	print, "	Keywords"
	print, "	    verbose	- if set, print run-time info"
	print, "			  (def=don't print)"
	print
	return
endif
;-
;
;       Specify common blocks.
;
@scan_hdr.com
;
;
;	Set general variables.
;
ny_use1 = sizeof(xmats, 1) - 1
do_verb = keyword_set(verbose)
;
;
;	Apply X and T matrices.
;
; ------------------------------
;
;     Theory:
;
;	   (S_inst  is measured Stokes vector)
;	   (S_cal   is calibrated Stokes vector)
;
;	   S_inst = X T S_cal
;
;     Applied Below:
;
;	   S_cal  = invert(T) invert(X) S_inst
;
; ------------------------------
;
;
;	Apply X matrix for each position along slit.
;
if do_verb then print, '>>>>>>> applying X matrices (multiplication) ...'
for y = 0, ny_use1 do begin

	i_scr(*,y) = xmats(y,0,0) * ii(*,y) + $
		     xmats(y,0,1) * qq(*,y) + $
		     xmats(y,0,2) * uu(*,y) + $
		     xmats(y,0,3) * vv(*,y)

	q_scr(*,y) = xmats(y,1,0) * ii(*,y) + $
		     xmats(y,1,1) * qq(*,y) + $
		     xmats(y,1,2) * uu(*,y) + $
		     xmats(y,1,3) * vv(*,y)

	u_scr(*,y) = xmats(y,2,0) * ii(*,y) + $
		     xmats(y,2,1) * qq(*,y) + $
		     xmats(y,2,2) * uu(*,y) + $
		     xmats(y,2,3) * vv(*,y)

	v_scr(*,y) = xmats(y,3,0) * ii(*,y) + $
		     xmats(y,3,1) * qq(*,y) + $
		     xmats(y,3,2) * uu(*,y) + $
		     xmats(y,3,3) * vv(*,y)
endfor
;
;	Get and apply T matrix.
;
if do_verb then print, '>>>>>>> applying T matrix (multiplication) ...'
t_mat = get_t(0, float(s_vtt(0)), float(s_vtt(1)), float(s_vtt(2)), tfile)
t_mat = invert(t_mat)
;
ii = t_mat(0,0)*i_scr + t_mat(0,1)*q_scr + t_mat(0,2)*u_scr + t_mat(0,3)*v_scr
qq = t_mat(1,0)*i_scr + t_mat(1,1)*q_scr + t_mat(1,2)*u_scr + t_mat(1,3)*v_scr
uu = t_mat(2,0)*i_scr + t_mat(2,1)*q_scr + t_mat(2,2)*u_scr + t_mat(2,3)*v_scr
vv = t_mat(3,0)*i_scr + t_mat(3,1)*q_scr + t_mat(3,2)*u_scr + t_mat(3,3)*v_scr
;
;	Optionally de-skew of the spectral images.
;
if do_skew then begin
	if do_verb then print, '>>>>>>> removing skewness (skew) ...'
	ii = skew(ii, sslope)
	qq = skew(qq, sslope)
	uu = skew(uu, sslope)
	vv = skew(vv, sslope)
endif
;
;	Remove residual I -> Q,U,V crosstalk.
if do_verb then print, '>>>>>>> removing I crosstalk (icross) ...'
icross, ii, qq, uu, vv, xc1, xc2
;
;	Done.
;
end
