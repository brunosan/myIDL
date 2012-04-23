pro aspcal, ii, qq, uu, vv, vttaz, vttel, tblpos, xtype, ttype, $
	xfile=xfile, tfile=tfile, vtou=vtou
;+
;
;	procedure:  aspcal
;
;	purpose:  apply X and T to Stokes I, Q, U, and V
;
;	author:  rob@ncar, 5/92
;
;	notes:  rather than matrix-multiplying in reverse order, are
;		transposing matrices and multiplying in regular order
;		(then could transpose the result)
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 9 then begin
	print
	print, "usage:  aspcal, i, q, u, v, vttaz, vttel, tblpos, xtype, ttype"
	print
	print, "	Apply X and T to Stokes I, Q, U, and V."
	print
	print, "	Arguments"
	print, "		i,q,u,v	    - input and output arrays"
	print, "		vttaz	    - telescope azimuth (degrees)"
	print, "		vttel	    - telescope elevation (degrees)"
	print, "		tblpos	    - telescope table angle (degrees)"
	print, "		xtype	    - type of X matrix"
	print, "		                0 = use xfile"
	print, "		                1 = use identity matrix"
	print, "		ttype	    - type of T matrix"
	print, "		                0 = get parameters from tfile"
	print, "		                1 = use identity matrix"
	print
	print, "	Keywords"
	print, "		xfile	    - the file containing the"
	print, "			      polarimeter response matrix"
	print, "			      (def='X' if xtype=0)"
	print, "		tfile	    - name of T matrix parameter file;"
	print, "			      must be set if ttype=0"
	print, "		vtou	    - percent of V to add to U,"
	print, "			      and U to subtract from V"
	print, "			      (def = no crosstalk removal)"
	print
	return
endif
;-
;
;	Get X.
;
if xtype eq 0 then begin				; read X from file
	if n_elements(xfile) eq 0 then xfile = 'X'
	openr, /get_lun, unit, xfile
	X = fltarr(4, 4, /nozero)
	str = ''
	for i = 1, 4 do readf, unit, str
	readf, unit, X
	free_lun, unit
	X = transpose(X)
endif else begin					; use identity matrix
	X = get_imat(4)
endelse
;
;	Get T.
;
;	Combine telescope paramters with pointing information
;	and compute and normalize the T matrix.
;
;	Note that get_t returns the transpose of the T matrix,
;	so don't have to transpose it (see 'notes' at top of page).
;
if n_elements(tfile) eq 0 then begin
	T = get_t(ttype, vttaz, vttel, tblpos)
endif else begin
	T = get_t(ttype, vttaz, vttel, tblpos, tfile)
endelse
;
;	     M = X T S , where M is the measured stokes values
;	Call A = X T
;	Thus M = A S
;	  So S = B M  , where B = inverse of A
;
AI = invert( X # T )
;
;	Apply matrix to data.
;
iiii = AI(0,0)*ii + AI(0,1)*qq + AI(0,2)*uu + AI(0,3)*vv
qqqq = AI(1,0)*ii + AI(1,1)*qq + AI(1,2)*uu + AI(1,3)*vv
uuuu = AI(2,0)*ii + AI(2,1)*qq + AI(2,2)*uu + AI(2,3)*vv
vvvv = AI(3,0)*ii + AI(3,1)*qq + AI(3,2)*uu + AI(3,3)*vv
;
ii = iiii
qq = qqqq
uu = uuuu
vv = vvvv
;
;	Apply vtou.
;
if n_elements(vtou) ne 0 then begin
	temp = uu
	uu = uu + vtou * vv
	vv = vv - vtou * temp
endif
;
end
