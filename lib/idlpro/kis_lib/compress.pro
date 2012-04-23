PRO compress,afile,host=remhost,options=options
;+
; NAME:
;	COMPRESS
; PURPOSE:
;	compresses (FITS-)files (16 bit images). 
;	(use KIS_LIB-procedure UNCOMPRESS to un-compress a compressed file.)
;*CATEGORY:            @CAT-# 11 37@
;	FITS-Files , Tools
; CALLING SEQUENCE:
;	COMPRESS,filename [,HOST=remote_host] [,/OPTIONS=opt_string]
; INPUTS:
;	filename: (string) name of (FITS-)file(s) to be compressed;
;		  if filename contains "wild characters", all matching files 
;		  will be compressed except those which end on ".CF" .
;	          ".CF" will be appended to the name of each compressed file,
;		  overwriting any existing file of this name. The original
;		  files will be removed.
; OPTIONAL INPUT PARAMETER:
;	HOST=remote_host : (string) if set, the compressing program (COMPFITS)
;		  will be executed remotely on host <remote_host> to avoid 
;		  net file transport.
;	OPTIONS=opt_string : options passed to compressing program COMPFITS,
;		  see man-pages of COMPFITS for details. Option -c will 
;		  be passed in any case; do **not** specify -q (quiet mode)
;		  Example:
;		  OPTIONS='-nvw -N 5' : n indicates non-Fits-file, v "verbose",
;		                        w print "entropy" for each bit plane,
;					-N 5 use 5 as "partition value".
;		  Default: COMPFITS is called with -c(n) -F <filename>
;		  -n is omitted if filename contains '.fits.' or ends on 
;		  '.fits';
;		  ("partition value" is selected by COMPFITS using internal
;		  default parameters.)
; OUTPUTS:
;	none
; COMMON BLOCKS:
;	none
; SIDE EFFECTS:
;	messages from COMPFITS 
; RESTRICTIONS:
;	see man pages for COMPFITS
; PROCEDURE:
;       For each matched filename not ending on .CF :
;	spawns compfits -c -F <file> [opt_string] ;
;	checks compfits-messages for string 'Compressed'; if found, the
;	original file(s) will be removed assuming that COMPFITS-action
;	was successful.
; MODIFICATION HISTORY:
;	nlte (KIS), 1992-04-27
;-
on_error,1
if n_params() ne 1 then message,$
     'Usage: COMPRESS,filename [,HOST=remote_host] [,/OPTIONS=opt_string]'
if (size(afile))(0) ne 0 or (size(afile))(1) ne 7 then message,$
     '1st argument must be a string.'
file=afile & cd,current=cwd
if strmid(file,strlen(afile)-3,3) eq '.CF' then message,$
   'filename must not end on .CF for compression.'
;
cd,current=cwd
file=strcompress(afile,/rem) & if strpos(file,'/') ne 0 then file=cwd+'/'+file
ff=findfile(file,count=n)
if n lt 1 then message,'no such file: '+file
i=1 & j=0
while i ge 0 do begin 
      i=strpos(file,'/',i) & if i ge 0 then begin j=i & i=i+1 & endif
endwhile
fildir=strmid(file,0,j)
;print,'fildir: ',fildir & print,'ff:' & print,ff
;print,'ok?' & yn='' & read,yn & if yn ne 'y' then stop
nii=0
for i=0,n-1 do begin
    if strmid(ff(i),strlen(ff(i))-3,3) ne '.CF' then $
       if nii eq 0 then begin ii=i & nii=1 & endif else ii=[ii,i]
endfor
nii=n_elements(ii)
if nii lt 1 then message,'no valid file match.'
;print,'ff(ii):' & print,ff(ii) & yn='' & read,yn & if yn ne 'y' then stop
;
compmessfil=fildir+'/'+getenv('USER')+'_compfits.msg'
if n_elements(remhost) eq 1 then rhost=(getenv('HOST') ne remhost) else rhost=0
for i=0,nii-1 do begin
ffii=ff(ii(i))
if (strpos(ffii,'.fits.') gt 0) or $
   (strpos(ffii,'.fits') eq strlen(ffii)-5) then copt=' -c ' else copt=' -cn '
if n_elements(opt_string) eq 1 then copt=copt+opt_string
c='compfits'+copt+' -F '+ffii
c=c+' >&'+compmessfil+';cat <'+compmessfil+';rm '+compmessfil
if rhost then begin
   c='rsh '+remhost+' "'+c+'"'
endif
;print,'i=',i,' spawn:' & print,c
if nii gt 1 then print,'COMPRESS: ',ffii 
spawn,c,from_compfits
;
k=n_elements(from_compfits) & ok=0
if k lt 1 then print,ffii+': no message from compfits' else $
   if strmid(from_compfits(k-1),0,10) ne 'Compressed' then begin
      print,ffii+': unexpected message from compfits'
      print,from_compfits
   endif else ok=1
if ok then begin
   print,from_compfits
   c='rm '+ffii
   if rhost then c='rsh '+remhost+' "'+c+'"'
   spawn,c
endif else print,ffii+': not deleted'
endfor
;
end
