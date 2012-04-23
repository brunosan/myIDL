pro ver_dc,n_file,ps=ps

file=['08','08','09','10','16','17','17','29','29']+'oct98.'$
   +['000','006','000','000','002','000','003','000','001']

if(n_file lt 0 or n_file gt n_elements(file)-1) then begin
   print,'el no. de fichero debe estar comprendido entre 0 y ',$
      n_elements(file) 
   return
endif
      
dum=rfits_im(file(n_file),1,dd,hdr,/desp)

npos=dd.naxis3/4

dcm=fltarr(npos,4)

n_menos1=lonarr(npos,4)

for i=0,npos-1 do begin
   for j=0,3 do begin
      dum=rfits_im(file(n_file),4*i+j+1,dd,hdr,/desp)
      dcm(i,j)=mean(dum>0)
      n_menos1(i,j)=n_elements(where(dum eq -1))
   endfor
endfor

!p.multi=[0,2,2]
if(keyword_set(ps) eq 1) then begin
   set_plot,'ps'
   device,filename=file(n_file)+'.ps'
   for j=0,3 do plot,dcm(*,j),yrange=[0,500],title=file(n_file),ytit='DC',$
      charsize=1.0   
   for j=0,3 do plot,n_menos1(*,j),yrange=[0,20000],title=file(n_file),$
      ytit='no. -1',charsize=1.0      
   device,/close
   device,filename='dc_exmpl.ps'
   dumlab=rfits_im(file(8),190,dd,hdr,/desp)
   dumvtt=rfits_im(file(0),2,dd,hdr,/desp)
   dumgct=rfits_im(file(6),2,dd,hdr,/desp)
   !p.multi=[0,2,3]
   plot,dumlab(*,165),/xsty,ytit='DC scan',tit='LAB',yrange=[-100,1500],/ysty
   plot,dumlab(*,165),/xsty,ytit='DC scan',tit='LAB',yrange=[-100,100],/ysty
   plot,dumvtt(*,135),/xsty,ytit='DC scan',tit='VTT',yrange=[-100,1500],/ysty
   plot,dumvtt(*,135),/xsty,ytit='DC scan',tit='VTT',yrange=[-100,100],/ysty
   plot,dumgct(*,103),/xsty,ytit='DC scan',tit='GCT',yrange=[-100,1500],/ysty
   plot,dumgct(*,103),/xsty,ytit='DC scan',tit='GCT',yrange=[-100,100],/ysty
   device,/close
   set_plot,'x'
endif else begin
   for j=0,3 do plot,dcm(*,j),yrange=[0,500],title=file(n_file),ytit='DC',$
      charsize=1.0
   pause
   for j=0,3 do plot,n_menos1(*,j),yrange=[0,20000],title=file(n_file),$
      ytit='no. -1',charsize=1.0      
endelse

!p.multi=0      
return
end      
