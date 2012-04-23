;+
; NAME:
;       EXTRACTHLP
; PURPOSE:
;       Extract help text from an IDL routine, full text or one liner.
; CATEGORY:
; CALLING SEQUENCE:
;       extracthlp, infile, [out]
; INPUTS:
;       infile = file to extract from.    in 
;       out = output file or text array.  in 
;             If file then appended to. 
; KEYWORD PARAMETERS:
;       Keywords: 
;         /LISTFILE to list file name on terminal screen. 
;         /LINER extracts only first line in liner format. 
;         /ARRAY return a text array with help text. 
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: if outfile is not given then the 
;         help text is sent to the terminal screen. 
;         Extracthlp searches for the first occurrence 
;         of k@yword_set, assuming it is for /HELP. 
; MODIFICATION HISTORY:
;       R. Sterner, 11 Sep, 1989.
;	R. Sterner, 26 Feb, 1991 --- Renamed from extract_help.pro
;-
 
	pro extracthlp, infile, out, listfile=lst, liner=lnr, $
	  array=arr, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Extract help text from an IDL routine, full text or '+$
	    'one liner.'
	  print,' extracthlp, infile, [out]'
	  print,'   infile = file to extract from.    in'
	  print,'   out = output file or text array.  in'
	  print,'         If file then appended to.'
	  print,' Keywords:'
	  print,'   /LISTFILE to list file name on terminal screen.'
	  print,'   /LINER extracts only first line in liner format.'
	  print,'   /ARRAY return a text array with help text.'
	  print,' Notes: if outfile is not given then the'
	  print,'   help text is sent to the terminal screen.'
	  print,'   Extracthlp searches for the first occurrence'
	  print,'   of k@yword_set, assuming it is for /HELP.'
	  return
	endif
 
	;----  open input file  -------
	get_lun, inlun
	on_ioerror, err
	openr, inlun, infile
	if !version.os eq 'vms' then begin		; VMS
	  fnam = getwrd(infile,/last,delim=']')
	  fnam = getwrd(fnam,/last,delim=':')
	  fnam = strlowcase(getwrd(fnam,delim='.'))
	endif else begin				; Unix
	  fnam = getwrd(strlowcase(repchr(infile,'.')),0)
	endelse
 
	;----  open output file  --------
	if keyword_set(arr) then begin
	  out = ['']
	endif else begin
	  if n_params(0) lt 2 then begin
	    outlun = -1
	  endif else begin
	    get_lun, outlun
	    openu, outlun, out, /append
	  endelse
	endelse
 
	;-----  Search for start of help text  --------
	if not keyword_set(lnr) then begin
	  if keyword_set(arr) then begin
	    out = [out,strupcase(fnam)]
	  endif else begin
	    printf, outlun, ' '+strupcase(fnam)
	  endelse
	endif
	if keyword_set(lst) then print, ' '+strupcase(fnam)
	t = ''
	while not eof(inlun) do begin
	  readf, inlun, t
	  if strpos(strlowcase(t),'keyword_set') ge 0 then goto, next
	endwhile
	if not keyword_set(lnr) then begin
	  if keyword_set(arr) then begin
	    out = [out,' No help text found.']
	  endif else begin
	    printf, outlun,' No help text found.'
	  endelse
	endif else begin
	  if keyword_set(arr) then begin
	    out = [out, fnam + ' = No help text found.']
	  endif else begin
	    printf, outlun, fnam + ' = No help text found.'
	  endelse
	endelse
	goto, done
 
	;-----  extract and dump help text  -------
next:	while not eof(inlun) do begin
	  readf, inlun, t
	  if strpos(strlowcase(t),'print') lt 0 then goto, done
	  p1 = strpos(t,"'") & if p1 lt 0 then p1=999
	  p2 = strpos(t,'"') & if p2 lt 0 then p2=999
	  p = p1<p2
	  delim = strmid(t,p,1)
	  flag = (strlen(t)-1) eq strpos(t,'$',0) ; Continued statement?
	  t = getwrd(t, 1, delim=delim, /notrim) ; Get text between quotes.
	  t2 = ''
	  if flag then begin  ; Process a continued statement.
	    t2 = ''
	    readf, inlun, t2
	    t2 = strtrim(t2,2)
	    t2 = strmid(t2,1,strlen(t2)-2)
	  endif	  

	  t = t + t2

	  if not keyword_set(lnr) then begin
	    if keyword_set(arr) then begin
	      out = [out,t]
	    endif else begin
	      printf, outlun, '  '+t,format='(a)'
	    endelse
	  endif else begin
	    if keyword_set(arr) then begin
	      out = [out,fnam+' = '+strtrim(t,2)]
	    endif else begin
	      printf, outlun, fnam+' = '+strtrim(t,2),format='(a)'
	    endelse
	    goto, done
	  endelse
	endwhile
	goto, done
 
err:	print,' Could not open file '+infile
 
done: 	if not keyword_set(lnr) then begin
	  if not keyword_set(arr) then printf, outlun, ' '
	endif
	on_ioerror, null
	if not keyword_set(arr) then begin
	  if outlun gt 0 then free_lun, outlun
	endif else begin
	  out = out(1:*)
	endelse
	free_lun, inlun
	return
 
	end
