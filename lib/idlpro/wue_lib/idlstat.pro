pro idlstat,head,maxi,versch,ende,file,title=str1,art=str2
;
; gibt eine Monatsstatistik aus
; in dem File file muessen die Daten formatiert stehen:
;     x y    (x: Zeit in Tagen  y: Statistik)
;
; PARAMETER:
;   head: Anzahl der Tage, die am Anfang ueberlesen werden
;   maxi: y-Wert, der 100% entspricht
;   versch: x=1.0 entspricht Sonntag+(versch Wochentage)
;   ende: letzter Tag des Monats
;

erase
if (n_elements(str1) eq 0) then str1=''
if (n_elements(str2) eq 0) then str2=''
head=head
nst=7*24
nw=5
pst=0.8/(nw+1)
pl=0.95
openr,1,file
if (head ne 0) then begin
  h=fltarr(2,head*24)
  readf,1,h
endif
a=fltarr(2,nst)
in=a
a(*,*)=0.
x=fltarr(nst)
y=x
xm=(findgen(nst)+24.0)/24.
ym=x
ym(*)=0.
nm=intarr(nst)
nm(*)=0
xr=[1.0-versch,8.0-versch]
for i=1,nw do begin
  if (versch ne 0) and (i eq 1) then begin
    i1=indgen(versch*24)
    a(*,i1)=0.
    i2=indgen(nst-versch*24)+versch*24
    in=in(0:1,0:max(i2)-min(i2))
    readf,1,in
    a(*,i2)=in(*,*)
  endif else begin
    a(*,*)=0.
    on_ioerror,weiter
    readf,1,a
    on_ioerror,null
  endelse
weiter:
  x(*)=a(0,*)-head
  y(*)=a(1,*)/maxi*100.*(x le ende)
  ym(*)=ym(*)+y(*)
  nm=nm+1*(x le ende)*(x ge 1)
  plot,x,y,position=[0.2,pl-pst+0.03,0.9,pl],/noerase,yrange=[0,100],xrange=xr,xstyle=1,xminor=24,xticks=7,/nodata,xticklen=0.1
  for j=0,167 do begin
    x1=x(j)-1.0/48.
    x2=x(j)+1.0/48.
    y2=y(j)
    if (y2 gt 100.0) then y2=100.0
    polyfill,[x1,x1,x2,x2],[0.,y2,y2,0.],col=100
  endfor
  plot,x,y,psym=10,position=[0.2,pl-pst+0.03,0.9,pl],/noerase,yrange=[0,100],xstyle=1,xminor=24,xticks=7,xrange=xr
  xr=xr+7.0
  pl=pl-pst
endfor
close,1
plot,xm,ym/nm,psym=10,position=[0.2,pl-pst-.1,0.9,pl-0.1],/noerase,yrange=[0,100],xstyle=1,/nodata,ytitle='Mittel',xminor=24,xticklen=0.1,xticks=7,xrange=[1.,8.]
str=['Sonntag','Montag','Dienstag','Mittwoch','Donnerst.','Freitag','Samstag']
t=[1.5,2.5,3.5,4.5,5.5,6.5,7.5]
axis,xaxis=1.,xtickname=str,xticks=6,xstyle=1,/noerase,xtickv=t,/save,ticklen=0
for j=0,167 do begin
  x1=xm(j)-1.0/48.
  x2=xm(j)+1.0/48.
  y2=ym(j)/nm(j)
  if (y2 gt 100.0) then y2=100.0
  polyfill,[x1,x1,x2,x2],[0.,y2,y2,0.],col=200
endfor
plot,xm,ym/nm,psym=10,position=[0.2,pl-pst-.1,0.9,pl-0.1],/noerase,yrange=[0,100],xstyle=1,xminor=24,xticks=7,xrange=[1.,8.]
xyouts,0.3, 200.0,str2,orientation=90,size=2
xyouts,3.,680.0,str1,size=2.5
end
