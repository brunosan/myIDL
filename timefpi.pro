function timefpi,file
;given a file name of a new-FPI data, it returns the seconds after the 00:00 time when it was taken.

t=strpos(file,'_Time')
if t EQ -1 then begin
	openr, unit, file, /get
	hdr = bytarr( 80, 36, /NOZERO )
	readu, unit, hdr
	close,unit
	hdr=string(hdr)
	file=sxpar( hdr, 'FILENAME')
	t=strpos(file,'_Time')
end
timestring=strmid(file,t+6,6)
hours=float(strmid(timestring,0,2))
minutes=float(strmid(timestring,2,2))
seconds=float(strmid(timestring,4,2))
time=float(seconds+(minutes+(hours)*60)*60)
return,time
end