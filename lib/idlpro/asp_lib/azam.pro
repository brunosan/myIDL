;
;	Compile azam codes.
;
@azam_tools
;
pro azam, dir, dummy
;+
;
;	procedure:  azam
;
;	purpose:  use interactive cursor to disambiguate azimuth in
;		  directories with a_* files
;
;	author:  paul@ncar, 6/93	(minor mod's by rob@ncar)
;
;	notes:
;
;  I recomend the following steps for a first azimuth disambiguation.
;
;  (1). On starting azam you are prompted for magnification.
;       I recomend you click on 3.
;  (2). From ( menu ) click on ( up down everywhere ).
;       This picks the field most perpendicular to the sun surface
;       everywhere.  This is a global disambiguation.
;       This disamgiguation should pinpoint the spots and get
;       most of the quiet regions set correct.
;  (3). From ( menu ) click on ( set reference ).
;       This sets a reference image which can be recalled by the 
;       interative mouse.  Use ( set reference ) often.
;  (4). The rest is fine detail working with the interactive mouse.
;       I think using the mouse in ( wads ) mode works the best.
;
;  - Paul, 9/30/93
;
;==============================================================================
;
;       Check number of parameters.
;
if n_params() gt 1 then begin
	print
	print, "usage:	azam [, dir ]"
	print
	print, "	Use interactive cursor to disambiguate azimuth in"
	print, "	directories with a_* files."
	print
	print, "	Arguments"
	print, "		dir	- directory path (string;"
	print, "			  def=use current working directory)"
	print
	return
endif
;-
				    ;Numbers of azam ascii and button windows.
common common_ab, wina, winb
wina = -1
				    ;Append directory name with / 
dty0 = ''
if n_elements(dir) ne 0 then  dty0 = dir
if dty0 ne '' then if strmid(dty0,strlen(dty0)-1,1) ne '/' then dty0=dty0+'/'

				    ;Read header, check for existence.
junk = read_floats( dty0+'a___header', error )
if  error ne 0  then begin
	print, !err_string
	print, 'a_* files may not exit or wrong directroy path wrong'
	return
end
				    ;Create op0.
azam_op, dty0, aa0, umb0, luz0, arr0

				    ;Plot field scale.
field_scale, aa0.cct_min, aa0.cct_max, mxfld=aa0.mxfld, window=winf

				    ;active = 0  if op0 is active.
				    ;active = 1  if op1 is active.
				    ;active = -1 to exit.
active = 0
				    ;Activate op0.
while  active ne -1  do begin
if  active eq 0  then begin
				    ;Run bulk of program
	azam_bulk, aa0, umb0, luz0, arr0, now_what

	case now_what of
				    ;Check for zoom images.
	'zoom': azam_zoom, aa0, umb0, luz0, arr0

				    ;Check for -EXIT-
	'-EXIT-': active = -1
				    ;Check for replace op request.
	'replace op': begin
				    ;Prompt for directory path.
		dty = azam_dir(aa0)
				    ;Check for valid directory path.
		if dty ne 'quit' then begin

				    ;Permit saving ongoing op.
			azam_azam, dty0, azam_a_azm(aa0), /click

				    ;Recreate op0.
			dty0 = dty
			azam_op, dty0, aa0, umb0, luz0, arr0
		end
		end
				    ;Check for other op request.
	'other op': begin
				    ;Switch to other op if it exits.
		if  n_elements(aa1) eq 0  then begin

				    ;Prompt for directory path.
			dty1 = azam_dir(aa0)

				    ;Check for valid directory path.
			if dty1 ne 'quit' then begin

				    ;Permit saving ongoing op.
				print,'Warning: may exceed core limit.
				azam_azam, dty0, azam_a_azm(aa0), /click

				    ;Create op1.
				azam_op, dty1, aa1, umb1, luz1, arr1
			end
		end
				    ;Switch to other op if it exits.
		if  n_elements(aa1) ne 0  then  active = 1
		end
	else:
	end
				    ;Activate op1.
end else if  active eq 1  then begin

				    ;Run bulk of program
	azam_bulk, aa1, umb1, luz1, arr1, now_what

	case now_what of
				    ;Check for zoom images.
	'zoom': azam_zoom, aa1, umb1, luz1, arr1

				    ;Check for -EXIT-
	'-EXIT-': active = -1
				    ;Check for replace op request.
	'replace op': begin

				    ;Prompt for directory path.
		dty = azam_dir(aa1)
				    ;Check for valid directory path.
		if dty ne 'quit' then begin

				    ;Permit saving ongoing op.
			azam_azam, dty1, azam_a_azm(aa1), /click

				    ;Recreate op1.
			dty1 = dty
			azam_op, dty1, aa1, umb1, luz1, arr1
		end
		end
				    ;Check for other op request.
	'other op': active = 0

	else:
	end
end
end
				    ;Save results.
azam_azam, dty0, azam_a_azm(aa0), /click
if  n_elements(aa1) ne 0  then $
azam_azam, dty1, azam_a_azm(aa1), /click

				    ;Close windows.
wdelete, wina, winb, winf
wina = -1

end
