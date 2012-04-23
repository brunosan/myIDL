;+
; NAME:
;       FACTOR
; PURPOSE:
;       Find prime factors of a given number.
; CATEGORY:
; CALLING SEQUENCE:
;       factor, x, p, n
; INPUTS:
;       x = Number to factor.		in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       p = Array of prime numbers.		out 
;       n = Number of each element of p.	out 
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner.  4 Oct, 1988.
;       RES 25 Oct, 1990 --- converted to IDL V2.
;       Johns Hopkins University Applied Physics Laboratory.
;-
 
	PRO FACTOR, X, P, N, help=hlp
 
	IF (N_PARAMS(0) LT 3) or keyword_set(hlp) THEN BEGIN
	  PRINT,' Find prime factors of a given number.'
	  PRINT,' factor, x, p, n'
	  PRINT,'   x = Number to factor.		in'
	  PRINT,'   p = Array of prime numbers.		out'
	  PRINT,'   n = Number of each element of p.	out'
	  RETURN
	ENDIF
 
	S = SQRT(X)		; Only need primes up to sqrt(X).
	G = FIX(50 + 0.13457*S)	; Upper limit of # primes up to S.
	P = PRIME(G)		; Find G primes.
	N = INTARR(N_ELEMENTS(P))	; Divisor count.
 
	T = LONG(X)		; working number.
	I = 0			; index of test prime.
 
LOOP:	PT = P(I)				; pull test prime.
	T2 = LONG(T/PT)				; result after division.
	IF T EQ T2*PT THEN BEGIN		; check if it divides.
	  N(I) = N(I) + 1			; yes, count it.
	  T = T2				; result after division.
	  IF T2 EQ 1 THEN GOTO, DONE		; check if done.
	  GOTO, LOOP				; continue.
	ENDIF ELSE BEGIN
	  I = I + 1				; try next prime.
	  IF I GE G THEN GOTO, LAST		; Nothing up to sqrt works.
	  GOTO, LOOP				; continue.
	ENDELSE
 
LAST:	P = [P,T]			; Residue was > sqrt, must be prime.
	N = [N,1]			; Must occur only once. (else < sqrt).
 
DONE:	W = WHERE(N GT 0)
	N = N(W)			; Trim excess off tables.
	P = P(W)
	RETURN
	END
