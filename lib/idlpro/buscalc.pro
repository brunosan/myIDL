pro buscalc,delta1,delta2
;ferro2,-18,90,51,-6,90,51,m1,inv1,eps & print,eps
;ferro2,-16,100,51,-8,80,51,m1,inv1,eps & print,eps
;ferro2,-16,110,51,-6,80,51,m1,inv1,eps & print,eps
;ferro2,-13,110,51,-3,110,51,m1,inv1,eps & print,eps
;ferro2,9,110,45,7,110,45,m1,inv1,eps & print,eps
;ferro2,-12,110,51,-4,110,51,m1,inv1,eps & print,eps

smin=1000
imin=0
jmin=0
step=3
n=180/step+1
nfac=6
fac=findgen(nfac)*0.04+0.92
labfac=strtrim(string(fac,format='(f4.2)'))
epsi=fltarr(n,n,nfac)
epsq=fltarr(n,n,nfac)
epsu=fltarr(n,n,nfac)
epsv=fltarr(n,n,nfac)
epsp=fltarr(n,n,nfac)
ref=where(fac eq 1)

thx=findgen(n)*step
thy=findgen(n)*step
for k=0,nfac-1 do begin
   for i=0,90,step do begin
;   print,'****',i
      for j=0,180,step do begin
;      ferro2,i,159.5,51,j,102.5,45.,m1,inv1,eps
         ferro2,i,delta1/fac(k),50.,j,delta2/fac(k),50.,m1,inv1,eps
         epsi(i/step,j/step,k)=eps(0)
         epsq(i/step,j/step,k)=eps(1)
         epsu(i/step,j/step,k)=eps(2)
         epsv(i/step,j/step,k)=eps(3)
         epsp(i/step,j/step,k)=eps(4)
	 if(j le 90) then begin
            epsi((i+90)/step,(j+90)/step,k)=eps(0)
            epsq((i+90)/step,(j+90)/step,k)=eps(1)
            epsu((i+90)/step,(j+90)/step,k)=eps(2)
            epsv((i+90)/step,(j+90)/step,k)=eps(3)
            epsp((i+90)/step,(j+90)/step,k)=eps(4)
	 endif else begin   
            epsi((i+90)/step,(j-90)/step,k)=eps(0)
            epsq((i+90)/step,(j-90)/step,k)=eps(1)
            epsu((i+90)/step,(j-90)/step,k)=eps(2)
            epsv((i+90)/step,(j-90)/step,k)=eps(3)
            epsp((i+90)/step,(j-90)/step,k)=eps(4)
	 endelse
      endfor	 
   endfor
endfor
epsimax=(fix(max(epsi(*,*,ref))*10)/10.)<0.9
epsqmax=(fix(max(epsq(*,*,ref))*10)/10.)<0.40
epsumax=(fix(max(epsu(*,*,ref))*10)/10.)<0.40
epsvmax=(fix(max(epsv(*,*,ref))*10)/10.)<0.40
epspmax=(fix(max(epsp(*,*,ref))*10)/10.)<0.8
labeli='COTA I = 0.'+strtrim((fix(epsimax*10))<9,2)
labelq='COTA Q = 0.'+strtrim((fix(epsqmax*10))<5,2)
labelu='COTA U = 0.'+strtrim((fix(epsumax*10))<5,2)
labelv='COTA V = 0.'+strtrim((fix(epsvmax*10))<5,2)
labelp='COTA P = 0.'+strtrim((fix(epspmax*10))<8,2)
good=fltarr(n,n,nfac)
for k=0,nfac-1 do begin
   dum=fltarr(n,n)
   z=where(epsi(*,*,k) ge epsimax and epsq(*,*,k) ge epsqmax and $
      epsu(*,*,k) ge epsumax and epsv(*,*,k) ge epsvmax)
   if(z(0) ne -1) then dum(z)=1
   good(*,*,k)=dum
endfor   
   
!p.multi=[0,3,2]
!p.charsize=2.0
loadct,2
;window,0,xsize=1024,ysize=768
contour,epsi(*,*,ref),thx,thy,levels=epsimax,$
   /fill,title=labeli,$
   /xstyle,/ystyle,xtitle='THETA LC1',ytitle='THETA LC2',c_charsize=1.2

contour,epsq(*,*,ref),thx,thy,levels=epsqmax,$
   title=labelq,$
   /xstyle,/ystyle,c_charsize=1.2,/fill,xtitle='THETA LC1',ytitle='THETA LC2'
;contour,epsu(*,*,ref),thx,thy,levels=epsumax,c_colors=30,/xstyle,/ystyle,$
;   c_charsize=1.2,/fill,/overplot
;contour,epsv(*,*,ref),thx,thy,levels=epsvmax,c_colors=180,/xstyle,/ystyle,$
;   c_charsize=1.2,/fill,/overplot

contour,epsu(*,*,ref),thx,thy,levels=epsumax,$
   title=labelu,$
   /xstyle,/ystyle,c_charsize=1.2,/fill,xtitle='THETA LC1',ytitle='THETA LC2'
;contour,epsq(*,*,ref),thx,thy,levels=epsqmax,c_colors=80,/xstyle,/ystyle,$
;   c_charsize=1.2,/fill,/overplot
;contour,epsv(*,*,ref),thx,thy,levels=epsvmax,c_colors=180,/xstyle,/ystyle,$
;   c_charsize=1.2,/fill,/overplot

contour,epsv(*,*,ref),thx,thy,levels=epsvmax,title=labelv,$
   /xstyle,/ystyle,c_charsize=1.2,/fill,xtitle='THETA LC1',ytitle='THETA LC2'
;contour,epsq(*,*,ref),thx,thy,levels=epsqmax,c_colors=80,/xstyle,/ystyle,$
;   c_charsize=1.2,/fill,/overplot
;contour,epsu(*,*,ref),thx,thy,levels=epsumax,c_colors=30,/xstyle,/ystyle,$
;   c_charsize=1.2,/fill,/overplot

contour,epsp(*,*,ref),thx,thy,levels=epspmax,title=labelp,$
   /xstyle,/ystyle,c_charsize=1.2,/fill,xtitle='THETA LC1',ytitle='THETA LC2'

contour,good(*,*,ref),thx,thy,levels=1,title='GOOD',$
   /xstyle,/ystyle,c_charsize=1.2,/fill,xtitle='THETA LC1',ytitle='THETA LC2'

pause

for k=0,nfac-1 do begin
label='!6 GOOD !7k = !6'+labfac(k)+'!7k!do!n!6 '
contour,good(*,*,k),thx,thy,levels=1,title=label,$
   /xstyle,/ystyle,c_charsize=1.2,/fill,xtitle='THETA LC1',ytitle='THETA LC2'
endfor  

;pause
;good2=good
;for k=1,nfac-1 do good2(*,*,k)=good2(*,*,k)*good(*,*,ref)
;for k=0,nfac-1 do begin
;contour,good2(*,*,k),thx,thy,levels=1,$
;   title='GOOD -- FACTOR='+strtrim(fac(k),2),$
;   /xstyle,/ystyle,c_charsize=1.2,/fill,xtitle='THETA LC1',ytitle='THETA LC2'
;endfor  
 
pause
!p.multi=0
contour,total(good,3),thx,thy,levels=[-2,-1,0]+nfac,title='GOOD',$
   /xstyle,/ystyle,c_charsize=1.2,/follow,xtitle='THETA LC1',ytitle='THETA LC2'

 
;stop
;pause
!p.multi=0
!p.charsize=1.0
;loadct,0


return
end      	 
