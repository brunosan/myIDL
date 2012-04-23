pro calib_vtt

file=['08','08','09','09','09','09','10','10','10']+'oct98.'$
   +['001','010','002','006','008','009','002','006','011']

pzero=   [0.4,0.4,0.4,-23,-23,0.4,0.4,-1.1,-23]
rzero=[0.,0.,0.,-21.5,-21.5,0.,0.,-21.5,-21.5]
delta=[89.7,89.7,89.7,89.7,89.7,89.7,89.7,89.7,89.7]

mm=fltarr(4,4,n_elements(file))

data=0
for j=0,n_elements(file)-1 do begin
   print,file(j)
   print,' '
   calib2_mod,file(j),m,pzero(j),rzero(j),delta(j),data=data
   mm(*,*,j)=m
endfor   
   
uth=[9,13,9,11,11,14,8,10,12]
utm=[35,57,19,27,51,18,40,2,29]  

ut=uth+utm/60.

set_plot,'ps'
device,filename='calib_vtt.ps',/landscape
!p.multi=[0,4,4]
for i=0,3 do for j=0,3 do plot,ut,mm(i,j,*),psym=1,/ynoz,charsize=1.5
device,/close
set_plot,'x'
!p.multi=0

stop
return
end
