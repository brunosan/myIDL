;+
; NAME:
;	UNLOAD
; PURPOSE:
; 	$$$ Unloads <n> image-files to disc:
;	    either from 1/2"-PDP-tape (+ conversion to "SUN-CCD"-form),
;	    from ExaByte written by an AT-CCD-system,
;	    or from ExaByte containing tar-files of "SUN-CCD"-format;
;	$$$ Creates listing of image-header-infos (standard-output &
;	    "log-file" (ASCII).
;*CATEGORY:            @CAT-#  2@
;	CCD Tools
; CALLING SEQUENCE:
;	UNLOAD ,n ,{/PDP | /AT1 | /TAR} [,/SKIP_FILES=nskip] [,/HEADER] ...
;              ... [,/DELETE] 
; INPUTS:
;	n      : unload <n> files from input-device.
;	/PDP   : input-device is 1/2"-mag.-tape written by task "CCD"
;	         on PDP at Iza~na (RCA-CCD).
;       /AT1   : input-device is ExaByte-tape wriiten by an AT-CCD-system
;	         at Iza~na.
;       /TAR   : input-device is ExaByte-tape containing tar-files with
;	          images of "SUN-CCD"-format.
;       (One and only one of above key-words must be set !)
; OPTIONAL INPUT PARAMETERS:
;	/SKIP_FILES=nskip : keyword parameter; if set, <nskip> tape-files
;		  will be skipped before unloading a file (default: no
;		  skip; if /SKIP_FILES with no value: nskip=1).
;	/HEADER : read & print infos from SUN-CCD-header (default: headers
;		  will not be read in).
;       /DELETE : CCD-image-files will be deleted after reading the 
;                 headers; only the ASCII-file with header-infos will be
;		  kept on disc. 
; OUTPUTS:
; 	none
; SIDE EFFECTS:
;       Image-files of form "SUN-CCD" will be created under active working
;       directory (FORTRAN-binary) (unless /DELETE was set)
;	   file-names: tar-file-name in case of /TAR;
;	               <tape>-RCA-SUNCCD[.<suffix>].<file-no> in case of /PDP;
;		       <tape>-SUNCCD[.<suffix>].<file-no> in case of /AT1.
; 	ASCII-file with file-header-infos of all unloaded images,
;	   file-name: <tape>-UNLOADlog.<Mmm_dd_hh:mm:ss_yyyy>';
;	Output on standard_out: file-header-infos.
; RESTRICTIONS:
; 	see description of keywords /PDP, /TAR, and /AT1
; PROCEDURE:
; 	loop over n files:
;	spawns either program pdp2sun_idl
;	                (remote to MARS; this program unloads
;                        1 PDP-tape-file & converts it to "SUN_CCD"-format),
;       or calls procedure rdat00 (which spawns program at1_2_sun_idl) to
;	                unload 1 FITS-file from ExaByte-tape & converts it
;			to "SUN_CCD"-format),
;       or spawns a tar-command to copy a tar-file from ExaByte-drive to disk 
;	            (command remote to host where cassette has been attached);
;       reads image-header from created disk-file if requested by /HEADER.
; MODIFICATION HISTORY:
;	H. Schleicher, KIS, 1991-Apr-03
;	H. Schleicher, KIS, 1991-Apr-30: new file-names
;	H. Schleicher, KIS, 1991-May-22: RCA-exposure unit is 50 msec (not 20)
;	H. Schleicher, KIS, 1992-Feb-27: option /HEADER, /dev/nrst2 also
;					 for host DAISY.
;	H. Schleicher, KIS, 1992-Mar-02: new key-words /TAR, /AT1
;	H. Schleicher, KIS, 1992-Jul-17: rdat00 put into same file as unload
;-

PRO rdat00,infl,skip_image=nskip,reset=ireset,comm=ccomm
;
; NAME:
;	RDAT00
; PURPOSE:
;	Reads an AT1-CCD image file from ExaByte tape written by AT1-
;       software and creates a "SUN-CCD"-disk-file.
;*CATEGORY:            @CAT-#  2@
;	CCD/AT1
; CALLING SEQUENCE:
;	RDAT00,file-name [,/SKIP_IMAGE] [,/COMM | ,COMM=string]
; INPUTS:
;	file-name : string, name of disk-file for processed image data
;		    (no "suffix", absolute directory path or relative to
;		     current path).
; OPTIONAL INPUTS:
;       SKIP_FILE= n :
;	    Before dumping a file from ExaByte, the tape will be forward-
;	    skipped over <n> files. Depending on the selected AT-write-mode,
;	    there is either 0 or 1 file-mark at the begin-of-tape and either 
;	    0, 1, or 2 file-marks between adjacent tape files.
;	    When called for the 1st time, RDAT00 will consult the user how the 
;	    ExaByte was written. In case of 2 file-marks between files, it is 
;	    assumed, that the actual tape-position is either at begin-of-tape
;	    or between two adjacent eof-marks (this is the actual tape position
;	    after a file dump action). 
;       /RESET :    If set, the procedure will request user to enter new infor-
;	    mations for ExaByte specific parameters, 
;	    image-size, binning, etc. If not set, values from previous call of
;           RDAT00 will be used again (at 1st call, these parameters will be 
;	    requested in any case).
;       COMM=string :
;	    string='NEW': User is requested to enter "general comment"-lines
;	       which will be written into an ASCII-file created by RDAT00;
;	       Program at1_2_sun will read this file and store the text into
;	       the "general comment"-field of the image-file.
;	    string=comm-file-name : Program at1_2_sun will read existing file
;	       <comm-file-name> to obtain the "general comments".
;	    string='NO' or COMM=0 or **no** key-parameter COMM set: 
;	       No "general comments" to be read in by at1_2_sun.
;	/COMM :     Program at1_2_sun will read same comment-file as last time.
;
; OUTPUTS:
;	file-name : complete file-name of SUN-CCD disk-file on regular return;
;		    empty string on error.
; OPTIONAL OUTPUTS:
;	none.
; COMMON BLOCKS:
;	COMMON EXACOM0,exab_host,exab_driv,neof1,neof2,nrecimg,...,comfil
;	Purpose: to save some local variables for later calls;
;       all variables are set by this procedure.
; SIDE EFFECTS:
;       If this procedure is called for the 1st time within an IDL-session,
;	the user is querried for the host-name of the
;       workstation to which the ExaByte drive is attached (in a workstation-
;	network, this is not neccessarily the workstation on which the IDL-
;	session is active);
;	A disc-file ("SUN-CCD-format" FORTRAN unformatted, sequential) is 
;	created.
; RESTRICTIONS:
;	If IDL-session is active on an other workstation than the workstation
;	at which the ExaByte drive is attached, "Networking software instal-
;	lation option" of "Network Information Service (NIS) (formerly known
;       as "Sun Yellow Pages") must be active.
; PROCEDURE:
;	In case of /SKIP=n (n>0), UNIX-command MT will be spawned to skip
;	over file-marks (if images are separated by file-marks) or to skip over
;	m records (m calculated from n and number-of-records-per-image as 
;	specified by user on request).
;	Program AT1_2_SUN will be spawned to dump a file
;	from ExaByte-tape and to process the data. These spawned actions must
;	be executed at the host to which the ExaByte-drive is attached; if the
;	"ExaByte-host" is not the "local" host (on which this IDL-session is 
;	running), the UNIX-commands are spawned together with a remote shell-
;	command (RSH) to the "ExaByte-host".
;	AT1_2_SUN will optionally extract a sub-image from the original image
;	on ExaByte-tape and/or will compress the image by binning before
;	writing the image data on disk.
; MODIFICATION HISTORY:
;	1992-Mar-02  H. Schleicher, KIS (adopted from rdat10.pro)
;       1992-Jun-10  H. S., KIS: start at1_2sun from actual working directory;
;				  ExaB-host other than venus, mars, goofy, 
;				  daisy: device name may be nrst* .
;
; *** for other sites: change statements enclosed below between 
; ***                      ";site-specific_start"
; ***                  and ";site-specific_end" !!
; ***                  modify also site-specific code in program "at1_2_sun" !!
;
; common block "exacom0" keeps name of ExaByte-host and EOF-informations:
common exacom0,exab_host,exab_driv,neof1,neof2,nrecimg,recsiz,x00,y00,$
               xmm,ymm,binxx,binyy,comfil
;
on_error,2
;
;site-specific_start: ----------------------------------------------------------------
; location and name of FORTRAN program which reads a file from ExaByte
; and processes image (byte-swapping):
    at1_f77_read='at1_2_sun'
; default device name of ExaByte drive ("no rewind"):
    exab_driv1='nrst1' & exab_driv2='nrst2' & exab_driv_def=exab_driv1
;site-specific_end --------------------------------------------------------------------
;
if n_params() le 0 then message,$
       'Usage: RDAT00,infil [,/SKIP_IMAGE=nskip] [,COMM=string]] [,/RESET]'
infil=infl & infl=' '
if (size(infil))(1) ne 7 then message,'1st argument must be a string'
if strlen(infil) lt 1 then message,'1st argument must not be an empty string'
;
neu=0
;
if keyword_set(ireset) then begin exab_host='' & exab_driv=exab_driv_def
                  x00=0 & y00=0 & binxx=0 & binyy=0 & nx=0 & ny=0 & endif 
;
   if n_elements(exab_host) lt 1 then exab_host='' 
   if exab_host eq '' then begin
;exab_host , exab_drive ?
      print,'Enter: name of Exabyte_Host or: LOCAL'
      exab_host=' '
      read, exab_host
      exab_host=strlowcase(exab_host)   
      if exab_host eq 'local' then exab_host='LOCAL'
    exho=exab_host & if exho eq 'LOCAL' then exho=getenv('HOST')
    case 1 of
      exho eq 'venus1': begin exab_host='venus' & exab_driv=exab_driv1 & end
      exho eq 'venus2': begin exab_host='venus' & exab_driv=exab_driv2 & end
      exho eq 'venus': goto,jmp2
      exho eq 'daisy1': begin exab_host='daisy' & exab_driv=exab_driv1 & end
      exho eq 'daisy2': begin exab_host='daisy' & exab_driv=exab_driv2 & end
      exho eq 'daisy' : goto,jmp2
      exho eq 'mars' or exho eq 'goofy'  : exab_driv=exab_driv_def
      else            : goto,jmp2
    endcase
    goto,jmp3
jmp2:    if exho eq 'venus' or exho eq 'daisy' then $    
	 print,'Enter ExaB-device-name '+exab_driv1+' or '+exab_driv2 else $
         print,'Enter ExaB-device-name (e.g. nrst0)'
	 exab_driv=' '
	 read,exab_driv
	 if (exho eq 'venus' or exho eq 'daisy') and $
            (exab_driv ne exab_driv1 and exab_driv ne exab_driv2) then $
	    goto,jmp2
;
jmp3:
;file marks, record-size ?
      neof1=0 & neof2=0
      print,'Enter: number of file-marks at begin-of-tape'
      read,neof1
      print,'Enter: number of file-marks between files'
      read,neof2 
      print,'ExaB-record size (bytes) ?'
again:  print,'     Enter: s (=2880) m (=4096) b (=16384) <other value>'
      crec='' & read,crec & crec=strlowcase(strcompress(crec,/remove))
      case strmid(crec,0,1) of
          '': goto,again
         's': recsiz=2880
         'm': recsiz=4096
         'b': recsiz=16384
         else: recsiz=fix(crec)
      endcase
      crec=''
      if neof2 eq 0 then begin
again2: print,$
         'Enter: number of records per image **on tape-file** (incl. header)'
	 print,$
        '   or: image format: <nx,yn> or s (400x600) m (512x512) b (1024x1024)'
	 crec='' & read,crec
	 if strpos(crec,',') gt 0 then strput,crec,' ',strpos(crec,',')
         crec=strlowcase(strcompress(strtrim(crec,2))) 
	 nrecimg=0 
	 case strmid(crec,0,1) of
             '': goto,again2
	    's': rrecimg=2.*(400.*600.+1440.)/recsiz
	    'm': rrecimg=2.*(512.*512.+1440.)/recsiz
            'b': rrecimg=2.*(1024.*1024.+1440.)/recsiz
	    else: begin
		  i=strpos(crec,' ')
	          if i gt 0 then begin
		     nximg=fix(strmid(crec,0,i)) 
		     nyimg=fix(strmid(crec,i+1,strlen(crec)-i-1))
		     rrecimg=2.*(float(nximg)*float(nyimg)+1440.)/recsiz 
		  endif else nrecimg=fix(crec)
                  end
         endcase
	 if nrecimg eq 0 then begin 
	    nrecimg=fix(rrecimg)
	    if nrecimg lt rrecimg then nrecimg=nrecimg+1
         endif
      endif
;binning,  sub-image ?
      print,$
      '** before writing to disk **: shall image be scissored and/or binned ?'$
      ,' Enter y/n'
      yn='' & read,yn & yn=strlowcase(strcompress(yn,/rem))
      if yn eq 'y' then begin 
         print,'Enter subscripts x0,y0, xm,ym, of lower-left, upper-right corners of sub-image:'
         read,x00,y00,xmm,ymm 
         x00=x00>0 & y00=y00>0 & xmm=xmm>(x00+1) & ymm=ymm>(y00+1)
	 print,'Enter binning factors binx,biny:'
	 read,binxx,binyy & binxx=binxx>1 & binyy=binyy>1
      endif else begin 
         x00=0 & y00=0 & xmm=32767 & ymm=xmm & binxx=1 & binyy=1 & endelse
   endif
;
   if strmid(exab_driv,0,4) ne 'nrst' then $
      message,'Unknown ExaByte-drive: '+exab_driv
;
;general comments ?
   icomm=0
   if keyword_set(ccomm) then begin
      if strupcase(ccomm) eq 'NO' then goto,cont
      icomm=1
      if (size(ccomm))(1) eq 2 then begin jcomm=ccomm & ccomm=' ' & endif else jcomm=-1
      if jcomm eq 1 and n_elements(comfil) gt 0 then goto,cont
      if jcomm eq 1 or strupcase(ccomm) eq 'NEW' then begin
         comfil='AT1@SUNCCD@COMMENTS@'+getenv('USER')
	 get_lun,unitc
	 openw,unitc,comfil
         print,'Enter "general comment" -lines! (terminate with empty input)'
comread: z=' '
	 read,z
	 if strlen(z) gt 0 then begin
	    printf,unitc,z
	    goto,comread
	 endif
	 z='@end'
	 printf,unitc,z
	 free_lun,unitc
	 print,'comments written to ',comfil
      endif else comfil=strtrim(ccomm,2)
   endif
cont:
;  Skip over <nskip> images
   command=''
   if neof2 gt 0 then begin
      nrecimg=0
      if keyword_set(nskip) then skip=neof1+nskip*neof2 else skip=neof1
      if skip gt 0 then $
         command='mt -f /dev/'+exab_driv+' fsf '+string(skip)
   endif else if keyword_set(nskip) then begin
      skip=nrecimg*nskip
         command='mt -f /dev/'+exab_driv+' fsr '+string(skip)
      endif
   if neof1 gt 0 and neof2 le 0 then begin
     if command eq '' then $
        command='mt -f /dev/'+exab_driv+' fsf '+string(neof1) else $
        command='mt -f /dev/'+exab_driv+' fsf '+string(neof1)+'; '+command
   endif
   if command ne '' then begin
      if exab_host ne 'LOCAL' then command='rsh '+exab_host+' '+command
      print,command
      spawn,command
   endif
   neof1=neof2-1 > 0  ; tape now not at BOT!   
;
; Start FORTRAN program "at1_f77_read" which dumps an ExaByte-file from tape
; and writes the byte-swaped image-data on file <infil>.<suffix>
; (suffix set by program to avoid overwriting):
   argument='EXAB='+exab_driv+' RECS='+string(recsiz,format='(i0)')
   argument=argument+' NREC='+string(nrecimg,format='(i0)')
   argument=argument+' X0='+string(x00,format='(i0)')
   argument=argument+' Y0='+string(y00,format='(i0)')
   argument=argument+' XM='+string(xmm,format='(i0)')
   argument=argument+' YM='+string(ymm,format='(i0)')
   argument=argument+' BINX='+string(binxx,format='(i0)')
   argument=argument+' BINY='+string(binyy,format='(i0)')
   argument=argument+' '+strtrim(infil,2)
   l=strlen(argument)
   pos1=strpos(argument,'.',l-4) 
   if pos1 gt 0 then strput,argument,' ',pos1
   if icomm eq 1 then argument='COMM='+comfil+' '+argument
   command=at1_f77_read+' '+argument
   if exab_host ne 'LOCAL' then begin
      cd,current=cwd & command='rsh '+exab_host+' "cd '+cwd+'; '+command+'"'
   endif
   print,command
   spawn,command,at1f77read_out
   nelem=n_elements(at1f77read_out)
   if nelem lt 2 then goto, junsucc
   pos1=strpos(at1f77read_out(nelem-2),'image written on disk-file')
   if pos1 lt 0 then goto, junsucc
   infil=strtrim(at1f77read_out(nelem-1),2)
    goto,jexit
;
junsucc:  print,'RDAT00: reading from ExaByte unsuccessful'
	  if nelem lt 1 then print,'        no messages from spawn returned' else begin
          print,'        messages from spawn:'
          for j=0,nelem-1 do print,at1f77read_out(j)
          endelse
;
;
jexit: 
infl=infil & return
end

PRO unload,n,pdp=ipdp,at1=iat1,tar=itar,skip_files=nskip,header=header,$
           delete=idelete
;
on_error,1
tape_host='mars ' & tape_driv='rtp000 ' 
exab_driv1='nrst1 ' & exab_driv2='nrst2 ' 
pdp2sun='pdp2sun_idl'
;
nc=1L
bb=intarr(50)
comm=bytarr(4000,/nozero)
;
if n_params() lt 1 then message, $
' usage: UNLOAD ,n ,{/PDP | /AT1 | /TAR} [,SKIP_FILES=k] [,/HEADER] [,/DELETE]'
if keyword_set(ipdp)+keyword_set(itar)+keyword_set(iat1) gt 1 then message, $
   ' only one keyword /PDP or /AT1 or /TAR is allowed.'
;
case 1 of 
  keyword_set(ipdp): begin itape=1 & ctape='PDP-magtape' & end
  keyword_set(itar): begin itape=2 & ctape='ExaB(tar)' & end
  keyword_set(iat1): begin itape=3 & ctape='ExaB(AT1)' & end
  else: itape=-1
endcase
if itape eq -1 then message,' one of keywords /PDP, /AT1, or /TAR must be set.'
;
print,'UNLOAD: Enter name of tape/cassette (string)!'
tape_name=string(0)
read,tape_name
if itape eq 2 then begin
   print,'UNLOAD: Enter name of HOST where you attached the ExaByte-cassette!'
   exab_host=string(0)
   read,exab_host
   if exab_host eq 'venus' or exab_host eq 'daisy' then begin
      print,'UNLOAD: ExaByte drive ',exab_driv1,' or ',exab_driv2,' ?'
ask:      print,'        Enter 1 or 2 !'
      jexab=0
      read,jexab
      if jexab ne 1 and jexab ne 2 then goto,ask
      if jexab eq 1 then exab_driv=exab_driv1 else exab_driv=exab_driv2
   endif else exab_driv=exab_driv1
endif
;
if itape eq 3 then begin
   print,$
'UNLOAD: "General Comments" to be inserted? Enter  "no" | "yes" | comment_file-name'
   ccc=' ' & read,ccc
   case 1 of 
      strlen(ccc) lt 1 : ccom='NO'
      strupcase(ccc) eq 'NO' :  ccom='NO'
      strupcase(ccc) eq 'YES': ccom=1
      else: ccom=ccc
   endcase
   cd,current=currdir & file0=currdir+'/'+tape_name+'-SUNCCD'
endif
;
if keyword_set(nskip) then begin
  ieof=nskip
  case itape of
             1 : spawn,'rsh '+tape_host+'mt -f /dev/'+tape_driv+'fsf '+$
                        string(format='(i0)',ieof)
             2 : spawn,'rsh '+exab_host+' mt -f /dev/'+exab_driv+'fsf '+$
                        string(format='(i0)',ieof)
  endcase    ; case itape=3 (/AT1): skipping will be performed by rdat00.
  jeof=ieof
endif else jeof=0
;
user=getenv('USER') & cd,current=currdir
;
listfile=tape_name+'-UNLOADlog.'+blnk2ulin(strmid(systime(),4,99))
openw,/GET_LUN,unit2,listfile
;
nunload=0 & projold=' '
for i=1,n do begin
;
nfil=jeof+i  ; file count on tape
case 1 of
itape eq 1:  begin  ; PDP-1/2"-tape (RCA-CCD)
   file=currdir+'/'+tape_name+'-RCA-SUNCCD'
   spawn,'rsh '+tape_host+pdp2sun+' '+file,prog_out
   nelem=n_elements(prog_out)
   if nelem ge 2 then begin
      for j=nelem-1,0,-1 do begin
         pos1=strpos(prog_out(j),'image written on disk-file:')
         if pos1 gt -1 then begin
            file=strtrim(prog_out(j+1),2)
            goto,jsucc
         endif
      endfor
   endif
   errmess=strarr(nelem+1)
   errmess(0)='UNLOAD: reading from mag.-tape unsuccessful'
   errmess(1:*)=prog_out
   goto,junsucc
   end
itape eq 2:  begin  ; tar-ExaB
   ntry=0
again:
   spawn,'rsh '+exab_host+' "cd '+currdir+'; tar vxbf 128 /dev/'+$
         exab_driv+'"',tarmess
   nelem=n_elements(tarmess)
   if nelem eq 0 then begin
      ntry=ntry+1
      if ntry eq 1 then begin 
	 print,'          EOF(?) detected, try again' & goto,again & endif
      errmess='UNLOAD - ExaByte: no file extracted.'
      goto,junsucc
   endif
  if strpos(tarmess(0),'x ') ne 0 or strpos(tarmess(0),',') lt 3 then $ 
    begin 
      errmess=strarr(nelem+1)
      errmess(0)='UNLOAD - ExaByte: unexpected tar-message:'
      errmess(1:*)=tarmess
      goto,junsucc
  endif
  file=strmid(tarmess(0),2,strpos(tarmess(0),',')-2)
  goto,jsucc
  end
itape eq 3:  begin ; AT1-ExaB
      file=file0
;      print,'unload: i=',i,' file =',file,' skip=',jeof,' ccom =',ccom
               if i eq 1 then rdat00,file,skip=jeof,/reset,comm=ccom else $
                        if ccom ne 'NO' then rdat00,file,/comm else rdat00,file
;               print,'after return from rdat00 file=',file
               if file ne ' ' then goto,jsucc
	       errmess='error in rdat00' & goto,junsucc
             end
endcase
;
junsucc: 
printf,unit2,format='("file UNLOAD-count",i4)',jeof+i
printf,unit2,format='(9x,a)',errmess
print,format='("file UNLOAD-count",i4)',jeof+i
print,format='(9x,a)',errmess
goto,jnext
jsucc:
if not keyword_set(idelete) then nunload=nunload+1 ; counts successfully unloaded
;                                               files not to be deleted again
if keyword_set(header) then begin
if keyword_set(idelete) then $
   openr,/GET_LUN,unit1,file,/f77_unformatted,/delete else $
   openr,/GET_LUN,unit1,file,/f77_unformatted
on_ioerror,erread
readu,unit1,nc,comm
readu,unit1,bb
on_ioerror,null & free_lun,unit1
goto,readok
erread:
status=' IO-error!! '
projprint=' ??? ' & ccd=' ??? ' & txt=' ??? ' & time=' ??? '
itime =-1  & expos=-1. & bb=intarr(50)
on_ioerror,null & free_lun,unit1
goto,ausgabe
;
readok:
; check if infil was extracted from PDP-tape before Nov. '90:
if bb(17) eq -9 then vers=0 else vers=1
;            old                    new
if vers eq 0 then begin
   status=strcompress(string(comm(18:73))) ; img-type, reduction-status, img-ID
   time=string(comm(0:17))
   proj='RCA'
   ccd='RCA-CCD'
   if nc lt 1 or nc gt 50 then $
      txt='UNLOAD: invalid value no. text-lines nc '+string(nc) else begin
      nc=nc-1 & txt=strcompress(string(comm(80:nc*80-1))) & endelse
   expos=bb(9)*0.05
endif else begin
   status=strcompress(string(comm(0:6))+' '+string(comm(27:79)))
   ccd=string(comm(0:6))
   time=string(comm(8:25))
   if bb(15) le 1 or bb(15) gt 50 then $
      proj='UNLOAD: invalid value no. project-lines '+string(bb(15)) else $
      proj=strcompress(string(comm(80:bb(15)*80-1)))
   if bb(15) le 1 or bb(16) gt 50 or bb(16) le bb(15) then $
     txt='UNLOAD: invalid value no. expos-comment-lines '+string(bb(16)) else $
     txt=strcompress(string(comm(bb(15)*80:bb(16)*80-1)))
   expos=float(bb(9)*bb(17))*0.001
endelse
case 1 of
 i eq 1: begin projprint=proj & projold=proj & end
 proj eq projold: projprint='same project'
 else: begin projprint=proj & projold=proj & end
endcase
itime=(long(bb(47)*60L)+long(bb(48)))*60L+long(bb(49))
;
ausgabe:
printf,unit2,$
format='("file ",a,"-# ",i0," / ",a," UNLOAD-# ",i0," expos-time ",a,1x,i5)',$
      ccd,bb(18),ctape,nfil,time,itime
if itape eq 2 then printf,unit2,format='(9x,"ExaB-tar-file ",a)',file else $
if itape eq 3 then printf,unit2,format='(9x,"SUNCCD-file ",a)',file

printf,unit2,format='(5x,a)',status
printccd,unit2,format='(5x,a)',projprint
printccd,unit2,format='(5x,a)',txt
;
print,$
      format='("file ",a,"-# ",i0," / UNLOAD-# ",i0," expos-time ",a,1x,i5)',$
      ccd,bb(18),nfil,time,itime
if itape eq 2 then print,format='(9x,"ExaB-tar-file ",a)',file else $
if itape eq 3 then printf,unit2,format='(9x,"SUNCCD-file ",a)',file
print,format='(5x,a)',status
printccd,-1,format='(5x,a)',projprint
printccd,-1,format='(5x,a)',txt
;
endif else begin   ; no header-infos requested
   case itape of
      1: txt='PDP-tape'
      2: txt='SUNCCD-file from ExaByte (tar) '+file
      3: txt='SUNCCD-file from ExaByte (AT1) '+file
   endcase
  printf,unit2,format='(" tape-# ",i0," / ",a," UNLOAD-# ",i0,1x,a)',$
         nfil,ctape,i,txt
   print,format='(" tape-# ",i0," UNLOAD-# ",i0,1x,a)',nfil,i,txt
   if keyword_set(idelete) then spawn,'rm '+file
endelse
jnext:
if keyword_set(idelete) then print,'UNLOAD: !!! CCD-disk-file REMOVED !!!' $
else print,'UNLOAD: !!! ',nunload,'. CCD-file kept on disk :',file
; 
if itape eq 2 then spawn,'rsh '+exab_host+' mt -f /dev/'+exab_driv+'fsf 1'
endfor
;
if nunload lt 1 then $
   printf,unit2,'UNLOAD: no SUN-CCD disk files kept !!' else  $
   printf,unit2,nunload,currdir,$
   form='("UNLOAD: ",i0," SUN-CCD disk files kept on directory ",a)'  
free_lun,unit2
print,'UNLOAD: Log-file :',listfile
return
end
