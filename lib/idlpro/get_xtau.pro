function get_xtau,lambda,ang

refr_ind=n_k_mirror(lambda)
n=refr_ind(0)
k=refr_ind(1)

rad=ang*!pi/180.

p=n^2.-k^2.-sin(rad)^2.
q=4.*n^2.*k^2.

f2=1./2.*(p+sqrt(p^2.+q))
g2=1./2.*(-p+sqrt(p^2.+q))

if(k eq 0) then r=0 else r=2.*sqrt(f2)*sin(rad)*tan(rad) 
s=sin(rad)^2.*tan(rad)^2.

x2=(f2+g2-r+s)/(f2+g2+r+s)
x=sqrt(x2)

tantau=2.*sqrt(g2)*sin(rad)*tan(rad)/(s-f2-g2)

tau=atan(tantau)*180./!pi
if (tau le 0.) then tau=tau+180.

return,[x,tau]
end
