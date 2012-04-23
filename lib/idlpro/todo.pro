pro todo,ind,display=display,teles=teles,bitpix=bitpix,desp=desp

if(keyword_set(display) eq 0) then display=0
if(keyword_set(teles) eq 0) then teles=0
if(keyword_set(bitpix) eq 0) then bitpix=0
if(keyword_set(desp) eq 0) then desp=0

map_in   ='scans/'+['08','10','10','08','08','09','09','10','10']+ $
          'oct98.'+ $
          ['003','004','010','004','012','003','008','005','009']
fileff   =['08','10','10','08','08','09','09','10','10']+'oct98.'+ $
          ['002','001','012','002','007','005','005','001','012']
filecalib=['08','10','10','08','08','09','09','10','10']+'oct98.'+ $
          ['001','002','011','001','010','006','008','006','011']

;map_in(ind)=fileff(ind)

pzero=[0.4,0.4,-23.,0.4,0.4,-23.5,-23.5,-1.1,-23.]
rzero=[0.,0.,-21.5,0.,0.,-21.5,-21.5,-21.5,-21.5]
delta=89.7

acum2iquv,map_in(ind),fileff(ind),filecalib(ind),pzero(ind),rzero(ind),$
   delta,display=display,teles=teles,bitpix=bitpix,desp=1
      

return
end
