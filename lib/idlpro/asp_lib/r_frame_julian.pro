function r_frame_julian, year, month, day, utime
;+
;
;	function:  r_frame_julian
;
;	purpose:  compute Julian time including fraction of day.
;
;	author:  paul@ncar
;
;=============================================================================
;
;Check number of parameters.
;
if n_params() eq 0 then begin
	print
	print, "usage:	djd = r_frame_julian( year, month, day, utime )"
	print
	print, "	Return double precision Julian time including"
	print, "	fraction of day."
	print
	print, "	Arguments:"
	print, "		   year	- year of observation"
	print, "			  (1900 added for 50 < year < 101 )"
	print, "			  (2000 added for year < 51 )"
	print, "		  month	- month of year"
	print, "		    day	- day of month"
	print, "		  utime	- universal time in hours"
	return, 0
endif
;-
;
;	Correct abbreviated year number.
;
iy = year
if  iy gt 50 and iy le 100  then  iy=iy+1900
if  iy le 50                then  iy=iy+2000
;
;	Return julian time.
;	Note: julday() returns julian day that starts at 12:00 ut on
;	      the given date.
;
return, double( julday( month, day, iy ) ) - .5 + utime/24.
;
end
