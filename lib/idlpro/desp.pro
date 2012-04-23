function desp,imin,deltax,deltay

fimin=fft(imin,-1)

tam=size(imin)
if(tam(1) MOD 2 eq 0) then begin
   nux=findgen(tam(1)/2+1)/tam(1)
   nux=[nux,-reverse(nux(1:tam(1)/2-1))]
endif else begin
   nux=findgen(tam(1)/2+1)/tam(1)
   nux=[nux,-reverse(nux(1:tam(1)/2))]
endelse
if(tam(2) MOD 2 eq 0) then begin
   nuy=findgen(tam(2)/2+1)/tam(2)
   nuy=[nuy,-reverse(nuy(1:tam(2)/2-1))]
endif else begin
   nuy=findgen(tam(2)/2+1)/tam(2)
   nuy=[nuy,-reverse(nuy(1:tam(2)/2))]
endelse
   
nuxx=meshx(nux,nuy)
nuyy=meshy(nux,nuy)

phi=-2*!pi*(deltax*nuxx+deltay*nuyy)
i=complex(0.,1.)
phi=cos(phi)+i*sin(phi)
fimout=fimin*phi

imout=float(fft(fimout,1))

return,imout
end
