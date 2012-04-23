pro azimuth_flip, a_azm, whr_flip	$
, a_1azm, a_1incl			$
, a_2azm, a_2incl
;+
;
;	procedure:  azimuth_flip
;
;	purpose:  flip 180 degree azimuth ambiguity based on where() array;
;		  not usually used interactively
;
;	author:  paul@ncar, 4/93	(minor mod's by rob@ncar)
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() eq 0 then begin
	print
	print, "usage:	azimuth_flip, a_azm,  whr_flip $"
	print, "		    , a_1azm, a_1incl  $"
	print, "		    , a_2azm, a_2incl"
	print
	print, "	azimuth_flip, b_azm,  whr_flip $"
	print, "		    , b_1azm, b_1incl  $"
	print, "		    , b_2azm, b_2incl"
	print
	print, "	azimuth_flip, c_azm,  whr_flip $"
	print, "		    , c_1azm, c_1incl  $"
	print, "		    , c_2azm, c_2incl"
	print
	print, "	Flip 180 degree azimuth ambiguity based on where()"
	print, "	array; not usually used interactively."
	print
	print, "	Arguments"
	print, "		a_azm	- 2D array of azimuth ccw from normal"
	print, "			  to elevation mirror (-180. to 180.)"
	print, "		whr_flip- where array to flip azimuth 180 deg."
	print, "		a_1incl	- 2D array of inclination from"
	print, "			  solar surface normal (0. to 180.)"
	print, "		a_1azm	- 2D array of azimuth from"
	print, "			  solar west (-180. to 180.)"
	print, "		a_2incl	- (ambigous inclination and azimuth)"
	print, "		a_2azm"
	print
	return
endif
;-
		    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		    ;Exchange the 180 degree ambiguity in the arrays
		    ;for the subscripts in whr_flip.
		    ;
if  sizeof(whr_flip, 0) gt 0  then begin
		    ;
		    ;Flip direction of a_azm.
		    ;Find where a_azm if greater than 180.
		    ;Put a_azm in range -180. to 180.
		    ;
	a_azm( whr_flip ) = a_azm( whr_flip )+180.
	whr = where( a_azm gt 180., nwhr )
	if  nwhr ne 0  then  a_azm( whr ) = a_azm( whr )-360.
		    ;
		    ;Flip local frame field components.
		    ;
	tmp                 = a_1azm( whr_flip )
	a_1azm( whr_flip )  = a_2azm( whr_flip )
	a_2azm( whr_flip )  = tmp
		    ;
	tmp                 = a_1incl( whr_flip )
	a_1incl( whr_flip ) = a_2incl( whr_flip )
	a_2incl( whr_flip ) = tmp
		    ;
endif
end
		    ;
		    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
