function get_t, ttype, vttaz, vttel, tblpos, tfile
;+
;
;	function:  get_t
;
;	purpose:  return a telescope matrix
;
;	authors:  rob and paul, 9/92
;
;	notes:  1) the tfile contains the 11 parameters in order (no text)
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() lt 1 then begin
usage:
	print
	print, "usage:	T = get_t(  0  , vttaz, vttel, tblpos, tfile)    -or-"
	print, "	T = get_t(  1  [...])                            -or-"
	print, "	T = get_t( 2|3 , vttaz, vttel, tblpos)"
	print
	print, "	Return a telescope matrix."
	print
	print, "	Arguments"
	print, "	    ttype	- T matrix type"
	print, "		            0 = get parameters from tfile"
	print, "		            1 = return identity matrix"
	print, "		            2 = T.wn0"
	print, "		            3 = T.ex0"
	print, "	    vttaz	- telescope azimuth (degrees)"
	print, "	    vttel	- telescope elevation (degrees)"
	print, "	    tblpos	- telescope table angle (degrees)"
	print, "	    tfile	- name of file containing T"
	print, "		          parameters (for ttype=0)"
	print
	print
	print, "   ex:  t = get_t(0, az, el, pos, 'T.92.03.25.f.4')"
	print
	return, 0
endif
;-
;
case ttype of
  0: begin					; get parameters from file
	if n_params() ne 5 then goto, usage
	openr, in_unit, tfile, /get_lun
	params = fltarr(11, /nozero)
	readf, in_unit, params
	free_lun, in_unit
	winret = params(0)
	winang = params(1)
	exret  = params(2)
	exang  = params(3)
	offout = params(4)
	rs     = params(5)
	rp     = params(6)
	ret    = params(7)
	prirs  = params(8)
	prirp  = params(9)
	priret = params(10)
     end
  1: begin					; identity matrix
	return, get_imat(4)
     end
  2: begin					; T.wn0
	if n_params() ne 4 then goto, usage
	winret	= 0.0000000
	winang	= 0.0000000
	exret	= 4.1801858
	exang	= 81.4523849
	offout	= 92.5412674
	rs	= 0.9327444
	rp	= 0.8703937
	ret	= 159.5155334
	prirs	= 0.9035645
	prirp	= 0.9035175
	priret	= 179.9855957
     end
  3: begin					; T.ex0
	if n_params() ne 4 then goto, usage
;	rt0    =       0.0940000
;	rn0    =       0.1658667
;	rk0    =       3.1687703
	winret =       3.9473975
	winang =      10.1195459
	exret  =       0.0000000
	exang  =       0.0000000
	offout =      94.3116684
	rs     =       0.9307785
	rp     =       0.8672211
	ret    =     155.4314880
	prirs  =       0.8975186
	prirp  =       0.8974682
	priret =     179.9825439
     end
  else: goto, usage
endcase
;
;	Combine telescope paramters with pointing information.
;
T = vttmtx( vttaz, vttel, tblpos, $
            winret, winang,       $
            exret, exang,         $
            offout,               $
            rs, rp, ret,          $
            prirs, prirp, priret )
;
;	Normalize and return the T matrix.
;
T = T/T(0,0)
return, T
end
