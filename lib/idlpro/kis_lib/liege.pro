PRO liege,data,from=wstart,to=wend,plot=iplot
;+
; NAME:
;	LIEGE
; PURPOSE:
;	 Extracts data from digitized version of Liege-Atlas
;*CATEGORY:            @CAT-# 31 32 25@
;	 Spectral Analysis , Spectral Lines Identification , Plotting
; CALLING SEQUENCE:
;	 LIEGE,data [,FROM=wstart [,TO=wend] ] [,/PLOT]
; INPUTS:
;	none
; OPTIONAL INPUT PARAMETER:
;	FROM = wstart : start wavelength (blue end of requested
;	     wavelength intervall) in Angstroem. The actual start-
;	     value will be the largest integer <= wstart;
;	     If ** not ** set: procedure will request user to enter
;	     start wavelength. <wstart> >=3600 .
;	TO = wend : end wavelength (red end of requested wavelength-
;	   intervall) in Angstroem. Only meaningful if FROM=wstart 
;	   was set. If FROM=wstart is set but ** not ** TO=wend:
;	   wend= actual <wstart> +1. will be assumed. <wend> <=9301 .
;       /PLOT : The extracted spectrum will be plotted.
; OUTPUTS:
;	data : (short) integer-array containing the spectral intensities
;	   of the requested wavelength intervall. Atlas-continuum =10000;
;	   wavelength step size: 2 mA.
; SIDE EFFECTS:
;	If FROM=wstart not set, the prosedure will request for input;
;	a scratch file 'tmp' under the current working directory will be
;	created and removed afterwards.
; RESTRICTIONS:
;	The digitized atlas covers wavelength region 3601 A to 9301 A.
; PROCEDURE:
;	Spawns UNIX-command dd to dump & swap requested part of atlas
;       to ./tmp
; MODIFICATION HISTORY:
;	ps, ???
;	nlte, 1990-Jul-17 : key-words FROM, TO, /PLOT
;	nlte, 1992-Jun-10 : liege.dat now in /dat/daisy_2/spectral_atlas/
;	nlte, 1993-Apr-08 : GOOFY: liege.dat in /dat/goofy_2/spectral_atlas/
;	nlte, 1993-Apr-21 : use cd,current=cwd to get current working direct.
;       19/8/93 : data file in $IDL_DIR/data/kis_lib
;		  Reinhold Kroll 19/8/93
;	28/1/99: data file in $IDL_LOCAL/data/kis_lib
;-
on_error,1
host=strlowcase(getenv('HOST'))
; if host eq 'goofy' then atlas_host='goofy' else atlas_host='daisy'
atlas_file=getenv('IDL_LOCAL')+'/data/liege.dat'
;
if n_params() le 0 then $
   message,'Usage: LIEGE,data [,FROM=wstart [,TO=wend] ]'
if keyword_set(wstart) then begin
   wl=fix(wstart)
   if wl lt 3600 then message,'LIEGE: wstart must be >= 3600'
endif else goto,again
if keyword_set(wend) then begin 
      we=fix(wend)
      if we gt 9301 then message,'LIEGE: wstart must be <= 9301' 
      if we lt wl then message,'LIEGE: wend must be >= wstart'
      nblocks=(we-wl)>1
      goto,jmp
endif else begin nblocks=1 & goto,jmp & endelse
;
again:   print,'Enter wavelengths [A] : start <= end (integer, 3600 - 9301):'
   wl=1 & we=1
   read,wl,we
   if wl lt 3600 or wl gt we or we gt 9301 then goto,again
   nblocks=(we-wl)>1
;----
jmp:
nblocks=nblocks>1
ndata=500L*nblocks
ndatt=(500L+12)*nblocks
tmp=intarr(ndatt)

start=(wl-3600)*2+14
count=fix(2*nblocks)
cd,current=cwd & tmpfil=cwd+'/tmp'
;
cmd='dd if='+atlas_file+' of='+tmpfil+' conv=swab count='+$
     string(count,format='(i0)')+' skip='+string(start,format='(i0)')
;if host ne atlas_host then cmd='rsh '+atlas_host+' "'+cmd+'"'
   print,cmd
   spawn,cmd
   openr,unit,tmpfil,/get_lun
   readu,unit,tmp
   free_lun,unit
;
data=intarr(ndata)
for i=0,nblocks-1 do begin
    i1=i*512L & i2=i1+6 & i3=i1+19 & i4=i1+511
   data(500L*i)=[tmp(i1:i2),tmp(i3:i4)]
endfor
tmp=0
;
spawn,'rm '+tmpfil
;
n=(size(data))(1)

if keyword_set(iplot) then begin
   if min(data) ge 8000 then imin=8000 else imin=0
   if max(data) le 2000 then imax=2000 else imax=10000
   plot,wl+findgen(n)*0.002,data,$
   yrange=[imin,imax],tit='Liege-Atlas',xtit='Wavelength [A]'
endif
end
