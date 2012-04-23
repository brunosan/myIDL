pro modula,delta,f

ang=findgen(91)

rad=ang*!pi/180.
cc=cos(rad)
ss=sin(rad)
delta=findgen(360)-180
d=delta*!pi/180
f=fltarr(91,360)
for j=0,90 do begin
   c=cc(j)
   s=ss(j)
   g=(c-s) * (c-s*cos(d)) * (s*sin(d)+cos(d)) / (c+s)  
   g=g-(c*c+s*s*cos(d)+s*sin(d))*sin(d)
   f(j,*)=g
endfor

return
end
 
