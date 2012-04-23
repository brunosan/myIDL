pro eq_retarder,th1,ret1,th2,ret2

p=[1,1,0,0]#retarder(th1,ret1)#retarder(th2,ret2)

theta2=atan(1-p(1),p(2))
sth=sin(theta2)
cd=1-(1-p(1))/sth/sth

theta2=theta2*90./!pi
delta=acos(cd)*180./!pi

print,transpose(p)
print,transpose([1,1,0,0]#retarder(theta2,delta))

;stop
return
end

