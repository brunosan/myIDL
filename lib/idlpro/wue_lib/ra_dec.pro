;+
; NAME:
;        RA_DEC
; PURPOSE:
;        Display an astronomical coordinate system (only rectangular)
; CATEGORY:
;        
; CALLING SEQUENCE:
;        RA_DEC,ra_min,ra_max,dec_min,dec_max or
;        RA_DEC,ra_mid,dec_mid,fieldsize
; INPUTS:
;        ra_min  = lowest right ascension to be displayed
;        ra_max  = highest right ascension to be displayed
;        dec_min = lowest declination to be displayed
;        dec_max = highest declination to be displayed
;        ra_mid  = right ascension of the field center
;        dec_mid = declination of the field center
;        fieldsize = fieldsize
; UNITS:
;	 right ascension in hours
;	 declination in degrees
;	 fieldsize in arc minutes
; KEYWORD PARAMETERS:
;        XMIN : x-axis is divided in at least XMIN parts (default 4)
;        YMIN : y-axis is divided in at least YMIN parts (default 4)
; Standard plotting keywords :
;      TITLE,SUBTITLE,XTITLE,YTITLE,TICKLEN,XTICKLEN,YTICKLEN,CHARSIZE
; OUTPUTS:
;        none.
; COMMON BLOCKS:
;        none.
; SIDE EFFECTS:
;        none.
; RESTRICTIONS:
;        none.
; PROCEDURE:
;        The axes are divided into at least XMIN resp. YMIN parts (one
;        tick can only correspond to 1, 2, 5, 10 or 20 hours, minutes or
;        seconds resp. degrees, arc minutes or arc seconds). The ranges
;        are rounded in such a way that the field is as great or greater
;        as the demanded one. The resulting coordinate system is plotted
;        without any data.
; MODIFICATION HISTORY:
;   GSC:       Written, M. Kunkel, Univ. Wuerzburg, Germany, Apr. 1992
;   SIXTY_INT: Written by R. S. Hill, STX, 19-OCT-87        (SIXTY) 
;              Output changed to single precision.  RSH, STX, 1/26/88
;              Output changed to integer. M. Kunkel, 24-MAR-92
;-
;
FUNCTION sixty_int,scalar
      np = n_params(0)
      if (np ne 1) then goto,arg_error
      sz = size(scalar)
      ndim = sz(0) 
      if (ndim ne 0) then goto,arg_error
      ss=abs(3600.0d0*scalar)
      mm=abs(60.0d0*scalar) 
      dd=abs(scalar) 
      result=intarr(3)
      result(0)=fix(dd)
      result(1)=fix(mm-60.0d0*result(0))
      result(2)=nint(ss-3600.d0*result(0)-60.0d0*result(1))
      if result(2) eq 60 then begin
	 result(2)=0
	 result(1)=result(1)+1
	 if result(1) eq 60 then begin
	    result(1)=0
	    result(0)=result(0)+1
         endif
      endif
      if scalar lt 0.0d0 then begin 
         if result(0) ne 0 then result(0) = -result(0) else $
         if result(1) ne 0 then result(1) = -result(1) else $
         result(2) = -result(2)
      endif
      return,result
arg_error:  
      print,'One scalar argument needed'                           
      return,replicate(100,3)
      end
pro ra_dec,ra_min,ra_max,dec_min,dec_max,XTITLE=XTITLE,YTITLE=YTITLE, $
      TITLE=TITLE,SUBTITLE=SUBTITLE,TICKLEN=TICKLEN,XTICKLEN=XTICKLEN, $
      YTICKLEN=YTICKLEN,CHARSIZE=CHARSIZE,XMIN=XMIN,YMIN=YMIN
   if n_elements(XTITLE) eq 0 then XTITLE=!x.title
   if n_elements(YTITLE) eq 0 then YTITLE=!y.title
   if n_elements(TITLE) eq 0 then TITLE=!p.title
   if n_elements(SUBTITLE) eq 0 then SUBTITLE=!p.subtitle
   if n_elements(TICKLEN) eq 0 then TICKLEN=!p.ticklen
   if n_elements(XTICKLEN) eq 0 then XTICKLEN=!x.ticklen
   if n_elements(YTICKLEN) eq 0 then YTICKLEN=!y.ticklen
   if n_elements(CHARSIZE) eq 0 then CHARSIZE=!p.charsize
   if XTICKLEN eq 0. then XTICKLEN=TICKLEN
   if YTICKLEN eq 0. then YTICKLEN=TICKLEN
   if n_elements(XMIN) eq 0 then XMIN=4
   if n_elements(YMIN) eq 0 then YMIN=4
   if n_params() eq 3 then begin
      rs=ra_min-dec_min/1800./cos(ra_max/180.*!pi)
      re=ra_min+dec_min/1800./cos(ra_max/180.*!pi)
      ds=ra_max-dec_min/120.
      de=ra_max+dec_min/120.
   endif else begin
      if n_params() eq 4 then begin
	 rs=float(ra_min)
	 re=float(ra_max)
	 ds=float(dec_min)
	 de=float(dec_max)
      endif else begin
         print,'Calling Sequence - RA_DEC,ra_min,ra_max,dec_min,dec_max or'
         print,'                   RA_DEC,ra_mid,dec_mid,fieldsize'
         return
      endelse
   endelse 
   einh=(re-rs)/XMIN
   if (einh ge 1) then begin
      dim=1
      lein=alog10(einh)
      case 1 of
	 (lein ge 1.7): einh=50
	 (lein ge 1.3): einh=20
	 (lein ge 1.0): einh=10
	 (lein ge 0.7): einh=5
	 (lein ge 0.3): einh=2
	 else:          einh=1
      endcase
   endif else begin
      einh=einh*60.
      if (einh ge 1) then begin
         dim=0
         lein=alog10(einh)
         case 1 of
	    (lein ge 1.3): einh=20
	    (lein ge 1.0): einh=10
	    (lein ge 0.7): einh=5
	    (lein ge 0.3): einh=2
	    else:          einh=1
         endcase
      endif else begin
         dim=-1
         einh=einh*60.
         lein=alog10(einh)
         case 1 of
      	    (lein ge 1.3): einh=20
	    (lein ge 1.0): einh=10
	    (lein ge 0.7): einh=5
	    (lein ge 0.3): einh=2
	    else:          einh=1
         endcase
      endelse
   endelse
   if (rs lt 0.) then rs=rs+24
   rs=rs*60^(1-dim)/einh
   rs=float(long(rs))*einh/60^(1-dim)
   if (re gt 24.) then re=re-24
   re=re*60^(1-dim)/einh+.99
   re=float(long(re))*einh/60^(1-dim)
   r_dim=dim
   r_einh=einh
   einh=(de-ds)/YMIN
   if (einh ge 1) then begin
      dim=1
      lein=alog10(einh)
      case 1 of
	 (lein ge 1.3): einh=20
	 (lein ge 1.0): einh=10
	 (lein ge 0.7): einh=5
	 (lein ge 0.3): einh=2
	 else:          einh=1
      endcase
   endif else begin
      einh=einh*60.
      if (einh ge 1) then begin
         dim=0
         lein=alog10(einh)
         case 1 of
	    (lein ge 1.3): einh=20
	    (lein ge 1.0): einh=10
	    (lein ge 0.7): einh=5
	    (lein ge 0.3): einh=2
	    else:          einh=1
         endcase
      endif else begin
         dim=-1
         einh=einh*60.
         lein=alog10(einh)
         case 1 of
      	    (lein ge 1.3): einh=20
	    (lein ge 1.0): einh=10
	    (lein ge 0.7): einh=5
	    (lein ge 0.3): einh=2
	    else:          einh=1
         endcase
      endelse
   endelse
   if (ds lt -90.) then ds=-90.
   ds=ds*60^(1-dim)/einh
   if (ds lt 0.) then ds=ds-.99
   ds=float(long(ds))*einh/60^(1-dim)
   if (de gt 90.) then de=90.
   de=de*60^(1-dim)/einh
   if (de gt 0.) then de=de+.99
   de=float(long(de))*einh/60^(1-dim)
   d_dim=dim
   d_einh=einh
   if (rs gt re) then re=re+24
   r=dblarr(1)
   d=r
   xm=fltarr(2)
   ym=xm
   xm(0)=rs
   xm(1)=re
   ym(0)=ds
   ym(1)=de
   !x.style=1
   !y.style=1
   xt=nint((re-rs)*60^(1-r_dim)/r_einh)
   yt=nint((de-ds)*60^(1-d_dim)/d_einh)
   xtick=strarr(xt+1)
   ytick=strarr(yt+1)
   x=re
   if (x ge 24) then x=x-24
   case r_dim of
      1: begin
	    xtick(xt)=string(format='(I2,"!Uh!N")',(sixty_int(rs))(0))
	    xtick(0)=string(format='(I2,"!Uh!N")',(sixty_int(x))(0))
         end
      0: begin
	    xtick(xt)=string(format='(I2,"!Uh!N",I2,"!Um!N")', $
	       (sixty_int(rs))(0:1))
	    xtick(0)=string(format='(I2,"!Uh!N",I2,"!Um!N")', $
	       (sixty_int(x))(0:1))
	 end
     -1: begin
	    xtick(xt)=string(format='(I2,"!Uh!N",I2,"!Um!N",I2,"!Us!N")', $
	       sixty_int(rs))
	    xtick(0)=string(format='(I2,"!Uh!N",I2,"!Um!N",I2,"!Us!N")', $
	       sixty_int(x))
	 end
   endcase
   for i=1,xt-1 do begin
      x=rs+(re-rs)/xt*i
      if (x ge 24) then x=x-24
      x=sixty_int(x)
      case r_dim of
        1: xtick(xt-i)=string(format='(I2,"!Uh!N")',x(0))
        0: if (x(1) ne 0) then $
	     xtick(xt-i)=string(format='(I2,"!Um!N")',x(1)) $
           else $
	     xtick(xt-i)=string(format='(I2,"!Uh!N",I2,"!Um!N")',x(0),x(1))
       -1: if (x(2) ne 0) then $
	     xtick(xt-i)=string(format='(I2,"!Us!N")',x(2)) $
           else begin
	     if (x(1) ne 0) then $
	       xtick(xt-i)=string(format='(I2,"!Um!N",I2,"!Us!N")',x(1),x(2)) $
             else $
               xtick(xt-i)=string(format='(I2,"!Uh!N",I2,"!Um!N",I2,"!Us!N")',x)
           endelse
      endcase
   endfor
   case d_dim of
      1: begin
	    ytick(0)=string(format='(I3,"!Uo!N")',(sixty_int(ds))(0))
	    ytick(yt)=string(format='(I3,"!Uo!N")',(sixty_int(de))(0))
         end
      0: begin
	    ytick(0)=string(format='(I3,"!Uo!N",I2,"!U''!N")', $
	       (sixty_int(ds))(0:1))
	    ytick(yt)=string(format='(I3,"!Uo!N",I2,"!U''!N")', $
	       (sixty_int(de))(0:1))
	 end
     -1: begin
	    ytick(0)=string(format='(I3,"!Uo!N",I2,"!Um!N",I2,"!U''''!N")', $
	       sixty_int(ds))
	    ytick(yt)=string(format='(I3,"!Uo!N",I2,"!Um!N",I2,"!U''''!N")', $
	       sixty_int(de))
	 end
   endcase
   for i=1,yt-1 do begin
      y=ds+(de-ds)/yt*i
      y=sixty_int(y)
      case d_dim of
        1: ytick(i)=string(format='(I3,"!Uo!N")',y(0))
        0: if (y(1) ne 0) then $
	     ytick(i)=string(format='(I2,"!U''!N")',y(1)) $
           else $
	     ytick(i)=string(format='(I3,"!Uo!N",I2,"!U''!N")',y(0),y(1))
       -1: if (y(2) ne 0) then $
	     ytick(i)=string(format='(I2,"!U''''!N")',y(2)) $
           else begin
	     if (y(1) ne 0) then $
	       ytick(i)=string(format='(I2,"!Um!N",I2,"!U''''!N")',y(1),y(2)) $
             else $
	       ytick(i)=string(format='(I3,"!Uo!N",I2,"!Um!N",I2,"!U''''!N")',y)
           endelse
      endcase
   endfor
   plot,psym=3,xm,ym,xticks=xt,yticks=yt,xtickname=xtick,ytickname=ytick, $
      /nodata,XTITLE=XTITLE,YTITLE=YTITLE,TITLE=TITLE,SUBTITLE=SUBTITLE, $
      XTICKLEN=XTICKLEN,YTICKLEN=YTICKLEN,XRANGE=[re,rs],CHARSIZE=CHARSIZE
return
end

