pro colapso

im=rfits_im('24nov98.006c',4,dd)

nlambdas=dd.naxis1
nslit=dd.naxis2
nt=dd.naxis3/4


nlin=2
posmax=fltarr(nt,nslit,nlin)
posmin=fltarr(nt,nslit,nlin)
ampmax=fltarr(nt,nslit,nlin)
ampmin=fltarr(nt,nslit,nlin)

xin=[10,170]
xfin=[130,230]

format=['(i2,$)','(i3,$)','(i4,$)','(i5,$)','(i6,$)']
print,nt
for i=0,nt-1 do begin
   print,i+1,format=format(fix(alog10(i+1)))
   imi=rfits_im('24nov98.006c',4*i+1)
   z=where(imi lt 0)
   imi(z)=imi(z)+65536
   imv=rfits_im('24nov98.006c',4*(i+1))
   imiv=median(imv,3)/median(imi,3)
;   fimiv=fft(imiv,-1)
;   z1=[53,76]
;   z2=[nlambdas,nslit]-z1
;   fimiv(z1(0),z1(1))=0
;   fimiv(z2(0),z2(1))=0
;   imiv2=float(fft(fimiv,1))
   for j=0,nslit-1 do begin
      lin=abs(imiv(xin(0):xfin(0),j))
      z=where(lin eq max(lin))
      if(lin(z(0)) gt 0.005) then begin
         for k=0,nlin-1 do begin
            lin=imiv(xin(k):xfin(k),j)
            z=where(lin eq min(lin))
	    posmin(i,j,k)=z(0)+xin(k)
	    ampmin(i,j,k)=lin(z(0))
            z=where(lin eq max(lin))
	    posmax(i,j,k)=z(0)+xin(k)
	    ampmax(i,j,k)=lin(z(0))
         endfor	
      endif	  
   endfor
;   if(i eq 100) then stop
endfor
print,' '

vel=(posmax+posmin)*0.03*3.e5/2./15650.
vel0=reform(vel(*,*,0))
z=where(vel0 ne 0)
vel0(z)=vel0(z)-mean(vel0(z))
vel(*,*,0)=vel0
vel1=reform(vel(*,*,1))
z=where(vel1 ne 1)
vel1(z)=vel1(z)-mean(vel1(z))
vel(*,*,1)=vel1
campo=(posmax-posmin)*0.03/2./4.67e-13/15650./15650.
0.03/2./4.67e-13/15650./15650.: Command not found

campo(*,*,0)=campo(*,*,0)/3.
campo(*,*,1)=campo(*,*,1)/1.65

save,filename='colapso.idl',posmax,posmin,ampmax,ampmin,vel,campo
stop
return
end   
