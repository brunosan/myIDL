pro  mve,var
;+
; ROUTINE:                 mve
;
; AUTHOR:                 Terry Figel, ESRG, UCSB 10-21-92
;
; CALLING SEQUENCE:        mve,var
;
; INPUT:   
;              var         an array
;
; PURPOSE:                 print out the max min mean and std deviation of var
;-
std=stdev(var,mean)
nn=n_elements(var)
print,form='(5a15)','n_elements','mean','std dev','minimum','maximum'
print,form='(i15,4g15.5)',nn,mean,std,min(var,max=max),max
return
end

