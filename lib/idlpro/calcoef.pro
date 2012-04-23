pro calcoef,calimage

; This program reads a calibration file 'calimage' and computes
; the modulated and demodulated matrices and their errors.
; It also computes the modulation efficiencies. 
; Output is displayed and written to a txt file.

; Made by vmp@ll.iac.es 

mmm=rfits_im(calimage,1,dd,hdr,/desp)

nx=fix(dd.naxis1)
ny=fix(dd.naxis2)
nz=fix(dd.naxis3)-8
npos=nz/4 ; retarder positions

dark=fltarr(nx,ny)

dat1=fltarr(nx,ny)
dat2=fltarr(nx,ny)
dat3=fltarr(nx,ny)
dat4=fltarr(nx,ny)

; plus state

val1_p=fltarr(npos)
val2_p=fltarr(npos)
val3_p=fltarr(npos)
val4_p=fltarr(npos)

; minus state

val1_m=fltarr(npos)
val2_m=fltarr(npos)
val3_m=fltarr(npos)
val4_m=fltarr(npos)

; computing mean dark

for ind=1,8 do begin
	mmm=float(rfits_im(calimage,ind,dd,hdr,/desp)) & print,ind
	dark=dark+mmm/8.
endfor

; computing mean values of callibration states

for ind=0,npos-1 do begin

	jnd=ind*4+9
	mmm=float(rfits_im(calimage,jnd,dd,hdr,/desp)) & print,jnd
        dat1=mmm-dark

	mmm=float(rfits_im(calimage,jnd+1,dd,hdr,/desp)) & print,jnd+1
	dat2=mmm-dark

	mmm=float(rfits_im(calimage,jnd+2,dd,hdr,/desp)) & print,jnd+2
	dat3=mmm-dark

	mmm=float(rfits_im(calimage,jnd+3,dd,hdr,/desp)) & print,jnd+3
	dat4=mmm-dark

	if (ind eq 0) then begin
	
		tvwin,(dat1+dat2+dat3+dat4)/4.

		message,'Click Lower Left Corner on Image1',$
			/informational
		cursor,x_1,y_1,3,/device
		message,'Click Upper Right Corner on Image1',$
			/informational
		cursor,x_2,y_2,3,/device
		
		message,'Click Lower Left Corner on Image2',$
			/informational
		cursor,x_3,y_3,3,/device
		message,'Click Upper Right Corner on Image2',$
			/informational
		cursor,x_4,y_4,3,/device
		d
	
	endif


	val1_p(ind)=mean(dat1(x_1:x_2,y_1:y_2))
	val2_p(ind)=mean(dat2(x_1:x_2,y_1:y_2))
	val3_p(ind)=mean(dat3(x_1:x_2,y_1:y_2))
	val4_p(ind)=mean(dat4(x_1:x_2,y_1:y_2))

	val1_m(ind)=mean(dat1(x_3:x_4,y_3:y_4))
	val2_m(ind)=mean(dat2(x_3:x_4,y_3:y_4))
	val3_m(ind)=mean(dat3(x_3:x_4,y_3:y_4))
	val4_m(ind)=mean(dat4(x_3:x_4,y_3:y_4))

endfor

; fit using regress

xo=fltarr(npos) ; for Stokes I
xx=fltarr(3,npos) ; for Stokes Q U and V

angul=findgen(npos)*5 ; retarder angles

pl=0.5*transpose(device(amr=0,pha=0,ang=0.))

for ind=0,npos-1 do begin
	retang=angul(ind)
	ret=transpose(device(amr=1.,pha=89.6,ang=retang))  ; 6300
;	ret=transpose(device(amr=1.,pha=-105.9,ang=retang)) ; green
;	ret=transpose(device(amr=1.,pha=-73,ang=retang))    ; IR
	mm=(ret#pl)#[1.,0.,0.,0.]
	xx(0,ind)=mm(1)
	xx(1,ind)=mm(2)
	xx(2,ind)=mm(3)
	xo(ind)=mm(0)
endfor

; arrays for fitting

a1=fltarr(4)
a2=fltarr(4)
a3=fltarr(4)
a4=fltarr(4)

sa1=fltarr(4)
sa2=fltarr(4)
sa3=fltarr(4)
sa4=fltarr(4)

ww=fltarr(npos)
ww(*)=1.0

tmp = regress(xx, val1_p, ww, result1, cte1,  sig, /relative_weight) 
tmp=reform(tmp)
a1(1:3)=tmp(0:2)
sa1(1:3)=sig(0:2)
a1(0)=cte1/mean(xo) ; indep. term is a1*xo 
sa1(0)=stdev(val1_p-(xx(0,*)*tmp(0)+xx(1,*)*tmp(1)+xx(2,*)*tmp(2)))/mean(xo)/sqrt(npos)


tmp = regress(xx, val2_p, ww, result2, cte2,  sig, /relative_weight) 
tmp=reform(tmp)
a2(1:3)=tmp(0:2)
sa2(1:3)=sig(0:2)
a2(0)=cte2/mean(xo)
sa2(0)=stdev(val2_p-(xx(0,*)*tmp(0)+xx(1,*)*tmp(1)+xx(2,*)*tmp(2)))/mean(xo)/sqrt(npos)

tmp = regress(xx, val3_p, ww, result3, cte3,  sig, /relative_weight) 
tmp=reform(tmp)
a3(1:3)=tmp(0:2)
sa3(1:3)=sig(0:2)
a3(0)=cte3/mean(xo)
sa3(0)=stdev(val3_p-(xx(0,*)*tmp(0)+xx(1,*)*tmp(1)+xx(2,*)*tmp(2)))/mean(xo)/sqrt(npos)

tmp = regress(xx, val4_p, ww, result4, cte4,  sig, /relative_weight) 
tmp=reform(tmp)
a4(1:3)=tmp(0:2)
sa4(1:3)=sig(0:2)
a4(0)=cte4/mean(xo)
sa4(0)=stdev(val4_p-(xx(0,*)*tmp(0)+xx(1,*)*tmp(1)+xx(2,*)*tmp(2)))/mean(xo)/sqrt(npos)

; normalization

kk=mean([a1(0),a2(0),a3(0),a4(0)])

a1=a1/kk
a2=a2/kk
a3=a3/kk
a4=a4/kk

sa1=sa1/kk
sa2=sa2/kk
sa3=sa3/kk
sa4=sa4/kk

;
val=[val1_p,val2_p,val3_p,val4_p]
result=[reform(result1),reform(result2),reform(result3),reform(result4)]

window,0
plot,val,psym=1,title='FIT'
oplot,result
window,1
plot,val-result,title='RESIDUALS'

openw,1,calimage+'_cal.txt'
printf,1,calimage+'_cal.txt'

print,'First Image Results'
print,' '
print,'S/N of the fit=',max(val)/stdev(val-result)
print,' '

printf,1,'First Image Results'
printf,1,' '
printf,1,'S/N of the fit=',max(val)/stdev(val-result)
printf,1,' '

; modulation and demodulation matrices

gg=[[reform(a1)],[reform(a2)],[reform(a3)],[reform(a4)]]

err=[[sa1],[sa2],[sa3],[sa4]]

both1=[reform(a1),sa1]
both2=[reform(a2),sa2]
both3=[reform(a3),sa3]
both4=[reform(a4),sa4]
print,'       Modulation Matrix                          Error Matrix    '
print,both1,format='(4(f7.4,1x),8x,4(f7.4,1x))'
print,both2,format='(4(f7.4,1x),8x,4(f7.4,1x))'
print,both3,format='(4(f7.4,1x),8x,4(f7.4,1x))'
print,both4,format='(4(f7.4,1x),8x,4(f7.4,1x))'

printf,1,'       Modulation Matrix                          Error Matrix    '
printf,1,both1,format='(4(f7.4,1x),8x,4(f7.4,1x))'
printf,1,both2,format='(4(f7.4,1x),8x,4(f7.4,1x))'
printf,1,both3,format='(4(f7.4,1x),8x,4(f7.4,1x))'
printf,1,both4,format='(4(f7.4,1x),8x,4(f7.4,1x))'

gg=transpose(gg)
err=transpose(err)

tdmod=fltarr(4,4,200)

dmod=fltarr(4,4)
errdmod=fltarr(4,4)

for ind=0,199 do begin
	tmp=gg+randomn(seed,16)*err
	tmp=invert(tmp)
	tdmod(*,*,ind)=tmp(*,*)
endfor

for ind=0,3 do begin
	for jnd=0,3 do begin
		dmod(ind,jnd)=mean(tdmod(ind,jnd,*))
		errdmod(ind,jnd)=stdev(tdmod(ind,jnd,*))
	endfor
endfor

dmod=transpose(dmod)
errdmod=transpose(errdmod)
both1=[dmod(0),dmod(1),dmod(2),dmod(3),errdmod(0),errdmod(1),errdmod(2),errdmod(3)]
both2=[dmod(4),dmod(5),dmod(6),dmod(7),errdmod(4),errdmod(5),errdmod(6),errdmod(7)]
both3=[dmod(8),dmod(9),dmod(10),dmod(11),errdmod(8),errdmod(9),errdmod(10),errdmod(11)]
both4=[dmod(12),dmod(13),dmod(14),dmod(15),errdmod(12),errdmod(13),errdmod(14),errdmod(15)]
print,'     Demodulation Matrix                          Error Matrix    '
print,both1,format='(4(f7.4,1x),8x,4(f7.4,1x))'
print,both2,format='(4(f7.4,1x),8x,4(f7.4,1x))'
print,both3,format='(4(f7.4,1x),8x,4(f7.4,1x))'
print,both4,format='(4(f7.4,1x),8x,4(f7.4,1x))'

printf,1,'     Demodulation Matrix                          Error Matrix    '
printf,1,both1,format='(4(f7.4,1x),8x,4(f7.4,1x))'
printf,1,both2,format='(4(f7.4,1x),8x,4(f7.4,1x))'
printf,1,both3,format='(4(f7.4,1x),8x,4(f7.4,1x))'
printf,1,both4,format='(4(f7.4,1x),8x,4(f7.4,1x))'

; eficiencies

ei1=1./sqrt(total(dmod(*,0)^2)*4)
eq1=1./sqrt(total(dmod(*,1)^2)*4)
eu1=1./sqrt(total(dmod(*,2)^2)*4)
ev1=1./sqrt(total(dmod(*,3)^2)*4)
ef=sqrt(eq1^2+eu1^2+ev1^2)
print,' '
print,'effic. Stokes I=',ei1
print,'effic. Stokes Q=',eq1
print,'effic. Stokes U=',eu1
print,'effic. Stokes V=',ev1
print,'total effic. Stokes=',ef

printf,1,' '
printf,1,'effic. Stokes I=',ei1
printf,1,'effic. Stokes Q=',eq1
printf,1,'effic. Stokes U=',eu1
printf,1,'effic. Stokes V=',ev1
printf,1,'total effic. Stokes=',ef

; arrays for fitting

a1=fltarr(4)
a2=fltarr(4)
a3=fltarr(4)
a4=fltarr(4)

sa1=fltarr(4)
sa2=fltarr(4)
sa3=fltarr(4)
sa4=fltarr(4)

ww=fltarr(npos)
ww(*)=1.0

tmp = regress(xx, val1_m, ww, result1, cte1,  sig, /relative_weight) 
tmp=reform(tmp)
a1(1:3)=tmp(0:2)
sa1(1:3)=sig(0:2)
a1(0)=cte1/mean(xo) ; indep. term is a1*xo 
sa1(0)=stdev(val1_m-(xx(0,*)*tmp(0)+xx(1,*)*tmp(1)+xx(2,*)*tmp(2)))/mean(xo)/sqrt(npos)


tmp = regress(xx, val2_m, ww, result2, cte2,  sig, /relative_weight) 
tmp=reform(tmp)
a2(1:3)=tmp(0:2)
sa2(1:3)=sig(0:2)
a2(0)=cte2/mean(xo)
sa2(0)=stdev(val2_m-(xx(0,*)*tmp(0)+xx(1,*)*tmp(1)+xx(2,*)*tmp(2)))/mean(xo)/sqrt(npos)

tmp = regress(xx, val3_m, ww, result3, cte3,  sig, /relative_weight) 
tmp=reform(tmp)
a3(1:3)=tmp(0:2)
sa3(1:3)=sig(0:2)
a3(0)=cte3/mean(xo)
sa3(0)=stdev(val3_m-(xx(0,*)*tmp(0)+xx(1,*)*tmp(1)+xx(2,*)*tmp(2)))/mean(xo)/sqrt(npos)

tmp = regress(xx, val4_m, ww, result4, cte4,  sig, /relative_weight) 
tmp=reform(tmp)
a4(1:3)=tmp(0:2)
sa4(1:3)=sig(0:2)
a4(0)=cte4/mean(xo)
sa4(0)=stdev(val4_m-(xx(0,*)*tmp(0)+xx(1,*)*tmp(1)+xx(2,*)*tmp(2)))/mean(xo)/sqrt(npos)

; normalization

kk=mean([a1(0),a2(0),a3(0),a4(0)])

a1=a1/kk
a2=a2/kk
a3=a3/kk
a4=a4/kk

sa1=sa1/kk
sa2=sa2/kk
sa3=sa3/kk
sa4=sa4/kk

;
val=[val1_m,val2_m,val3_m,val4_m]
result=[reform(result1),reform(result2),reform(result3),reform(result4)]

window,2
plot,val,psym=1,title='FIT'
oplot,result
window,3
plot,val-result,title='RESIDUALS'

print,' '
print,'Second Image Results'
print,' '
print,'S/N of the fit=',max(val)/stdev(val-result)
print,' '

printf,1,' '
printf,1,'Second Image Results'
printf,1,' '
printf,1,'S/N of the fit=',max(val)/stdev(val-result)
printf,1,' '

; modulation and demodulation matrices

gg=[[reform(a1)],[reform(a2)],[reform(a3)],[reform(a4)]]

err=[[sa1],[sa2],[sa3],[sa4]]

both1=[reform(a1),sa1]
both2=[reform(a2),sa2]
both3=[reform(a3),sa3]
both4=[reform(a4),sa4]
print,'       Modulation Matrix                          Error Matrix    '
print,both1,format='(4(f7.4,1x),8x,4(f7.4,1x))'
print,both2,format='(4(f7.4,1x),8x,4(f7.4,1x))'
print,both3,format='(4(f7.4,1x),8x,4(f7.4,1x))'
print,both4,format='(4(f7.4,1x),8x,4(f7.4,1x))'

printf,1,'       Modulation Matrix                          Error Matrix    '
printf,1,both1,format='(4(f7.4,1x),8x,4(f7.4,1x))'
printf,1,both2,format='(4(f7.4,1x),8x,4(f7.4,1x))'
printf,1,both3,format='(4(f7.4,1x),8x,4(f7.4,1x))'
printf,1,both4,format='(4(f7.4,1x),8x,4(f7.4,1x))'

gg=transpose(gg)
err=transpose(err)

tdmod=fltarr(4,4,200)

dmod=fltarr(4,4)
errdmod=fltarr(4,4)

for ind=0,199 do begin
	tmp=gg+randomn(seed,16)*err
	tmp=invert(tmp)
	tdmod(*,*,ind)=tmp(*,*)
endfor

for ind=0,3 do begin
	for jnd=0,3 do begin
		dmod(ind,jnd)=mean(tdmod(ind,jnd,*))
		errdmod(ind,jnd)=stdev(tdmod(ind,jnd,*))
	endfor
endfor

dmod=transpose(dmod)
errdmod=transpose(errdmod)
both1=[dmod(0),dmod(1),dmod(2),dmod(3),errdmod(0),errdmod(1),errdmod(2),errdmod(3)]
both2=[dmod(4),dmod(5),dmod(6),dmod(7),errdmod(4),errdmod(5),errdmod(6),errdmod(7)]
both3=[dmod(8),dmod(9),dmod(10),dmod(11),errdmod(8),errdmod(9),errdmod(10),errdmod(11)]
both4=[dmod(12),dmod(13),dmod(14),dmod(15),errdmod(12),errdmod(13),errdmod(14),errdmod(15)]
print,'     Demodulation Matrix                          Error Matrix    '
print,both1,format='(4(f7.4,1x),8x,4(f7.4,1x))'
print,both2,format='(4(f7.4,1x),8x,4(f7.4,1x))'
print,both3,format='(4(f7.4,1x),8x,4(f7.4,1x))'
print,both4,format='(4(f7.4,1x),8x,4(f7.4,1x))'

printf,1,'     Demodulation Matrix                          Error Matrix    '
printf,1,both1,format='(4(f7.4,1x),8x,4(f7.4,1x))'
printf,1,both2,format='(4(f7.4,1x),8x,4(f7.4,1x))'
printf,1,both3,format='(4(f7.4,1x),8x,4(f7.4,1x))'
printf,1,both4,format='(4(f7.4,1x),8x,4(f7.4,1x))'

; eficiencies

ei1=1./sqrt(total(dmod(*,0)^2)*4)
eq1=1./sqrt(total(dmod(*,1)^2)*4)
eu1=1./sqrt(total(dmod(*,2)^2)*4)
ev1=1./sqrt(total(dmod(*,3)^2)*4)
ef=sqrt(eq1^2+eu1^2+ev1^2)
print,' '
print,'effic. Stokes I=',ei1
print,'effic. Stokes Q=',eq1
print,'effic. Stokes U=',eu1
print,'effic. Stokes V=',ev1
print,'total effic. Stokes=',ef

printf,1,' '
printf,1,'effic. Stokes I=',ei1
printf,1,'effic. Stokes Q=',eq1
printf,1,'effic. Stokes U=',eu1
printf,1,'effic. Stokes V=',ev1
printf,1,'total effic. Stokes=',ef

close,1
end
