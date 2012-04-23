pro thpol_ret,hdr,thpol,thret

posmax=1000

tam=size(hdr)
thpol=fltarr(posmax)
thret=fltarr(posmax)

cntpol=0
cntret=0
for j=0,tam(1)-1 do begin
   angpol=0
   while(angpol ne -1) do begin
      angpol=strpos(hdr(j),'INSPOLAR=',angpol)
      if(angpol ne -1) then begin
	 thpol(cntpol)=float(strmid(hdr(j),angpol+10,20))
         cntpol=cntpol+1
	 angpol=angpol+1
      endif
   endwhile

   angret=0
   while(angret ne -1) do begin
      angret=strpos(hdr(j),'INSRETAR=',angret)
      if(angret ne -1) then begin
	 thret(cntret)=float(strmid(hdr(j),angret+10,20))
         cntret=cntret+1
	 angret=angret+1
      endif
   endwhile
endfor

thpol=thpol(0:cntpol-1)
thret=thret(0:cntret-1)

return
end      	 
