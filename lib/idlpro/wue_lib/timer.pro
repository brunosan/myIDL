;+
; NAME:
;       TIMER
; PURPOSE:
;       Measure elapsed time between calls.
; CATEGORY:
; CALLING SEQUENCE:
;       timer, [dt]
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords: 
;         /START  starts timer. 
;         /STOP   stops timer (actually updates elapsed time). 
;         /PRINT  prints timer report. 
;         NUMBER = n. Select timer number to use (default = 0).
;	     Timer numbers 0 through 9 may be used.
;	  COMMENT = cmt_text. Causes /PRINT to print:
;           cmt_text elapsed time: hh:mm:ss (nnn sec)
; OUTPUTS:
;       dt = optionally returned elapsed time in seconds.    out 
; COMMON BLOCKS:
;       timer_com
; NOTES:
;       Notes: 
;        Examples: 
;        timer, /start  use this call to start timer. 
;        timer, /stop, /print, dt   use this call to stop timer 
;          and print start, stop, elapsed time.  This example also 
;          returns elapsed time in seconds. 
;        Timer must be started before any elapsed time is available. 
;        Timer may be stopped any number of times after starting once, 
;        and the elapsed time is the time since the last timer start. 
;	 timer, /start, number=5   starts timer number 5.
;	 timer, /stop, /print, number=5   stops timer number 5
;        and prints result.
; MODIFICATION HISTORY:
;       R. Sterner, 17 Nov, 1989
;-
 
	pro timer, dt, start=strt, stop=stp, print=prnt, number=numb, $
	  comment=cmt, help=hlp
 
	common timer_com, t1, t2, dtc
 
	if keyword_set(hlp) then begin
hh:	  print,' Measure elapsed time between calls.'
	  print,' timer, [dt]'
	  print,'   dt = optionally returned elapsed time in seconds.    out'
	  print,' Keywords:'
	  print,'   /START  starts timer.'
	  print,'   /STOP   stops timer (actually updates elapsed time).'
	  print,'   /PRINT  prints timer report.'
	  print,'   NUMBER = n. Select timer number to use (default = 0).'
	  print,'      Timer numbers 0 through 9 may be used.'
	  print,'   COMMENT = cmt_text. Causes /PRINT to print:'
	  print,'     cmt_text elapsed time: hh:mm:ss (nnn sec)'
	  print,' Notes:'
	  print,'  Examples:'
	  print,'  timer, /start  use this call to start timer.'
	  print,'  timer, /stop, /print, dt   use this call to stop timer'
	  print,'    and print start, stop, elapsed time.  This example also'
	  print,'    returns elapsed time in seconds.'
	  print,'  Timer must be started before any elapsed time is available.'
	  print,'  Timer may be stopped any number of times after starting '+$
	    'once, and'
	  print,'  the elapsed time is the time since the last timer start.'
	  print,'  timer, /start, number=5   starts timer number 5.
	  print,'  timer, /stop, /print, number=5   stops timer number 5'
	  print,'  and prints result.'
	  return
	endif

	if n_elements(t1) eq 0 then begin
	  t1 = strarr(10)
	  t2 = strarr(10)
	  dtc = fltarr(10)
	endif
 
	c = 0		; Keyword detected.
	num = 0
	if keyword_set(numb) then num = numb		; Default timer number.
	snum = strtrim(num,2)
 
	if keyword_set(strt) then begin
	  t1(num) = systime()
	  c = 1
	endif
 
	if keyword_set(stp) or (n_params(0) gt 0) then begin
	  if t1(num) eq '' then begin
	    print,' Error: Timer '+snum+' has not been started.'
	    print,' Do  timer, /start  first.'
	    return
	  endif
	  t2(num) = systime()
	  dt = secstr(getwrd(t2(num),3)) - secstr(getwrd(t1(num),3))
	  dtc(num) = dt
	  c = 1
	endif
 
	if keyword_set(prnt) then begin
	  if t1(num) eq '' then begin
	    print,' Error: Timer '+snum+' has not been started.'
	    print,' Do  timer, /start  first.'
	    return
	  endif
	  if t2(num) eq '' then begin
	    print,' Error: Timer '+snum+$
	      ' must be stopped before elapsed time is available.'
	    print,' Do  timer, /stop, /print'
	    return
	  endif
	  c = 1
	  if not keyword_set(cmt) then begin
	    print,' Timer '+snum+' started: '+t1(num)
	    print,' Timer '+snum+' stopped: '+t2(num)
	    print,' Elapsed time: ',strsec(dtc(num))+' ('+$
	      strtrim(fix(dtc(num)),2)+' sec)'
	  endif else begin
	    print,cmt+' elapsed time: ',strsec(dtc(num))+' ('+$
	      strtrim(fix(dtc(num)),2)+' sec)'
	  endelse
	endif
 
	if c ne 1 then goto, hh
 
	return
	end
