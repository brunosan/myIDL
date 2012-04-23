pro inten,im,ff1,ff2,dmod,data,ffcor

;dum=rfits_im('29jun99.003',2601,dd,hdr,nrhdr,desp=desp)
;restore,'im_without_ff'
;im1=im
;restore,'ff1'
;ff1=ff
;restore,'ff2'
;ff2=ff
;restore,'dmod'

;restore,'data'
;mat_tel=fltarr(4,4)
;for j=0,3 do mat_tel(j,j)=1.
im1=im
fsize=size(ff1)
naxis1=fsize(2) & naxis2=fsize(3)
ffcor=fltarr(naxis1,naxis2)+1.

;naxis1=256.
;naxis2=256.
ind=0.

lin1=data(2) & lin2=data(3)
col=data(0) & col2=data(1)
esp=fltarr(256-col,lin2-lin1+1) & espf1=esp & espf2=esp

imdemod1=dmod # reform(im1,4,long(naxis1)*long(naxis2))
imdemod1=reform(imdemod1,4,naxis1,naxis2)

ffdemod1=dmod # reform(ff1,4,long(naxis1)*long(naxis2))
ffdemod1=reform(ffdemod1,4,naxis1,naxis2)

ffdemod2=dmod # reform(ff2,4,long(naxis1)*long(naxis2))
ffdemod2=reform(ffdemod2,4,naxis1,naxis2)

espf1(*,*)=ffdemod1(ind,col:*,lin1:lin2);/mean(ffdemod1(0,col:*,lin1:lin2))
esp(*,*)=imdemod1(ind,col:*,lin1:lin2);/mean(imdemod1(0,col:*,lin1:lin2))
espdum=total(esp,1)/(naxis1-col)
for j=0,lin2-lin1 do esp(*,j)=esp(*,j)/espdum(j)
esp=esp*mean(espdum)
espf2(*,*)=ffdemod2(ind,col:*,lin1:lin2);/mean(ffdemod2(0,col:*,lin1:lin2))

dum3a=median(reform(espf2/espf1),3)
dum4a=median(reform(esp/espf1),3)
nel=(71)*(lin2-lin1+1)

coef1=lstsqfit_old(reform(0.8>dum3a(110:180,*)<1.2,nel)-1.,1.-reform(dum4a(110:180,*)/mean(dum4a),nel))
print,coef1(0)

;dum1=dum4a/(1+(1-dum3a)*coef1(0))
;fit=dum1
;x=findgen(256-col)
;stop
;for j=lin1,lin2 do begin
;fit(*,j-lin1)=ajusta_seno(x,dum1(*,j-lin1)/mean(dum1(*,j-lin1))-1.,12)+1.
;endfor

;ffcor(col:*,lin1:lin2)=(1+(1-dum3)*coef1(0))*fit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lin1=data(6) & lin2=data(7)

espf1(*,*)=ffdemod1(ind,col:*,lin1:lin2);/mean(ffdemod1(0,col:*,lin1:lin2))
esp(*,*)=imdemod1(ind,col:*,lin1:lin2);/mean(imdemod1(0,col:*,lin1:lin2))
espdum=total(esp,1)/(naxis1-col)
for j=0,lin2-lin1 do esp(*,j)=esp(*,j)/espdum(j)
esp=esp*mean(espdum)
espf2(*,*)=ffdemod2(ind,col:*,lin1:lin2);/mean(ffdemod2(0,col:*,lin1:lin2))

dum3b=median(reform(espf2/espf1),3)
dum4b=median(reform(esp/espf1),3)

coef2=lstsqfit_old(reform(0.8>dum3b(110:180,*)<1.2,nel)-1.,1.-reform(dum4b(110:180,*)/mean(dum4b),nel))
print,coef2(0)


coef=(coef1(0)+coef2(0))/2.  & print,'coef=',coef

dum2=dum4b/(1+(1-dum3b)*coef)
x=findgen(256-col)
fit=dum2

for j=lin1,lin2 do begin
fit(*,j-lin1)=ajusta_seno(x,dum2(*,j-lin1)/mean(dum2(*,j-lin1))-1,12)+1.
endfor

ffcor(col:*,lin1:lin2)=(1+(1-dum3b)*coef)*fit

lin1=data(2) & lin2=data(3)

dum1=dum4a/(1+(1-dum3a)*coef)

for j=lin1,lin2 do begin
fit(*,j-lin1)=ajusta_seno(x,dum1(*,j-lin1)/mean(dum1(*,j-lin1))-1.,12)+1.
endfor

ffcor(col:*,lin1:lin2)=(1+(1-dum3a)*coef)*fit

return
end
