;+
; NAME:
;       PRIME
; PURPOSE:
;       Return an array with the specified number of prime numbers.
; CATEGORY:
; CALLING SEQUENCE:
;       p = prime(n)
; INPUTS:
;       n = desired number of primes.    in 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       p = resulting array of primes.   out 
; COMMON BLOCKS:
;       PRIME_COM
; NOTES:
;       Note: Primes that have been found in previous calls are 
;         remembered and are not regenerated. 
; MODIFICATION HISTORY:
;       RES  17 Oct, 1985.
;-
 
	FUNCTION PRIME,N, help=hlp
 
	COMMON PRIME_COM, MAX, PMAX
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Return an array with the specified number of prime numbers.'
	  print,' p = prime(n)'
	  print,'   n = desired number of primes.    in'
	  print,'   p = resulting array of primes.   out'
	  print,' Note: Primes that have been found in previous calls are'
	  print,'   remembered and are not regenerated.'
	  return, -1
	endif
 
	IF N_ELEMENTS(MAX) EQ 0 THEN MAX = 0	; Make MAX defined.
	IF N LE MAX THEN RETURN, PMAX(0:N-1)	; Enough primes in memory.
	P = LONARR(N)				; Need to find primes.
	IF MAX EQ 0 THEN BEGIN			; Have none now. Start with 8.
	  P(0) = [2,3,5,7,11,13,17,19]
	  IF N LE 8 THEN RETURN, P(0:N-1)	; Need 8 or less.
	  I = 8					; Need more than 8.
	  T = 19L
	ENDIF ELSE BEGIN			; Start with old primes.
	  P(0) = PMAX
	  I = MAX
	  T = P(MAX-1)
	ENDELSE
 
	IA = 0
	ADD = [2,2,4,2]
LOOP:	IF I EQ N THEN BEGIN
	  MAX = N
	  PMAX = P
	  RETURN, P
	ENDIF
LOOP2:	T = T + ADD(IA)
	IA = IA + 1
	IF IA EQ 4 THEN IA = 0
	IT = 1
LOOP3:	PR = P(IT)
	PR2 = PR*PR
	IF PR2 GT T THEN BEGIN
	  I = I + 1
	  P(I-1) = T
	  GOTO, LOOP
	ENDIF
	IF PR2 EQ T THEN GOTO, LOOP2
	IF (T MOD PR) EQ 0 THEN GOTO, LOOP2
	IT = IT + 1
	GOTO, LOOP3
	END
