function planckb,lambda,T,blbu
; lambda en A
; T en K

h=6.62626176e-34
k=1.380662e-23
c=2.99792458e8
lam=lambda*1e-10
nu=double(c/lam)
nu3=nu*nu*nu

return,2*h*nu3/c/c/(blbu*exp(h*nu/k/T)-1)
end
