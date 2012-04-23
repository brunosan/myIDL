;+
; NAME:
;	RDFITSA
; PURPOSE:
;	Reads an FITS-CCD image file either from ExaByte tape (e.g. written 
;	by AT1/CCD-software) or from disk (image array: 16 bit/pix most signif.
;	byte first)
;       and returns the image data (optionally after binning and/or a sub-
;       image) ** in an short integer array **. Comments and other infor-
;       mational parameters extracted from the FITS header may be transferred
;	via keyword argumentss.
;*CATEGORY:            @CAT-#  2 11@
;	CCD Tools , FITS-Files
; CALLING SEQUENCE:
;	RDFITSA,img_arr [,file-name] [,/EXABYTE] ...
;	  ... [,FITS_HEADER=header] [,STATUS=status] [,PROJECT=proj] [,TXT=txt]
;         ... [,ID=id], [,TIME=start] [,ITIME=itime] [,EXPOS=expos] 
;         ... [,PARAMETERS=param_vect]
;         ... [,/SKIP_FILE=n] [,/DELETE] [,/RESET] [,ERRFLAG=errflag]
; INPUTS:
;       img_arr : 2-dim short integer array for storing the image.
;           If, on input, img_arr is large enough to store the image (after
;	    applying binning/scissoring if already specified) and if keyword
;	    /RESET has not been set, the array will be used as it is.
;	    Otherwise, the procedure will request the user to enter a new 
;	    format for the array and for (new) sampling parameters.
;	    Examples (no /RESET in all cases):
;		img_arr=0
;		rdfitsa,img_arr, ...  RDFITSA will create a new array and
;			             will querry for sampling parameters;
;		rdfitsa,img_arr, ...  RDFITSA will use the same array and
;			             same sampling parameters again;
;		img_arr=0
;		rdfitsa,img_arr, ...  RDFITSA is forced to re-create the array
;			             and to querry for new sampling parameters.
; OPTIONAL INPUTS:
;	file-name : string, name of FITS disk-file;
;	    If key /EXABYTE is **not** set, the name of an already existing
;              (FITS-format) must be specified (absolute directory path or
;              relative to actual working directory). <file-name> may contain
;	       "wild characters" (e.g. '*'); if more than one matching file
;	       is found, the user is requested to select one of the matching
;	       file names; if no file is found on 1st attempt, RDFITSA will try
;	       again with '<file-name>*' .
;	       If the (completed) file-name ends on '.CF', it is assumed that
;	       the file was compressed by COMPFITS; un-cimpressing will be
;	       done in this case before reading the file.
;	       Array data: 16 bit/pix, most significant byte first; byte-
;	       order of ASCII-header may or may not be "reversed" (if disk file
;	       was created by "dd" with option "conv=swab" from original AT1-
;	       ExaByte-tape wriiten with "SWAP=OFF", the header is "reversed" 
;	       but the image array is "regular"; 
;	       if disk file was written by KIS_LIB procedure WRFITS, both 
;	       header and image array  are "regular").
;	    If key /EXABYTE **is** set, file-name is optionally; 
;              if file-name is specified, the FITS-file dumped from tape 
;	       will be named:
;	       /<dir>/<file-name>_<fits-name>[.<suff>].fits,
;	       where directory path <dir> will be taken from <file_name> if
;	       file_name contains a path or the "current working directory";
;	       <fits-name> will be derived from FITS-header keyword FILENAME 
;	       (if exists) and .<suff> will be selected from {000,001,...,999}
;	       to make the file name unique.
;              If file-name is not specified, RDFITSA will use
;              '<c.w.d.>/<user>-CCD_<fits-name>[.<suff>].fits' as file-name.
;       /EXABYTE :  key-word; 
;	    ** If set **: 
;	       This procedure spawns a UNIX DD command to dump (and, on
;              request, byte-swap) one file from ExaByte tape to disk. 
;	       If RDFITSA is called for the 1st time with /EXABYTE is set (or
;	       together with /RESET), the user is requested to enter host- 
;	       and device specific parameters.
;	    ** If this key-word is **not** set **: 
;	       Procedure reads file <file-name> directly from disk (no tape
;	       action). In this case, the complete file-name must be specified.
;	       This disk-file must be a byte-swapped FITS-file.
;       SKIP_FILE= n : Only meaningful if /EXABYTE was set.
;	    Before dumping a file from ExaByte, the tape will be forward-
;	    skipped over <n> files. Depending on the selected AT-write-mode,
;	    there is either 0 or 1 file-mark at the begin-of-tape and either 
;	    0, 1, or 2 file-marks between adjacent tape files.
;	    When called for the 1st time, RDFITSA will consult the user how
;	    the ExaByte was written. In case of 2 file-marks between files, 
;	    it is assumed, that the actual tape-position is either at 
;	    begin-of-tape or between two adjacent eof-marks (this is the 
;	    actual tape position after a file dump action). 
;       /DELETE :   Only meaningful if /EXABYTE was set. 
;           The FITS-disk-file dumped from tape will be removed after beeing 
;	    read in.
;	    If this key-word or key-word /EXABYTE is **not** set, the disk 
;	    file will **not** be deleted.
;       /RESET :    If set, the procedure will request user to enter new infor-
;	    mations for ExaByte specific parameters (if /EXAB was set), 
;	    image-size, binning, etc. If not set, values from previous call of
;           RDFITSA will be used again. At 1st call, these parameters will be 
;	    requested in any case.
;	
; OUTPUTS:
;       img_arr: 2-dim short integer array containing the image.
;           The array will be (re-)created if the calling program has
;	    **not** passed an array of appropriate format.
; OPTIONAL OUTPUTS:
;	FITS_HEADER=header : string-array containg the complete FITS header.
;	STATUS=status : string "status-info" for image-data.
;	PROJECT=proj : string "general comment" of observer.
;	TXT=txt : string "image specific comment" of observer.
;       ID=id : short integer, image-identification-number.
;	TIME=start : string, start of exposure.
;	ITIME=itime : long integer, start_of-expos._time (sec since midnight).
;       EXPOS=expos : floating_point, duration of exposure (sec).
;	PARAMETERS=param_vect : integer-array size=50, containing numeric
;		      image parameters.
;	ERRFLAG=errflag : RDFITSA returns an error-flag on return; errflg must
;		        be a VARIABLE (NOT a constant) on call;
;			coding for errflag: 
;			0: successful return, 1: probably an eof found when
;			dumping from ExaByte-tape, 2: disk-file smaller than
;			2880 bytes, 3: other problems with reading the file,
;			-1: invalid input parameters.
; COMMON BLOCKS:
;       COMMON FITSEXACOM,exab_host,exab_driv,dddir,neof1,neof2,nrecimg, ...
;                    ...  recsiz,swap,x0,y0,xmm,xm,ym,binx,biny,naxis1,naxis2
;	    Serves to save some variables for subsequent calls and for transfer
;	    to auxillary routines within this file.  
;           All variables are set by this procedure or in it's auxillary 
;           routines.
;       COMMON FITSEXACOM2,exab_driv1,exab_driv2,exab_driv_def,ddfildef,...
;                    ... infildef,ddmsgfile,remhost
;           For transfer to auxillary routines.
; SIDE EFFECTS:
;       If this procedure is called for the 1st time within an IDL-session
;	with key /EXABYTE set, the user is querried for the host-name of the
;	worksation to which the ExaByte drive is attached (in a workstation-
;	network, this is not neccessarily the workstation on which the IDL-
;	session is active);
;	A disk-file (byte-swapped "FITS-format") is created if /EXABYTE is set 
;	and /DELETE is not set;
;       Interactive in/out-put to standard in/out; error messages on unit -2.
; RESTRICTIONS:
;	If IDL-session is active on an other workstation than the workstation
;	at which the ExaByte drive is attached, "Networking software installa-
;	tion option" of "Network Information Service (NIS) (formerly known as
;	"Sun Yellow Pages") must be active.
; PROCEDURE:
;	In case of /EXABYTE,/SKIP=n, UNIX-command MT will be spawned to skip
;	over file-marks (if images are separated by file-marks) or to skip over
;	m records (m calculated from n and number-of-records-per-image as 
;	specified by user on request);
;	In case of /EXABYTE, UNIX-command "DD" will be spawned to dump a file
;	from ExaByte-tape and to process the data. These spawned actions must
;	be executed at the host to which the ExaByte-drive is attached; if the
;	"ExaByte-host" is not the "local" host (on which this IDL-session is 
;	running), the UNIX-commands are spawned together with a remote shell-
;	command (RSH) to the "ExaByte-host".
;	If DD-action was successful, the disk-FITS-file (which got a default 
;	name) will be read in (associated read) and the FITS-header will be 
;	interpreted by KIS_LIB-procedure FITS_HDR; Extracted/interpreted 
;	header-informations  will be stored into the appropriate optional
;	output variables.
;	Image scissoring and/or binning will be done if requested by user
;	or if the original image does not fit into the selected format of
;	the passed  image-array. The user is requested by RDFITSA to enter 
;	parameters for this transformation whenever a new image array was 
;	created, or the format of the image as read from disk has changed 
;	from previous one. Note, that these image modifications will **not**
;	affect the contents of the disk-file!
;	Finally, if /DELETE was set, the disk-file created by dd will be 
;	removed (spawning UNIX command "rm"), else UNIX command "mv" will be 
;	spawned to rename the file.
;	
; MODIFICATION HISTORY:
;	1992-Aug-25  H. Schleicher, KIS: created from rdfits.
;       1993-Feb-23 H. Schleicher, KIS: bug in DUMP_EXAB (case search);
;		                   bug in MAIN: if search gt 1 ...
;				   error messages on unit -2. 
;       1993-Apr-08 H. Schleicher, KIS: included special case for
;		                  stand-alone host GOOFY.
;       1993-Jun-04 H. Schleicher, KIS: DEWEY ExaB-device name is nrst0.
;-

PRO look4file,infil,cwd
;
; NAME:
;	LOOK4FILE
; PURPOSE:
;	Auxillary procedure for RDFITS: look for FITS-file <infil> on disk,
;	if not found, look for anu <infil>*; 
;	if not unique, querry user to select.
;*CATEGORY:            @CAT-#  2 11@
;	Auxillary/CCD
; CALLING SEQUENCE:
;	LOOK4FILE,infil,cwd
; INPUTS:
;	infil (string) : filename of FITS-file to be searched for.
;                        !! Also output variable !!
;       cwd   (string) : current working directory.
; OUTPUTS:
;	infil (string) : actual filename of FITS-file to be red in.
;	
; COMMON BLOCKS:
;	none
; SIDE EFFECTS:
;	
; RESTRICTIONS:
;	
; PROCEDURE:
;	
; MODIFICATION HISTORY:
;	nlte, 1992-Aug-20  created 
; ---
; 
on_error,1
   firsttry=1
jmpff:  ff=findfile(infil,count=nff)
   case 1 of
   nff lt 1 and firsttry : begin 
			     infil=infil+'*' & firsttry=0 & goto,jmpff
			   end
   nff lt 1 : message,'File '+infil+' not found.' ; this was 2nd try!
   nff gt 1 : begin print,'File '+infil+' not unique:'
		    for i=0,nff-1 do print,ff(i)
		    print,'Enter filename' & read,infil & goto,jmpff
              end
   nff eq 1 : begin
	        infil=ff(0)
	        if strmid(infil,strlen(infil)-3,3) eq '.CF' then begin
		   print,'disk file '+infil+' must be uncompressed (wait)'
;		   select suitable host to do it:
		   ddfil0=infil
		   if strpos(ddfil0,'/') ne 0 then ddfil0=cwd+'/'+infil
;site-specific_start: (1)------------------------------------------------------
                   if strlowcase(getenv('HOST')) eq 'goofy' then begin
		      chost='' & goto,jmpcmprs
		   endif
		      case 1 of
		         strmid(ddfil0,0,6) eq '/home/' : i=6
			 strmid(ddfil0,0,5) eq '/day/' : i=5
			 strmid(ddfil0,0,6) eq '/dat/' : i=5 
		         else : i=-2
		      endcase
		      case i of
		         -2   : chost=''
			 else : begin
			          chost=strmid(ddfil0,i,strpos(ddfil0,'/',i)-i)
				  if strpos(chost,'_') gt 0 then $
				      chost = strmid(chost,0,strpos(chost,'_'))
                                end
;site-specific_end (1)---------------------------------------------------------
		      endcase
jmpcmprs:          if chost eq '' or chost eq getenv('HOST') then $
		      uncompress,infil else uncompress,infil,host=chost
		   infil=strmid(infil,0,strlen(infil)-3)
		endif
	      end
   endcase
end ; ... of LOOK4FILE
;
;
PRO INIT_EXAB,infil,cwd
;
; NAME:
;	INIT_EXAB
; PURPOSE:
;	Auxillary procedure for RDFITS: get name of drive & exab_host;
;	Querry user how tape was written;
;	Position tape ahead of file.
;*CATEGORY:            @CAT-#  2 11@
;	AUXILLARY/CCD
; CALLING SEQUENCE:
;	INIT_EXAB,infil,cwd,swap
; INPUTS:
;	infil (string) : final name of FITS-file on disk;
;		         !!! may be modified on return !!!
;       cwd   (string) : current working directory (on input)
; OUTPUTS:
;	infil (string) : final name of FITS-file on disk, may be modified
;			 by pre-pended directory path.
; COMMON BLOCKS:
;	FITSEXACOM,exab_host,exab_driv,dddir,neof1,neof2,nrecimg,recsiz,$
;                  swap,x0,y0,xmm,xm,ym,binx,biny,naxis1,naxis2
;       FITSEXACOM2,exab_driv1,exab_driv2,exab_driv_def,ddfildef,infildef,$
;                  ddmsgfile,remhost
; SIDE EFFECTS:
;	
; RESTRICTIONS:
;	
; PROCEDURE:
;	
; MODIFICATION HISTORY:
;	nlte, 1992-Aug-20  created
;       nlte, 1993-Feb-23  accepts hit on Return-key for Exab_Host
; ---
;
common FITSEXACOM,exab_host,exab_driv,dddir,neof1,neof2,nrecimg,recsiz,$
                  swap,x0,y0,xmm,xm,ym,binx,biny,naxis1,naxis2
common FITSEXACOM2,exab_driv1,exab_driv2,exab_driv_def,ddfildef,infildef,$
                  ddmsgfile,remhost
on_error,1
;
; remove suffix ".fits" from infil (if present):
i=strpos(infil,'.fits')
if i ge 0 then if i+5 eq strlen(infil) then infil=strmid(infil,0,i)
; directory for file to be dumped from ExaByte:
case 1 of
     infil eq ''               : begin dddir=cwd & infil=cwd+'/'+infildef & end
     strmid(infil,0,1)  eq '/' : begin
        i=0 & while i ge 0 do begin j=i+1 & i=strpos(infil,'/',j) & endwhile
        dddir=strmid(infil,0,j-1)
     			    end
     strmid(infil,0,2) eq './' : begin
        i=1 & while i ge 0 do begin j=i+1 & i=strpos(infil,'/',j) & endwhile
        j=j-1 & if j eq 1 then begin
	                  dddir=cwd & infil=cwd+strmid(infil,1,strlen(infil)-1)
                          endif else begin
                          dddir=cwd+strmid(infil,1,j-1)
			  infil=cwd+strmid(infil,1,strlen(infil)-1)
			  endelse
                                 end
     strpos(infil,'/') gt 0    : begin
        i=strpos(infil,'/') 
	while i ge 0 do begin j=i+1 & i=strpos(infil,'/',j) & endwhile
        dddir=cwd+'/'+strmid(infil,0,j-1) & infil=cwd+'/'+infil
                                 end
     else                      : begin dddir=cwd & infil=cwd+'/'+infil & end
endcase
;
if n_elements(exab_host) lt 1 then exab_host=''
;
if exab_host ne '' then return  ; all ExaByte related parameters already known
		                ; from previous call of RDFITS.
;
; ========== following block executed only on 1st call or if /reset: ==========
;  ExaByte-host & -drive:
;site-specific_start: (2.0)----------------------------------------------------
   if strlowcase(getenv('HOST')) eq 'goofy' then begin
      exab_host='goofy' & goto,jmp22
   endif
;site-specific_end (2.0)-------------------------------------------------------
   print,'Enter: name of Exabyte_Host or hit Return (== LOCAL)'
   exab_host=' '
   read, exab_host
   exab_host=strlowcase(strcompress(exab_host,/remove))   
   if exab_host eq 'local' or exab_host eq '' then begin
      exab_host=getenv('HOST') & print,'Exabyte_Host will be '+exab_host
   endif
   case exab_host of
;site-specific_start: (2)------------------------------------------------------
   'venus1': begin exab_host='venus' & exab_driv=exab_driv1 & end
   'venus2': begin exab_host='venus' & exab_driv=exab_driv2 & end
   'mars'  : exab_driv=exab_driv1
   'daisy1': begin  exab_host='daisy' & exab_driv=exab_driv1 & end
   'daisy2': begin  exab_host='daisy' & exab_driv=exab_driv2 & end
   'venus' : goto,jmp2
   'daisy' : goto,jmp2
   'dewey'  : exab_driv='nrst0'
;site-specific_end (2)---------------------------------------------------------
   else    : goto,jmp22
   endcase
   goto,jmp3
jmp2: print,'ExaB-device-name '+exab_driv1+' or '+exab_driv2+' ? Enter 1 or 2'
   i=0 & read,i & if i eq 1 or i eq 2 then $
                       exab_driv='nrst'+string(i,form='(i1)') else goto,jmp2
   goto,jmp3
jmp22: print,'Enter ExaB-device-name (e.g. nrst0)'
   exab_driv='' & read,exab_driv
;
;  specify how ExaByte-tape has been written:
jmp3: neof1=0 & neof2=0
   print,'Enter: number of file-marks at begin-of-tape'
   read,neof1
   print,'Enter: number of file-marks between files'
   read,neof2 
   print,'ExaB-record size (bytes) ?'
   again:  
   print,'     Enter: s (=2880) m (=4096) b (=16384) <other value>'
   crec='' & read,crec & crec=strlowcase(strcompress(crec,/remove))
   case strmid(crec,0,1) of
       '': goto,again
      's': recsiz=2880
      'm': recsiz=4096
      'b': recsiz=16384
      else: recsiz=fix(crec)
   endcase
;
   print,'Was tape written by AT1 with byte swap ON ? Enter y or hit Return'
   crec='' & read,crec & crec=strlowcase(strcompress(crec,/remove)) 
   if strmid(crec,0,1) eq 'y' then swap=0 else swap=1
;
   crec=''
   if neof2 eq 0 then begin
   again2: print,$
      'Enter: number of records per image **on tape-file** (incl. header)'
      print,'    or: format of image on tape:' 
      print,'        <nx,yn> or s (400x600) m (512x512) b (1024x1024)'
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
;============================================================================
;
end ; ... for INIT_EXAB
;
;
PRO SKIP_EXAB,errflg,skip=nskip
;
; NAME:
;	SKIP_EXAB
; PURPOSE:
;	Position ExaByte tape ahead of wanted exposure
;	by forward skipping over file marks or by records.
;*CATEGORY:            @CAT-#  2 11@
;	AUXILLARY/CCD	
; CALLING SEQUENCE:
;	SKIP_EXAB,remhost,errflg,SKIP=nskip
; INPUTS:
;	none
; OPTIONAL INPUT PARAMETER:
;	SKIP=nskip : if set with nskip > 0, ExaByte tape will be forward 
;	             skipped by <nskip> exposures.
; OUTPUTS:
;	errflg  (integer): relevant only for case "LUCY, no file marks":
;		set =1 if dd (dump from ExaByte to disk) signals '0+0';
;		    =3 if there were other unespected signals from dd.
; COMMON BLOCKS:
;	FITSEXACOM,exab_host,exab_driv,dddir,neof1,neof2,nrecimg,recsiz,$
;                  x0,y0,xmm,xm,ym,binx,biny,naxis1,naxis2
;       FITSEXACOM2,exab_driv1,exab_driv2,exab_driv_def,ddfildef,infildef,$
;                  ddmsgfile,remhost
; SIDE EFFECTS:
;	ExaByte tape will be moved.
; RESTRICTIONS:
;	
; PROCEDURE:
; 	Spawns "mt -f /dev/<exab_driv> " to forward-skip either by 
;       neof1+nskip*neof2 file marks if expression >0 or to by nskip*nrecimg
;	records id there are no file marks; 
;	neof1, neof2, nrecimg, recsiz are obtained from common block FITSEXACOM
;       On return, neof1 will be set (neof2-1)>0 .
;       mt command will be spawned to a remote host if neccessary.
; MODIFICATION HISTORY:
;	nlte, 1992-Aug-21  created
;       nlte, 1993-Feb-23  accepts hit on Return-key for Exab_Host
;       nlte, 1993-Apr-08  special coding for host "LUCY" removed.
; ---
;
common FITSEXACOM,exab_host,exab_driv,dddir,neof1,neof2,nrecimg,recsiz,$
                  swap,x0,y0,xmm,xm,ym,binx,biny,naxis1,naxis2
common FITSEXACOM2,exab_driv1,exab_driv2,exab_driv_def,ddfildef,infildef,$
                  ddmsgfile,remhost
on_error,1
;
; skip tape ?
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
      if remhost then command='rsh '+exab_host+' "'+command+'"'
      print,command
      spawn,command
endif
neof1=(neof2-1) > 0  ; tape now NOT at BOT!
;
return   ; successful
;
junsucc: if errflg le 0 then errflg=3 & printf,-2,txt & return  ; unsuccessful
;
end ; ... of SKIP_EXAB
;
;
PRO DUMP_EXAB,ddfil0,n_out_dd,search,errflg
;
; NAME:
;	DUMP_EXAB
; PURPOSE:
;	Dumps an exposure (FITS-format) from ExaByte tape to disk.
;*CATEGORY:            @CAT-#  2 11@
;	AUXILLARY/CCD
; CALLING SEQUENCE:
;	DUMP_EXAB,ddfil0,swap,n_out_dd,search,errflg
; INPUTS:
;	ddfil0 (string): name of disk file (incl. directory path) beeing
;			 output file for dd;
;		     !!! will be modified in case of search = 1 !!!
;       search (integer): =0: normal dd-action (dump a tape file or dump
;			      <nrecimg> records in case of no file marks);
;                         >0: "search for header action": dump 1 record
;			      on <ddfil0>.hdr (and ddfil0 = <ddfil0>.hdr);
; OUTPUTS:
;	n_out_dd (integer) : number of output lines from dd message file.
;       errflg   (integer) : =1 if dd signals '0+0' (eof encountered ?),
;			     =3 if other unexpected signal from dd.
; COMMON BLOCKS:
;       FITSEXACOM,exab_host,exab_driv,dddir,neof1,neof2,nrecimg,recsiz,$
;                  swap,x0,y0,xmm,xm,ym,binx,biny,naxis1,naxis2
;       FITSEXACOM2,exab_driv1,exab_driv2,exab_driv_def,ddfildef,infildef,$
;                  ddmsgfile,remhost	
;       DUMPEXACOM,argument  ; to save argument in case of "search loop"
; SIDE EFFECTS:
;	ExaByte tape is moved behind next file mark following exposure data
;	or before next exposure (if no file marks between exposures) (in case
;	of "search", tape is moved by only one record);
;	disk file is created containing dumped (and, if requested) byte swapped
;	exposure (or only one record in case of "search").
; RESTRICTIONS:
;	
; PROCEDURE:
;	Spawns dd; command will be spawned to a remote host if neccessary.
; MODIFICATION HISTORY:
;	nlte, 1992-Aug-20  created
;       nlte, 1993-Feb-23  bug case search with search >1;
;                          error messages on unit -2
; ---
;
common FITSEXACOM,exab_host,exab_driv,dddir,neof1,neof2,nrecimg,recsiz,$
                  swap,x0,y0,xmm,xm,ym,binx,biny,naxis1,naxis2
common FITSEXACOM2,exab_driv1,exab_driv2,exab_driv_def,ddfildef,infildef,$
                  ddmsgfile,remhost
common dumpexacom,argument
on_error,1
;
case search of 
   0: begin 
       argument='if=/dev/'+exab_driv+' of='+ddfil0
       if swap then argument=argument+' conv=swab'
       argument=argument+' bs='+string(recsiz,format='(i0)')
       if neof2 eq 0 then $
          argument=argument+' count='+string(nrecimg,format='(i0)')
      end
   1: begin
        ddfil0=ddfil0+'.hdr'
        argument='if=/dev/'+exab_driv+' of='+ddfil0+' bs=' 
        argument=argument+string(recsiz,format='(i0)')+' count=1'
      end
   else: begin
        argument='if=/dev/'+exab_driv+' of='+ddfil0+' bs=' 
        argument=argument+string(recsiz,format='(i0)')+' count=1'
      end
endcase
;
command='dd '+argument  
if remhost then command='rsh '+exab_host+' '+command
print,command
ddmsgf=dddir+'/'+ddmsgfile
command=command+' >&'+ddmsgf
spawn,command
command='cat <'+ddmsgf
if remhost then command='rsh '+exab_host+' '+command
;print,command
out_dd='' & spawn,command,out_dd
command='rm '+ddmsgf & if remhost then command='rsh '+exab_host+' '+command
spawn,command ; remove ddmsgfile
n_out_dd=n_elements(out_dd)
if n_out_dd lt 1 then begin 
txt='% RDFITSA: DD from ExaByte unsuccessful: no message from DD'
goto,junsucc
endif
if n_out_dd gt 0 then print,out_dd
if n_out_dd lt 2 then begin 
   txt='% RDFITSA:  DD from ExaByte unsuccessful. ' & goto,junsucc
endif
if strmid(out_dd(0),0,3) eq '0+0' or strmid(out_dd(1),0,3) eq '0+0' then begin
   errflg=1 & txt='% RDFITSA:  DD from ExaByte unsuccessful. ' & goto,junsucc
endif
;
return   ; successful
;
junsucc: 
if errflg lt 1 then errflg=3
printf,-2,txt & return  ; unsuccessful
end   ; ... of DUMP_EXAB
;
;
PRO CHECK_ARRAY,img_arr,neu,nx,ny,kx,ky
;
; NAME:
;	CHECK_ARRAY
; PURPOSE:
;	Checks 1st argument if appropriate array for storing an image;
;	if not, a new array will be created (user must enter requested format 
;	for image array); checks format of original image format of exposure 
;       vs. format of img_arrarray and requests user to enter new 
;       binning/scissoring parameters if neccessary.
;*CATEGORY:            @CAT-#  2 11@
;	AUXILLARY/CCD
; CALLING SEQUENCE:
;	CHECK_ARRAY,img_arr,neu,nx,ny,kx,ky
; INPUTS:
;	img_array : if a 2-dim integer array as created
;                    by a previous call, this structure will be used again (if
;		      possible);
;		     else, such an array will be created.
;	          !!! may be modified on return !!!
;       neu (logical): =1:  forces img_arr to be re-created in any case.
;		  !!! may be modified on return !!!   
; OUTPUTS:
;       img_arr   : valid array for storing the exposure.
;	nx, ny    : size of array (may be > than physical image).
;       kx,ky     : size of binned sub-image after binning.
;       neu(logical): value either 0 or 1 depending on details. Do not use
;		      it's value after return!
; COMMON BLOCKS:
;	FITSEXACOM,exab_host,exab_driv,dddir,neof1,neof2,nrecimg,recsiz,$
;                  swap,x0,y0,xmm,xm,ym,binx,biny,naxis1,naxis2
; SIDE EFFECTS:
;	
; RESTRICTIONS:
;	
; PROCEDURE:
;	
; MODIFICATION HISTORY:
;	nlte, 1992-Aug-24   created 
; ---
;
common FITSEXACOM,exab_host,exab_driv,dddir,neof1,neof2,nrecimg,recsiz,$
                  swap,x0,y0,xmm,xm,ym,binx,biny,naxis1,naxis2
on_error,1
;
sz=size(img_arr)
if sz(0) eq 2 and sz(1) gt 1 and sz(2) gt 1 then begin
   nx=sz(1) & ny=sz(2)
endif else begin img_arr=0 & neu=1 & endelse
;
jmpstruct:
if neu ne 0 then begin
   print,'Size of image-array to be stored in IDL memory?'
   jmp1: print ,$
      '  Enter: b (=1024x1024), m (=512x512), r (=320x512) s (=400x600), t (256x256), or: <nx>,<ny>'
   form_pic=''
   read ,form_pic & form_pic=strlowcase(strcompress(form_pic,/remove))
   case strmid(form_pic,0,1) of
      'b': begin nx=1024 & ny=1024 & end
      'm': begin nx=512 & ny=512 & end
      's': begin nx=400 & ny=600 & end
      't': begin nx=256 & ny=256 & end
      'r': begin nx=320 & ny=512 & end
      else: begin comma=strpos(form_pic,',')
                  if comma le 0 then goto,jmp1
		  nx=fix(strmid(form_pic,0,comma))
		  ny=fix(strmid(form_pic,comma+1,strlen(form_pic-comma)))
            end
   endcase
   img_arr=intarr(nx,ny) & par=intarr(50)-9
;
endif
;
; check size of image-array on disk (naxis1,2) <= size of img_arr (nx,ny) :
if (naxis1 gt nx) or (naxis2 gt ny) then begin
again3:
   if neu eq 0 then begin  ; try with previous scissoring / binning 
      xm=(xm>(x0+1))<(naxis1-1) & ym=(ym>(y0+1))<(naxis2-1)
      nxsub=xm-x0+1 & nysub=ym-y0+1 ; prelimin. size of sub-array read-in array
      kx=nxsub/binx & ky=nysub/biny ; size of binned sub-image after binning
      nxsub=kx*binx & nysub=ky*biny ; definite size of sub-array read-in array 
      xm=x0+nxsub-1 & ym=y0+nysub-1 ; definite outer boundaries sub-array
      neu= (kx gt nx) + (ky gt ny)
   endif
   if neu gt 0 then begin  
;     user must specify (new) scissoring / binning  or other format for .pic
      print,$
 FORMAT='("size of read-in image = ",i0," , ",i0," larger than ",i0," , ",i0)'$
      ,naxis1,naxis2,nx,ny 
      print,$
      'Extraction of a sub-image and/or binning or new array-format required !'
again4:
     print,'Enter "n" (new array) or : "s" (sub-image) "b" (binning) "sb" (both) !'
     sn='' & read,sn & sn=strlowcase(sn)
	 if sn eq 'n' then begin neu=1 & goto,jmpstruct & endif
     if (strpos(sn,'s') lt 0) and (strpos(sn,'b') lt 0) then goto,again4
     x0=0 & y0=0 & xm=xmm & ym=xmm & binx=1 & biny=1
     if strpos(sn,'s') ge 0 then begin
        print,$
           'Enter x0,y0, xm,ym of lower-left, upper-right corners of sub-image'
        read,x0,y0,xm,ym & x0=x0>0 & y0=y0>0
     endif
     if strpos(sn,'b') ge 0 then begin
        print,'Enter binning-factors x-,y-dimension (integer)'
        read,binx,biny & binx=binx>1 & biny=biny>1
     endif 
     neu=0 & goto,again3
   endif
endif
;
end  ; ... of CHECK_ARRAY
;
;
PRO rdfitsa,img_arr,ainfil, fits_header=header,status=status,project=proj,$
       txt=txt,id=id,time=time,itime=itime,exposure=expos,parameters=bb,$
       exabyte=itape,skip_file=nskip,delete=idelete,reset=ireset,errflag=errflg
;
; *** documentation see at begin of this file!
; *** for other sites: change statements enclosed below between
; ***           ";site-specific_start"
; ***           and ";site-specific_end" !!
;
common fitsexacom,exab_host,exab_driv,dddir,neof1,neof2,nrecimg,recsiz,$
                  swap,x0,y0,xmm,xm,ym,binx,biny,naxis1,naxis2
common fitsexacom2,exab_driv1,exab_driv2,exab_driv_def,ddfildef,infildef,$
                  ddmsgfile,remhost
;
on_error,1 & errflg=-1
;
;site-specific_start: (0)------------------------------------------------------
; default device name of ExaByte drive ("no rewind"):
    exab_driv1='nrst1' & exab_driv2='nrst2' & exab_driv_def=exab_driv1
;
;site-specific_end (0)---------------------------------------------------------
;
user=getenv('USER') & unit=-999
ddfildef=user+'-dd_swab.fits' ; default for file created by dd
infildef=user+'-CCD' ; default for part of final file name.
cd,current=cwd      ; current directory stored to cwd (no cd !)
ddmsgfile=user+'-dd_FITS.msg' ; file for message from DD
;
if n_params() le 0 then begin
 print,'Usage: RDFITSA,img_arr [,infil] [,/EXABYTE [,/SKIP_FILE=nskip] ...'
 print,'  ... [,/DELETE] [,/RESET] [other optional outputs] [,ERRFLAG=errflag]'
 goto,jexit
endif
;
if n_elements(dddir) lt 1 then dddir=''
;
xmm=32767 ; max short integer
neu=0
if keyword_set(ireset) then begin
   exab_host='' & exab_driv=exab_driv_def & dddir='' & neu=1
   img_arr=0 & nx=0 & ny=0
   x0=0 & y0=0 & xm=xmm & ym=xmm & binx=1 & biny=1
endif
;
if n_params() eq 1 then begin
   if not keyword_set(itape) then message,$
          'Either name of existing FITS-file or /EXAB must be specified'
   infil=''
endif else begin
   infil=ainfil
   sz=size(infil) & if sz(0) ne 0 or sz(1) ne 7 then $
                    message,'2nd arg (file_name) must be a string'
   infil=strcompress(infil,/rem)
endelse
;
search=0
;
if not keyword_set(itape) then begin
; **** case: read FITS-file <infil> ("or so") from disk
       look4file,infil,cwd
       ddfil0=infil & n_out_dd=-1
       goto,jmpopen
endif
;
; **** case if /EXAB set: Initialize ExaByte tape (get parameters):
       init_exab,infil,cwd
;
; **** case /EXAB set: come here to do required tape actions
   if strmid(exab_driv,0,4) ne 'nrst' then $
      message,'Unknown ExaByte-drive: '+exab_driv
   remhost= exab_host ne getenv('HOST')
;
;  position tape before desired exposure: 
   skip_exab,errflg,skip=nskip
   if errflg gt 0 then goto,jexit  ; unsuccessful tape position action. Abort.
;   
;
jdumpandread:  
ddfil0=dddir+'/'+ddfildef ; path & name of file for dd-action
search=0 
;
jdump:
dump_exab,ddfil0,n_out_dd,search,errflg
if errflg gt 0 then goto,junsucc
;
jmpopen:   ; come here if dd was successfull or if existing file to be read
openr,unit,ddfil0,/get_lun
ddfil0stat=fstat(unit) & if ddfil0stat.size gt 2880L then goto,jsucc
errflg=2
txt='% RDFITS: size of disk file '+string(ddfil0stat,form='(i0)')+' too small.'
printf,-2,txt
;
junsucc:
if errflg lt 1 then errflg=3
if n_out_dd eq -1 or n_out_dd gt 1 then help,ddfil0stat,/st
goto,jexit  
;
jsucc:   ; read FITS header
errflg=0
; read FITS-header:
fits_hdr,unit,date,time,datemodif,proj,txt,fitsfile,id,itime,expos,bb,$
         szx,szy,nrecs
; check :
if id eq -999 and search gt 0 then begin 
   printf,-2,'goto,jdump, search=',search
   search=search+1 & goto,jdump ; next block!
endif 
if id eq -999 then begin  
; fits_hdr: 1st record of dumped file is not a FITS-header!
  if not keyword_set(itape) then return
;;;;  if neof2 gt 0 or exab_host eq 'lucy' then begin ; LUCY is dead!
  if neof2 gt 0 then begin
     command='mv '+ddfil0+' err_'+ddfil0
     printf,-2,command & spawn,command
     printf,-2,'file with no header written to err_'+ddfil0
     goto,jexit
  endif else begin
; read tape backwards behind record with previously read header
     free_lun,unit 
     command='rm '+ddfil0 & spawn,command & print,command
     command='mt -f /dev/'+exab_driv+' bsr '+string(nrecimg,format='(i0)')
     if remhost then command='rsh '+exab_host+' '+command
     printf,-2,command & spawn,command
; now read tape block by block until next fits-header:
     search=1
     goto,jdump ; dump 1 block from tape, check if fits-header 
  endelse
endif
if search gt 0 then begin
;  come here after successful search for a header-block
     free_lun,unit 
     command='rm '+ddfil0 & spawn,command
     command='mt -f /dev/'+exab_driv+' bsr 1'
     if remhost then command='rsh '+exab_host+' '+command
     printf,-2,command & spawn,command 
     search=0 & goto,jdumpandread ; now regular dump & read complete file
endif   
;
if n_elements(naxis1) eq 0 then neu=1 else $
   neu=neu + (szx ne naxis1) + (szy ne naxis2)
   naxis1=szx & naxis2=szy ; actual size (x,y) image-array on disk
print,$
   FORMAT='("FITS-header has been read in. Image-array-size: ",i0," , ",i0)' $ 
   ,naxis1,naxis2
;
; check img_arr; user must specify format if not already done
check_array,img_arr,neu,nx,ny,kx,ky
;
case bb(0) of
   -9 : typ='unknown'
    1 : typ='dark-field'
    2 : typ='flat-field'
    3 : typ='image'
 else : typ='special '+string(bb(0),form='(i0)')
endcase
case bb(1) of
   -9 : red='unknown'
    0 : red='raw data'
    1 : red='dark subtr.'
    2 : red='flatfld div.'
    3 : red='cleaned'
 else : red='special '+string(bb(1),form='(i0)')
endcase
   status=$
      'FITS '+datemodif+' Type: '+typ+' reduct: '+red+' '+fitsfile
;
; read image array:
p=assoc(unit,intarr(naxis1,naxis2,/nozero),2880L*nrecs)
if nx eq naxis1 and ny eq naxis2 then begin
;  ***** image same format as img_arr ***** :
   img_arr=p(0)
   print,'image -> img_arr (binning=1,x0=y0=0)'
endif else if nx ge naxis1 and ny ge naxis2 then begin
;  ***** image is smaller than img_arr ***** :
    img_arr=intarr(nx,ny)
    img_arr(0:naxis1-1,0:naxis2-1)=p(0)
    print,'image -> img_arr (binning=1,x0=y0=0; image < array !)'
endif else begin
;  ***** image is larger than ccd_struct.pic ***** do scissoring/binning:
   img_arr=intarr(nx,ny)
   print,$
       FORMAT='(" img_arr(0:",i0,",0:",i0,") <-")',kx-1,ky-1
   if binx gt 1 or biny gt 1 then print,$
    FORMAT='(" rebin(image(",i0,":",i0,",",i0,":",i0,"),",i0,",",i0,")")',$
       x0,xm,y0,ym,kx,ky else print,$
    FORMAT='(" image(",i0,":",i0," , ",i0,":",i0,")")',x0,xm,y0,ym
   if binx gt 1 or biny gt 1 then $
      img_arr(0:kx-1,0:ky-1) = rebin((p(0))(x0:xm,y0:ym),kx,ky) $
   else img_arr(0:kx-1,0:ky-1)=(p(0))(x0:xm,y0:ym)
   bb(7)=bb(7) < bb(23)+xm*bb(21) & bb(8)=bb(8) < bb(24)+ym*bb(22)
   ngood=(xm < bb(25)-1)-x0 +1
   bb(25)=ngood/binx & if bb(25)*binx lt ngood then bb(25)=bb(25)+1
   ngood=(ym < bb(26)-1)-y0 +1
   bb(26)=ngood/biny & if bb(26)*biny lt ngood then bb(26)=bb(26)+1
   bb(23)=bb(23)+x0*bb(21) & bb(24)=bb(24)+y0*bb(22)
   bb(21)=bb(21)*binx & bb(22)=bb(22)*biny
   dattim=systime()
   dattim=strcompress(strmid(dattim,22,2)+' '+strmid(dattim,4,12))
   i1=strpos(txt,'%H new image format (offset / binning):')
   if i1 gt 0 then begin
      i2=strpos(txt,':',i1)+1
      i3=strpos(txt,'^',i2)+1 & i4=strlen(txt)-i3
      txt0=strmid(txt,0,i2)+' '+dattim+'^'
      if i4 gt 0 then txt0=txt0+strmid(txt,i3,i4)
      txt=strcompress(txt0) & txt0=''
   endif else $
      txt=txt+'%H new image format (offset / binning): '+dattim+'^'
   i1=strpos(txt,'%DATE ')
   if i1 gt 0 then begin
      i2=i1+7
      i3=strpos(txt,'^',i2)+1 & i4=strlen(txt)-i3
      txt0=strmid(txt,0,i2)+dattim
      if i4 gt 0 then txt0=txt0+strmid(txt,i3,i4)
      txt=strcompress(txt0) & txt0=''
   endif else txt=txt+'%DATE '+dattim+'^'
endelse
;       
free_lun,unit & unit=-999
;
header=mkfitshdr(proj,txt,bb,nx,ny)
;
if not keyword_set(itape) then goto,jexit
;
if keyword_set(itape) and keyword_set(idelete) then begin
   command='rm '+ddfil0
   if remhost then command='rsh '+exab_host+' '+command
   spawn,command & print,'FITS-file removed.'
   goto,jexit
endif 
;
; case /EXAB and no /DELETE: mv dd-file
suff=-1
if fitsfile ne '' then infil=infil+'_'+fitsfile
ddfil=infil
i=strpos(ddfil,'.fits') & if i gt 0 and i eq strlen(ddfil)-5 then $
                          ddfil=strmid(ddfil,0,i)
ddfils=ddfil+'.fits'
ff=findfile(ddfils,count=nff)
while nff gt 0 do begin 
   suff=suff+1 & if suff gt 999 then goto,jbadsuff 
   ddfils=ddfil+string(suff,form='(".",i3.3,".fits")')
   ff=findfile(ddfils,count=nff)
endwhile
command='mv '+ddfil0+' '+ddfils
if remhost then command='rsh '+exab_host+' '+command
spawn,command & print,'FITS-file: '+ddfils
;
jexit: 
if unit ge 100 then free_lun,unit
return
;
jbadsuff: printf,-2,ddfil+' suffix overflow. No new disk file written.'
          printf,-2,'Original FITS-File: ',ddfil0+' not removed.'
          goto,jexit
end


