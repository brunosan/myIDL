;+
; NAME:
;	LMOORE
; PURPOSE:
;	List atomic lines from C.E. Moores Multiplett tables
; CATEGORY:
;
; CALLING SEQUENCE:
;	LMOORE,START,END,FILE=FILE,LUN=LUN,/SILENT,/PRINT
; INPUTS:
;	START	: Start wavelength for search (in Angstroems!)
;	END	: End wavelength for search
; OPTIONAL INPUT PARAMETERS:
;
; KEYWORDS:
;	FILE	: If supplied, open a file with that name
;		  and write output additionally to it. Close
;		  file on exiting
;	LUN	: If given, write output additionally to that lun,
;		  MUST BE ALREADY OPENED when calling. Do NOT 
;		  close on exiting
;	SILENT	: if set, do not output on stdout
;	PRINT   : if set and nonzero, print directly on standard
;		  printer, using enscript. If filename is not 
;		  set via FILE keyword, open a temporary file
;		  named 'moore-linelist.tmp' and remove it after
;		  printing. 
; OUTPUTS:
;	Prints lines between start and end wavelength are printet on 
;	stdin and/or file
; COMMON BLOCKS:
;	MOORE	: hold data read from catalogue file
; SIDE EFFECTS:
;	creates a common block of 1.5 MByte if not already present.
; RESTRICTIONS:
;	$IDL_DIR/data/moore  must be present and 
;	suitably formatted
; NOTES:
;	i) When called for the first time, data are read in from
;	the file $IDL_DIR/data/moore
;	which contains atomic line data
;       ii) the PRINT keyword has no effect, if only LUN is used
;	to direct output to a disk file, since this unit will 
;	not be closed on exiting. 
;	iii)  Notice that specifying FILE=... overrides any
;	setting with LUN=...
; EXAMPLES:
;	LMOORE,3000,3002
;	list all lines betwen 3000 and 3002 Angstroems on stdout
;	LMOORE,3000,3002,file='lines.3000-3002',/print
;	as above, but save in file 'lines.3000-3002' on disk and
;       print that file immediately.
; MODIFICATION HISTORY:
;	written March 92 by Reinhold Kroll
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


pro lmoore,xstart,xend,file=file,lun=lun,silent=silent,print=print

common moore,mr

on_error,2
;
;  output on a file ?
;
defname='moore-linelist.tmp'
lunit=-1
if keyword_set(lun) then lunit=lun
if keyword_set(print) and not keyword_set(file) then begin
	file=defname
	endif
if keyword_set(file) then begin 
	get_lun,lunit
	openw,lunit,file
	endif

smr=size(mr)
if smr(0) eq 0 then rmoore
smr=size(mr)
if smr(0) eq 0 then begin
	print,'**** Sorry, could not read data file, exiting ..'
	return
	endif
n1=0
n2=smr(1)-1
n=(n2+n1)/2
xs=float(string(mr(n1).lam))
xe=float(string(mr(n2).lam))
;
; check input sanity
;
if xstart lt xs then begin
	xstart=xs
	print,'**** Start wavelength reset to minimum :',xstart
	endif
if xend   gt xe then begin
	xend=xe
	print,'**** End wavelength reset to maximum :',xend
	endif

if xend le xstart then begin
	print,'*** That is not a legal search interval (start > end) !!'
	print,'*** requested start: ',xstart,' end: ',xend
	return
	endif
;
; find xstart with interval searching
;
while (n2-n1) gt 1  do begin
	xl=float(string(mr(n).lam))
	if xl ge xstart then n2=n
	if xl lt xstart then n1=n
	n=(n2+n1)/2
	endwhile
;
; list to xend
;
xl=float(string(mr(n2).lam))
while xl lt xend do begin 
	elem=string(mr(n2).elem)
	ion=string(mr(n2).ion)
	intens=string(mr(n2).intens)
	mult=string(mr(n2).mult)
	e1=string(mr(n2).e1)
	e2=string(mr(n2).e2)
	e3=string(mr(n2).e3)
	source=string(mr(n2).source)
	rem1=string(mr(n2).rem1)
	rem2=string(mr(n2).rem2)
	rem3=string(mr(n2).rem3)

	if not keyword_set(silent) then  $
		print,format="(2x,f9.3,a3,a2,a5,a1,a8,a6,a6,a8)", $
			xl,elem,ion,mult,rem2,intens,e1,e2,e3
	if lunit gt 0 then begin
		printf,lunit,format="(2x,f9.3,a3,a2,a5,a1,a8,a6,a6,a8)", $
			xl,elem,ion,mult,rem2,intens,e1,e2,e3
		endif
	n2=n2+1
	xl=float(string(mr(n2).lam))
	endwhile

if keyword_set(file) then begin
	close,lunit
	free_lun,lunit
	if keyword_set(print) then begin 
		spawn,/sh,'enscript -G '+file
		if file eq defname then spawn,/sh,'/bin/rm '+file
		endif
	endif
return
end
