FUNCTION power1,scan
;+
; NAME:
;	POWER1
; PURPOSE:
;	Returns power spectrum of a 1-dim scan.
;*CATEGORY:            @CAT-#  4 10@
;	Power Spectra , FFT
; CALLING SEQUENCE:
;	power = POWER1 (scan)
; INPUTS:
;	scan  : real-vector (1-dim) with data.
; OUTPUTS:
;	power : power-spectrum (1-dim real vector, size = size of scan)
;	        = | FT{scan} | **2 after linear trend beeing removed.
; COMMON BLOCKS:
;	none
; SIDE EFFECTS:
;	none
; RESTRICTIONS:
;	none
; PROCEDURE:
;	linear trend (least square fit using POLY_FIT from IDL-
;	USER's Library) subtraction; Fourier-transform using IDL-
;	routine FFT); square of absolute Fourier-value.
; MODIFICATION HISTORY:
;	1990-03-17 H.S., KIS  (power.pro)
;	1991-08-09 H.S., KIS : renamed to power1
;-
on_error,1
sz=size(scan)
n=sz(1)
c1=poly_fit(findgen(n),scan,1,fit)
fit=scan-fit
p=abs(fft(fit,-1))^2
return,p
end
