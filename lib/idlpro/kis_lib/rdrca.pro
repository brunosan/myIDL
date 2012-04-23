PRO rdrca,ccd,infil,pdp=itape,exab=iexab,skip_file=nskip,delete=idelete
;+
; NAME:
;	RDRCA
; PURPOSE:
;	Reads an RCA-CCD image file either from PDP-1/2"-tape (conversion to
;       "SUNCCD"-format) or from disk (must be already SUNCCD-format);
;	the disk-file may be already resident or may be dumped from
;	ExaByte-tape (tar) within this procedure.
;       RDRCA returns the image data which will be stored into a structure.
;*CATEGORY:            @CAT-#  2@
;	CCD Tools
; CALLING SEQUENCE:
;	RDRCA,image_structure [,file-name] [,{/PDP | EXAB='host'}] 
;                             [,SKIP_FILE=n] [,/DELETE]
; INPUTS:
;	none
; OPTIONAL INPUTS:
;	file-name : string, name of disk-file for image data;
;	       ignored if key /EXAB is set (tar will create a disk-file
;	       with the name as found on ExaByte-tape);
;	       if key /PDP or /EXAB is **not** set, the file-name of a disk-
;	       resident file with SUNCCD-converted image data must be 
;	       specified **including** it's 'suffix';
;	       if key /PDP **is** set, a new disk-file with this name
;	       will be created to store the image (converted to SUNCCD).
;	       If file-name is not specified, this procedure will use
;	       './<user>-RCA-SUNCCD' as file-name (<user> = user-name).
;       /PDP : key-word; if set, this procedure will spawn FORTRAN-program
;              "pdp2sun_idl" which reads **one** file from PDP-1/2"-tape,
;	       converts it's contents (extraction of parameters from header
;	       and byte-swapping the image data) and which then writes the data
;	       to disk-file <file-name>.<suffix> (<suffix> = <file-no.>, even-
;	       tually extended by '.nnn', nnn from {000,001,...,999} as set by
;	       program pdp2sun_idl); the file is created in the "current 
;              directory" if <file-name> does not contain a path.
;	EXAB= 'host' : a tar-file is dumped from ExaByte-tape to disk; the
;	       cassette is attached to ExaByte-drive at host <host> (if /EXAB
;	       was set with no host-string, the host-name will be querried 
;	       within this procedure);
;	       the contents of the tar-file must be in SUNCCD-format;
;	       the file-name of the created disk file is taken from ExaByte-
;	       tape; the file is created in the "current directory"; 
;
;	       If neither /PDP nor /EXAB are set: Procedure reads disk-file
;	       <file-name> (no tape action). In this case, file-name
;	       must be specified including it's "suffix". This disk-file must
;	       be of "SUNCCD"-format, created previously by a run of program
;	       ,e.g., "pdp2sun_idl", "pdp2sun_user", or "unload".
;
;       /SKIP_FILE= n : Only meaningful if /PDP or /EXAB was set. Before 
;	       reading a file from tape, the tape will be forward-skipped over
;	       <n> files. 
;       /DELETE : Only meaningful if /PDP or /EXAB was set (ignored else). 
;	       The disk-file with converted image data will be removed
;	       image data will be removed after it's contents has been read in
;	       by this procedure.
;	       By default, the disk-file will **not** be removed.
; OUTPUTS:
;       image_structure : IDL-structure containing the image and all relevant 
;	       parameters; it's format will be created/defined if the calling
;	       program has not passed a structure of appropriate format.
;	       Structure-tags:
;	       .status : string, status-info for image-data.
;	       .time   : string, start & end of exposure.
;	       .project: string, "general comment" of observer.
;	       .txt    : string, "image specific comment" of observer.
;	       .id     : integer, image-identification-number.
;	       .itime  : long integer, start_of-exposure_time (sec since 
;	                 midnight).
;	       .expos  : floating_point, length of exposure (sec).
;	       .par    : integer-array size=50, containing image parameters.
;	       .pic    : integer-array containing the extracted image
;			 it's size can be specified by the user; if the
;			 original CCD-image does not fit into this array,
;			 the user will be requested to specify how to
;			 extract part of the image or how to compress it.
; OPTIONAL OUTPUTS:
;	none.
; COMMON BLOCKS:
;
; SIDE EFFECTS:
;	A disk-file (FORTRAN unformatted, sequential, "SUNCCD") is created
;	if /PDP or /EXAB is set.
; RESTRICTIONS:
;	If IDL-session is active on an other workstation than the workstation
;	at which the requested 1/2"- or ExaByte- tape-drive is attached,
;	software installation option" of "Network Information Service (NIS)
;	(formerly known as "Sun Yellow Pages") must be active.
; 
; PROCEDURE:
;	In case of /PDP or /EXAB, UNIX-command "mt" will be spawned to skip 
;	over file-marks.
;	In case /PDP, program PDP2SUN_IDL will be spawned to "mars" which reads
;	a file from 1/2"-tape and converts the data to "SUNCCD-format";
;	the converted data will be written into a disk-file (f77_unformatted).
;	In case /EXAB=host, UNIX-command "tar -vxbf 128 /dev/nrst1" will be
;	spawned to <host> (where the ExaByte cassette is attached)
;-
; MODIFICATION HISTORY:
;	1991-Apr-03  H. Schleicher, KIS
;	1991-Apr-30  H. S., KIS: Option /EXAB; other default for file-name.
;       1991-May-13  H. S., KIS: ExaByte-hosts venus,venus1 =(venus,nrst1), 
;	                                             venus2 =(venus,nrst2).
;       1991-May-24  H. S., KIS: text-lines termination by '^'
;	1992-Jun-09  H. S., KIS: other ExaByte-hosts.
;
on_error,1
;
ccd={RCA,status:'',time:'',proj:'',txt:'',id:0,itime:0L,expos:0.0,par:intarr(50)$
     ,pic:intarr(320,512)}
;
tape_host='mars '
;pdp2sun='/usr/share/local/lib/ccd_progs/pdp2sun_idl'
pdp2sun='pdp2sun_idl'
tape_host='mars '
tape_driv='rtp000'
exa_hosts=strarr(8)
exa_hosts(0)='venus'
exa_hosts(1)='mars'
exa_hosts(2)='goofy'
exa_hosts(3)='daisy'
exa_hosts(4)='venus1'
exa_hosts(5)='venus2'
exa_hosts(6)='daisy1'
exa_hosts(7)='daisy2'
exa_driv1='nrst1'
exa_driv2='nrst2'
exa_tar='tar vxbf 128 /dev/'
cd,current=currwd
;
nc=1L
nxny=lonarr(2)
bb=intarr(50,/nozero)
comm=bytarr(4000,/nozero)
bld=intarr(320,512,/nozero)
;
if n_params() le 0 then message,$
   'Usage: RDRCA,image_structure [,file_name] [,{/PDP | EXAB=''host''}] '+$
   '[,SKIP_FILE=nskip] [,/DELETE]]' 
if keyword_set(itape) and keyword_set(iexab) then message, $
   'both keywords /PDP and /EXAB were set, only one keyword allowed.'
if n_params() eq 1 and not keyword_set(iexab) and not keyword_set(itape) then $
    message,'file_name or /PDP or EXAB=''host'' must be specified.'
if n_params() eq 1 and keyword_set(itape) then $
   file=currwd+'/'+getenv('USER')+'-RCA-SUNCCD'
if n_params() gt 1 then begin
   if (size(infil))(0) ne 0 or (size(infil))(1) ne 7 then message,$
      '2nd parameter (file_name) not a string.'
   if strlen(infil) lt 1 and not keyword_set(iexab) then $
      message,'file_name is an empty string'
   if strlen(infil) ge 1 then file=infil
endif
;
if keyword_set(itape) then begin
; case /PDP:
   if keyword_set(nskip) then if nskip ge 1 then begin
      command='rsh '+tape_host+'mt -f /dev/'+tape_driv+' fsf '+string(nskip)
      spawn,command
   endif
;
   if strmid(file,0,1) ne '/' then file=currwd+'/'+file
   command='rsh '+tape_host+pdp2sun+' '+file
   spawn,command,f77read_out
   nelem=n_elements(f77read_out)
   if nelem lt 2 then goto, junsucc
   for j=nelem-1,0,-1 do begin
       pos1=strpos(f77read_out(j),'image written on disk-file:')
       if pos1 gt -1 then begin
         file=strtrim(f77read_out(j+1),2)
         goto,jsucc
       endif
   endfor
junsucc:  print,'RDRCA: reading from 1/2"-mag.-tape unsuccessful'
	  if nelem lt 1 then print,'        no messages from spawn returned' $
	  else begin
             for j=0,nelem-1 do print,f77read_out(j)
          endelse
          goto,jret  
;
endif else if keyword_set(iexab) then begin
; case /EXAB:
   if (size(iexab))(0) ne 0 or (size(iexab))(1) ne 7 then begin
      print,'RDRCA: /EXAB set with no host-name.'
where: print,'       Enter host of ExaByte!'
      exa_host=string(0)
      read,exa_host
   endif else exa_host=iexab
   for j=0,n_elements(exa_hosts) do begin
       if exa_host eq exa_hosts(j) then begin
          if j ne 5 and j ne 7 then exa_driv=exa_driv1 else exa_driv=exa_driv2
	  if j eq 4 or j eq 5 then exa_host=exa_hosts(0) 
	  if j eq 6 or j eq 7 then exa_host=exa_hosts(3)
          goto,exaok
       endif
   endfor
   goto,where
exaok:
   if keyword_set(nskip) then if nskip ge 1 then $
      spawn,'rsh '+exa_host+' mt -f /dev/'+exa_driv+' fsf '+$
            string(format='(i0)',nskip)
   spawn,'rsh '+exa_host+' "cd '+currwd+'; '+exa_tar+exa_driv+'"',tarmess
   nelem=n_elements(tarmess)
   if nelem eq 0 then begin
      errmess='RDRCA - ExaByte: no file extracted.'
      goto,tarunsucc
   endif
  if strpos(tarmess(0),'x ') ne 0 or strpos(tarmess(0),',') lt 3 then $ 
    begin 
      errmess=strarr(nelem+1)
      errmess(0)='RDRCA - ExaByte: unexpected tar-message:'
      errmess(1:*)=tarmess
      goto,tarunsucc
  endif
  file=strmid(tarmess(0),2,strpos(tarmess(0),',')-2)
  goto,jsucc
tarunsucc:
  print,format='(a)',errmess(0)
  print,format='(9x,a)',errmess(1:*)
  goto,jret 
endif
;
jsucc:
get_lun,unit 
openr,unit,file,/f77_unformatted
readu,unit,nc,comm
 ;print,'nc',nc
;print,comm(0:20)
readu,unit,bb
readu,unit,nxny
readu,unit,bld
;
; check if file was extracted from PDP-tape before Nov. '90:
if bb(17) eq -9 then vers=0 else vers=1
;            old                    new
if vers eq 0 then begin
   ccd.status=string(comm(18:73)) ; img-type, reduction-status, img-ID
   ccd.time=string(comm(0:17))
   ccd.proj='RCA'
   bb(15)=2
   nc=nc-1
   if nc gt 2 then $
   for i=2,nc-1 do comm(80*i-1:80*i-1)=94 ; string(byte(94))='^' 
   comm(80*nc-1:80*nc-1)=64 ; string(byte(64))='@'
   ccd.txt=strcompress(string(comm(80:nc*80-1)))
   bb(16)=nc
   ccd.expos=bb(9)*0.05
   bb(17)=50
endif else begin
   ccd.status=string(comm(0:6))+' '+string(comm(27:79))
   ccd.time=string(comm(8:25))
   ccd.proj=strcompress(string(comm(80:bb(15)*80-1)))
   ccd.txt=strcompress(string(comm(bb(15)*80:bb(16)*80-1)))
   ccd.expos=float(bb(9)*bb(17))*0.001
endelse
ccd.id=bb(2)
ccd.itime=(long(bb(47)*60)+long(bb(48)))*60L+long(bb(49))
ccd.par=bb
ccd.pic=bld
free_lun,unit
if keyword_set(idelete) and (keyword_set(itape) or keyword_set(iexab)) then $
   spawn,'rm '+file
jret:return
;
end





