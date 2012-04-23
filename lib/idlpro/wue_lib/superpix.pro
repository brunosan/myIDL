pro superpix,a,binsz,abin,sbin,align=align,compare=compare
;+
; ROUTINE:           superpix
;
; USEAGE:            superpix, a, binsz, abin, sbin
;                    superpix, a, binsz, abin, sbib, /align, /compare
;
; PURPOSE:           compute super pixel average and standard deviation
;                    of a scene
;
; INPUT:
;         a          image array
;
;         binsz      A scalar specifying the number of horizontal and 
;                    vertical sub-pixels in one super pixel. 
;                    BINSZ must be an odd integer.
;
;         align      If set, output arrays are REBINed back up to the 
;                    original size and output array cell centers are aligned
;                    with input array cell centers.
;
;         compare    if set, compare A and ABIN with the FLICK procedure
;
; OUTPUT:
;         abin       mean value of superpixel at superpixel cell centers
;
;         sbin       standard deviation of superpixel at superpixel
;                    cell centers.
;
; AUTHOR:            Paul Ricchiazzi    oct92 
;                    Earth Space Research Group, UCSB
;
;-
if binsz mod 2 eq 0 then message,'BINSZ must be a odd integer'
if binsz lt 0 then       message,'BINSZ must be positive'
;
sz=size(a)
nx=sz(1)
ny=sz(2)
nxb=fix(nx/binsz)
nyb=fix(ny/binsz)
nxr=nxb*binsz
nyr=nyb*binsz
dx=nx-nxr
dy=ny-nyr
sig=smooth(a^2,binsz)
ave=smooth(a,binsz)                          
sig=sqrt(sig-ave^2 > 0.)
ix=dx/2+(binsz-1)/2+indgen(nxb)*binsz
iy=dy/2+(binsz-1)/2+indgen(nyb)*binsz
index=(replicate(1,n_elements(ix)) # iy)*nx+(ix # replicate(1,n_elements(iy)))
abin=ave(index)
sbin=sig(index)
if keyword_set(align) or keyword_set(compare) then begin
  ix1=dx/2+(binsz-1)/2 & ix2=ix1+nxr-1
  iy1=dy/2+(binsz-1)/2 & iy2=iy1+nyr-1
;  ix=fix((nxb-1)*findgen(nx)/(nx-1)+.5)
;  iy=fix((nyb-1)*findgen(ny)/(ny-1)+.5)
  ix=fix(nxb*(findgen(nx)-ix1)/(ix2-ix1)+.5) > 0 < (nxb-1)
  iy=fix(nyb*(findgen(ny)-iy1)/(iy2-iy1)+.5) > 0 < (nyb-1)
  index=(replicate(1,n_elements(ix)) # iy)*nxb+ $
        (ix # replicate(1,n_elements(iy)))
  if keyword_set(compare) then flick,bytscl(a),bytscl(abin(index))
  if keyword_set(align) then begin
    abin=abin(index)
    sbin=sbin(index)
  endif
endif
end



