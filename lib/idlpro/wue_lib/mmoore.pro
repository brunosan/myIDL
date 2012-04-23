;+
; NAME:
;	MMOORE
; PURPOSE:
;	List multipletts from C.E. Moores Multiplett tables
; CATEGORY:
;
; CALLING SEQUENCE:
;	MMOORE,ELEM,ION,MULTI,FILE=FILE,LUN=LUN,/SILENT,/PRINT
; INPUTS:
;	ELEM	: Search for that element
;	ION	: Search for that ion
;	MULTI	: Search for that multiplett
; OPTIONAL INPUT PARAMETERS:
;
; KEYWORDS:
;	FILE	: If supplied, open a file with the given name
;		  and write output additionally to it, close
;		  file on exiting 
;	LUN	: If given, write output additionally to that lun,
;		  MUST BE ALREADY OPENED when calling. lun is 
;                 NOT closed on exiting.
;	SILENT	: if set, suppress output on stout
;	PRINT	: if set and nonzero, print results directly on
;		  the default printer, using enscript. If no
;		  filename is given via FILE parameter, a temporary
;		  file is created, named 'moore-multipletts.tmp' and
;		  removed after printing.
; OUTPUTS:
;	List all lines found in the specified multiplett on 
;	stdin and/or file
; COMMON BLOCKS:
;	MOORE	: hold data read from catalogue file
; SIDE EFFECTS:
;	creates a common block of 1.5 MByte when called for the first
;       time. This common is also used by LMOORE
; RESTRICTIONS:
;	'$IDL_DIR/data/moore' must be present and 
;	suitably formatted
; NOTES:
;	i) When called for the first time, data are read in from
;	the file '$IDL_DIR/data/moore' 
;       which contains atomic line data
;       ii) PRINT does not work if only keyword LUN is supplied,
;       since in this case the disk file will not be closed on exiting.
; EXAMPLES:
;	MMOORE,'FE',1,318,/PRINT
; 	find multiplett 318 of Fe-1, show on stdout and print results
;       directly
;	MMOORE,'FE',1,318,FILE='fe1.318'
;       as above, however do not print, but save results on file 'fe1.318'.
; 	A more sophisticated use:
;       .
;	.
;	openw,1,'fe1.mult'
;	for i=1,10 do mmore,'FE',1,i,lun=1    ; list multipletts 1-10
;	close,1
; 	.
;	.	
; MODIFICATION HISTORY:
;	written March 92 by Reinhold Kroll
;       last update 02.Apr.92 rkr
;-------------------------------------------------------------
;
; The following module reads the moore data file
;
pro rmoore
on_error,2
on_ioerror,ret
common moore,mr

entries=26323
moorefile=getenv('IDL_LOCAL')+'/data/moore'

m= {mentry,lam:bytarr(9),rem1:bytarr(9),elem:bytarr(2),ion:bytarr(2), $
	rem2:bytarr(2),mult:bytarr(5),rem3:bytarr(2),source:bytarr(2), $
	intens:bytarr(8),e1:bytarr(6),e2:bytarr(6),e3:bytarr(8)}
mr=replicate(m,entries)

get_lun,lun
openr,lun,moorefile
print,' reading ',moorefile,' ...'
ass=assoc(lun,m)
for i=0,entries-1 do mr(i)=ass(i)
close,lun
free_lun,lun
return

ret:
print,'**** I/O error while reading ',moorefile
close,1
return
end



pro mmoore,elin,io,mu,file=file,lun=lun,silent=silent,print=print, $
 	   append=append

on_error,2
on_ioerror,next
common moore,mr

defname='moore-multipletts.tmp'
lunit=-1
app_flag=0
if keyword_set(lun) then lunit=lun
if keyword_set(append) then app_flag=1 
if keyword_set(print) and not keyword_set(file) then begin
	file=defname
	endif
if keyword_set(file) then begin 
	get_lun,lunit
	openw,lunit,file,append=app_flag
	endif

smr=size(mr)
if smr(0) eq 0 then begin
	rmoore
	smr=size(mr)
	endif

if smr(0) eq 0 then begin
	print,'**** Sorry, could not read data file, exiting ..'
	return
	endif
if lunit gt 0 then begin
	printf,lunit,';'
	printf,lunit, $
	    format="('; Lines in Multiplett ',I5,' of ',a3,i2)", $
	    mu,elin,io
	printf,lunit,';'
	endif

by=bytarr(80)
by=byte(strcompress(strupcase(elin)+' '))
el=string(by(0:1))
n=-1
next:
n=n+1
if n gt (smr(1)-2) then goto,ret
	elem=string(mr(n).elem)
	if elem ne el then goto, next 
	ion=float(string(mr(n).ion))
	if ion ne io then goto, next
	mult=float(string(mr(n).mult))
	if mult ne mu then goto, next
	xl=float(string(mr(n).lam))
	intens=string(mr(n).intens)
	e1=string(mr(n).e1)
	e2=string(mr(n).e2)
	e3=string(mr(n).e3)
	source=string(mr(n).source)
	rem1=string(mr(n).rem1)
	rem2=string(mr(n).rem2)
	rem3=string(mr(n).rem3)


	if not keyword_set(silent) then  $
		print,format="(2x,f9.3,a3,i2,i5,a2,a8,a6,a6,a8)", $
			xl,elem,ion,mult,rem2,intens,e1,e2,e3
	if lunit gt 0 then   $
		printf,lunit,format="(2x,f9.3,a3,i2,i5,a2,a8,a6,a6,a8)", $
			xl,elem,ion,mult,rem2,intens,e1,e2,e3
	goto,next

ret:
if keyword_set(file) then begin
	close,lunit
	free_lun,lunit
	if keyword_set(print) then begin
		spawn,/sh,'enscript -G '+file
		if (file=defname) then spawn,/sh,'/bin/rm '+defname
		endif
	endif
return
end
