FUNCTION CBAR,zmin,zmax,ncol=n_col,height=wy,margin=margin,tick=tick
;+
; NAME:
;	CBAR
; PURPOSE:
;	Creates a rectangle with values increasing linearly from zmin to zmax
;	in 1st dimension + some margin + optional tick marks; may serve to
;	show correlation between z-values and colors/grey-scales.
;*CATEGORY:            @CAT-# 15@
;	Image Display
; CALLING SEQUENCE:
;	array = CBAR ( zmin,zmax ...
;	        ... [,NCOL=ncol] [,HEIGHT=h] [,MARGIN=margin] [,TICK=ntick] )
; INPUTS:
;	zmin, xmax : range of values to be generated.
; OPTIONAL INPUT PARAMETER:
;	NCOL=ncol : number of "color"-columns = number of z-values = length of
;		    rectangle (without margin); default: ncol=256 .
;       HEIGHT=h  : size of rectangle (rows) (without margin & ticks); 
;		    default: h=15 .
;	MARGIN=margin : size of margin surrounding the "color-strip";
;	            default: margin=5 (no margin if MARGIN=0).
;       TICK=ntick : number of tick marks below the "color-strip";
;	            default: no tick marks;
; OUTPUTS:
;	2-dim array; size 1st dim: ncol+2*margin; 
;	                  2nd dim: h+2*margin + more space for ticks if necess.
;	             data type same as zmin, zmax.
; COMMON BLOCKS:
;	none
; SIDE EFFECTS:
;	
; RESTRICTIONS:
;	
; PROCEDURE:
;	straight
; MODIFICATION HISTORY:
;	nlte, 1992-Sep-24 
;-
on_error,1
if n_params() ne 2 then message,$
   'Usage: bar = CBAR ( zmin,zmax [,optional keyword parameters] )'
;
if n_elements(n_col) then nc=n_col else nc=256
if n_elements(margin) eq 1 then marg=margin else marg=5
if n_elements(wy) then ny0=wy else ny0=15
;
nx=nc+2*marg 
ntick=0
if n_elements(tick) gt 0 then if tick gt 0 then ntick=(tick>3)<nc/2
if ntick gt 0 then ticklen=9 else ticklen=0
mdown=max([marg,ticklen])
ny=ny0+marg+mdown
;
if (size(zmin))(0) ne 0 or (size(zmax))(0) ne 0 then message,$
   '1st, 2nd argument (zmin, zmax) must be single variables or constants'
type=max([(size(zmin))(1),(size(zmax))(1)])
case type of
  1: b=bytarr(nx,ny)+byte((fix(zmin)+fix(zmax))/2)
  2: b=intarr(nx,ny)+(zmin+zmax)/2
  3: b=lonarr(nx,ny)+(zmin+zmax)/2L
  4: b=fltarr(nx,ny)+(zmin+zmax)/2.
  5: b=dblarr(nx,ny)+(zmin+zmax)/2D
  else: message,'1st, 2nd argument (zmin, zmax) invalid type'
endcase
zback=b(0,0)
;
if type le 3 then zfp=float(zmin)+findgen(nc)*float(zmax-zmin)/float(nc-1) $
else              zfp=zmin+findgen(nc)*(zmax-zmin)/float(nc-1)
z1=min([zmin,zmax]) & z2=max([zmin,zmax])
case type of
  1: z=(byte(nint(zfp)) <z2) >z1
  2: z=(nint(zfp) <z2) >z1
  3: z=(nlong(zfp) <z2) >z1
  else: z=zfp
endcase
;
for i=mdown,mdown+ny0-1 do b(marg:marg+nc-1,i)=z
;
if ntick gt 0 then begin
   m1=mdown-ticklen & m2=mdown-1 & m3=mdown-ticklen/2
   b(marg,m1:m2)=zmin & b(marg+nc-1,m1:m2)=zmin
   inc=float(nc)/float(ntick-1)
   for t=1,ntick-2 do begin
       i=nint(t*inc) & if abs(i-nc/2) lt 2 then m=m1 else m=m3
       b(marg+i,m:m2)=zmin
   endfor
endif
;
return,b
end


