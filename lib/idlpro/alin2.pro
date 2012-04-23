pro alin,im,ff,dmod,modul,mat_tel,data,ffnew,fringes

;ffnew=ff
;iop=1
;if(iop eq 1) then return


naxis1=256.
naxis2=256.

im2=im
ff2=ff
ffnew=fltarr(4,naxis1,naxis2)
fringes=fltarr(3,naxis1,naxis2)


imdemod2=dmod # reform(im2,4,long(naxis1)*long(naxis2))
imdemod2=reform(imdemod2,4,naxis1,naxis2)

ffdemod2=dmod # reform(ff2,4,long(naxis1)*long(naxis2))
ffdemod2=reform(ffdemod2,4,naxis1,naxis2)


for ind=1,3 do begin
print,ind
lin1=data(2) & lin2=data(3)
col=data(0) & col2=data(1)

freq=45

esp=fltarr(256-col,lin2-lin1+1) & espf=esp & fit=esp & fitn=esp

;esp(*,*)=ffdemod1(ind,col:*,lin1:lin2)/mean(ffdemod1(0,col:*,lin1:lin2))
esp(*,*)=imdemod2(ind,col:*,lin1:lin2)/mean(imdemod2(0,col:*,lin1:lin2))
espf(*,*)=ffdemod2(ind,col:*,lin1:lin2)/mean(ffdemod2(0,col:*,lin1:lin2))

;correction for bad points and small fringes

esp=filtra_tip(median(esp,3)) & espf=filtra_tip(median(espf,3))

;esp=median(esp,4) & espf=median(espf,4)
x=findgen(256-col)


for l=lin1,lin2 do begin
dum=espf(*,l-lin1)-mean(espf(*,l-lin1))
fit(*,l-lin1)=ajusta_seno(x,dum,freq)+$
              ajusta_seno(x,dum,freq*2.);+$
;	      ajusta_seno(x,dum,freq*3.)    
endfor


lim=10

dif=fltarr(lim*2+1,lim*2+1)
for j=-lim,lim do begin
for i=-lim,lim do begin
sh=shift(fit,j,i)
;dif(lim+j,lim+i)=std(esp(100:190,lim:lin2-lin1+1-lim)-$
;                      sh(100:190,lim:lin2-lin1+1-lim))
dif(lim+j,lim+i)=std(esp(70:160,lim:lin2-lin1+1-lim)-$
                      sh(70:160,lim:lin2-lin1+1-lim))
endfor
endfor
dif2=dif
posm=where(dif eq min(dif))
posy=posm/(2*lim+1)-lim
posx=posm mod (2*lim+1)-lim
posy=0  ;min(posy)
posx=0  ;min(posx)

tam=size(esp)
fesp=fft((esp-mean(esp)),-1)
ffit=fft(fit,-1)
corr=float(fft(fesp*conj(ffit),1)) 
corr(*,10:tam(2)-11)=0. 
corr(10:tam(1)-11,*)=0.   
posmax=where(corr eq max(corr))
posmax=posmax(0)
posx=posmax MOD tam(1)
posy=posmax/tam(1)
if(posx gt tam(1)/2) then posx=posx-tam(1)
if(posy gt tam(2)/2) then posy=posy-tam(2)
;stop
print,posx,posy

espf2=shift(espf,posx,posy)
for l=lin1,lin2 do begin
dum=espf2(*,l-lin1)-mean(espf2(*,l-lin1))
fitn(*,l-lin1)=ajusta_seno(x,dum,freq)+$
               ajusta_seno(x,dum,freq*2.);+$
;	       ajusta_seno(x,dum,freq*3.)
;fitn(*,l-lin1)=fitn(*,l-lin1)+mean(espf2(*,l-lin1))           
endfor

if posy gt 0. then begin
for j=0,posy do fitn(*,j)=fitn(*,posy+1)
endif
if posy lt 0. then begin
for j=abs(posy),0,-1 do fitn(*,lin2-lin1-j)=fitn(*,lin2-lin1-abs(posy)-1)
endif



res1=esp-fitn
fit1=(espf-fit+fitn)*mean(ffdemod2(0,col:*,lin1:lin2))  ;new artificial flat fild for the first beam
ffnew(ind,col:*,lin1:lin2)=fit1
fringes(ind-1,col:*,lin1:lin2)=fitn
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lin1=data(6) & lin2=data(7)

;esp(*,*)=ffdemod1(ind,col:*,lin1:lin2)/mean(ffdemod1(0,col:*,lin1:lin2))
esp(*,*)=imdemod2(ind,col:*,lin1:lin2)/mean(imdemod2(0,col:*,lin1:lin2))
espf(*,*)=ffdemod2(ind,col:*,lin1:lin2)/mean(ffdemod2(0,col:*,lin1:lin2))
esp=filtra_tip(median(esp,3)) & espf=filtra_tip(median(espf,3))
;esp=median(esp,4) & espf=median(espf,4)

x=findgen(256-col)


for l=lin1,lin2 do begin
dum=espf(*,l-lin1)-mean(espf(*,l-lin1))
fit(*,l-lin1)=ajusta_seno(x,dum,freq)+$
              ajusta_seno(x,dum,freq*2.)

endfor


lim=10
dif=fltarr(lim*2+1,lim*2+1)
for j=-lim,lim do begin
for i=-lim,lim do begin
sh=shift(fit,j,i)
;dif(lim+j,lim+i)=std(esp(100:190,lim:lin2-lin1+1-lim)-$
;                      sh(100:190,lim:lin2-lin1+1-lim))
dif(lim+j,lim+i)=std(esp(80:160,lim:lin2-lin1+1-lim)-$
                      sh(80:160,lim:lin2-lin1+1-lim))
endfor
endfor
;stop
posm=where(dif eq min(dif))
posy=posm/(2*lim+1)-lim
posx=posm mod (2*lim+1)-lim
posy=0 ;min(posy)
posx=0  ;min(posx)

tam=size(esp)
fesp=fft(esp-mean(esp),-1)
ffit=fft(fit,-1)
corr=float(fft(fesp*conj(ffit),1))     
corr(*,10:tam(2)-11)=0. 
corr(10:tam(1)-11,*)=0. 
posmax=where(corr eq max(corr))
posmax=posmax(0)
posx=posmax MOD tam(1)
posy=posmax/tam(1)
if(posx gt tam(1)/2) then posx=posx-tam(1)
if(posy gt tam(2)/2) then posy=posy-tam(2)
;stop
print,posx,posy

espf2=shift(espf,posx,posy)
for l=lin1,lin2 do begin
dum=espf2(*,l-lin1)-mean(espf2(*,l-lin1))
fitn(*,l-lin1)=ajusta_seno(x,dum,freq)+$
               ajusta_seno(x,dum,freq*2.)
endfor

if posy gt 0. then begin
for j=0,posy do fitn(*,j)=fitn(*,posy+1)
endif
if posy lt 0. then begin
for j=abs(posy),0,-1 do fitn(*,lin2-lin1-j)=fitn(*,lin2-lin1-abs(posy)-1)
endif



res2=esp-fitn 
fit2=(espf-fit+fitn)*mean(ffdemod2(0,col:*,lin1:lin2))   ;new artificial flat field for the beam 2
ffnew(ind,col:*,lin1:lin2)=fit2
fringes(ind-1,col:*,lin1:lin2)=fitn
endfor


ffnew(0,*,*)=1.

;lin1=28 & lin2=119

lin1=data(2) & lin2=data(3)
ffnew(0,col:*,lin1:lin2)=ffdemod2(0,col:*,lin1:lin2)

;lin1=144 & lin2=235
lin1=data(6) & lin2=data(7)

ffnew(0,col:*,lin1:lin2)=ffdemod2(0,col:*,lin1:lin2)

ffmod=modul # reform(ffnew,4,long(naxis1)*long(naxis2))
ffmod=reform(ffmod,4,naxis1,naxis2)
ffnew=ffmod

stop
return

end
