pro azam_menu, aa, umbra, laluz, arrow, now_what
;+
;
;	procedure:  azam_menu
;
;	purpose:  do or set path to azam menu option.
;
;	author:  paul@ncar, 6/93	(minor mod's by rob@ncar)
;
;==============================================================================
;
;	Check number of parameters.
;
if  n_params() ne 5  then begin
	print
	print, "usage:	azam_menu, aa, umbra, laluz, arrow, now_what"
	print
	print, "	Do or set path to azam menu option."
	print
	print, "	Arguments"
	print, "		aa	- I/O azam data set structure"
	print, "		umbra	- I/O where array for umbra hi light"
	print, "		laluz	- I/O where array for active hi light"
	print, "		arrow	- I/O arrow point structure"
	print, "		now_what- returned ascii string request"
	print
	return
endif
;-
				    ;Image magnification factor.
				    ;Margin width around images.
				    ;Unmagnified dimensions.
t     = aa.t
xdim  = aa.xdim
ydim  = aa.ydim
txdim = t*xdim
tydim = t*ydim
				    ;Reset some variables.
white  = aa.white
yellow = aa.yellow
red    = aa.red
black  = aa.black
				    ;Labels for pop up menu.
if  aa.zoom eq 0  then begin
				    ;
	if aa.stretch $
	then  ps='PostScript' $
	else  ps = 'continue'
				    ;
	if aa.head(104) ne 0. $
	then  pf='UH potential field' $
	else  pf='continue'
				    ;
	labels = strarr(2,15)
	labels(0,*) = $
	[ 'replace op' $
	, 'sight reversal' $
	, 'reversal' $
	, 'ambigs' $
	, 'umbra' $
	, 'arrow points' $
	, 'zoom' $
	, 'blink' $
	, 'sub flick' $
	, 'flick' $
	, 'profiles' $
	, 'custom image' $
	, 'clear' $
	, 'primer' $
	, 'continue' $
	]
	labels(1,*) = $
	[ '-EXIT-' $
	, 'another inversion azimuth' $
	, 'overwrite a_* files' $
	, 'write azimuth file' $
	, 'read azimuth file' $
	, 'recover original' $
	, 'recover reference' $
	, ps $
	, 'other azimuth' $
	, 'center' $
	, 'up down everywhere' $
	, pf $
	, 'help' $
	, 'spectra' $
	, 'continue' $
	]
end else begin
	labels = strarr(2,11)
	labels(0,*) = $
	[ 'sight reversal' $
	, 'reversal' $
	, 'ambigs' $
	, 'umbra' $
	, 'arrow points' $
	, 'blink' $
	, 'sub flick' $
	, 'flick' $
	, 'profiles' $
	, 'clear' $
	, 'primer' $
	]
	labels(1,*) = $
	[ '-RETURN-' $
	, 'recover original' $
	, 'recover reference' $
	, 'other azimuth' $
	, 'center' $
	, 'up down everywhere' $
	, 'help' $
	, 'spectra' $
	, 'continue' $
	, 'continue' $
	, 'continue' $
	]
end
labels = reform( labels, n_elements( labels ) )

				    ;Prompt for menu choice.
now_what = labels( pop_cult( labels ) )

				    ;Check for return to calling program.
case now_what of
'continue'		: return
'zoom'			: return
'replace op'		: return
'-EXIT-'		: return
'-RETURN-'		: return
				    ;Check for help button.
'help'			: azam_help
				    ;Work on custom image.
'custom image'		: azam_custom, aa, umbra, laluz, arrow

				    ;Check if current results are to be saved.
'overwrite a_* files'	: azam_azam, aa.dty, azam_a_azm(aa), /click

				    ;Check for profiles.
'profiles'		: azam_profiles, umbra, laluz, arrow, aa

				    ;Check for specta display.
'spectra'		: azam_spectra, aa, umbra, laluz, arrow

				    ;Check for blinking.
'blink'			: azam_blink, umbra, laluz, arrow, aa

				    ;Check for blinking in both
				    ;display windows.
'flick'			: azam_flick, aa, umbra, laluz, arrow

				    ;Check for blinking sub image in both
				    ;display windows.
'sub flick'		: azam_slick, aa, umbra, laluz, arrow

				    ;Check for PostScript.
'PostScript'		: azam_ps, aa, umbra, laluz, arrow

				    ;Check for whole image primer.
'primer': begin
				    ;Prompt for azam image name.
	labs = azam_image_names(aa)
	lb = labs( pop_cult( labs ) )
	if lb eq 'continue' then return

				    ;Prompt for which image to overwrite.
	labs = ['local azimuth','local incline','both','no plot']
	side = labs( pop_cult( labs, title='overwrite which image?') )

				    ;Change name of custom images.
	lb0 = lb
	set = strmid(lb,0,3)
	if set eq 'SET' then lb0=strmid(lb,4,100)

				    ;Compute image.
	if set eq 'SET' or side ne 'no plot' then $
	tmp = azam_image( lb, aa, umbra, laluz, arrow )

				    ;Set and display interactive images.
	if  side eq 'local azimuth'   or  side eq 'both'  then begin
		aa.name0 = lb0
		aa.img0 = tmp
		tw, aa.win0, aa.img0, 0, 0
	end
	if  side eq 'local incline'  or  side eq 'both'  then begin
		aa.name1 = lb0
		aa.img1 = tmp
		tw, aa.win1, aa.img1, 0, 0
	end
	end
				    ;Write sight azimuth file.
'write azimuth file': begin

	mess = 'Enter output file name (q=quit) (Return=AZAM)'
	error = 1
	while error ne 0 do begin
		error = 0
				    ;Prompt for file name.
		azam_file = strcompress( azam_text_in(aa,mess), /remove_all )

		if azam_file eq 'q' then  return
		if azam_file eq ''  then  azam_file = 'AZAM'

				    ;Protect a_* files.
		if  strmid( azam_file, 0, 2 ) eq 'a_'  then begin
			mess = 'REENTER, ' $
			+ 'output to a_file not allowed (q=quit)'
			error = 1
		end
	end
				    ;Read a_azm file from directory.
	a_azm = read_floats(aa.dty+'a_azm',error)
	if error ne 0 then  print, !err_string

				    ;Put ongoing azimuth in stream vector.
	a_azm(aa.vec_sxy) = aa.b_azm(aa.sxy)

				    ;Output strean file.
	err = write_floats( aa.dty+azam_file, a_azm, error )
	if error ne 0 then  print, !err_string
	end

else: goto, continue11
end
return
continue11:
				    ;
case now_what of
				    ;
				    ;Revise contour highlights.
				    ;
'reversal': begin
	azam_cont, aa.b_1incl, aa.sdat, 90., t, laluz, nwhr
	aa.hilite = now_what
	end
'sight reversal': begin
	azam_cont, aa.b_psi, aa.sdat, 90., t, laluz, nwhr
	aa.hilite = now_what
	end
'ambigs': begin
	azam_ambigs, aa.b_azm, aa.sdat, t, laluz, nwhr
	aa.hilite = now_what
	end
				    ;
				    ;Reverse ongoing azimuth everywhere.
				    ;
'other azimuth'		: azam_flipa, aa, aa.sxy
				    ;
				    ;Recover the original azimuth.
				    ;
'recover original'	: azam_flipa, aa, where( aa.azm ne aa.azm_o )
				    ;
				    ;Recover the reference azimuth.
				    ;
'recover reference'	: azam_flipa, aa, where( aa.azm ne aa.azm_r )
				    ;
				    ;Pick most vertical field everywhere.
				    ;
'up down everywhere'	: azam_flipa, aa $
			  , where( abs(aa.b_2incl-90.) gt abs(aa.b_1incl-90. ))
				    ;
				    ;Do potential field disambiguation.
				    ;
'UH potential field'	: azam_flipa, aa, azam_pot_field(aa)
				    ;
				    ;Compute arrow points.
				    ;
'arrow points'		: arrow = azam_arrow( aa.b_1azm, aa.b_1incl, aa.sxy $
			  , aa.t, aa.angxloc )
				    ;
				    ;Compute umbra contour.
				    ;
'umbra': begin
				    ;
	if pop_cult(['widget entry','click entry']) then begin
		tmp = aa.img0
		aa.img0 = azam_image( 'continuum', aa,umbra,laluz,arrow )
		tw, aa.win0, aa.img0, 0, 0
		azam_click_xy, aa, 'Click on intensity level', xx00, yy00
		aa.umb_lvl = aa.b__cct(xx00,yy00)
		print, 'Contour is', aa.umb_lvl
		aa.img0 = tmp
		tv, aa.img0, 0, 0
	end else begin
		mess = 'Enter umbra contour level'
		if aa.umb_lvl gt 0 $
		then  mess = mess+' (was '+stringit(aa.umb_lvl)+')'
		on_ioerror, ioerror0
		ioerror0:
		umb_lvl = 0L
		reads, azam_text_in(aa,mess), umb_lvl
		aa.umb_lvl = umb_lvl
	end
				    ;
	tmp = bytarr(xdim,ydim)
	tmp( aa.pxy ) = 1
	azam_cont, aa.b__cct, tmp, aa.umb_lvl, t, umbra, nwhr
	end
				    ;
				    ;Set azimuth from another directory.
				    ;
'another inversion azimuth': begin
				    ;
				    ;Prompt for directory path.
				    ;
	dty = azam_dir(aa)
	if dty eq 'quit' then return
				    ;
				    ;Get unstretched 2D image info
				    ;for ongoing directory. 
				    ;
	if aa.stretch then begin
		azm1  = b_image( aa.dty+'a_azm', b_str=b )
		sxy0  = b.sxy
		xdim0 = b.xdim
		ydim0 = b.ydim
	end else begin
		sxy0  = aa.sxy
		xdim0 = aa.xdim
		ydim0 = aa.ydim
	end
				    ;
				    ;Get 2D azimuth image and structure
				    ;of other directory.
				    ;
	azm1 = b_image( dty+'a_azm', b_str=b, bkg=9999. )
				    ;
				    ;Check that image size is the same.
				    ;
	if  xdim0 ne b.xdim  or  ydim0 ne b.ydim  then begin
		azam_click_xy, aa $
		, 'Image size differ; click image to contunue'
		return
	end
				    ;
				    ;Get vector form for azimuth.
				    ;
	azm1 = azm1(sxy0)
				    ;
				    ;Form 2D array.
				    ;
	azam = fltarr(aa.xdim,aa.ydim)
	azam(aa.sxy) = azm1(aa.vec_sxy)
				    ;
				    ;Replace missing data by ongoing azimuth.
				    ;
	whr = where( azam eq 9999., nwhr )
	if nwhr ne 0 then  azam(whr) = aa.b_azm(whr)
				    ;
				    ;Find azimuth difference.
				    ;
	azam = (azam-aa.b_azm+720.) mod 360.
				    ;
				    ;Disambiguate azimuth.
				    ;
	azam_flipa, aa, where( azam gt 90.  and  azam lt 270. )
	end
				    ;
				    ;Read sight azimuth file.
				    ;
'read azimuth file': begin
				    ;
	mess = 'Enter sight azimuth file name (q=quit) (Return=AZAM)'
	error1:
	error = 1
	while error ne 0 do begin
				    ;
				    ;Prompt for file name.
				    ;
		azam_file = strcompress( azam_text_in(aa,mess), /remove_all )
				    ;
		if azam_file eq 'q' then  return
		if azam_file eq ''  then  azam_file = 'AZAM'
				    ;
				    ;Try to read file.
				    ;
		a_azam = read_floats( aa.dty+azam_file, error )
		if error ne 0 then  print, !err_string
				    ;
		if error eq 0 then begin
				    ;
				    ;Check if file is right length.
				    ;
			if n_elements(a_azam) ne aa.nsolved then begin
				mess = 'REENTER, ' $
				+ 'file is wrong length (q=quit)'
				error = 1
			end
				    ;
		end
				    ;
	end
				    ;
				    ;Form 2D array.
				    ;
	azam = fltarr(aa.xdim,aa.ydim)
	azam(aa.sxy) = a_azam(aa.vec_sxy)
				    ;
				    ;Find azimuth difference.
				    ;
	azam = (azam-aa.b_azm+720.) mod 360.
				    ;
				    ;Disambiguate azimuth.
				    ;
	azam_flipa, aa, where( azam gt 90.  and  azam lt 270. )
	end
				    ;
				    ;Check for center.
				    ;
'center': begin
				    ;
	azam_click_xy, aa, 'Click on azimuth center', xcen, ycen
	aa.cen_lat = aa.b__lat(xcen,ycen)
	aa.cen_e_w = aa.b__e_w(xcen,ycen)
				    ;
				    ;Prompt if want disambiguation.
				    ;
	if  pop_cult(['yes','no'], title='Want center disambiguation?' ) $
	then return
				    ;
				    ;Prompt for spot polarity.
				    ;
	polarity = 1-2*pop_cult(['yes','no'], title='Is spot positive?' )
				    ;
				    ;Find expected azimuth relative to center.
				    ;
	azm = atan( polarity*(aa.b__lat-aa.cen_lat) $
	, polarity*(aa.b__e_w-aa.cen_e_w) ) *180./!pi
				    ;
	az1 = aa.b_1azm-azm
	whr = where( az1 lt 0., nwhr )
	if  nwhr ne 0  then  az1(whr) = az1(whr)+360.
	whr = where( az1 gt 180., nwhr )
	if  nwhr ne 0  then  az1(whr) = 360.-az1(whr)
				    ;
	az2 = aa.b_2azm-azm
	whr = where( az2 lt 0., nwhr )
	if  nwhr ne 0  then  az2(whr) = az2(whr)+360.
	whr = where( az2 gt 180., nwhr )
	if  nwhr ne 0  then  az2(whr) = 360.-az2(whr)
				    ;
				    ;Flip direction of a_azm where field
				    ;azimuth agrees best with expected.
				    ;
	azam_flipa, aa, where( az1 gt az2 )
				    ;
	laluz = -1
	end
				    ;
				    ;Check for clear to standard images.
				    ;
'clear': begin
	aa.name0  = 'local azimuth'
	aa.name1  = 'local incline'
	aa.hilite = ''
	umbra = -1
	laluz = -1
	arrow = { hi: -1, lo: -1 }
	end
				    ;
else:
end
				    ;
				    ;Restore display images.
				    ;
azam_display2, aa, umbra, laluz, arrow
				    ;
end
