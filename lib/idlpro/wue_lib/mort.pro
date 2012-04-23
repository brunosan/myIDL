;+
; NAME:
;       MORT
; PURPOSE:
;       Mortgage or loan computation.
; CATEGORY:
; CALLING SEQUENCE:
;       mort, amt, yi, ny, pmt
; INPUTS:
;       amt = amount borrowed.            in 
;       yi = yearly interset rate in %.   in 
;       ny = number of years for loan.    in 
;       pmt = monthly payment.            in 
;         May be an array, see notes. 
; KEYWORD PARAMETERS:
;       Keywords: 
;         SUMMARY=sm  return summary array: 
;           [total paid, cost of credit, cost as %, times original, 
;            months, required monthly payment] 
;           If any payment < required value then sm(0) is returned as -1. 
;         FILE=f  output file. 
;         /NOLIST suppresses listing. 
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Note: pmt may be an array.  If not enough 
;         payments the last value is used repeatedly. 
;         Mort is run interactively if no arguments are given. 
; MODIFICATION HISTORY:
;       R. Sterner, 5 Jul, 1990
;-
 
	pro mort, amt0, yi0, ny, pmt, help=hlp, summary=sm, $
	  file=file, nolist=nolst
 
	if keyword_set(hlp) then begin
	  print,' Mortgage or loan computation.'
	  print,' mort, amt, yi, ny, pmt'
	  print,'   amt = amount borrowed.            in'
	  print,'   yi = yearly interset rate in %.   in'
	  print,'   ny = number of years for loan.    in'
	  print,'   pmt = monthly payment.            in'
	  print,'     May be an array, see notes.'
	  print,' Keywords:'
	  print,'   SUMMARY=sm  return summary array:'
	  print,'     [total paid, cost of credit, cost as %, times original,'
	  print,'      months, required monthly payment]'
	  print,'     If any payment < required value then sm(0) is -1.'
	  print,'   FILE=f  output file.'
	  print,'   /NOLIST suppresses listing.'
	  print,' Note: pmt may be an array.  If not enough'
	  print,'   payments the last value is used repeatedly.'
	  print,'   Mort is run interactively if no arguments are given.'
	  return
	endif
 
	;-------  Must prompt for some or all parameters  ---------------
	if n_elements(amt0) eq 0 then begin
	  print,' '
	  print,' ---==< Mortgage computation >==---'
	  print,' '
	  amt0 = ''
	  read,' Enter loan amount: ',amt0
	  if amt0 eq '' then return
	  amt0 = amt0 + 0.
	endif
 
	if n_elements(yi0) eq 0 then begin
	  yi0 = ''
	  read,' Enter yearly interest rate: ',yi0
	  if yi0 eq '' then return
	  yi0 = yi0 + 0.
	endif
 
	if n_elements(ny) eq 0 then begin
	  ny = ''
	  read,' Enter number of years for loan: ',ny
	  if ny eq '' then return
	  ny = ny + 0.
	endif
 
	;------  compute required payment  ---------
	yi = yi0/100.				; yearly rate as a fraction.
	amt = amt0				; Loan amount.
	mi = yi/12.				; Monthly interest.
	nm = ny*12.				; Number of months of loan.
 
	cpmt = amt*(mi/(1.-1./(1.+mi)^nm))	; Computed monthly payment.
	cpmt = long(cpmt*100. + .5)/100.	; Round to nearest penny.
 
	;-----  if no payment given prompt  -------------
	if n_elements(pmt) eq 0 then begin
ploop:	  pmt = ''
	  print, cpmt, format="(' Monthly payment = ',f8.2)"
	  read,' To change payment enter new amount (RET for same): ',pmt
	  if pmt eq '' then pmt = cpmt
	  pmt = pmt + 0.
	  if pmt lt cpmt then begin
	    print,cpmt,format="(' You must pay at least ',f8.2)"
	    goto, ploop
	  endif
	endif
 
	;-------  Handle payment as an array  ---------
	pmt = array(pmt)		; Force to be an array.
	if min(pmt) lt cpmt then begin
	  print,' Error in mort: all payments must be at the required value.'
	  sm = [-1.]
	  return
	endif
	lst = n_elements(pmt) - 1	; Last element.
 
	;-------  handle summary printout  ---------
	sflag = 0			; Summary only flag. Def = print all.
	if (n_params(0) lt 4) then begin
	  sflag = ''
	  read,' Print summary only? y/n: ',sflag
	  sflag = strlowcase(sflag) eq 'y'
	endif
 
	;------  handle output file  -----------
	if n_elements(file) ne 0 then begin
 	  get_lun, lun
	  openw, lun, file
	  print,' Output going to file '+file+' . . .'
	endif else begin
	  lun = -1
	endelse
 
	;-------  init values  -----------
	mon = 0				; Month counter.
	total = 0.			; Total payed.
	pmt_a = 0.			; Total Payment (may vary).
	pmti = 0.			; Amount of payment that is interest.
	pmtp = 0.			; Amount of payment that is principal.
 
	;--------  List initial conditions ------------
	if not keyword_set(nolst) then begin
	  printf,lun, amt0, yi0, ny, cpmt, $
	    format="(//,' Loan amount = ',f10.2,/,"+$
            "' Yearly interest rate = ',"+$
	    "f6.3,'%',/,' Number of years = ',f4.1,/,"+$
	    "' Required monthly payment = ',f8.2)"
	  lo = min(pmt)
	  hi = max(pmt)
	  if lo ne hi then begin
	    printf,lun,lo,hi,format="(' Actual monthly payment "+$
	      "varies from = ',f8.2,' to ',f8.2,//)"
	  endif else begin
	    printf,lun,lo,format="(' Actual monthly payment = ',f8.2,//)"
	  endelse
	  printf, lun, ' '
	endif
 
	;--------  List table heading  ---------
	if (not keyword_set(nolst)) and (sflag ne 1) then begin
	  printf,lun,' Mon   Payment  Interest  Principal  Remaining     Total'
	endif
 
	;---------  Computation loop  ---------------
loop:
	if (not keyword_set(nolst)) and (sflag ne 1) then begin
	  printf,lun, mon, pmt_a, pmti, pmtp, amt, total, $
	    format="(' ',i3,'  ',f8.2,'  ',f8.2,'  ',f9.2"+$
	           ",'  ',f10.2,'  ',f10.2)"
	endif
 
	if amt eq 0 then goto, done
	pmt_a = pmt(mon<lst)		; Pull out payment.
	mon = mon + 1			; inc mon
	pmti = amt*mi			; interest.
	pmtp = pmt_a - pmti		; Principal
	if pmt_a gt amt then begin	; Last pmt.
	  pmt_a = amt			; Pay all.
	  pmtp = pmt_a			; All principal
	endif
	amt = amt - pmtp		; reduce owed.
	total = total + pmt_a		; Add to total.
	goto, loop
 
	;------  computation complete  ------------
done:	if (not keyword_set(nolst)) then begin
	  printf,lun,' '
	  printf,lun,total,format="(' Summary:',/,' Total paid = ',f12.2,"+$
	    "' dollars.')"
	  printf,lun,total-amt0, format="(' Cost of credit = ',f12.2,"+$
	    "' dollars.')"
	  printf,lun,100.*(total-amt0)/amt0, format="(' Cost of credit = ',"+$
	    "f7.2,' % of amount borrowed.')"
	  printf,lun,total/amt0, format="(' Total = ',f7.4,"+$
	    "' times original loan amount.')"
	  printf,lun,mon, format="(' Number of months = ',i5)"
	endif
 
	if lun gt 0 then begin
	  free_lun, lun
	  print,' Output file ' + file + ' complete.'
	endif
 
	sm = [total,total-amt0,100.*(total-amt0)/amt0,total/amt0,mon,cpmt]
 
	return
	end
