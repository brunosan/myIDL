pro lookexab
;+
; NAME:
;	LOOKEXAB
; PURPOSE:
;	Easy-to-use procedure to display CCD-exposures from ExaB-tape.
;*CATEGORY:            @CAT-#  2 15@
;	CCD Tools , Image Display
; CALLING SEQUENCE:
;	LOOKEXAB
; INPUTS:
;	none
; OPTIONAL INPUT PARAMETER:
;	none
; OUTPUTS:
;	none
; OPTIONAL OUTPUTS:
;	none
; COMMON BLOCKS:
;	none
; SIDE EFFECTS:
;	Raster-image on display-window
; RESTRICTIONS:
;	ExaByte-tape must contain FITS-images as created by AT1-software.
; PROCEDURE:
;	looping of following sequence of procedures:
;	rdfitsa - print header & display image (tvscl) - rdpix
; MODIFICATION HISTORY:
;	nlte (KIS), 1992-08-26 created
;	nlte (KIS), 1993-06-04 minor update messages
;-
on_error,2
;
first=1
print,'Hit RETURN when ExaByte drive is ready for reading!'
yn='' & read,yn 
jmpskp:
print,'How many exposures to be skipped? Enter number or hit RETURN'
nskip=0 & yn='' & read,yn & if yn ne '' then nskip=fix(yn)
again:
if first then rdfitsa,ccd,fits=hdr,/exab,skip=nskip,/del,/res else $
              rdfitsa,ccd,fits=hdr,/exab,skip=nskip,/del
for i=0,n_elements(hdr)-1 do print,hdr(i) 
tvscl,ccd
if first then print,'Move cursor into image-window to get x,y,z-values!'
if first then print,'Hit key "Front (L5)" if image-window not in foreground!'
rdpix,ccd
if first then print,'Move cursor back to IDL-command-window!'
first=0
;
jmpq: print,'Quit, Next exposure or Skip over exposures? Enter q/n/s'
nskip=0 & yn='' & read,yn 
if strlowcase(strtrim(yn,2)) eq 'n' then goto,again
if strlowcase(strtrim(yn,2)) eq 's' then goto,jmpskp
if strlowcase(strtrim(yn,2)) ne 'q' then goto,jmpq 
;  
print,'ExaByte tape will stop here. Press rubber knot at drive to rewind it!'
;
end
