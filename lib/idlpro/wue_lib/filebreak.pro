;+
; NAME:
;       FILEBREAK
; PURPOSE:
;       Breaks a file name into components.
; CATEGORY:
; CALLING SEQUENCE:
;       FILEBREAK, NAME, DIR, FILE, EXT
; INPUTS:
;       NAME = file name to process (form DDD:[ddd]FFFF.XXX).   in.
; KEYWORD PARAMETERS:
; OUTPUTS:
;       DIR = directory (DDD:[ddd], null if none).              out.
;       FILE = file name (FFFF).                                out.
;       EXT = extension (XXX, null if none).                    out.
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       Ray Sterner,  16 APR, 1985.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES, Added DIR 29 May, 1985.
;-
 
	PRO FILEBREAK, NAME, DIR, FILE, EXT, help=hlp
 
	IF (N_PARAMS(0) EQ 0) or keyword_set(hlp) THEN BEGIN
	  PRINT,' Breaks a file name into components.
	  PRINT,' FILEBREAK, NAME, DIR, FILE, EXT
	  PRINT,'   NAME = file name to process (form DDD:[ddd]FFFF.XXX).  in
	  PRINT,'   DIR = directory (DDD:[ddd], null if none).             out
	  PRINT,'   FILE = file name (FFFF).                               out
	  PRINT,'   EXT = extension (XXX, null if none).                   out
	  RETURN
	ENDIF 
 
	DIR = ''
	EXT = ''
	FILE = NAME
	L1 = STRPOS(NAME,']')
	IF L1 EQ -1 THEN L1 = STRPOS(NAME,':')
	L = STRPOS(NAME,'.',L1+1)
	IF L1 NE -1 THEN BEGIN
	  DIR = STRSUB(NAME,0,L1)
	  FILE = STRSUB(NAME,L1+1,999)
	ENDIF
	IF L EQ -1 THEN RETURN
	FILE = STRSUB(NAME,L1+1,L-1)
	EXT = STRSUB(NAME,L+1,STRLEN(NAME)-1)
	RETURN
	END
