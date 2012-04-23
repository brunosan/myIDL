;+
; NAME:
;       NEXTITEM
; PURPOSE:
;       Return next line from a file, ignore comments & null lines.
; CATEGORY:
; CALLING SEQUENCE:
;       itm = nextitem(lun, [txt])
; INPUTS:
;       lun = unit number of opened text file.     in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       txt = optionally returned complete line.   out
;       itm = first word in text line.             out
; COMMON BLOCKS:
; NOTES:
;       Note: Useful to read control files.  First item on each
;         line is returned. Items may be delimited by spaces,
;         commas, or tabs.  Null lines and comments are ignored.
;         Comment lines have * as the first character in the line.
;         If a line contains only a single space it is considered
;         a null line. The entire text line may optionally be
;         returned.  It has commas and tabs converted spaces,
;         ready for GETWRD.  On EOF a null string is returned.
; MODIFICATION HISTORY:
;       Written by R. Sterner, 19 June, 1985.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES  5 Nov, 1985 --- returned TXT.
;-
 
	FUNCTION NEXTITEM,LUN,TXT, help = h
 
	if (n_params(0) lt 1) or keyword_set(h) then begin
	  print,' Return next line from a file, ignore comments & null lines.'
	  print,' itm = nextitem(lun, [txt])'
	  print,'   lun = unit number of opened text file.     in'
	  print,'   txt = optionally returned complete line.   out'
	  print,'   itm = first word in text line.             out'
	  print,' Note: Useful to read control files.  First item on each'
	  print,'   line is returned. Items may be delimited by spaces,'
	  print,'   commas, or tabs.  Null lines and comments are ignored.'
	  print,'   Comment lines have * as the first character in the line.'
	  print,'   If a line contains only a single space it is considered'
	  print,'   a null line. The entire text line may optionally be'
	  print,'   returned.  It has commas and tabs converted spaces,'
	  print,'   ready for GETWRD.  On EOF a null string is returned.'
	  return, -1
	endif
 
	TXT = ''
LOOP:	IF EOF(LUN) THEN GOTO, ENDFILE
	READF,LUN,TXT
	IF TXT EQ "" THEN GOTO, LOOP
	IF TXT EQ " " THEN GOTO, LOOP
	IF STRSUB(TXT,0,0) EQ '*' THEN GOTO, LOOP
	TXT = STRESS(TXT,'R',0,',',' ')			; Replace commas.
	TXT = STRESS(TXT,'R',0,'	',' ')		; Replace tabs.
	RETURN, GETWRD(TXT,0)
 
ENDFILE:
	RETURN, ""
 
	END
