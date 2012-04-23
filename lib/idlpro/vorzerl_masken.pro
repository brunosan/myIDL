;+
; NAME:
;	 VORZERL_MASKEN
; PURPOSE:
;	 Computes the Positions of spectral lines in the focal plane of
;	 the VTT Echelle Spectrograph, including the neccessary
;        dimensions for the predisperser mask.
;*CATEGORY:            @CAT-# 24 37@
;	 Observer Support , Tools
; CALLING SEQUENCE:
;	 VORZERL_MASKEN
; INPUTS:
;	 None. You are prompted for all necessary input
; OUTPUTS:
; 	 Results are printed to STDOUT or a file resp.
; COMMON BLOCKS:
;        common block MASK_DATA
; SIDE EFFECTS:
; 	 Common Block MASK_DATA is created.
;	 Procedures VORZERL_AUX1 and VORZERL_AUX2 are compiled (if not
;	 already present) 
; RESTRICTIONS:
;        The program doesn't check for all unreasonable results. For
;        example the observer himself should avoid predisperser mask
;        slitwidths of less than 0.2mm or distances lower than about
;        1-2mm (this because of technical difficulties in manufacturing.
; 	 If any problems arise, please contact ps@kis.uni-freiburg.de
; PROCEDURE:
; 	 You will be asked to type in the wavelengths of those lines you wish
;	 to observe. The results are printed to standard output.
;	 A more detailed manual is available in our local info-system:
;	 >info vorzerl_masken.dvi
; MODIFICATION HISTORY:
;        ps (KIS), 1992-02-13
;        nlte (KIS) 1992-02-17 : minor updates (MASKE -> VORZERL_MASKE)
;        ps (KIS)  1992-05-05 : include variation of predisperser
;           dispersion with wavelength. Allow for wavelengths > 9999 A.
;	    possibility of output in File. update of device dependent
;	    parameters (list of D. Soltau, april 16,1992)
;        ps (KIS) 1992-06-05 : correction of wrong output when using
;           wavelength ranges
;        ps (KIS) 1992-06-12 updated version 3.0
;           New features: Search for alternative Wavelengths by Position
;	    in the focal plane. Selection of alternative order also for bad
;	    cases (out of blaze) possible (marked by negative order).
;	    Change language to english
;        ps (KIS) 1992-06-30 new variable BRANGE: half of usuable range 
;           around blaze angle. used for determining the possibility of
;	    alternative order. can be changed by the user
;---

pro vorzerl_aux1
;
; NAME:
;	vorzerl_aux1
; PURPOSE:
;	read the wavelengths for the program vorzerl_masken
;	from standard input
;*CATEGORY:            @CAT-# 24 37@
;	Interactive I/O
; CALLING SEQUENCE:
;	vorzerl_aux1
; INPUTS:
;	none
; OPTIONAL INPUT PARAMETER:
;	none
; OUTPUTS:
; 	none
; COMMON BLOCKS:
;       common block MASK_DATA, created by the main procedure
; SIDE EFFECTS:
; 	Contens of MASK_DATA is changed
; RESTRICTIONS:
; 	only usefull when called from vorzerl_masken
; MODIFICATION HISTORY:
;	PS (KIS) 1992-06-10
;  ---
on_error,2
common mask_data,lams,ber,ordnung,aord,angles,angle,n_wl,lrange,lzent,$
       blaz,brange,g2,ml,d_vz5,d_vz,f_s,vfak,ga0,vz0,vzst,ew,skip,left,up
print & print
repeat begin
  writeu,-1,up,'  <N>ew or <a>dditional wavelength (N/A)? ',left
  ch='' & read,ch & ch=strupcase(ch)
endrep until strpos('NA',ch) ge 0 and ch ne ''
if ch eq 'N' then n_wl=0
on_ioerror,fehleingabe
repeat begin
  print
  print,'Please enter wavelength '+strtrim(n_wl+1,1)+' (in Angstroem)'+ $
        ' (RETURN = Ende)'
  wl='' & read,wl
  if wl ne '' then begin
    p=strpos(wl,'-')
    if (n_wl eq 0) then begin
      if p eq -1 then begin
        lams=float(strtrim(wl)) & ber=0.
      endif else begin
        lams=float(strtrim(strmid(wl,0,p)))
        ber=float(strtrim(strmid(wl,p+1,strlen(wl)-p-1)))
        if lams gt ber then begin
          tmp=ber & ber=lams & lams=tmp
        endif
      endelse
      ordnung=fix(ml/lams+0.5)
      d0=ordnung-ml/lams
      aord=fix(ordnung-d0/abs(d0))
      da=blaz-asin(aord*lams/g2)
      if abs(da) gt brange then aord=-aord
      angles=asin(ordnung*lams/g2)
    endif else begin
      if p eq -1 then begin
        lams=[lams,float(strtrim(wl))] & ber=[ber,0.]
      endif else begin
        lams=[lams,float(strtrim(strmid(wl,0,p)))]
        ber=[ber,float(strtrim(strmid(wl,p+1,strlen(wl)-p-1)))]
        if lams(n_wl) gt ber(n_wl) then begin
          tmp=ber(n_wl) & ber(n_wl)=lams(n_wl) & lams(n_wl)=ber(n_wl)
        endif
      endelse
      ordnung=[ordnung,fix(ml/lams(n_wl)+0.5)]
      d0=ordnung(n_wl)-ml/lams(n_wl)
      aord=[aord,fix(ordnung(n_wl)-d0/abs(d0))]
      da=blaz-asin(aord(n_wl)*lams(n_wl)/g2)
      if abs(da) gt brange then aord(n_wl)=-aord(n_wl)
      angles=[angles,asin(ordnung(n_wl)*lams(n_wl)/g2)]
    endelse
    n_wl=n_wl+1
  endif
endrep until wl eq ''
if n_wl gt 1 then begin
  index=sort(lams)
  lams=lams(index)
  ordnung=ordnung(index)
  aord=aord(index)
  ber=ber(index)
  angles=angles(index)
endif
return
fehleingabe:
print
print,'The data you entered were not successfully interpreted.'
print,'Please check for the right format.'
print,'Continue: RETURN'
  ch='' & read,ch 
on_ioerror,null
return
end

function vorzerl_aux2
;
; NAME:
;	vorzerl_aux2
; PURPOSE:
;	compute the width and position of a predisperser mask for the VTT
; CALLING SEQUENCE:
;	vorzerl_aux2
; INPUTS:
;	none
; OUTPUTS:
; 	none
; COMMON BLOCKS:
;       common block MASK_DATA, created by the main procedure
; SIDE EFFECTS:
; 	Contens of MASK_DATA is changed
; RESTRICTIONS:
; 	only usefull if called from vorzerl_masken
; MODIFICATION HISTORY:
;	PS (KIS) 1992-06-10
;  ---
on_error,2
common mask_data,lams,ber,ordnung,aord,angles,angle,n_wl,lrange,lzent,$
       blaz,brange,g2,ml,d_vz5,d_vz,f_s,vfak,ga0,vz0,vzst,ew,skip,left,up
ex=[-1.5,0,-1.5,1.5,0,1.5,0,0]
eu=[0,0,-1.5,-1.5,0,0,0,-4] & ed=-eu
m_h=160.      ; height of mask (mm)
m_w=119.      ; width of mask  (mm)


cew=cos(ew)

if n_wl eq 0 then begin
  print
  print,'Please enter at least one wavelength !'
  print,'Continue: RETURN'
  ch='' & read,ch
  return,1
endif
if n_wl eq 1 then begin
  print
  print,lams(0),form="('Only one wavelength : Lambda = ',f10.3,' A')"
  print,'Line position in the center of the spectrograph focal plane.'
  print,'Use standard central mask.'
  print,f_s*2*abs(ordnung(0))/g2/cos(angles(0)), $
    format="('Dispersion in the focal plane: ',f7.5,' cm/A')"
  print,'Device settings:'
  print
  print,vz0-lams(0)*vzst,form="('Predisperser : ',f8.1)"
  print
  print,fix(ga0-100*angles(0)/!pi*180.+0.5),form="('Grating       : ',i8)"
  goto,end_print
endif
nm1=n_wl-1
x_mask=fltarr(n_wl)
dx_mask=fltarr(n_wl)
x_lam=fltarr(n_wl)
x_ber=fltarr(n_wl)
disp=fltarr(n_wl)
lma=max([lams,ber]) & ix=where(ber gt 0)
if ix(0) ge 0 then lmi=min([lams,ber(ix)]) else lmi=min(lams)
if lma-lmi gt lrange then begin
  print
  print,'Wavelength range too large for predisperser mask !!!'
  print,lrange,form="(i4,' A max. Please check. Continue: RETURN')"
  ch='' & read,ch
  return,1
endif
lzent=fix(lma+lmi)/2
zent:
print
print,lzent,format="('Central wavelength :  ',i5,' Angstroem')"
print
writeu,-1,'OK?  RETURN or new value '
choice='' & read,choice
if choice ne '' then begin
  ch=float(strtrim(choice))
  if (ch-lmi gt lrange/2) or (lma-ch gt lrange/2) then begin
    print
    print,"Doesn't fit into predisperser mask"
    goto,zent
  endif
  lzent=ch
endif
ang_vz=asin(lzent*75.0e-7)
d_vz=d_vz5/0.999297*cos(ang_vz)
for i=0,nm1 do begin
  if ber(i) eq 0 then x_mask(i)=(lams(i)-lzent)/d_vz $
  else x_mask(i)=((lams(i)+ber(i))/2-lzent)/d_vz
endfor
vrz=vz0-lzent*vzst
ai=where(angles eq min(angles),n_ai)
if n_ai gt 1 then ai=ai(0)
angle=blaz
for i=0,3 do $
  angle=asin(abs(ordnung(ai))*lams(ai)/g2-(-20-x_mask(ai)*vfak)/2/f_s*cos(angle))
angle=angle(0)
print & print
print,angle/!pi*180.,format="('Grating angle = ',f5.2,' Grad')"
print
writeu,-1,'OK?  RETURN or new value '
choice='' & read,choice
if choice ne '' then angle=float(strtrim(choice))/180.*!pi
for i=0,nm1 do begin
  l0=sin(angle)*g2/abs(ordnung(i))
  disp(i)=f_s*2*abs(ordnung(i))/g2/cos(angle)
  x_lam(i)=x_mask(i)*vfak+(lams(i)-l0)*disp(i)
  if ber(i) then x_ber(i)=x_mask(i)*vfak+(ber(i)-l0)*disp(i)
endfor
ix1=sort(x_lam)
if ber(ix1(0)) then r_l=x_ber(ix1(0)) else r_l=x_lam(ix1(0))
r_r=x_lam(ix1(1))
dy1=(r_r-r_l)*0.9
if dy1 lt 0 then begin
  ovpos=1 & goto,overlap
endif
dx_mask(ix1(0))=dy1/disp(ix1(0))/d_vz
if ber(ix1(0)) then dx_mask(ix1(0))=dx_mask(ix1(0))+ $
     (ber(ix1(0))-lams(ix1(0)))/d_vz
r_r=x_lam(ix1(nm1))
if ber(ix1(nm1-1)) then r_l=x_ber(ix1(nm1-1)) else r_l=x_lam(ix1(nm1-1))
dy1=(r_r-r_l)*0.9
if dy1 lt 0 then begin
  ovpos=nm1 & goto,overlap
endif
dx_mask(ix1(nm1))=dy1/disp(ix1(nm1))/d_vz
if ber(ix1(nm1)) then dx_mask(ix1(nm1))=dx_mask(ix1(nm1))+ $
     (ber(ix1(nm1))-lams(ix1(nm1)))/d_vz
if n_wl gt 2 then begin
  for i=1,nm1-1 do begin
    r_r=x_lam(ix1(i))
    if ber(ix1(i-1)) then r_l=x_ber(ix1(i-1)) else r_l=x_lam(ix1(i-1))
    dy1=(r_r-r_l)*0.9
    r_r=x_lam(ix1(i+1))
    if ber(ix1(i)) then r_l=x_ber(ix1(i)) else r_l=x_lam(ix1(i))
    dy2=(r_r-r_l)*0.9
    dx_mask(ix1(i))=min([dy1,dy2])/disp(ix1(i))/d_vz
    if dy1 lt 0 then begin
      ovpos=i & goto,overlap
    endif
    if ber(ix1(i)) then dx_mask(ix1(i))=dx_mask(ix1(i))+ $
         (ber(ix1(i))-lams(ix1(i)))/d_vz
  endfor
endif
goto,noover
overlap:
message,'Attention!',/cont
print,lams(ix1(ovpos)),x_lam(ix1(ovpos))+35,form= $
   "('Wavelength ',f9.3,', position ',f5.1,' overlaps with the')"
print,lams(ix1(ovpos-1)),ber(ix1(ovpos-1)),x_lam(ix1(ovpos-1))+35, $
   x_ber(ix1(ovpos-1))+35,form= $
   "('domain ',f9.3,' - ',f9.3,', ',f5.1,' - ',f5.1,'.')"
print,'Please change the domain boundaries. Continue: RETURN'
ch='' & read,ch
return,1
noover:
spawn,'clear'
print,angle/!pi*180.,format="('Grating angle =  ',f5.2,' Grad')"
print,fix(ga0-100*angle/!pi*180.+0.5),format="('Reading       =  ',i4)"
print,lzent,format="('Lambda_cent   = ',i5,' Angstroem')"
print,vrz,format="('Predisperser  =  ',f6.1)"
print
print,180*ew/!pi,form="('Predisperser mask for entrance slit angle ',f5.2)"
print
print,' No        Lambda           Y     dY'
print,'             [A]           [mm]  [mm]
for i=0,nm1 do begin
  if ber(i) eq 0 then begin
    print,i+1,lams(i),x_mask(i)*cew,dx_mask(i),$
    format="(i3,6x,f9.3,6x,f7.2,f6.2)"
  endif else begin
    print,i+1,lams(i),ber(i),x_mask(i)*cew,dx_mask(i),$
    format="(i3,x,f9.3,' -',f9.3,f7.2,f6.2)"
  endelse
endfor
print
print,skip,'Spectrum'
print
print,' Nr        Lambda        Ord     Disp    <X>         Range'
print,'             [A]                [cm/A]   [cm]         [cm]'
for i=0,nm1 do begin
  if ber(i) eq 0 then begin
    dy1=x_lam(i)+35-dx_mask(i)/2*d_vz*disp(i)
    dy2=x_lam(i)+35+dx_mask(i)/2*d_vz*disp(i)
    print,i+1,lams(i),ordnung(i),disp(i),x_lam(i)+35,dy1,dy2, $
    format="(i3,6x,f9.3,6x,i4,4x,f5.3,f8.1,3x,f6.1,' -',f6.1)"
  endif else begin
    dy=x_lam(i)+(x_ber(i)-x_lam(i))/2+35
    dy1=dy-dx_mask(i)/2*d_vz*disp(i)
    dy2=dy+dx_mask(i)/2*d_vz*disp(i)
    print,i+1,lams(i),ber(i),ordnung(i),disp(i),dy,dy1,dy2, $
    format="(i3,x,f9.3,' -',f9.3,i4,4x,f5.3,f8.1,3x,f6.1,' -',f6.1)"
  endelse
endfor
end_print:
print
print
repeat begin
  writeu,-1,up,' <O>k or change <L>ines or <S>lit widths ?',left
  ch='' & read,ch & ch=strupcase(ch)
endrep until strpos('OLS',ch) ge 0 and ch ne ''
if ch eq 'L' then return,1
if ch eq 'S' then begin
  for i=0,nm1 do begin
    writeu,-1,'New width for slit '+strtrim(i+1,1)+' or RETURN'
    ch='' & read,ch
    if ch ne '' then dx_mask(i)=float(ch)
  endfor
  goto,noover
endif
aus:
print & print
repeat begin
  writeu,-1,up,' Output to a file ?  (Y/N) '
  ch='' & read,ch & ch=strupcase(ch)
endrep until strpos('YN',ch) ge 0 and ch ne ''
if ch eq 'Y' then begin
  print,'Name of the file (Default: Vz_Mask.data)'
  ch='' & read,ch
  if ch eq '' then ch='Vz_Mask.data'
  close,1 & openw,1,ch,/append
  print,'Indentification header (1 line)'
  ch='' & read,ch
  printf,1,ch & printf,1
  if n_wl eq 1 then begin
    printf,1,lams(0),form="('Only one wavelength : Lambda = ',f10.3,' A')"
    printf,1,'Line position in the center of the spectrograph focal plane.'
    printf,1,'Use standard central mask.'
    printf,1,f_s*2*abs(ordnung(0))/g2/cos(angles(0)), $
      format="('Dispersion in the focal plane: ',f5.3,' cm/A')"
    printf,1,'Device settings:'
    printf,1
    printf,1,vz0-lams(0)*vzst,form="('Predisperser : ',f8.1)"
    printf,1
    printf,1,fix(ga0-100*angles(0)/!pi*180.+0.5),form="('Grating       : ',i8)"
    printf,1 & printf,1
    close,1
    return,0
  endif
  printf,1,angle/!pi*180.,format="('Grating angle =  ',f5.2,' Grad')"
  printf,1,fix(ga0-100*angle/!pi*180.+0.5),format="('Reading       =  ',i4)"
  printf,1,lzent,format="('Lambda_cent   = ',i5,' Angstroem')"
  printf,1,vrz,format="('Predisperser  =  ',f6.1)"
  printf,1
  printf,1,180*ew/!pi, $
         form="('Predisperser mask for entrance slit angle ',f5.2)"
  printf,1
  printf,1,' No        Lambda           Y     dY'
  printf,1,'             [A]           [mm]  [mm]
  for i=0,nm1 do begin
    if ber(i) eq 0 then begin
      printf,1,i+1,lams(i),x_mask(i)*cew,dx_mask(i),$
      format="(i3,6x,f9.3,6x,f7.2,f6.2)"
    endif else begin
      printf,1,i+1,lams(i),ber(i),x_mask(i)*cew,dx_mask(i),$
      format="(i3,x,f9.3,' -',f9.3,f7.2,f6.2)"
    endelse
  endfor
  printf,1
  printf,1,skip,'Spectrum'
  printf,1
  printf,1,' Nr        Lambda        Ord     Disp    <X>         Range'
  printf,1,'             [A]                [cm/A]   [cm]         [cm]'
  for i=0,nm1 do begin
    if ber(i) eq 0 then begin
      dy1=x_lam(i)+35-dx_mask(i)/2*d_vz*disp(i)
      dy2=x_lam(i)+35+dx_mask(i)/2*d_vz*disp(i)
      printf,1,i+1,lams(i),ordnung(i),disp(i),x_lam(i)+35,dy1,dy2, $
      format="(i3,6x,f9.3,6x,i4,4x,f5.3,f8.1,3x,f6.1,' -',f6.1)"
    endif else begin
      dy=x_lam(i)+(x_ber(i)-x_lam(i))/2+35
      dy1=dy-dx_mask(i)/2*d_vz*disp(i)
      dy2=dy+dx_mask(i)/2*d_vz*disp(i)
      printf,1,i+1,lams(i),ber(i),ordnung(i),disp(i),dy,dy1,dy2, $
      format="(i3,x,f9.3,' -',f9.3,i4,4x,f5.3,f8.1,3x,f6.1,' -',f6.1)"
    endelse
  endfor
  printf,1 & printf,1
  close,1
endif
print & print
repeat begin
  writeu,-1,up,'Printout a workshop drawing ?  (Y/N) '
  ch='' & read,ch & ch=strupcase(ch)
endrep until strpos('YN',ch) ge 0 and ch ne ''
if ch eq 'Y' then begin
  x_mask=x_mask*cew
  h=m_h/2. & w=m_w/2.
  writeu,-1,'<S>creen or <P>rinter ? '
  ch='' & read,ch & ch=strupcase(ch)
  if ch eq 'P' then begin
    fcol=250
    olddev=!d.name & set_plot,'ps'
    device,/landscape,xsize=25,ysize=18,xoff=1,yoff=27,filen='maske.ps'
  endif else begin
    window,xsize=750,ysize=550
    fcol=0
  endelse
  plot,[-w,w],[-h,h],xsty=5,ysty=5,subtit='',/nodata,$
       pos=[(n_wl+1)*.019,.01,(n_wl+1)*.019+.476,.89889]
  plots,[-w,w,w,-w,-w],[-h,-h,h,h,-h]
  plots,-[w,w-1.5,w-1.5,w],[h+10,h+8.5,h+11.5,h+10]&plots,-w,[h+8.5,h+11.5]
  plots,[w,w-1.5,w-1.5,w],[h+10,h+8.5,h+11.5,h+10]&plots,w,[h+8.5,h+11.5]
  xyouts,0,h+11,string(m_w,form='(f6.2)'),align=.5
  plots,[-w,w],h+10 & plots,[-30,30],h+5
  plots,-[30,28.5,28.5,30],[h+5,h+3.5,h+6.5,h+5]&plots,-30,[h+3.5,h+6.5]
  plots,[30,28.5,28.5,30],[h+5,h+3.5,h+6.5,h+5]&plots,30,[h+3.5,h+6.5]
  xyouts,0,h+6,'60.00',align=.5
  for i=0,nm1 do begin
    dy1=x_mask(i)-dx_mask(i)/2
    dy2=x_mask(i)+dx_mask(i)/2
    plots,[-30,30,30,-30,-30],[dy1,dy1,dy2,dy2,dy1]
    plots,-w-4-4*i,[-h,x_mask(i)]
    plots,-w-4-4*i+ex,x_mask(i)+eu
    plots,-w-4-4*i+ex,ed-h
    xyouts,-w-5-4*i,(-h+x_mask(i))/2,ori=90,alig=.5, $
           string(x_mask(i)+h,form='(f6.2)')
    plots,w+3.5+ex,dy1+eu 
    plots,w+3.5+ex,dy2+ed
    xyouts,w+6,x_mask(i)-1,string(dx_mask(i),i+1,form='(f4.2,i3)')
  endfor  
  plots,-w-4-4*i,[-h,h]
  plots,-w-4-4*i+ex,h+eu
  plots,-w-4-4*i+ex,ed-h
  xyouts,-w-5-4*i,0,string(m_h,form='(f6.2)'),alig=.5,ori=90

  plot,[0,1],[10,65],xsty=5,ysty=5,subtit='',/nodata,/noerase, $
       pos=[.775,.05,.915,.95]
  for i=0,nm1 do begin
    if ber(i) ne 0 then begin
      dy=x_lam(i)+(x_ber(i)-x_lam(i))/2+35
      if (dy ge 10) and (dy le 65) then begin
       dy1=min([65,max([10,dy-dx_mask(i)/2*d_vz*disp(i)])])
       dy2=max([10,min([65,dy+dx_mask(i)/2*d_vz*disp(i)])])
       polyfill,[0,1,1,0],[dy1,dy1,dy2,dy2],col=fcol
       polyfill,[0,1,1,0,0],[x_lam(i),x_lam(i),x_ber(i),x_ber(i),x_lam(i)]+35
       xyouts,-.05,(x_lam(i)+x_ber(i))/2+35,alig=.5,orien=90,siz=.8, $
             string(lams(i),ber(i),form="(f7.1,'-',f7.1)")
       xyouts,-.15,(x_lam(i)+x_ber(i))/2+35,alig=.5,orien=90, $
             string(i+1,form='(i2)')
      endif
    endif else if (x_lam(i) ge -25 ) and (x_lam(i) le 30) then begin
      dy1=min([65,max([10,x_lam(i)+35-dx_mask(i)/2*d_vz*disp(i)])])
      dy2=max([10,min([65,x_lam(i)+35+dx_mask(i)/2*d_vz*disp(i)])])
      polyfill,[0,1,1,0],[dy1,dy1,dy2,dy2],col=fcol
      plots,[0,1],x_lam(i)+35,thick=2.5
      xyouts,-.05,x_lam(i)+35,alig=.5,orien=90,string(lams(i),form='(f7.1)')
      xyouts,-.15,x_lam(i)+35,alig=.5,orien=90,string(i+1,form='(i2)')
    endif
  endfor
  axis,/yax,pos=[.775,.05,.915,.95],xsty=5,ysty=5
  plots,[1,0,0,1],[10,10,65,65]
  xyouts,.735,.5,'Spectrum View',/norm,alig=.5,size=2,orien=90
  xyouts,.965,.05,/norm,orien=90,size=1.25,string(180*angle/!pi,lzent, $
        form="('Grating angle  ',f6.2,'     Predisperser L!iZent!n',i6)")
  xyouts,.99,.05,/norm,orien=90,size=1.25,string(180*ew/!pi, $
        form="('Measures for entrance slit angle ',f4.2)")
  date=systime() & date=strmid(date,0,11)+strmid(date,20,4)
  xyouts,1,1,alig=1,ori=90,/norm,size=.5,'vz_mask V3.0 '+date
  if ch eq 'P' then begin
    device,/close
    set_plot,olddev
    print & print,'Printout PostScript file using  lpr -Plw -h maske.ps'
  endif
endif

return,0
end

PRO VORZERL_MASKEN

on_error,2
common mask_data,lams,ber,ordnung,aord,angles,angle,n_wl,lrange,lzent,$
       blaz,brange,g2,ml,d_vz5,d_vz,f_s,vfak,ga0,vz0,vzst,ew,skip,left,up
f_s	=1491.		; Spectrograph focal length [cm]
g2	=253164.6	; 2 x grating constant
vz0	=4961		; Zero position predisperser
ga0	=10003		; Zero position main grating
vzst	=0.17077	; slope of predisperser [scalestep/Angstroem]
blaz	=1.10706	; Blaze-angle main grating (= 63.43 deg)
brange  =0.035          ; usable blaze range (+- 2 deg)
ml	=g2*sin(blaz)	; order*wavelength in blaze
d_vz5	=16.73		; dispersion predisperser [Angstroem/mm] at 5000A
lrange	=130*d_vz5	; Max. nutzbarer Bereich im VZ-Spektrum [A]
ew      =!pi*2.15/180	; angle of entrance slit of spectrograph (= 2.15 deg)
vfak	=1/10.49	; scaling factor of spectrograph image (cm/mm)
n_wl=0
run=0
skip='                   '
up=string(byte([27,91,65]))
left='            '
left=left+string(byte([27,91,68,27,91,68,27,91,68,27,91,68,27,91,68, $
   27,91,68,27,91,68,27,91,68,27,91,68,27,91,68,27,91,68,27,91,68]))
menue:
spawn,'clear',/noshell
print,'*******************************************************************'
print,'*                                                                 *'
print,'*       Multiple Wavelength Predisperser Masks for the VTT        *'
print,'*       Version 3.0                                               *'
print,'*                                    (6/1992)  P.Suetterlin (KIS) *'
print,'*******************************************************************'
print
if n_wl ge 1 then begin
  print,'        No.     Lambda     Order      Angle'
  for i=0,n_wl-1 do begin
    if aord(i) le 0 then begin
      print,i+1,lams(i),ordnung(i),angles(i)/!pi*180, $
      format="(6x,i3,5x,f9.3,6x,i3,7x,f5.2)"
    endif else begin
      print,i+1,lams(i),ordnung(i),angles(i)/!pi*180, $
      format="(6x,i3,5x,f9.3,6x,i3,'*',6x,f5.2)"
    endelse
  endfor
  print
  print
endif
print,skip,'(1) Enter Wavelength'
print,skip,'(2) Delete Wavelength'
print,skip,'(3) Change Order'
print,skip,'(4) Show Parameters'
print,skip,'(5) Compute Positions
print,skip,'(6) Find additional wavelength'
print
print,skip,'(0) Quit'
print
print
repeat begin
  writeu,-1,up,'Your Choice (0 - 6)',left
  ch='' & read,ch
endrep until strpos('0123456',ch) ge 0 and ch ne ''
case ch of
  '1'   : begin
           run=0
           vorzerl_aux1
           goto,menue
          end
  '2'	: begin
            run=0
            goto,remove_lams
          end
  '3'   : begin
            run=0
            goto,neu_ord
          end
  '4'   : begin
            run=0
            goto,show_params
          end
  '5'	: begin
           res=vorzerl_aux2()
	   if res ne 1 then goto,ganzaus
           run=1
	   goto,menue
          end
  '6'   : goto,find_lam
  '0'   : goto,ganzaus
  else  : 
endcase
goto,menue
remove_lams:
if n_wl ge 2 then begin
  print
  writeu,-1,'Delete: which wavelength (1-'+strtrim(n_wl,1)+') '
  choice='' & read,choice 
  ch=strpos('0123456789',choice)
  if ch le n_wl and ch ge 1 then begin
    if ch eq n_wl then begin
      lams=lams(0:ch-2)
      ordnung=ordnung(0:ch-2)
      aord=aord(0:ch-2)
      ber=ber(0:ch-2)
      angles=angles(0:ch-2)
    endif else begin
      lams(ch-1)=lams(ch:*) & lams=lams(0:n_wl-2)
      ordnung(ch-1)=ordnung(ch:*) & ordnung=ordnung(0:n_wl-2)
      aord(ch-1)=aord(ch:*) & aord=aord(0:n_wl-2)
      ber(ch-1)=ber(ch:*) & ber=ber(0:n_wl-2)
      angles(ch-1)=angles(ch:*) & angles=angles(0:n_wl-2)
    endelse
    n_wl=n_wl-1
  endif
endif
goto,menue
neu_ord:
if n_wl eq 0 then begin
  print
  print,'Please enter at least one wavelength !'
  print,'Continue: RETURN'
  ch='' & read,ch
  goto,menue
endif
print
print
repeat begin
  writeu,-1,up, $
  'Change order for which wavelength (1-'+strtrim(n_wl,1)+')',left
  choice='' & read,choice & ch=strpos('123456789',choice)
endrep until ch ge 0 and choice ne ''
if ch le n_wl-1 then begin
  if aord(ch) gt 0 then begin
    tmp=ordnung(ch) & ordnung(ch)=aord(ch) & aord(ch)=tmp
    angles(ch)=asin(abs(ordnung(ch))*lams(ch)/g2)
  endif else begin
    print
    print,'For this wavelength only the given order is possible. The
    print,'next order lies outside the usable blaze angle and therefore'
    print,'shows a strongly decreased intensity.'
    print & print
    repeat begin
      writeu,-1,up,'Still change (Y/N) ',left
      ch1='' & read,ch1 & ch1=strupcase(ch1)
    endrep until strpos('YN',ch1) ge 0 and ch1 ne ''
    if ch1 eq 'Y' then begin
      tmp=ordnung(ch) & ordnung(ch)=aord(ch) & aord(ch)=tmp
      angles(ch)=asin(abs(ordnung(ch))*lams(ch)/g2)
    endif
  endelse
endif
goto,menue
show_params:
spawn,'clear',/noshell
print
print,'Adopted Parameters'
print,f_s,form="('Focal length spectrograph:   ',i5)"
print,vz0,form="('Zero position predisperser:  ',i5)"
print,vzst,form="('Slope predisperser reading:  ',f8.5)"
print,d_vz5,form="('Dispersion predisperser:     ',f8.4)"
print,ga0,form="('Zero position grating:       ',i6)"
print,fix(18000*ew/!pi)/100.,form="('Angle entrance slit:         ',f5.2)"
print,fix(18000*brange/!pi)/100.,form="('Usable Blaze Range:          ',f5.2)"
print
print
print
repeat begin
  writeu,-1,up,'Change values ?  (Y/N) ',left
  ch='' & read,ch & ch=strupcase(ch)
endrep until strpos('YN',ch) ge 0
if ch eq 'Y' then begin
  choice=''
  print & print,'Focal length spectrograph: (new value or RETRURN)'
  read,choice & if choice ne '' then f_s=float(choice)
  print & print,'Zero position predisperser: (new value or RETRURN)'
  read,choice & if choice ne '' then vz0=float(choice)
  print & print,'Slope predisperser reading: (new value or RETRURN)'
  read,choice & if choice ne '' then vzst=float(choice)
  print & print,'Dispersion predisperser at 5000 A: (new value or RETRURN)'
  read,choice & if choice ne '' then d_vz5=float(choice)
  lrange=10*fix(130.*d_vz5/10.)
  print & print,'Zero position grating: (new value or RETRURN)'
  read,choice & if choice ne '' then ga0=float(choice)
  print & print,'Angle of entrance slit: (new value or RETRURN)'
  read,choice & if choice ne '' then ew=float(choice)/180*!pi
  print & print,'Usable Blaze Range: (new value or RETRURN)'
  read,choice & if choice ne '' then brange=float(choice)/180*!pi
endif
goto,menue
find_lam:
print
print,'Find an additional posible wavelength, if the usable range in the'
print,"focal plane isn't completely used."
if run eq 0 then begin
  print
  print,'Before selecting this feature, please do a computation run for'
  print,'the current wavelength set (main menue no. 5)
  writeu,-1,'Continue: RETURN'
  ch='' & read,ch 
  goto,menue
endif  
print & print
repeat begin
  writeu,-1,up,'Desired position (10-65)'
  ch='' & read,ch & ch=strupcase(ch)
  linpos=fix(ch)
endrep until linpos ge 10 and linpos le 65
spawn,'clear',/noshell
print,'Order    Wavelength at x= ',strtrim(linpos,1),'  Dispersion [cm/A]'
for i=20,70 do begin
  l0=sin(angle)*g2/i
  if abs(l0-lzent) le lrange/2 then begin
    d0=f_s*2*i/g2/cos(angle)
    l1=l0+(linpos-35)/d0
    l1=l1-(l1-lzent)/d_vz/10/d0
    print,i,l1,d0,form='(i5,10x,f9.3,10x,f5.3)'
  endif
endfor
print
writeu,-1,'Continue: RETURN'
ch='' & read,ch 
goto,menue
ganzaus:
print & print
print,'              good luck on observation !'
end
