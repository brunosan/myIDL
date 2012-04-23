;+
; NAME:
;       SECSTR
; PURPOSE:
;       Convert a time string to seconds.
; CATEGORY:
; CALLING SEQUENCE:
;       s = secstr(tstr)
; INPUTS:
;       tstr = time string.          in
;         Scalar or string array.
; KEYWORD PARAMETERS:
; OUTPUTS:
;       s = seconds after midnight.  out
; COMMON BLOCKS:
; NOTES:
;       Note: time string must have the following format:
;         [DDD/]hh:[mm[:ss[:nnn/ddd]]]
;         where hh=hours, mm=minutes, ss=seconds, DDD=days,
;         nnn/ddd=a fraction.
;         Examples: 12:, 12:34, 12:34:10, 2/12:34:10,
;         2/12:34:10:53/60, 12:34:10:53/60
; MODIFICATION HISTORY:
;       Written R. Sterner, 10 Jan, 1985.
;       Johns Hopkins University Applied Physics Laboratory.
;       Added day: 21 Feb, 1985.
;       Added negative time: 16 Apr, 1985.
;       RES 18 Sep, 1989 --- converted to SUN.
;       R. Sterner 2 Jan, 1990 --- allowed arrays.
;-
 
	FUNCTION SECSTR,TSTR0, help=hlp
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Convert a time string to seconds.'
	  print,' s = secstr(tstr)'
	  print,'    tstr = time string.          in'
	  print,'      Scalar or string array.'
	  print,'    s = seconds after midnight.  out'
	  print,' Note: time string must have the following format:'
	  print,'   [DDD/]hh:[mm[:ss[:nnn/ddd]]]'
	  print,'   where hh=hours, mm=minutes, ss=seconds, DDD=days,'
	  print,'   nnn/ddd=a fraction.'
	  print,'   Examples: 12:, 12:34, 12:34:10, 2/12:34:10,'
	  print,'   2/12:34:10:53/60, 12:34:10:53/60'
	  return, -1
	endif
 
	aflag = isarray(tstr0)		; Is argument an array? (0=no, 1=yes).
	tstra = array(tstr0)		; Force it to be an array.
	nnt = n_elements(tstra)		; Number of elements.
	sa = dblarr(nnt)		; Out array of seconds after midnight.
 
	for ii = 0, nnt-1 do begin	; Loop through input time strings.
 
	tstr = tstra(ii)		; Pull out ii'th time string.
;-------  first search for day  -----------
	TDY = 0.			; default is none.
	IOFF = 0			; no offset for other items.
	LMINUS = STRPOS(TSTR,'-')	; look for negative time.
	T = STRESS(TSTR,'R',0,'-',' ')  ; replace it by a space.
	LS = STRPOS(T,'/')		; look for a '/'
	T = STRESS(T,'R',0,':',' ')	; replace ':' with spaces.
	T = STRESS(T,'R',0,'/',' ')	; replace '/' with space.
	IF LS GT 0 THEN T = STREP(T,'F',999,'      0')  ; add 0 to end.
	FNDWRD,T,NWDS,LOC,LEN		; locate words.
	IF NWDS LT 2 THEN GOTO, GET     ; only 0 or 1 item, assume hrs.
	IF (LS GT LOC(0)) AND (LS LT LOC(1)) THEN BEGIN   ; found day.
	  TDY = GETWRD(T,0)		; get day.
	  IOFF = 1			; must offset other items by 1.
	ENDIF
 
GET:	TH = GETWRD(T,0+IOFF)		; Pick off hours.
	TM = GETWRD(T,1+IOFF)		; Pick off minutes.
	TS = GETWRD(T,2+IOFF)		; Pick off seconds.
	TN = GETWRD(T,3+IOFF)		; Pick off num of fract of a second.
	TD = GETWRD(T,4+IOFF)		; Pick off den of fract of a second.
	IF TD EQ 0 THEN TD = 1		; I fno denomiator then use 1.
 
	S = 86400.D0*TDY + 3600.D0*TH + 60.D0*TM + $	; convert to seconds.
	      DOUBLE(TS) + DOUBLE(TN)/DOUBLE(TD)
	IF LMINUS NE -1 THEN S = -S			; was a negative time.
 
	sa(ii) = s
 
	endfor
 
	if aflag eq 0 then sa = sa(0)	; If scalar input give scalar output.
 
	RETURN, sa
 
	END
