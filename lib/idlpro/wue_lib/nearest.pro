;+
; Name: NEAREST.PRO
; Purpose: For a target value, return value nearest
;   to a multiple of given step.  Also optionally
;   the two multiples surrounding.
; Category: Math.
; Calling sequence: V = NEAREST( S, T, [ VLO, VHI ])
; Inputs:
;   S = step size.
;   T = target value.
; Outputs:
;   V = multiple of S nearest T.
; Optional output parameters:
;   VLO = largest multiple of S <= T.
;   VHI = smallest multiple of S > T.
; Restrictions:
; Procedure:  Uses MOD.  Corrects for problems with negative values.
; Modification history:  R. Sterner  10 Apr, 1986.
;	Johns Hopkins University Applied Physics Laboratory.
;-

	FUNCTION NEAREST, S, T, VLO, VHI,help=h

	if keyword_set(h) then begin
	  print,'For a target value, return value nearest to a multiple of given step'
	  print,'V = NEAREST( S, T, [ VLO, VHI ])'
	  print,'  S = step size.			in'
	  print,'  T = target value.			in'
	  print,'  VLO = largest multiple of S <= T.	in (optional)'
	  print,'  VHI = smallest multiple of S > T.	in (optional)'
	  print,'  V = multiple of S nearest T.		out'
	  return,-1
	endif

	D = T MOD S

	V = T - D

	IF T < 0 THEN BEGIN
	  VHI = V
	  VLO = VHI - S
	ENDIF ELSE BEGIN
	  VLO = V
	  VHI = VLO + S
	ENDELSE

	IF (ABS(T-VLO) LT ABS(T-VHI)) THEN RETURN, VLO ELSE RETURN, VHI

	END
