pro tv_fft,z

ns=size(z)
z=congrid(z,256,256,/interp)
;WINDOW, XSIZE=540, YSIZE=540  
;LOADCT, 39  
TVSCL, z, 10, 270  
  
; Compute the two-dimensional FFT.  
f = FFT(z)  
logpower = ALOG10(ABS(f)^2)   ; log of Fourier power spectrum.  
TVSCL, logpower, 270, 270  
  
; Compute the FFT only along the first dimension.  
f = FFT(z, DIMENSION=1)  
logpower = ALOG10(ABS(f)^2)   ; log of Fourier power spectrum.  
TVSCL, logpower, 10, 10  
  
; Compute the FFT only along the second dimension.  
f = FFT(z, DIMENSION=2)  
logpower = ALOG10(ABS(f)^2)   ; log of Fourier power spectrum.  
TVSCL, logpower, 270, 10  


end