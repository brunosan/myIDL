;pro filigree,dat1,px,fil
pro filigree

; px = tamanyo del pixel en segundos de arco
; fil= tamanyo del filigree en segundos de arco

dat1=fltarr(300,300)
px=0.2
fil=0.5

dat=dat1
dmin=min(dat)
dmax=max(dat)
datm=mean(dat)
tam=size(dat)
n=tam(1)-1
m=tam(2)-1

ncuad=fix(3*fil/px)
if(ncuad/2*2 eq ncuad) then ncuad=ncuad+1

; ncuad=fix(5)
ncuad2=ncuad/2
rad=shift(dist(ncuad,ncuad),ncuad2,ncuad2)*px
cuad=0.3*datm*exp(-rad*rad*2./fil/fil)
;if(1.5*datm gt dmax) then dmax=1.5*datm

; cuad=bytarr(ncuad,ncuad)+200

pradial,dat,px,kr,pkr

datb=byte((dat-dmin)*255./(dmax-dmin))
cuadb=byte(cuad*255./(dmax-dmin))
stop
;window,0,xpos=1140-n,ypos=900-m,xsize=n,ysize=m
window,0,xpos=1024-n,ypos=0,xsize=n,ysize=m

tv,datb,0,0
wtam=300
;window,1,xpos=1140-wtam-100,ypos=900-m-wtam-50,xsize=wtam+100,ysize=wtam
window,1,xpos=1024-wtam-100,ypos=m+50,xsize=wtam+100,ysize=wtam
plot,alog(kr),alog(pkr)


!err=1

while(!err ne 4) do begin
   wset,0
   tvrdc,x,y,/dev
   wait,.1
   if(!err eq 1 and x ge 0 and x le n and y ge 0 and y le m) then begin
      x1=x-ncuad2
      if(x1 lt 0) then x1=0
      x2=x+ncuad2
      if(x2 gt n) then x2=n
      y1=y-ncuad2
      if(y1 lt 0) then y1=0
      y2=y+ncuad2
      if(y2 gt m) then y2=m
  
      cx1=x1-x+ncuad2
      cx2=x2-x+ncuad2
      cy1=y1-y+ncuad2
      cy2=y2-y+ncuad2
      dat(x1:x2,y1:y2)= dat(x1:x2,y1:y2)+cuad(cx1:cx2,cy1:cy2)
      
      wset,0
      tv,datb(x1:x2,y1:y2)+cuadb(cx1:cx2,cy1:cy2),x1,y1
   endif else if(!err eq 2) then begin
      print,'calculando el espectro de potencias'
      pradial,dat,px,kr1,pkr1
      wset,1
      plot,alog(kr),alog(pkr),thick=2,xtitle='ln(px)',ytitle='ln(power)'
      oplot,alog(kr1),alog(pkr1),lin=2
      print,'listo
   endif

endwhile

return
end
