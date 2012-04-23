PRO statist,a
;+
; NAME:
;	STATIST
; PURPOSE:
; Invokes IDL-routine "help",
;	prints minimum, maximum, r.m.s., and arithmetic mean 
;	of data.
;*CATEGORY:            @CAT-# 33@
;	Statistics
; CALLING SEQUENCE:
;	STATIST,data
; INPUTS:
;	data : 1- or more-dimensional array containing numerical
;	       data.
; OUTPUTS:
;	none
; COMMON BLOCKS:
;	none
; SIDE EFFECTS:
;	print line to standard output.
; RESTRICTIONS:
;	none
; PROCEDURE:
;	straight (using IDL-routines help,min,max,stdev)
; MODIFICATION HISTORY:
;	nlte, 1990-03-17 
;	nlte, 1992-02-05  on_error
;-
on_error,1
help,a
print,'min',min(a),' max',max(a),' rms',stdev(a,m),' mean',m
return
end
