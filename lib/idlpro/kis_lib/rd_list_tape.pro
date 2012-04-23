;+
; NAME:
;	RD_LIST_TAPE
; PURPOSE:
;	read+list n RCA-CCD images from PDP-tape or from ExaByte
;*CATEGORY:            @CAT-#  2@
;	CCD Tools
; CALLING SEQUENCE:
;	RLT,tape,n,SKIPEOF=ieof
; INPUTS:
;	tape   : string for selection of input-device; if it contains
;		 'PDP' or 'EXAB' as substring, input-device is
;		 PDP-1/2"-tape-unit or ExaByte-drive, rsp.;
;	n      : read first n files on input-device
; OPTIONAL INPUT PARAMETER:
;	SKIPEOF=ieof : keyword parameter; if set, <ieof> eof's will be
;		       skipped before reading a file (default: no skip,
;		       if /SKIPEOF with no value: ieof=1).
; OUTPUTS:
; 	none
; COMMON BLOCKS:
;       RLTCOMMON,EXAB_HOST
;	          EXAB_HOST (string) set by this procedure when called 
;		  for the 1st time: HOST-name of host where ExaByte-
;		  cassette has been attached. (To save this variable 
;		  for subsequent calls).
; SIDE EFFECTS:
; 	list of tape-files with info-block contents written on disk-file
;	'RLT_out.<Mmm_dd_hh:mm:ss_yyyy>'
; RESTRICTIONS:
; 	all tape-files (also on ExaByte) must be of type "CCD".
; PROCEDURE:
; 	loop over n files:
;	spawns either ~/idl/pdp2sun_idl (remote to MARS) or
;	TAR on ExaByte-drive (remote to host where cassette has been
;       attached), reads INFO-block-data from disk-file
;	(disk-file will be removed after use).
; MODIFICATION HISTORY:
;	nlte, 1990-01-03 
;	nlte, 1990-04-25: device-selection with substring
;	nlte, 1991-03-27: invokes new program pdp2sun_idl
;-
PRO rlt,tape,n,skipeof=ieof
;
common rltcommon,exab_host
;
tape_host='mars ' & tape_driv='rtp000 ' & exab_driv='nrst1 '
pdp2sun='pdp2sun_idl'
;
nc=1L
nxny=lonarr(2)
bb=intarr(50,/nozero)
comm=bytarr(4000,/nozero)
;
if n_params() lt 2 then message,' usage: RLT, {PDP | EXAB} ,n [,SKIPEOF=k]' 
itape=-1
if strpos(strupcase(tape),'PDP') ge 0 then itape=1 else $
if strpos(strupcase(tape),'EXAB') ge 0 then itape=2
if itape eq -1 then message,' - specified input-device not PDP or EXAB :'+tape
;
if itape eq 2 and n_elements(exab_host) lt 1 then begin
   print,'RLT: enter name of host where you attached the ExaByte-cassette!'
   exab_host=string(0)
   read,exab_host
endif
;
if keyword_set(ieof) then begin
  if itape eq 1 then spawn,$
    'rsh '+tape_host+'mt -f /dev/'+tape_driv+'fsf '+string(format='(i0)',ieof)$
  else spawn,'rsh '+exab_host+' mt -f /dev/'+exab_driv+'fsf '+$
             string(format='(i0)',ieof)
  jeof=ieof
endif else jeof=0
openw,/GET_LUN,unit2,'out_RLT.'+blnk2ulin(strmid(systime(),4,99))
;
for i=1,n do begin
;
if itape eq 1 then begin
   file=getenv('PWD')+'/RCA_f77_unform'
   spawn,'rsh '+tape_host+pdp2sun+' '+file,prog_out
   nelem=n_elements(prog_out)
   if nelem ge 9 then begin
      for j=nelem-2,0,-1 do begin
         pos1=strpos(prog_out(j),'image written on disc-file:')
         if pos1 gt -1 then begin
            file=strtrim(prog_out(j+1),2)
            goto,jsucc
         endif
      endfor
   endif
   errmess=strarr(nelem+1)
   errmess(0)='RLT: reading from mag.-tape unsuccessful'
   errmess(1:*)=prog_out
   goto,junsucc
endif else begin
   spawn,'rsh '+exab_host+' tar vxbf 128 /dev/'+exab_driv,tarmess
   nelem=n_elements(tarmess)
   if nelem eq 0 then begin
      errmess='RLT - ExaByte: no file extracted.'
      goto,junsucc
   endif
  if strpos(tarmess(0),'x ') ne 0 or strpos(tarmess(0),',') lt 3 then $ 
    begin 
      errmess=strarr(nelem+1)
      errmess(0)='RLT - ExaByte: unexpected tar-message:'
      errmess(1:*)=tarmess
      goto,junsucc
  endif
  file=strmid(tarmess(0),2,strpos(tarmess(0),',')-2)
  goto,jsucc
endelse
;
junsucc: 
printf,unit2,format='("file RLT-count",i4)',jeof+i
printf,unit2,format='(9x,a)',errmess
print,format='("file RLT-count",i4)',jeof+i
print,format='(9x,a)',errmess
goto,jnext
jsucc:
openr,/GET_LUN,unit1,file,/f77_unformatted,/delete
readu,unit1,nc,comm
readu,unit1,bb
readu,unit1,nxny
free_lun,unit1
;
; check if infil was created before Nov. '90:
if bb(17) eq -9 then vers=0 else vers=1
;            old                    new
if vers eq 0 then begin
   status=string(comm(18:73)) ; img-type, reduction-status, img-ID
   time=string(comm(0:17))
   proj='RCA'
   nc=nc-1
   txt=string(comm(80:nc*80-1))
   expos=bb(9)*0.02
endif else begin
   status=string(comm(0:6))+' '+string(comm(27:79))
   time=string(comm(8:25))
   proj=string(comm(80:bb(15)*80-1))
   txt=string(comm(bb(15)*80:bb(16)*80-1))
   expos=float(bb(9)*bb(17))*0.001
endelse
id=bb(2)
itime=(long(bb(47)*60L)+long(bb(48)))*60L+long(bb(49))
sum=bb(10)
nfil=jeof+i
printf,unit2,$
      format='("file PDP-# ",i0," / RLT-# ",i0," expos-time ",a,1x,i5)',$
      bb(18),nfil,time,itime
if itape eq 2 then printf,unit2,format='(9x,"ExaB-tar-file ",a)',file
printf,unit2,format='(9x,a)',status
printf,unit2,format='(9x,a)',proj
printf,unit2,format='(9x,a)',txt
;
print,$
      format='("file PDP-# ",i0," / RLT-# ",i0," expos-time ",a,1x,i5)',$
      bb(18),nfil,time,itime
if itape eq 2 then print,format='(9x,"ExaB-tar-file ",a)',file
print,format='(9x,a)',status
print,format='(9x,a)',proj
print,format='(9x,a)',txt
;
jnext:
if itape eq 2 then spawn,'rsh '+exab_host+' mt -f /dev/'+exab_driv+'fsf 1'
endfor
;
free_lun,unit2
return
end
