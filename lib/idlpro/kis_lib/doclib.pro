;+
; NAME:
;	DOCLIB
; PURPOSE:
;	Extract the documentation template of one or more procedures.
;	Invokes KIS-Version of doc_lib_unix (=DOCLIBUNIXKIS) if IDL is
;       running under UNIX.
;*CATEGORY:            @CAT-# 13@
;	Help
; CALLING SEQUENCE:
;	doclib	                   ;For prompting.
;	doclib,'Name' [,keywords]  ;Extract documentation for procedure 'Name'
;	                            using the current !PATH.
; INPUTS:
;	Name = string containing the name of the procedure.
;	Under Unix, Name may include "*" as "wild-character" or "*" for "all"
;       (not allowed if output to paper-printers).
;	
; KEYWORDS (All Versions):
;	/PRINT                  : documentation is sent to the default printer:
;		                  (UNIX: 'lpr -h -Pt0' = local InkJet printer);
; KEYWORDS (UNIX-Version):
;	PRINT= 'te' or ='TE'    : output to 'lpr -h -PTE';
;	PRINT= 'lw' or ='LW'    : output to LaserWriter (standard format);
;	PRINT= 'lw2' or ='LW2'  : output to LaserWriter (2-column-format);
;	PRINT= 'file' or ='FILE': output to file "./<name[_lib]>.IDL_doc[.n]";
;	PRINT= '<shell-command>': the specified string is interpreted as a
;				  shell-command used for output with its
;				  standard input the documentation:
;				  I.e. PRINT="cat > junk";
;       PRINT= 0 or not set     : output piped thru "more" to terminal screen.
;
;	DIRECTORY= '<directory_to_search>' 
;	                    If omitted, use  current directory and !PATH;
;	           Abbreviations for common libraries:
;	DIRECTORY= '.'   :  search current directory **only**;
;	DIRECTORY= 'kis' :  search in KIS_LIB **only**;
;	DIRECTORY= 'user':  search in IDL-USER's Library **only**;
;	DIRECTORY= 'stat':  search in IDL-STATISTICS Library **only**;
;	DIRECTORY= 'widg':  search in IDL-WIDGETS Library **only**;
;	DIRECTORY= 'other': search in OTHER_CONTRIBS (creaso,esrg_ucsb,windt)
;                           **only**;
;	DIRECTORY= 'iue' :  search in IUE-library (KIS-version) **only**;
;	DIRECTORY= 'jhu' :  search in JHUAPL-library (KIS-version) **only**;
;       DIRECTORY= 'nasa':  search in NASA-ASTROLIB (KIS-version) **only**.
;
;	MULTI= flag : to allow printing of more than one file if the module
;		      exists in more than one directory in the path + the
;		      current directory.
; KEYWORDS VMS-Version):
;	/FILE          : If present and non-zero, the output is left in the
;		         file userlib.doc, in the current directory.
;	PATH= '<path>' : optional directory/library search path.  Same format
;		         and semantics as !PATH.  If omitted, !PATH is used.
;
; OUTPUTS:
;	Documentation is sent to the standard output unless /PRINT
;	is specified.
; COMMON BLOCKS:
;	None.
; SIDE EFFECTS:
;	Output is produced on terminal or printer.
; RESTRICTIONS:
;	The DIRECTORY and MULTI keywords are ignored under VMS. The
;	FILE and PATH keywords are ignored under Unix.
; MODIFICATION HISTORY:
;	Written, DMS, Sept, 1982.
;	Added library param, Jul 1987.
;	Unix version, DMS, Feb, 1988.
;	New VMS version, DMS, Dec. 1989
;	Wrapper procedure to call the correct version
;		under Unix and VMS, AB, Jan 1990
;       Added support for DOS, SNG, Dec, 1990
;	Adapted for KIS, H.S., Jul, 1991
;	1992-Jul-17: pro DOCLIBUNIX added into same file as DOCLIB
;	1992-Nov-03: more libraries included
;       1993-Mar-22: 'WINDT' replaced by 'OTHER' (OTHER_CONTRIBS)
;       1993-Mar-31: userlib-procs DOC_LIB_VMS, DOC_LIB_DOS -> DL_VMS, DL_DOS
;		     (IDL vers. 3.0.0)
;-

pro doclibunixkis, name, print=printflg, directory = direct, multi = multi
;   +NODOCUMENT
; NAME:
;	DOCLIBUNIXKIS
; PURPOSE:
;	Extract the documentation template of one or more procedures.
;	Use DOCLIB to call this procedure if under UNIX!
;*CATEGORY:            @CAT-# 13@
;	Help, documentation.
; CALLING SEQUENCE:
;	doclibunixkis	;For prompting.
;	doclibunixkis, Name ;Extract documentation for procedure Name using
;			the current !PATH.
; INPUTS:
;	Name = string containing the name of the procedure (may include
;	       "*" as "wild-character" or "*" for all (not allowed if output
;	       to paper-printers).
;	
; OPTIONAL INPUT PARAMETERS:
;	PRINT = keyword parameter which, if set to 1 or ='t0','T0', sends
;		output of doc_lib_unix to 'lpr -h -Pt0';
;	      = 'te' or ='TE': output to 'lpr -h -PTE';
;	      = 'lw' or ='LW': output to LaserWriter (standard format);
;	      = 'lw2' or ='LW2': output to LaserWriter (2-column-format);
;	      = 'file' or ='FILE': output to file "./<name[_lib]>.IDL_doc[.n]";
;               If PRINT is an other string, it is interpreted as a shell- 
;		command used for output with its standard input the 
;		documentation.  I.e. PRINT="cat > junk".
;             = 0 or not set: output piped thru "more" to terminal screen.
;	DIRECTORY = directory or Library to search; if omitted, use  current
;	        directory and !PATH;
;	      = '.' :    search current directory **only**;
;	      = 'kis' :  search in KIS_LIB **only**;
;	      = 'user':  search in IDL-USER's Library **only**;
;	      = 'stat':  search in IDL-STATISTICS Library **only**;
;	      = 'widg':  search in IDL-WIDGETS Library **only**;
;	      = 'other': search in OTHER_CONTRIBS (Creaso, Esrg_Ucsb, Windt)
;	                        **only**.
;	MULTI = flag to allow printing of more than one file if the module
;		exists in more than one directory in the path + the current
;		directory.
; OUTPUTS:
;	No explicit outputs.  Documentation is piped through more unless
;	/PRINT is specified.
; COMMON BLOCKS:
;	None.
; SIDE EFFECTS:
;	output is produced on terminal or printer.
; RESTRICTIONS:
;	??
; PROCEDURE:
;	Straightforward.
; MODIFICATION HISTORY:
;	DMS, Feb, 1988.
;	nlte,KIS, Jul 26, 1991 : 
;                 other defaults & short names for printer;
;		  printer='file' ==  printer='cat > outfile' (oufile set here)
;		  directory='<short name for public libraries>'
;	          complete print-out (name='*') supressed.
;  -NODOCUMENT

on_error,2              ;Return to caller if an error occurs
if n_elements(name) gt 0 then goto,jmp0	;Interactive query?
	name = ''
	read,'Name of procedure or * for all: ',name
  if not keyword_set(printflg) then begin
    printflg = ''
    read,'Enter t0, te, lw, or lw2 for printer, 0 for terminal, f for file: ',$
        printflg
    if printflg eq '' or printflg eq ' ' then printflg='0'
    if strupcase(strtrim(printflg,2)) eq 'F' then printflg='FILE'
  endif
  if not keyword_set(direct) then begin
    direct=' '
    print,'Directory to search: Enter directory-name or:'
    read,' . (="current"), * (="all"), iue, jhu, nasa, kis, user, other, stat, widg : ',direct
    case direct of
       '*': direct=''
       'all': direct=''
       '': direct='.'
       ' ': direct='.'
      else: direct=direct
    endcase
  endif
;    
jmp0:
name = strlowcase(name)		;make it always lower case
if n_elements(direct) eq 0 then direct=''
if direct eq '' then path = ".:" + !path $	;Directories to search
	else path = direct
pathlc = '.'
if path eq '.' then goto,jmp1
pathlc = 'X'
if strmid(path,0,2) eq '.:' then goto,jmp1
pathlc = strlowcase(strmid(strtrim(path,2),0,5))
idldir=getenv('IDL_DIR')
if idldir eq '' then idldir='/usr/local/lib/idl/lib/' else $
                     idldir=idldir+'/lib/'
;case pathlc of
case 1 of
  strpos(pathlc,'kis') eq 0 :  path=idldir+'kis_lib' ; there must be a link to kis_lib !
  strpos(pathlc,'user') eq 0 : path=idldir+'userlib'
  strpos(pathlc,'stat') eq 0 : path=idldir+'statlib'
  strpos(pathlc,'widg') eq 0 : path=idldir+'widgetlib'
  strpos(pathlc,'other') eq 0 : path=idldir+'other_contribs'
  strpos(pathlc,'wind') eq 0 : path=idldir+'other_contribs'
  strpos(pathlc,'iue') eq 0 : path=idldir+'other_libs/iue_pro' ; there must be a link to other_libs !
  strpos(pathlc,'jhu') eq 0 : path=idldir+'other_libs/pro'
  strpos(pathlc,'nasa') eq 0 : path=idldir+'other_libs/nasa_pro'
     else: path=path
endcase
jmp1:
if n_elements(printflg) eq 0 then printflg='0'
case strupcase(strtrim(printflg,2)) of
 '1':  output = "  'lpr -h -Pt0' " 
 '0':  output = " more " 
 'T0': output =" 'lpr -h -Pt0' "
 'TE': output = " 'lpr -h -PTE' "
 'LW': output = " 'enscript -h' "
 'LW2': output = " 'enscript -h -2r ' " 
  else: output = " '"+printflg+"' " 
endcase
if strtrim(name,2) eq '*' and (strpos(strlowcase(output),'lpr') ge 0 or $
        strpos(strlowcase(output),'enscr') ge 0) then $
        message,'Papierausgabe der kompletten Dokumentation nicht erlaubt!'
;
if strupcase(strcompress(output,/remove_all)) ne "'FILE'" then goto,jmp3
   outfil=strcompress(name,/remove_all)
   if outfil eq '*' then outfil='ALL'
   while strpos(outfil,'*') ge 0 do begin
         i=strpos(outfil,'*') & strput,outfil,'%',i
   endwhile
   if pathlc ne '.' then outfil = outfil+'_'+pathlc+'.IDL_doc' $
   else outfil = outfil+'.IDL_doc'
   suffix=0
   outfil0=outfil
jmp2: ff=''
   ff=findfile(outfil,count=nout)
   if nout gt 0 then begin
       suffix=suffix+1 
       outfil=outfil0+'.'+string(suffix,format='(i0)')
       goto,jmp2
   endif
   output = " 'cat > "+outfil+"' "
;   print,output
jmp3:
;   print,'output =',output
if n_elements(multi) le 0 then multi = 0	;Only print once
if strpos(name,"*") ge 0 then begin	;Wild card?
	multi = 1		;allow printing of multiple files
	endif

cmd = !dir + "/bin/doc_library "+output+strtrim(multi,2)+' ' ;Initial cmd
	
while strlen(path) gt 0 do begin ; Find it
	i = strpos(path,":")
	if i lt 0 then i = strlen(path)
	file = strmid(path,0,i)+ "/" + name + ".pro"
;	print,"File: ",file
	path = strmid(path,i+1,1000)
	cmd = cmd + ' ' + file
	endwhile
;print,cmd+ output
spawn,cmd+ output
end


pro doclib, name, print=printflg, directory = direct, multi = multi, $
	PATH = path, FILE=file


on_error,2                        ;Return to caller if an error occurs
case !version.os of 
  'vms':  DL_VMS, NAME, FILE=file, PRINT=printflg, PATH=path
  'DOS':  DL_DOS, NAME, DIRECTORY=direct, PRINT=printflg
  else:  DOCLIBUNIXKIS, NAME, print=printflg, directory = direct, multi = multi
endcase
end







