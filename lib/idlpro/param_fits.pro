function param_fits,hdr,keyw,vartype=vartype,delimiter=delimiter

if(keyword_set(vartype) eq 0) then vartype=0
if(keyword_set(delimiter) eq 0) then delimiter='false'

posmax=10000

tam=size(hdr)
;param=fltarr(posmax)
param=strarr(posmax)

cnt=0
for j=0,tam(1)-1 do begin
   pos=0
   while(pos ne -1) do begin
      pos=strpos(hdr(j),keyw,pos)
      if(pos ne -1) then begin
;	 param(cnt)=float(strmid(hdr(j),pos+10,20))
	 param(cnt)=strmid(hdr(j),pos+10,20)
         cnt=cnt+1
	 pos=pos+1
      endif
   endwhile

endfor


if(cnt ne 0) then begin
   if(delimiter ne 'false') then begin
      posdel=intarr(posmax)
      pos=0
      cnt2=0

      pos=strpos(param(0),"'",pos)
      if(pos ne -1) then begin 
         posdel(cnt2)=pos
	 cnt2=cnt2+1
	 pos=pos+1
      endif else begin
         podel(cnt2)=-1	 
	 cnt2=cnt2+1
	 pos=pos+1
      endelse

      while(pos ne -1) do begin
         pos=strpos(param(0),delimiter,pos)
         if(pos ne -1) then begin 
	    posdel(cnt2)=pos
	    cnt2=cnt2+1
	    pos=pos+1
	 endif
      endwhile

      pos=strpos(param(0),"'",posdel(cnt2-1)+1)
      if(pos ne -1) then begin 
         posdel(cnt2)=pos
	 cnt2=cnt2+1
	 pos=pos+1
      endif else begin
         podel(cnt2)=20	 
	 cnt2=cnt2+1
	 pos=pos+1
      endelse

      posdel=posdel(0:cnt2-1)
   endif else begin
      posdel=[-1,20]
   endelse
   param=param(0:cnt-1)

   if(vartype eq 0) then begin
      param_out=strarr(n_elements(param),n_elements(posdel)-1)
      for j=0,n_elements(posdel)-2 do begin
         for i=0,n_elements(param)-1 do begin
            param_out(i,j)= $
	       strtrim(strmid(param(i),posdel(j)+1,posdel(j+1)-posdel(j)-2),2)
	  endfor     
      endfor	 
   endif else if(vartype eq 1) then begin
      param_out=intarr(n_elements(param),n_elements(posdel)-1)
      for j=0,n_elements(posdel)-2 do begin
         for i=0,n_elements(param)-1 do begin
            param_out(i,j)= $
	       fix(strmid(param(i),posdel(j)+1,posdel(j+1)-posdel(j)-1))
	  endfor     
      endfor	 
   endif else if(vartype eq 2) then begin
      param_out=lonarr(n_elements(param),n_elements(posdel)-1)
      for j=0,n_elements(posdel)-2 do begin
         for i=0,n_elements(param)-1 do begin
            param_out(i,j)= $
	    long(strmid(param(i),posdel(j)+1,posdel(j+1)-posdel(j)-1))
	  endfor     
      endfor	 
   endif else if(vartype eq 3) then begin
      param_out=fltarr(n_elements(param),n_elements(posdel)-1)
      for j=0,n_elements(posdel)-2 do begin
         for i=0,n_elements(param)-1 do begin
            param_out(i,j)= $
	    float(strmid(param(i),posdel(j)+1,posdel(j+1)-posdel(j)-1))
	  endfor     
      endfor	 
   endif else if(vartype eq 4) then begin
      param_out=dblarr(n_elements(param),n_elements(posdel)-1)
      for j=0,n_elements(posdel)-2 do begin
         for i=0,n_elements(param)-1 do begin
            param_out(i,j)=$ 
	    double(strmid(param(i),posdel(j)+1,posdel(j+1)-posdel(j)-1))
	  endfor     
      endfor
   endif
   if(n_elements(param_out) eq 1) then param_out=param_out(0)
endif else begin
   print,'KEYWORD desconocida'   
   param_out=0
endelse   

return,param_out
end      	 
