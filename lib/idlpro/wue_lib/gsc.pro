;+
; NAME:
;      GSC
; PURPOSE:
;      Display the data of the Guide Star Catalog
; CATAGORY:
;
; CALLING SEQUENCE
;      GSC,ra_min,ra_max,dec_min,dec_max
; INPUTS:
;        ra_min  = lowest right ascension to be displayed
;        ra_max  = highest right ascension to be displayed
;        dec_min = lowest declination to be displayed
;        dec_max = highest declination to be displayed
; UNITS:
;        right ascension in hours
;        declination in degrees
;        fieldsize in arc minutes
; KEYWORD PARAMETERS:
;        MAGMAX  : no stars brighter than MAGMIN
;        MAGMIN  : only stars brighter than MAGMAX
;        EQUINOX : use other equinox than 2000 (default)
; OUTPUTS:
;        the data of the Guide Star Catalog as a list on the terminal
; COMMON BLOCKS:
;        none.
; SIDE EFFECTS:
;        The file /tmp0/gsc is created. If this file exists, nobody else
;        can use gsc. If you interrupt gsc.pro, ypu must remove this file
;        by hand.
; RESTRICTIONS:
;        only one person can use gsc.pro at the same time
; PROCEDURE:
;        calls the program gsc
; MODIFICATION HISTORY:
;        Written, M. Kunkel, Univ. Wuerzburg, Germany, Jan. 1993
;-
;
pro gsc,ra_min,ra_max,dec_min,dec_max,MAGMIN=MAGMIN,MAGMAX=MAGMAX, $
	 EQUINOX=EQUINOX
   openr,unit,'/tmp0/gsc',error=err,/get_lun
   if (err eq 0) then begin
      print,'GSC in use. Please try again later'
      close,unit
      free_lun,unit
      return
   endif else $
      spawn,'touch /tmp0/gsc'
   if (dec_min gt dec_max) then begin
      tmp=dec_min
      dec_min=dec_max
      dec_max=tmp
   endif
   gscbin='/usr/local/bin/gsc'
   !p.multi=[0,2,1]
   if n_elements(MAGMIN) eq 0 then MAGMIN=17
   if n_elements(MAGMAX) eq 0 then MAGMAX=-3
   if n_elements(EQUINOX) eq 0 then EQUINOX=2000.
   xtitle='Right Ascension ('+string(equinox,format='(F6.1)')+')'
   ytitle='Declination ('+string(equinox,format='(F6.1)')+')'
   ra_dec,ra_min,ra_max,dec_min,dec_max,xtitle=xtitle,ytitle=ytitle
   if (equinox ne 2000) then begin
      ra_min=ra_min*15.
      ra_max=ra_max*15.
      precess,ra_min,dec_min,equinox,2000.
      precess,ra_max,dec_max,equinox,2000.
      ra_min=ra_min/15.
      ra_max=ra_max/15.
   endif
   ra=0.d0
   de=0.d0
   mag=0.
   class=0
   i=findgen(31)/15.*!pi
   usersym,cos(i),sin(i)
   if (dec_min lt -7.5) then begin
      spawn,'rsh luna ls /cdrom/gsc/s0730',result
      while (result(0) eq '') do begin
         print
         print,'Please mount GSC Vol 2, then press <return>'
	 print,get_kbrd(1)
         spawn,'rsh luna ls /cdrom/gsc/s0730',result
      endwhile
      comm=gscbin+' -i -r '+string(ra_min)+' -R '+string(ra_max)+' -d '
      comm=comm+string(dec_min)+' -D '+string(min([dec_max,-7.5]))+' -M '
      comm=comm+string(magmin)+' -m '+string(magmax)
      spawn,comm,unit=unit
      readf,unit,ra,de,mag,class
      while(class ne 99) do begin
	 if (equinox ne 2000.) then begin
            ra=ra*15.
            precess,ra,de,2000.,equinox
            ra=ra/15.
         endif
         case class of
          99:
          0: begin
       	    plots,ra,de,psym=8,symsize=.5*(1+magmin-mag)
            print,ra,de,mag,class
           end
          else: begin
	    plots,ra,de,psym=6,symsize=.5*(1+magmin-mag)
            print,ra,de,mag,class
	   end
         endcase
         readf,unit,ra,de,mag,class
      endwhile
      close,unit
      free_lun,unit
   endif
   if (dec_max gt -7.5) then begin
      spawn,'rsh luna ls /cdrom/gsc/n0730',result
      while (result(0) eq '') do begin
         print
         print,'Please mount GSC Vol 1, then press <return>'
	 print,get_kbrd(1)
         spawn,'rsh luna ls /cdrom/gsc/n0730',result
      endwhile
      comm=gscbin+' -i -r '+string(ra_min)+' -R '+string(ra_max)+' -d '
      comm=comm+string(max([dec_min,-7.5]))+' -D '+string(dec_max)+' -M '
      comm=comm+string(magmin)+' -m '+string(magmax)
      spawn,comm,unit=unit
      readf,unit,ra,de,mag,class
      while(class ne 99) do begin
	 if (equinox ne 2000.) then begin
            ra=ra*15.
            precess,ra,de,2000.,equinox
            ra=ra/15.
	 endif
         case class of
          99:
          0: begin
       	    plots,ra,de,psym=8,symsize=.5*(1+magmin-mag)
            print,ra,de,mag,class
           end
          else: begin
	    plots,ra,de,psym=6,symsize=.5*(1+magmin-mag)
            print,ra,de,mag,class
	   end
         endcase
         readf,unit,ra,de,mag,class
      endwhile
      close,unit
      free_lun,unit
   endif
   spawn,'\rm /tmp0/gsc'
   plot,[0,1.2],[0,18],/nodata,xstyle=4,ystyle=4
   xyouts,0.15,18.5,'star',charsize=2
   xyouts,0.4,18.5,'non-star',charsize=2
   xyouts,0.95,18.5,'mag',charsize=2
   for i=2,magmin,2 do begin
      plots,0.2,18.5-1.1*i,psym=8,symsize=.5*(1+magmin-i)
      plots,0.5,18.5-1.1*i,psym=6,symsize=.5*(1+magmin-i)
      xyouts,0.8,18.5-1.1*i,string(i),charsize=2
   endfor
   !p.multi=[0,1,1]
return
end
