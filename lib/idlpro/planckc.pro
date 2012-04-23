function planckc,lambda,T
; lambda en A
; T en K

h=6.62626176e-27
k=1.380662e-16
c=2.99792458e10

;c1=2*h*c*c*1.e32
;c2=h*c*1e8/k

lam=lambda*1e-8

return,2*h*c*c*1.e-8/lam^5/(exp(h*c/lam/k/T)-1)
;return,c1/lambda^5/(exp(c2/lambda/T)-1)
end
