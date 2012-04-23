function azam_pot_field, aa
;+
;
;	function:  azam_pot_field
;
;	purpose:  return where array to disambiguate azimuth based
;		  on University of Hawaii potential field calculation.
;
;	author:   paul@ncar 5/94
;
;=============================================================================
;
;	Check number of parameters.
;
if n_params() eq 0 then begin
	print
	print, "usage:	whr = azam_pot_field( aa )"
	print
	print, "	Return where array to disambiguate azimuth based"
	print, "	on University of Hawaii potential field calculation."
	print
	print, "	Argument"
	print, "		aa	- input azam structure"
	print
	return, -1
endif
;-
;-----------------------------------------------------------------------------
;							5/11/94
;
;'azam' can disambiguate based on the University of Hawaii potential
;field calculation.
;
;In order to do the potential field the parallactic angle must be in
;the a___header file.  Program 'bite' was modified on 5/10/94 to output
;the parallactic angle in a___header.  From the structure returned
;by b_image('a__cct',b_str=b) the parallactic angle should be b.head(104)
;in degrees.
;
;To update the a___header file without changing anything else in the 
;directory one could do the following:
;
;	mkdir child		Create a child directory.
;	cd child		Change to child directory.
;	bite ../*.bi -x		Expand *.bi file to a_* files.
;	cd ..			Return to parent directory.
;	mv child/a___header .	Update a___header file.
;	rm -r child		Remove child directory and contents.
;
;I have updated files
;
;	/swing/d1/asp/data/red/92.06.24/op09/a___header
;	/kenobi/d/asp/data/red/92.06.19/op07/a___header
;
;To use 'azam' for potential field disambiguation click on
;(UH potential field) in the (menu).  The program takes 2 to 5 minutes.
;The disambiguation is found by comparison with the calculated
;potential field.
;
;The only inputs are the fitted line of sight compontent of
;the magnetic field and ephemeris info.  The program does 2D fft's.
;The UH routine is about 50 lines of math with no comments.
;I do not know the theory.
;
;(UH potential field) does seem to give a better initial disambiguation
;than (up down everywhere) or (center).
;
;I found an error in the way I applied the UH code in the past.
;Even so I do not think it is a good idea to persue the UH code itself.
;It does not have the resolution for interactive work on ASP data.
;A better way is to try their ideas under 'azam'.
;
;Paul Seagraves
				    ;Get scan center relative to disk center
				    ;(arc sec).
tmp = s_image(aa.dty+'a__rgtasn', aa )
xas = tmp(aa.xdim/2,aa.ydim/2)
tmp = s_image(aa.dty+'a__dclntn', aa )
yas = tmp(aa.xdim/2,aa.ydim/2)
				    ;Solar radius in (arc sec).
ras = aa.head(102)
				    ;Latitude of scan center relative to
				    ;disk center (radians).
bc = asin(yas/ras)
				    ;Longitude of scan center relative to
				    ;disk center (radians).
lc = asin(xas/(ras*cos(bc)))
				    ;Do University of Hawaii potential
				    ;field calculation.
pot_field, lc, bc $
, aa.b_fld*cos(aa.b_psi*(!pi/180.)) $
, px, py
				    ;Potential field azimuth CCW
				    ;from sun west (degrees).
pa = atan(py,px)*(180./!pi)
				    ;Parallactic angle (degrees).
plc = aa.head(104)
				    ;p angle (degrees).
ppp = aa.head(100)
				    ;Ongoing azimuth CCW from sun west.
azm = ( (aa.b_azm+(90.+plc-ppp+90.+180.)) mod 360. ) - 180.

				    ;Azimuth difference.
tmp = (azm-pa+720.) mod 360.
				    ;Where array the other azimuth is closer.
chg = where( tmp gt 90.  and  tmp lt 270., nchg )

				    ;Updated sight azimuth array.
upd = azm
if nchg ne 0 then  upd(chg) = ( (upd(chg)+(180.+180.)) mod 360. ) - 180.
				    ;Where array for plot background.
sbkg = where( aa.sdat eq 0 )
				    ;Plot new sight azimuth.
wset, aa.win0
tvasp, upd, bi=tmp, /notv, min=-180., max=180., white=sbkg, /wrap
tv, puff(tmp,aa.t), 0, 0
azam_relabel, aa, 'New sight azimuth sun W CCW', aa.win0

				    ;Plot old sight azimuth.
wset, aa.win1
tvasp, azm, bi=tmp, /notv, min=-180., max=180., white=sbkg, /wrap
tv, puff(tmp,aa.t), 0, 0
azam_relabel, aa, 'Old sight azimuth sun W CCW', aa.win1

				    ;Plot UH potential field azimuth.
window, /free, xsize=aa.t*aa.xdim, ysize=aa.t*aa.ydim $
, xpos=0, ypos=30, title='UH potential field azimuth sun W CCW'
tvasp, pa, bi=tmp, /notv, min=-180., max=180., white=sbkg, /wrap
tv, puff(tmp,aa.t), 0, 0
				    ;Prompt if user wants update.
if pop_cult(['New azimuth','Old azimuth'],title='Click on choice') $
then  chg=-1
				    ;Delete extra window.
wdelete, !d.window
				    ;Return where array.
return, chg
				
end
