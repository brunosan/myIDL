pro red_gct,lambda,n_orden

deg2rad=!pi/180.
rad2deg=180/!pi

phi=60.*deg2rad
gamma=1.7285*deg2rad

d=1/317e-7	;separacion entre rayas en angstrom en la red
focal=10000.	;focal en mm del espejo de camara

lambdab=2*d*sin(phi)*cos(gamma)/n_orden
disp=focal*n_orden/d/cos(phi-gamma)

print,'   orden   lambda blaze  dispersion(mm/A)'
print,n_orden,lambdab,disp

sinbeta=n_orden*float(lambda)/d/2./cos(gamma)
if(abs(sinbeta) gt 1) then begin
   print,lambda, ' A no es visible en ese orden'
endif else begin
   beta=(asin(sinbeta)-gamma)
   disp=focal*n_orden/d/cos(beta)
   print,'      orden   lambda        beta   dispersion(mm/A)'
   print,n_orden,lambda,beta*rad2deg,disp
   print,' '
   print,'longitudes de onda ordenes anterior y posterior'
   lambda1=2*d*sin(beta+gamma)*cos(gamma)/(n_orden-1)
   lambda2=2*d*sin(beta+gamma)*cos(gamma)/(n_orden+1)
   print,lambda1,lambda2

endelse

return
end
