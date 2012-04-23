function xshift, kfft0, dx
;+
;
;	purpose:  FFT frequency space shift theorem.
;
;		For example for vector xxxx0:
;			dx = 5.
;			kfft0 = fft(xxxx0,-1)
;			kfft1 = xshift( kfft0, dx )
;			xxxx1 = float( fft(kfft1,1) )
;		Should get same as:
;			xxxx1 = shift( xxxx0, 5. )
;
;	notes & restrictions:
;
;		1) kfft0 is conjugate symmetric about Nyquist frequency.
;		2) Conjugate symmetry assumed but not checked.
;		3) Assume kfft0 has only one dimension greater than 1.
;		4) Assume standard -1 direction for the real to complex
;		   transtorm.  IDL's fft(xxxx0,-1) has the -1.
;		5) Use -dx for opposite of note (4).
;		6) Returned value for xshift() is a complex vector.
;		7) IDL's float() extracts real part; strange mnemonic.
;
;	author:  Paul Seagraves 92.05.11; minor mod's by Rob Montgomery
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 2 then begin
	print
	print, "usage:  ret = xshift(kfft0, dx)"
	print
	print, "	FFT frequency space shift theorem."
	print
	print, "     - kfft0 is conjugate symmetric about Nyquist frequency."
	print, "     - Conjugate symmetry assumed but not checked."
	print, "     - Assume kfft0 has only one dimension greater than 1."
	print, "     - Assume standard -1 direction for the real to complex"
	print, "       transtorm.  IDL's fft(xxxx0,-1) has the -1."
	print, "     - Use -dx for opposite of previous note."
	print, "     - Returned value for xshift() is a complex vector."
	print, "     - IDL's float() extracts real part; strange mnemonic."
	print
	return, 0
endif
;-
		;
		;Save phase in common for when it doesn't change call-to-call.
		;
common com_xshift, sav_np, sav_dx, phase
		;
		;Check if sav_np is defined.
		;Initialize sav_np and sav_dx on first entry.
		;
if sizeof(sav_np, 1) eq 0 then begin
	sav_np = -1
	sav_dx = 0.0
endif
		;
		;Set up an array to be returned as functional value.
		;Eliminate any dimension of size 1.
		;
kfft1 = reform(kfft0)
		;
		;Check that kfft0 has only one dimension greater than one.
		;
if (sizeof(kfft1, 0) ne 1) or (sizeof(kfft1, 1) lt 2) then begin
	print, '    xshift(ARG,dx): ARG must have one and only'
	print, '    one dimension greater than one'
	stop
endif
		;
		;Get size of input array.
		;
np = sizeof(kfft1, 1)
		;
		;Nyquist frequency.
		;
nq = np/2
		;
		;Set phase if array length or shift has changed.
		;
if (np ne sav_np) or (dx ne sav_dx) then begin
	sav_np = np
	sav_dx = dx
		;
		;Exponent of phase of the shift except for sqrt(-1).
		;
	k = -2.*!PI * findgen(nq+1)*dx / np
		;
		;Set complex phase.
		;
	phase = complex( cos(k), sin(k) )
		;
endif
		;
		;Apply phase shift from 0 to Nyquist frequency.
		;
kfft1(0:nq) = phase * kfft1(0:nq)
		;
		;Set conjugate symmetry about Nyquist frequency.
		;
kfft1(np-nq:np-1) = conj( reverse( kfft1(1:nq) ) )
		;
		;Return the result as the function value.
		;
return, kfft1
		;
end
