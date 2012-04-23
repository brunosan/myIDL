PRO printccd,arg1,arg2,format=form_string
;+
; NAME:
; 	PRINTCCD
; PURPOSE:
;     formatted print-out of a "CCD_STRUCT"-text_string
;            (broken into several print lines at occurences of character "^") 
;     or of "CCD_STRUCT"-parameters (together with "meaning").
;*CATEGORY:            @CAT-#  2 14@
; 	CCD Tools , I/O 
; CALLING SEQUENCE:
;	PRINTCCD [,unit] ,information [,FORMAT='(format string)']
; INPUTS:
;	information: EITHER: string containing a text as stored in
;		            ccd_struct.proj or or ccd_struct.txt
;		            (with "^" indicating end-of-line).
;	             OR    : parameter-vector (intarr, size =50) as in
;			     ccd_struct.par .
; OPTIONAL INPUT PARAMETERS:
;  	unit : output unit number; must be 1st argument if specified;
;	       default: standard output: -1 .
; KEYWORD PARAMETERS:
;	FORMAT='(format string)' : format string according to IDL-rules
;	             (specifying output of one text-line);
;		     default: text: new line after "^"; 
;		              params: "(i)= <value> : <meaning>	/" for each
;			              parameter entry with value other than -9 
; OUTPUTS:
;  	none
; SIDE EFFECTS:
;       ASCII-output of one or several lines to file or standard-out as
;       specified by unit number.
; RESTRICTIONS:
; 	none
; PROCEDURE:
; 	straight foreward  	
; MODIFICATION HISTORY:
;	nlte (KIS) 1992-Feb-27
;	nlte (KIS) 1992-Apr-30  commented output of par(50), unit optional
;-
on_error,1
case n_params() of
     1: begin unit=-1 & info=arg1 & carg='1st' & end
     2: begin unit=arg1 & info=arg2 & carg='2nd' & end
     else: message,$
           'Usage: PRINTCCD [,unit], information [,FORMAT=''(format string)'']'
endcase
sz=size(info)
if sz(0) eq 0 and sz(1) eq 7 then goto,jtext
if sz(0) eq 1 and sz(1) eq 50 and sz(2) eq 2 then goto,jpar
message,carg+' argument must be a string or an integer-array size 50'
;
jtext:
textend=strlen(info)
if textend lt 1 then return
;
ze=strpos(info,'^')
if ze lt 0 then if keyword_set(form_string) then $
                   printf,unit,info,form=form_string else $
		   printf,unit,info $ 
else begin
     za=0
     while za lt textend do begin
          if keyword_set(form_string) then $
               printf,unit,strmid(info,za,ze-za>1),form=form_string $
          else printf,unit,strmid(info,za,ze-za>1)
          za=ze+1 & ze=strpos(info,'^',za)
	  if ze lt za then ze=textend+1
     endwhile
endelse
return
;
jpar:
if keyword_set(form_string) then $
   printf,unit,info,form=form_string else begin
;
   meaning=strarr(50)
   meaning(0:2)=['img_type','reduct','img_ID']
   meaning(3:6)=['bin_x','bin_y','offset_x','offset_y'] ; orig. CCD
   meaning(7:8)=['end_x ','end_y'] ; true image / CCD-pix
   meaning(9)='expos/unit' & meaning(17)='unit exp ms'
   meaning(18)='tape-file-#' ; (from FITS "FILENAME")
   meaning(19:20)=['loop-ID','loop-counter']
   meaning(21:24)=['bin_x','bin_y','start_x','start_y'] ; act. image / CCD-pix
   meaning(25:26)=['size_x','size_y'] ; true image data (after binning)
   meaning(27:29)=['gain','zerolevel','speed'] ; orig. CCD
   meaning(46)='bitpix'
   meaning(47:49)=['hh','mm','ss'] ; start time exposure (ss rounded)
;   
   jj=[0,1,2] & kk=where(info(jj) ne -9, nii) ; image status
   if nii gt 0 then begin
      printf,unit,'Status actual image:'
      txt='   PAR'
      for i=0,n_elements(jj)-1 do begin
      j=jj(i)
      if info(j) ne -9 then begin
         addtxt=string(j,info(j),form='("(",i0,")= ",i0,": ")')+meaning(j)
         if strlen(txt)+strlen(addtxt) gt 78 then begin
           printf,unit,txt & txt='   '+addtxt+'/  '
         endif else txt=txt+addtxt+'/  '
      endif
      endfor
      printf,unit,txt
   endif
   jj=[25,26,21,22] & kk=where(info(jj) ne -9, nii) ; image format
   if nii gt 0 then begin
      printf,unit,'Format actual true image :'
      txt='   PAR'
      for i=0,n_elements(jj)-1 do begin
      j=jj(i)
      if info(j) ne -9 then begin
         addtxt=string(j,info(j),form='("(",i0,")= ",i0,": ")')+meaning(j)
         if strlen(txt)+strlen(addtxt) gt 78 then begin
           printf,unit,txt & txt='   '+addtxt+'/  '
         endif else txt=txt+addtxt+'/  '
      endif
      endfor
      printf,unit,txt
   endif
   jj=[23,24,7,8] & kk=where(info(jj) ne -9, nii) ; CCD-pix coordinates 
;						    true img boundaries
   if nii gt 0 then begin
      printf,unit,'CCD-pix coordinates actual true image :'
      txt='   PAR'
      for i=0,n_elements(jj)-1 do begin
      j=jj(i)
      if info(j) ne -9 then begin
         addtxt=string(j,info(j),form='("(",i0,")= ",i0,": ")')+meaning(j)
         if strlen(txt)+strlen(addtxt) gt 78 then begin
           printf,unit,txt & txt='   '+addtxt+'/  '
         endif else txt=txt+addtxt+'/  '
      endif
      endfor
      printf,unit,txt
   endif
   jj=[18,19,20,9,17,47,48,49] & kk=where(info(jj) ne -9, nii) ; exposure
   if nii gt 0 then begin
      printf,unit,'Exposure:'
      txt='   PAR'
      for i=0,n_elements(jj)-1 do begin
      j=jj(i)
      if info(j) ne -9 then begin
         addtxt=string(j,info(j),form='("(",i0,")= ",i0,": ")')+meaning(j)
         if strlen(txt)+strlen(addtxt) gt 78 then begin
           printf,unit,txt & txt='   '+addtxt+'/  '
         endif else txt=txt+addtxt+'/  '
      endif
      endfor
      printf,unit,txt
   endif
   jj=[3,4,5,6,27,28,29,46] ; "official" params: original CCD 
   kk=where(info(jj) ne -9, nii) & if nii lt 1 then goto,jother
   printf,unit,'Original CCD setup:'
      txt='   PAR'
      for i=0,n_elements(jj)-1 do begin
      j=jj(i)
      if info(j) ne -9 then begin
         addtxt=string(j,info(j),form='("(",i0,")= ",i0,": ")')+meaning(j)
         if strlen(txt)+strlen(addtxt) gt 78 then begin
           printf,unit,txt & txt='   '+addtxt+'/  '
         endif else txt=txt+addtxt+'/  '
      endif
      endfor
      printf,unit,txt
;
jother:
   jj=[10+indgen(7),30+indgen(16)] ; "un-official" params
   kk=where(info(jj) ne -9, nii)
   if nii lt 1 then return
   printf,unit,'Params set by user:'   
   ii=jj(kk) ; valid values
   txt='   PAR'
   for i=0,nii-1 do begin
   addtxt=string(ii(i),info(ii(i)),form='("(",i0,")= ",i0," ")')
   if strlen(txt)+strlen(addtxt) gt 78 then begin
      printf,unit,txt & txt='   '+addtxt+'/  '
   endif else txt=txt+addtxt+'/  '
   endfor
   printf,unit,txt
;
endelse
end

