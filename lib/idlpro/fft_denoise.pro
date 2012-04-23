;apply FFT filet: this filter
;calculates the FFT of a spectrum. A
;selected region in the frequency-bins
;is then smoothed using a median function.
;Useful for th noise problem with TIP2
;in October 2005
function fft_denoise,im
  
  sz=size(im)
  rg=[170,200]                  ;this is the range where in the fft of
                                ;the noisy stokes profile an
                                ;additional peak appears.
                                ;The position of this peak might vary
                                ;with, eg., temperature or integration
                                ;time. we used 300 ms
  
  med=9                         ;median smooth value for the region rg
  
                                ;apply filter only for profiles q,u,v
  nbin=sz(2)
  for ip=1,3 do for iy=0,sz(3)-1 do begin
    fv=fft(reform(im(ip,*,iy)),-1) 
    fv(rg(0):rg(1))=median(fv(rg(0):rg(1)),med)
    fv(nbin-1-rg(1):nbin-1-rg(0))= $
      median(fv(nbin-1-rg(1):nbin-1-rg(0)),med)
    im(ip,*,iy)=fft(fv,1)
  endfor
  print,'f',format='(a,$)'    ;indicate that FFT was applied
  
  return,im
end
