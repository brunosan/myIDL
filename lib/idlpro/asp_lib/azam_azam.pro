pro azam_azam, dir, a_azam, dummy, click=click, type=type
;+
;
;	procedure:  azam_azam
;
;	purpose:  disambiguate a_* file directory based
;		  a_azam argument or AZAM file in the directory
;
;	author:  paul@ncar, 6/93	(minor mod's by rob@ncar)
;
;==============================================================================
;
;       Check number of parameters.
;
if n_params() gt 2 then begin
	print
	print, "usage:	azam_azam [, dir [, a_azam ] ]"
	print
	print, "	Disambiguate a_* file directory based"
	print, "	a_azam argument or AZAM file in the directory."
	print, "	No arguments or keywords changed."
	print
	print, "	Arguments"
	print, "		dir	- directory with a_* files (def '')"
	print, "		a_azam	- input sight azimuth file"
	print, "			  (def: read AZAM file in dir or if"
	print, "			  no AZAM file read a_azm file)"
	print, "	Keywords"
	print, "		click	- set for click ok to overwrite"
	print, "		type	- set for typed ok to overwrite"
	print
	return
endif
;-
				    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				    ;
				    ;Get directory path.
				    ;
print
print, 'Starting azam_azam.pro procedure'
dty = ''
if n_elements(dir) ne 0 then dty=dir
if dty ne '' then if strmid(dty,strlen(dty)-1,1) ne '/' then dty=dty+'/'
if dty ne '' then print, 'directory: '+dty
				    ;
				    ;Read a_azm sight azimuth file.
				    ;
a_azm = read_floats( dty+'a_azm', error )
if error ne 0 then  goto, ioerror
				    ;
if  n_elements(a_azam) ne 0  then begin
				    ;
				    ;Get copy of input argument if it exists.
				    ;
	azam = a_azam
				    ;
end else begin
				    ;
				    ;Try to read AZAM file.
				    ;
	azam = read_floats( dty+'AZAM', error )
				    ;
	if  error ne 0  then begin
				    ;	
				    ;On error assume AZAM file does not exist.
				    ;Copy a_azm to AZAM and return.
				    ;
		i = write_floats( dty+'AZAM', a_azm )
		print, 'a_azm file copied to AZAM'
				    ;
	return
	end
				    ;
end
				    ;
				    ;Check that files agree in length.
				    ;
if  sizeof(azam,1) ne sizeof(a_azm,1)  then begin
	print,'Disambiguous and ambiguous files'
	print,'must be the same length.'
	print,'Something bad wrong.
	stop
end
				    ;
				    ;Subtract disambiguated and ambiguated
				    ;images and put result in range 0 to 360.
				    ;
tmp0 = fix( (azam-a_azm+3600.) mod 360. )
				    ;
				    ;Find where there are swaps.
				    ;
chg = where( tmp0 gt 90  and  tmp0 lt 270, nchg )
				    ;
				    ;If no swaps check if AZAM file is ok.
				    ;
if nchg eq 0 then begin
				    ;
	if  n_elements(a_azam) eq 0  then begin
				    ;
				    ;AZAM was input thus ok.
				    ;
		print,'Directory is up to date'
				    ;
	return
	end else begin
				    ;
				    ;Try to read AZAM file.
				    ;
		azam_file = read_floats( dty+'AZAM', error )
				    ;
		if error ne 0 then begin
				    ;
				    ;On error assume AZAM is not there.
				    ;Copy a_azm to AZAM and return.
				    ;
			i = write_floats( dty+'AZAM', a_azm )
			print, 'a_azm file copied to AZAM'
				    ;
		return
		end
				    ;
				    ;Check if AZAM file is up to date.
				    ;
		tmp0 = fix( (azam_file-a_azm+3600.) mod 360. )
		whr = where( tmp0 gt 90  and  tmp0 lt 270, nwhr )
		if nwhr eq 0 then begin
			print,'Directory is up to date.'
		return
		end
				    ;
	end
				    ;
end
				    ;
				    ;Prompt for ok to overwrite files.
				    ;
yn = 'y'
if  n_elements(click)  then begin
				    ;
	title = 'Want to overwrite a_* files ?'
	if  dty ne ''  then  title = 'Overwrite '+dty
	if  pop_cult( title=title,['yes','no'] )  then  yn='n'
				    ;
end else if n_elements(type) then begin
				    ;
	print
	read, 'Overwrite a_* files ? (y or n)--> ', yn
				    ;
end
if  yn ne 'y'  then return
				    ;
				    ;Write AZAM only if there are no
				    ;other changes.
				    ;
if  nchg eq 0  then begin
	i = write_floats( dty+'AZAM', a_azm )
	print, 'a_azm file copied to AZAM'
return
end
				    ;
print,'Updateing azimuth and inclination files'
				    ;
				    ;Update sight azimuth data.
				    ;
a_azm(chg) = a_azm(chg)+180.
whr = where( a_azm gt 180., nwhr )
if nwhr ne 0 then  a_azm(whr) = a_azm(whr)-360.
i = write_floats( dty+'a_azm', a_azm )
i = write_floats( dty+'AZAM',  a_azm )
				    ;
				    ;Update local azimuth.
				    ;
tmp0 = read_floats( dty+'a_1azm' )
tmp1 = read_floats( dty+'a_2azm' )
tmp       = tmp0(chg)
tmp0(chg) = tmp1(chg)
tmp1(chg) = tmp
i = write_floats( dty+'a_1azm', tmp0 )
i = write_floats( dty+'a_2azm', tmp1 )
				    ;
				    ;Update local inclination.
				    ;
tmp0 = read_floats( dty+'a_1incl' )
tmp1 = read_floats( dty+'a_2incl' )
tmp       = tmp0(chg)
tmp0(chg) = tmp1(chg)
tmp1(chg) = tmp
i = write_floats( dty+'a_1incl', tmp0 )
i = write_floats( dty+'a_2incl', tmp1 )
				    ;
print,'Finished azam_amam.pro'
return
				    ;
ioerror:
print, !err_string
				    ;
end
