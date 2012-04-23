PRO uncompress,afile,host=remhost,options=options
;+
; NAME:
;	UNCOMPRESS
; PURPOSE:
;	un-compresses (FITS-)files (16 bit images) which were compressed by
;	IDL-KIS_LIB-procedure COMPRESS or by program COMPFITS.
;*CATEGORY:            @CAT-# 11 37@
;	FITS-Files , Tools
; CALLING SEQUENCE:
;	UNCOMPRESS,filename [,HOST=remote_host] [,/OPTIONS=opt_string]
; INPUTS:
;	filename: (string) name of (FITS-)file(s) to be un-compressed. Only
;		  files ending on ".CF" will be un-compressed; if <filename>
;		  does not end on ".CF", the routine will append this suffix
;		  internally.
;		  If filename contains "wild characters", all matching files 
;		  which end on ".CF" will be un-compressed. 
;		  The name of the un-compressed file(s) will be obtained from
;		  the compressed one(s), but with ".CF" omitted, overwriting
;		  any existing file(s) of this name. The compressed files
;		  will be removed.
; OPTIONAL INPUT PARAMETER:
;	HOST=remote_host : (string) if set, the compressing program (COMPFITS)
;		  will be executed remotely on host <remote_host> to avoid 
;		  net file transport.
;	OPTIONS=opt_string : options passed to compressing program COMPFITS,
;		  see man-pages of COMPFITS for details. Option -d will 
;		  be passed in any case; do **not** specify -q (quiet mode)
;		  Example:
;		  OPTIONS='-nv' : n indicates non-Fits-file, v "verbose";
;		  Default: COMPFITS is called with:
;		                    -d(n) -f <file>.CF -F <file>
;		  -n is omitted if filename ends on '.fits.CF' .
;		  (COMPFITS reads the parameters which were used for 
;		  compression from the FITS-header, therefore **no** such
;		  values must be specified for un-compression).
; OUTPUTS:
;	none
; COMMON BLOCKS:
;	none
; SIDE EFFECTS:
;	Un-compressed file(s) will be created, compressed version deleted
;	if action was successful; messages from COMPFITS to standard-output.
; RESTRICTIONS:
;	see man pages for COMPFITS
; PROCEDURE:
;       For each matched filename ending on .CF :
;	spawns compfits -d -f <file>.CF -F <file> [opt_string] ;
;	checks compfits-messages for string 'Expanded:'; if found, the
;	compressed file(s) will be removed assuming that COMPFITS-action
;	was successful.
; MODIFICATION HISTORY:
;	nlte (KIS), 1992-04-27
;-
on_error,1
if n_params() ne 1 then message,$
     'Usage: UNCOMPRESS,filename [,HOST=remote_host] [,/OPTIONS=opt_string]'
cd,current=cwd 
file=strcompress(afile,/rem) & if strpos(file,'/') ne 0 then file=cwd+'/'+file
if (size(file))(0) ne 0 or (size(file))(1) ne 7 then message,$
     '1st argument must be a string.'
;
; append ".CF" to filename if neccessary:
if strmid(file,strlen(file)-3,3) ne '.CF' then file=file+'.CF'
;
ff=findfile(file,count=nii)
if nii lt 1 then message,'no such file(s): '+file
;
i=1 & j=0
while i ge 0 do begin 
      i=strpos(file,'/',i) & if i ge 0 then begin j=i & i=i+1 & endif
endwhile
fildir=strmid(file,0,j)
compmessfil=fildir+'/'+getenv('USER')+'_compfits.msg'
if n_elements(remhost) eq 1 then rhost=(getenv('HOST') ne remhost) else rhost=0
for i=0,nii-1 do begin
ffii=ff(i)
if strpos(ffii,'.fits.CF') eq strlen(ffii)-8 then copt=' -d ' else copt=' -dn '
if n_elements(opt_string) eq 1 then copt=copt+opt_string
c='compfits'+copt+' -f '+ffii+' -F '+strmid(ffii,0,strlen(ffii)-3)
c=c+' >&'+compmessfil+';cat <'+compmessfil+';rm '+compmessfil
if rhost then begin
   c='rsh '+remhost+' "'+c+'"'
endif
;print,'i=',i,' spawn:' & print,c
if nii gt 1 then print,'UNCOMPRESS: ',ffii
spawn,c,from_compfits
;
k=n_elements(from_compfits) & ok=0
if k lt 1 then print,ffii+': no message from compfits' else $
   if strmid(from_compfits(k-1),0,9) ne 'Expanded:' then begin
      print,ffii+': unexpected message from compfits'
      print,from_compfits
   endif else ok=1
if ok then begin
   print,from_compfits
   c='rm '+ffii
   if rhost then c='rsh '+remhost+' "'+c+'"'
;   print,'rm-spawn:',c
   spawn,c
endif else print,ffii+': not deleted'
endfor
;
end
