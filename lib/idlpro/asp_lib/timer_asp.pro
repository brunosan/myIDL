function timer, tm, dummy, init=init
;+
;
;	function:  timer
;
;	purpose:  return elapsed time in int array of [hours,mins,secs]
;
;	author:  rob@ncar, 10/93
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() eq 2 then begin
	print
	print, "usage:  t = timer(/init)	; 1st time"
	print, "	t = timer()		; other times"
	print, "	t = timer(tm)		; other times (tm returned)"
	print
	print, "	Return elapsed time in int array of [hours,mins,secs]."
	print
	print, "	Arguments"
	print, "		tm	- optional variable to contain the"
	print, "			  total # of elapsed minutes (float)"
	print
	print, "	Keywords"
	print, "		init	- initialize the timer"
	print
	print
	print, "   ex:  print, timer(/init)"
	print, "	; (do stuff) ..."
	print, "	print, timer()"
	print
	return, 0
endif
;-
;
;	Specify timer common block.
;
common timer_comm, time0
;
;	If 'init' set, initialize time zero and return.
;
if keyword_set(init) then begin
	tm = 0.0
	time0 = systime(1)
	return, [0, 0, 0]
endif
;
;	Else, calculate and return elapsed time.
;
ts = systime(1) - time0		; total time elapsed in seconds (float)
tm = ts / 60.0			; total time elapsed in minutes (float)
th = tm / 60.0			; total time elapsed in hours   (float)
;
hours = fix(th)
mins  = fix(tm - hours*60)
secs  = fix(round(ts) - long(hours)*3600L - long(mins*60))
;
return, [hours, mins, secs]
;
end
