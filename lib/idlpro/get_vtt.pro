function get_vtt,filem1,filew,lambda=lambda,theta=theta

obs_m1=get_stokesn(filem1,hdr)
tam=size(obs_m1)
npos_m1=tam(1)
step_m1=180./(npos_m1-1)
th_m1=findgen(npos_m1)*step_m1
gpol_m1=sqrt(total(obs_m1*obs_m1,2))
gpolm_m1=mean(gpol_m1)
q_m1=sqrt(sqrt((1-gpolm_m1)/(1+gpolm_m1)))
z=where(obs_m1(*,0) eq max(obs_m1(*,0)))
z=z(0)
th0_m1=-th_m1(z)
pesoq_m1=1.
pesou_m1=1.
pesov_m1=1.
tamobs_m1=size(obs_m1)
peso_m1=fltarr(tamobs_m1(1),tamobs_m1(2))
peso_m1(*,0)=pesoq_m1
peso_m1(*,1)=pesou_m1
peso_m1(*,2)=pesov_m1


obs_w=get_stokesn(filew)
tam=size(obs_w)
npos_w=tam(1)
step_w=180./(npos_w-1)
if(lambda eq 10830) then npos_w=npos_w-1
obs_w=obs_w(0:npos_w-1,*)
th_w=findgen(npos_w)*step_w
gpol_w=sqrt(total(obs_w*obs_w,2))
gpolm_w=mean(gpol_w)
q_w=sqrt((1-gpolm_w)/(1+gpolm_w))
z=where(obs_w(*,0) eq max(obs_w(*,0)))
z=z(0)
th0_w=-th_w(z)
pesoq_w=10.
pesou_w=10.
pesov_w=10.
tamobs_w=size(obs_w)
peso_w=fltarr(tamobs_w(1),tamobs_w(2))
peso_w(*,0)=pesoq_w
peso_w(*,1)=pesou_w
peso_w(*,2)=pesov_w


time=param_fits(hdr,'UT      =',delimiter=':',vartype=1) 
time=time(*,0)+(time(*,1)+time(*,2)/60.)/60.
time=time[0]
date=reform(param_fits(hdr,'DATE-OBS=',delimiter='-',vartype=1))
dum=date[0]
date[0]=date[2]
date[2]=dum
angles=get_angles(date[2],date[1],date[0],time,theta,decSun)

th2=angles(3)+90
th3=angles(4)
i1=angles(0)
i2=angles(1)
i3=0.85
r2=rotacion(th2)
r3=rotacion(th3)


xtau1=get_xtau(lambda,i1)
xtau2=get_xtau(lambda,i2)
xtau3=get_xtau(lambda,i3)

x1=xtau1(0)
tau1=xtau1(1)
x2=xtau2(0)
tau2=xtau2(1)
x3=xtau3(0)
tau3=xtau2(1)
th0_m1=th2+th3+th0_m1

loadct,2

sol=[x1,tau1,x2,tau2,x3,tau3,th0_m1,th0_w,q_m1,q_w]
;     0   1   2   3   4   5     6     7    8    9	
free=[1,  1,  1,  1,  1,  1,    1,    1,   1,   1]
zfree=where(free eq 1)
		
print,'valores iniciales: '
print,sol

eps=1

uno=[1,0,0,0]

obs=[obs_m1,obs_w]
th=[th_m1,th_w]
npos=npos_m1+npos_w

peso=[peso_m1,peso_w]

maxiter=50
iter=0
while(eps gt 1.e-3 and iter le maxiter) do begin
   iter=iter+1
   luzin=fltarr(npos,4)
   m1=espejo(sol(0),sol(1))
   m2=r3#espejo(sol(2),sol(3))#r2
   m4m3=rotacion(-90)#espejo(sol(4),sol(5))#espejo(sol(4),sol(5))#rotacion(90)
   for j=0,npos_m1-1 do begin
      luzin(j,*)=m4m3#m2#impolariz2(sol(8),th(j)+sol(6))#m1# $
                    impolariz2(sol(8),-th(j)-sol(6))#uno
   endfor
   for j=npos_m1,npos-1 do begin
      luzin(j,*)=m4m3#impolariz2(sol(9),-th(j)+sol(7))#m2#m1#uno
   endfor

   sint=luzin(*,1:3)
   for j=0,npos-1 do sint(j,*)=sint(j,*)/luzin(j,0)
;   pause
;   print,sol
;  plot,obs-sint
;   plot,obs
;   oplot,sint,color=80
;   stop
;   pause
   res=reform((obs-sint)*peso,npos*3)

   derx1=fltarr(npos,4)
   dertau1=fltarr(npos,4)
   derx2=fltarr(npos,4)
   dertau2=fltarr(npos,4)
   derx3=fltarr(npos,4)
   dertau3=fltarr(npos,4)
   derth0_m1=fltarr(npos,4)
   derq_m1=fltarr(npos,4)
   derth0_w=fltarr(npos,4)
   derq_w=fltarr(npos,4)

   dm1dx=despejo_x(sol(0),sol(1))
   dm1dtau=despejo_tau(sol(0),sol(1))
   dm2dx=r3#despejo_x(sol(2),sol(3))#r2
   dm2dtau=r3#despejo_tau(sol(2),sol(3))#r2

   for j=0,npos_m1-1 do begin
      derx1(j,*)=m4m3#m2#impolariz2(sol(8),th(j)+sol(6))#dm1dx# $
                    impolariz2(sol(8),-th(j)-sol(6))#uno
      dertau1(j,*)=m4m3#m2#impolariz2(sol(8),th(j)+sol(6))#dm1dtau# $
                    impolariz2(sol(8),-th(j)-sol(6))#uno
      derx2(j,*)=m4m3#dm2dx#impolariz2(sol(8),th(j)+sol(6))#m1# $
                    impolariz2(sol(8),-th(j)-sol(6))#uno
      dertau2(j,*)=m4m3#dm2dtau#impolariz2(sol(8),th(j)+sol(6))#m1# $
                    impolariz2(sol(8),-th(j)-sol(6))#uno
      derth0_m1(j,*)=m4m3#(m2#dimpolariz2_th(sol(8),th(j)+sol(6))#m1# $
                    impolariz2(sol(8),-th(j)-sol(6))  -  $
		    m2#impolariz2(sol(8),th(j)+sol(6))#m1# $
                    dimpolariz2_th(sol(8),-th(j)-sol(6)) )#uno
      derq_m1(j,*)=m4m3#(m2#dimpolariz2_q(sol(8),th(j)+sol(6))#m1# $
                    impolariz2(sol(8),-th(j)-sol(6))  +  $
		 m2#impolariz2(sol(8),th(j)+sol(6))#m1# $
                    dimpolariz2_q(sol(8),-th(j)-sol(6)) )#uno
   endfor

   dm4m3dq=rotacion(-90)#despejo_x(sol(4),sol(5))#espejo(sol(4),sol(5))#rotacion(90)+ $
          rotacion(-90)#espejo(sol(4),sol(5))#despejo_x(sol(4),sol(5))#rotacion(90)
   dm4m3dtau=rotacion(-90)#despejo_tau(sol(4),sol(5))#espejo(sol(4),sol(5))#rotacion(90)+ $
          rotacion(-90)#espejo(sol(4),sol(5))#despejo_tau(sol(4),sol(5))#rotacion(90)
   for j=npos_m1,npos-1-1 do begin
      derx3(j,*)=dm4m3dq#impolariz2(sol(9),-th(j)+sol(7))#m2#m1#uno
      dertau3(j,*)=dm4m3dtau#impolariz2(sol(9),-th(j)+sol(7))#m2#m1#uno
      derth0_w(j,*)=m4m3#dimpolariz2_th(sol(9),-th(j)+sol(7))#m2#m1#uno
      derq_w(j,*)=m4m3#dimpolariz2_q(sol(9),-th(j)+sol(7))#m2#m1#uno
   endfor

   
   derx1=derx1(*,1:3)
   for j=0,npos-1 do derx1(j,*)=derx1(j,*)/luzin(j,0)
   dertau1=dertau1(*,1:3)
   for j=0,npos-1 do dertau1(j,*)=dertau1(j,*)/luzin(j,0)

   derx2=derx2(*,1:3)
   for j=0,npos-1 do derx2(j,*)=derx2(j,*)/luzin(j,0)
   dertau2=dertau2(*,1:3)
   for j=0,npos-1 do dertau2(j,*)=dertau2(j,*)/luzin(j,0)

   derx3=derx3(*,1:3)
   for j=0,npos-1 do derx3(j,*)=derx3(j,*)/luzin(j,0)
   dertau3=dertau3(*,1:3)
   for j=0,npos-1 do dertau3(j,*)=dertau3(j,*)/luzin(j,0)

   derth0_m1=derth0_m1(*,1:3)
   for j=0,npos-1 do derth0_m1(j,*)=derth0_m1(j,*)/luzin(j,0)
   derth0_w=derth0_w(*,1:3)
   for j=0,npos-1 do derth0_w(j,*)=derth0_w(j,*)/luzin(j,0)

   derq_m1=derq_m1(*,1:3)
   for j=0,npos-1 do derq_m1(j,*)=derq_m1(j,*)/luzin(j,0)
   derq_w=derq_w(*,1:3)
   for j=0,npos-1 do derq_w(j,*)=derq_w(j,*)/luzin(j,0)

   derx1=derx1*peso
   dertau1=dertau1*peso
   derx2=derx2*peso
   dertau2=dertau2*peso
   derx3=derx3*peso
   dertau3=dertau3*peso
   derth0_m1=derth0_m1*peso
   derth0_w=derth0_w*peso
   derq_m1=derq_m1*peso
   derq_w=derq_w*peso
   
   xx=[[reform(derx1,npos*3)],[reform(dertau1,npos*3)],$
      [reform(derx2,npos*3)],[reform(dertau2,npos*3)],$
      [reform(derx3,npos*3)],[reform(dertau3,npos*3)],$
      [reform(derth0_m1,npos*3)],[reform(derth0_w,npos*3)],$
      [reform(derq_m1,npos*3)],[reform(derq_w,npos*3)]]

   coef=lstsqfit(xx(*,zfree),res)
   eps=max(abs(coef(*,0)))
;   print,coef
;   stop
   sol(zfree)=sol(zfree)+coef(*,0)
   sol(1)= sol(1) MOD 360
   sol(3)= sol(3) MOD 360
   sol(5)= sol(5) MOD 360
   sol(6)= sol(6) MOD 180
   while(sol(6) gt 180) do sol(6)=sol(6)-180.
   while(sol(6) lt 0) do sol(6)=sol(6)+180.
   sol(7)= sol(7) MOD 180
   while(sol(7) gt 180) do sol(7)=sol(7)-180.
   while(sol(7) lt 0) do sol(7)=sol(7)+180.
   if(sol(9) lt 0) then begin
      sol(9)=-sol(9)
;      sol(5)=sol(5)
   endif   
;   print,coef(*,0)
;   print,sol
   
endwhile

!p.multi=[0,1,2]
plot,obs-sint,/xsty
plot,obs,/xsty
oplot,sint,color=80
print,'# iteraciones: '
print,iter
print,'valores finales: '
print,sol
print,'errores: '
print,coef(*,1)
print,' '
!p.multi=0
return,sol
end
