;+
; NAME:
;	MDOC
; PURPOSE:
;       Menu- online documentation for IDL topics ("Functional Overview", 
;	IDL-Routines & Key-words, IDL-Procedure Libraries, KIS_LIB, 
;	WINDT_LIB, and other procedure libs).
;	Provides online documentation for IDL topics. The style
;	is a cross between Unix man pages and VMS online help. The
;	help is organized in a two level hierarchy --- Level 1 is the
;	global subject, and Level 2 supplies help on subjects within
;	each global subject. If !D.WINDOW is not -1, (window system in use)
;	the mouse is used to prompt for subjects, otherwise, the normal tty
;	interface is used.
;	This is a KIS_LIB -version of MP_BASIC from WINDT-Library.
;	This routine will be called by KIS_LIB-version of MAN_PROC.
;*CATEGORY:            @CAT-# 13@
;	Help
; CALLING SEQUENCE:
;	MDOC [, REQUEST]
; INPUTS:
;	REQUEST = A scalar string containing the item on which help is desired.
;	    This string can contain 1 or two (whitespace separated) words.
;	    The first word is taken as the global topic and the second
;	    as the topic within the scope of the first. Missing words
;	    are prompted for.
; OUTPUTS:
;	Help text is sent to the standard output.
; COMMON BLOCKS:
;	None.
; RESTRICTIONS:
;	The help text is derived from the LaTeX files used to produce
;	the reference manual. However, it is not possible to produce
;	exactly the same output as found in the manual due to limitations
;	of text oriented terminals. The text used is therefore considerably
;	abbreviated. Always check the manual if the online help is
;	insufficient. 
; MODIFICATION HISTORY:
;	3 November 1988, AB
;						January, 1989, AB
;	Added ambiguity resolution, ability to handle multiple levels,
;	and support for mouse.
;
;       Added support for DOS           SNG, December, 1990
;
;					3 January 1991, AB
;	Renamed from MAN_PROC to make room for the widget version.

;				       29 July 1991, nlte
;	KIS-specific: inclusion of KIS_LIB, WINDT_LIB.
;                                      03 November, 1992, nlte
;	KIS-specific: inclusion of "Functional Overview"
;	              and other libraries.
;                                      22 March 1993, nlte
;	KIS-specific: 'WINDT_LIB' replaced by 'OTHER_CONTRIBS' in string-
;                      array lv1_top0 .
;-
;

function MPB_SELTOPIC, SUBJECT, TOPIC_ARRAY, INITIAL
; Given a subject header and an array of topics, returns a string with
; the requested topic (which may or may not be in TOPIC_ARRAY).
; Initial is the index of the initial selection to be highlighed *if*
; a window system menu is used.
on_error,2                      ;Return to caller if an error occurs
target = ''
if (!d.name eq 'X' or (!d.window ne -1)) then begin	; Use wmenu
    index = wmenu([SUBJECT, TOPIC_ARRAY], title=0, initial=initial)
;   print,'index:',index,' target:','TOPIC_ARRAY(index-1)'
    if (index ne -1) then target = TOPIC_ARRAY(index-1)
  endif else begin				; Use tty
    openw, outunit, filepath(/TERMINAL), /MORE, /GET_LUN
    printf, outunit, format = '(/,A,":",/)', SUBJECT
    printf, outunit, TOPIC_ARRAY
    close, outunit
    outunit = 0
    print, format='(/,/)'
    read, 'Enter topic for which help is desired: ', target
  endelse

return, STRCOMPRESS(STRUPCASE(target),/REMOVE_ALL)    ; Up case & no blanks
end



function MPB_TM, KEY, TOPIC_ARRAY, FOUND, OUTUNIT
; Topic MAtch. Given a string, MPB_TM returns an array of indicies into
; TOPIC_ARRAY that match into FOUND. If there is an exact match
; only its index is returned, otherwise all elements with the same prefix
; match. The number of elements that matched is returned.
; OUTUNIT is the file unit to which output should be directed.
on_error,2                      ;Return to caller if an error occurs
found = [ where(STRTRIM(TOPIC_ARRAY) eq KEY, count) ] ; Match exact string
if (count le 0) then begin	; No exact match, try to match the prefix
  FOUND = [ where(strpos(TOPIC_ARRAY, KEY) eq 0, count) ]
  if ((count le 0) or (KEY eq '')) then begin		;Found it?
    count = 0
    printf,outunit, !MSG_PREFIX, 'Nothing matching topic "',KEY,'" found."
    printf,outunit, !MSG_PREFIX, 'Enter "?" for list of available topics.'
  endif else begin
    if (count ne 1) then begin
      printf, outunit, format = "(A,'Ambiguous topic ""', A, '"" matches:')",$
	     !MSG_PREFIX, KEY
      printf, OUTUNIT, TOPIC_ARRAY(FOUND)
      endif
  endelse
endif
return, count
end



PRO MDOC, REQUEST

  on_error,1                      ; Return to main level if error occurs
  outunit = (inunit = 0)
  lv1_topic = (lv2_topic = '')

; desired order in topic-1-menu:
  lv1_top0=['FUNCT_OVERV','ROUTINES','GRAPHICS_KEYWORDS','PLOT_KEYWORDS',$
            'USERLIB','KIS_LIB','STATLIB','OTHER_CONTRIBS','WIDGETLIB']

  if (N_ELEMENTS(REQUEST)) then begin
    temp = size(request)
    if (temp(0) NE 0) then begin
      MSG = 'Argument must be scalar.'
      goto, fatal
      endif
    if (temp(1) NE 7) then begin
      MSG = 'Argument must be of type string.'
      goto, FATAL
      endif
    ; Parse into 1 or two strings
    lv1_topic = STRUPCASE(STRTRIM(STRCOMPRESS(REQUEST), 2))
    if (((blank_pos = STRPOS(lv1_topic, ' '))) ne -1) then begin
	lv2_topic = STRMID(lv1_topic, blank_pos+1, 10000L)
	lv1_topic = STRMID(lv1_topic, 0, blank_pos)
      endif
  endif


  ; This code selects the global topic
  lv1_files = STRLOWCASE(findfile(filepath(sub='help','*.help')))
;  print,'lv1_files:',lv1_files
  if !version.os ne 'DOS' then begin
    tail = STRPOS(lv1_files, '.help')
  endif else begin
    tail = STRPOS(lv1_files, '.hel')
  endelse
  n = n_elements(lv1_files)
  for i = 0, n-1 do $
	lv1_files(i) = strmid(lv1_files(i), 0, tail(i))
  for i = 0, n-1 do begin	; Strip path part off lv1_files
    case !version.os of
      'vms': begin
        j = STRPOS(lv1_files(i), ']') + 1
        lv1_files(i) = strmid(lv1_files(i), j, 32767)
      end
      'DOS': begin
        j = STRPOS(lv1_files(i), '\')
        while (j ne -1) do begin
  	  lv1_files(i) = strmid(lv1_files(i), j+1, 32767)
          j = STRPOS(lv1_files(i), '\')
        endwhile
      end
      else:  begin      ; Unix otherwise
        j = STRPOS(lv1_files(i), '/')
        while (j ne -1) do begin
  	  lv1_files(i) = strmid(lv1_files(i), j+1, 32767)
          j = STRPOS(lv1_files(i), '/')
        endwhile
      end
    endcase
  endfor
;print,'lv1_topic:',lv1_topic
;print,'lv1_files:',lv1_files
;KIS-modification start (other order for topics in menu):
;  lv1_topics = STRUPCASE(lv1_files)
  lv1_top1 = STRUPCASE(lv1_files)
  lv1_fil1=lv1_files
  ntop0=(size(lv1_top0))(1) & ntop1=(size(lv1_top1))(1)
  lv1_topics=strarr(ntop1)
  nn=-1
  for j=0,ntop0-1 do begin
    iw=where(lv1_top1 eq lv1_top0(j),ncount)
    if ncount gt 0 then begin 
       nn=nn+1 & lv1_topics(nn)=lv1_top0(j) & lv1_files(nn)=lv1_fil1(iw(0)) 
    endif
  endfor
;print,'lv1_topics (1):', lv1_topics(0:nn)
;print,'lv1_files (1):', lv1_files(0:nn)
  if nn eq -1 then lv1_topics=lv1_top1 else begin
     for j=0,ntop1-1 do begin   
       iw=where(lv1_topics eq lv1_top1(j),ncount)
       if ncount lt 1 then begin 
          nn=nn+1 & lv1_topics(nn)=lv1_top1(j) & lv1_files(nn)=lv1_fil1(j)
       endif
     endfor
  endelse
;print,'lv1_topics (2):', lv1_topics(0:nn)
;print,'lv1_files (2):', lv1_files(0:nn)
lv1_fil1=''
;KIS-modofication end 
  initial = where(lv1_topics eq 'ROUTINES')
  if (lv1_topic eq '') then $
    lv1_topic = MPB_SELTOPIC('Help categories', lv1_topics, initial(0)+1)
;print,'lv1_topic:',lv1_topic
  openw, outunit, filepath(/TERMINAL), /MORE, /GET_LUN
  if (((count=MPB_TM(lv1_topic,lv1_topics,found,outunit))) eq 0) then $
    goto, done
  free_lun, outunit & outunit = 0
  lv2_subject = (lv1_files(found))(0)		; Use the first element
;print,'count=',count,' lv2_subject = ', lv2_subject
  ; At this point, a global subject exists, process the specific subject
  lv2_topics = ''
  offset = 0L
  openr, inunit, filepath(lv2_subject+'.help', subdir='help'), /GET_LUN
  outunit = 0;
  n = 0L
  readf,inunit,n			;Read # of records
  lv2_topics = strarr(n)			;Make names
  readf,inunit,lv2_topics			;Read entire string to inunit
  offsets = long(strmid(lv2_topics, 15, 30))	;Extract starting bytes
  lv2_topics = strmid(lv2_topics,0,15)		;Isolate names
  lv2topicsu=strcompress(strupcase(lv2_topics),/remove_all) ; KIS
  ; Determine the base of the help text
  tmp = fstat(inunit)
  text_base = tmp.cur_ptr

  ; If no topic is supplied, prompt for one
  if lv2_topic eq '' then $
    lv2_topic = MPB_SELTOPIC(STRUPCASE(lv2_subject), lv2_topics, 1)

  openw, outunit, filepath(/TERMINAL), /MORE, /GET_LUN
  if (((count=MPB_TM(lv2_topic,lv2topicsu,found,outunit))) eq 0) then $
    goto, done
  str = ''
  for i = 0, count-1 do begin
    index = found(i)
    if (count ne 1) then $
      printf, outunit, lv2_topics(index), $
	      format='("***************",/,A,/,"***************")'
      POINT_LUN, inunit, text_base + offsets(index)
      readf, inunit, str		; Skip the ";+"
      readf, inunit, str
      !err = 0
      while (str NE ";-") do begin
	printf, outunit, str, ' '
	if !err ne 0 then goto, DONE
	readf, inunit, str
	endwhile
      endfor

  goto, DONE
FATAL:		; The string MSG must be set
  message, MSG, /RETURN
DONE:
  if (outunit ne 0) then FREE_LUN, outunit
  if (inunit ne 0) then FREE_LUN, inunit
end
