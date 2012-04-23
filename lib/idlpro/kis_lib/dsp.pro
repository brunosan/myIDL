PRO mkbar,zmin,zmax,nx,ny,barpos,idev
;
; to create a scaled bar with values from zmin to zmax; the overall size is
; nx * ny pixel (the data-strip is smaller by 50 pix in x, 27 pix in y).
; The bar is displayed at position defined by 4-element vector barpos 
; [x0,y0, x1,y1] (units in pix if devixe is screen (idev=0), 
;                 units in normalized dev.-coords. if device is 'PS' (idev=1).
;
on_error,1
big=bytarr(nx,ny)+127
;
if idev eq 0 then begin    ; this is for screen
   nxc=nx-50>64 & nyc=ny-27>10 & cb=fltarr(nxc,nyc)
   bcpos=barpos & bcpos(0)=barpos(0)+(nx-nxc)/2 & bcpos(2)=barpos(2)-(nx-nxc)/2
                  bcpos(1)=barpos(1)+(ny-nyc-2) & bcpos(3)=barpos(3)-2
   c=zmin+findgen(nxc)*(zmax-zmin)/float(nxc-1)
   for i=1,nyc-1 do cb(*,i)=c
   bcpos=barpos & bcpos(0)=barpos(0)+(nx-nxc)/2 & bcpos(2)=barpos(2)-(nx-nxc)/2
                  bcpos(1)=barpos(1)+(ny-nyc-2) & bcpos(3)=barpos(3)-2
   tv,big,barpos(0),barpos(1)
   tv,bytscl(cb),bcpos(0),bcpos(1)
   plot,[zmin,zmax],[0.,1.],/noer,/nodat,xstyl=9,ystyl=4,pos=bcpos,/dev,$
        xticks=4,xminor=2,tickl=-0.4,charsi=0.85
endif else begin           ; this is for PS
   
   fx=float(barpos(2)-barpos(0))/float(nx)
   fy=float(barpos(3)-barpos(1))/float(ny)
   nxc=0.8*nx & nyc=0.35*ny & cb=fltarr(nxc,nyc)
   c=zmin+findgen(nxc)*(zmax-zmin)/float(nxc-1)
   for i=1,nyc-1 do cb(*,i)=c   
   bcpos=barpos
   bcpos(0)=bcpos(0)+fx*(nx-nxc)/2 & bcpos(2)=bcpos(2)-fx*(nx-nxc)/2
   bcpos(1)=bcpos(1)+fy*(ny-nyc-2) & bcpos(3)=bcpos(3)-2*fy
   tv,big,barpos(0),barpos(1),xsiz=barpos(2)-barpos(0),$
          ysiz=barpos(3)-barpos(1),/norm
    tv,bytscl(cb),bcpos(0),bcpos(1),xsiz=bcpos(2)-bcpos(0),$
                 ysiz=bcpos(3)-bcpos(1),/norm
   plot,[zmin,zmax],[0.,1.],/noer,/nodat,xstyl=9,ystyl=4,tickl=-0.4,$
                            xticks=4,xminor=2, charsi=0.75,pos=bcpos,/norm
endelse
end
;+
; NAME:
; 	DSP
; PURPOSE:
; 	Display and print 2D data with x/y-scales
;*CATEGORY:            @CAT-# 15@
;	Image Display
; CALLING SEQUENCE:
;	DSP,array [,RANGE=[zmin,zmax] [,DV=dev] [,XS=xsz] [,YS=ysz] ...
;	         ... [,XT=xtt] [,YT=ytt] [,HD=mtt] [,XX=xax] [,YY=yax] ...
;		 ... [,CO=col] [,PR=prt] [,BAR=bar_pos]
; INPUTS:
;	array: 2D array to be displayed and/or plotted (1st dim is "x").
; OPTIONAL INPUT PARAMETER: 
;	RANGE=[zmin,zmax] : the array-values between zmin,zmax will be
;                           scaled to 0,255 for display; 
;			    default: minimum,maximum values in array will be 
;                                    used for scaling.
;	DV='ps' : a non-encapsulated PostScript file (for output on PS-devices)
;		  is produced **additionally** to screen-display;
;       DV='pse' (or 'eps'): an encapsulated PostScript file (to be inserted
;		  into other documents like TeX) is produced additionally to 
;		  screen-display;
;         ='*!' or ='!*' (*: ps , eps , pse ): 
;	          **only** a PostScript file is produced; 
;	          default: output only on the device which was active before 
;		  calling DSP.
;       XS=xsz	: x-size of printed image (*); default =18 cm.
;	YS=ysz  : y-size of printed image (*); default =15 cm.
;       XT=xtt  : (string) x-axis label; default ='X'.
;       YT=ytt  : (string) y-axis label; default ='Y'.
;       HD=mtt  : (string) plot title; default ='' (no title).
;       XX=xax  : vector containing x values (vector-size = x-size of array!);
;                 default: indgen(nx), nx=size of 1st dim. of array.
;       YY=yax	: ditto for y axis.
;       BAR=bar_pos : a scaled bar is displayed at specified position showing
;	          the corespondence between colors/grey-scale and array values;
;		  bar_pos: 4-element vector [x0,y0,x1,y1] of lower left and
;		  upper right corner of the sub-image (in array pix; this sub-
;		  image is 50 pix longer and 27 pix wider than the colored 
;		  strip); if only /BAR is specified, the bar position is
;		  centered in x and set above (screen) or below the main image.
;       CO=col  : to produce Color-PostScript output (*);
;	          if DSP is called from a color-workstation, the active color-
;		  table will be used (value of col will be ignored); otherwise,
;		  color table #<col> (0 <= col <= 20) will be loaded;
;		  default: b/w PostScript output.
;       PR=prt  : meaningful only if DV='ps' (or '!ps' or 'ps!') (*):
;		  = 1 (or /PR): PS-file idl.ps will be sent to LW (or PJPS, 
;		     if col >= 0) !!! and then be removed !!!;
;                 = 2: PS-file idl.ps file will be renamed to idl_dsp.<nnn>.ps
;		      (no spooling to printer);
;                >= 3: PS-file idl.ps will be sent to local DeskJet (or TEKPS
;		     if col >= 0) !!! and then be removed !!!;
;		  this key is meaningless in case of encapsulated PostScript.
;		  Default (PR not set or PR <= 0): no action beside creating
;		  PS-file idl.ps; !!! in any case, an existing idl.ps will be
;		  overwritten !!!
;       BP=bit  : bits per pixel; default: 4 for b/w, 8 for color (*).
;       (*): these parameters do not affect screen display.
; OUTPUTS: 
;	none
; OPTIONAL OUTPUTS: 
;	none
; COMMON BLOCKS: 
;	none
; SIDE EFFECTS: 
;	PS-file idl.ps or idl_dsp.<nnn>.ps if DEV='ps' and PR=2 or not set.
;       Use the xsize and ysize parameters to obtain the desired size of
;       the output. 
; RESTRICTIONS:
;	Printing huge arrays takes rather long and should be avoided. 
;	If the image on the screen looks strange, try a larger window.  
; PROCEDURE: 
;	Combine tv and contour routines.
; MODIFICATION HISTORY:
;	1991-Jul-02 ws (KIS): created.
;       1992-Sep-04 ws (KIS): updates.
;	1992-Sep-29 nlte (KIS): additions: zrange, bar, color table loading,
;			              more options for prt, 
;			 tv,bytscl(array) (not array=bytscl(array) & tv,array).
;	1993-Apr-08 nlte (KIS): special case GOOFY: no spooling to tekps.
;       1993-Jun-21 nlte (KIS): PR=1: output device "LW" or "PJPS",
;			        PR=3: output device DeskJet or "TEKPS";
;				coding for bar improved. 
;- 
pro dsp,array,range=zrange,dv=dev,xs=xsz,ys=ysz,xt=xtt,yt=ytt,hd=mtt,$
        xx=xax,yy=yax,co=col,pr=prt,bp=bit,bar=barpos0
;
on_error,1
if n_params() ne 1 then message,$
                        'USAGE: DSP,array [,optional keyword parameters]'
sz=size(array)
if sz(0) ne 2 then message,'1st arg must be a 2-dim array'
olddev=!D.NAME & oldcol=!P.COLOR & oldback=!P.BACKGROUND
if n_elements(dev) le 0 then dev=olddev
if n_elements(xsz) le 0 then xsz=18
if n_elements(ysz) le 0 then ysz=15
if n_elements(xtt) le 0 then xtt='X'
if n_elements(ytt) le 0 then ytt='Y'
if n_elements(mtt) le 0 then ttm='' else ttm=mtt+'!C '
if n_elements(xax) le 0 then xax=indgen(sz(1))
if n_elements(yax) le 0 then yax=indgen(sz(2))
if n_elements(col) le 0 then begin col=-1 & bitdef=4 & endif else bitdef=8
if n_elements(prt) le 0 then prt=0
if n_elements(bit) le 0 then bit=bitdef
if n_elements(zrange) ne 2 then begin 
   zmin=min(array) & zmax=max(array)
endif else begin
   zmin=min(zrange) & zmax=max(zrange)
endelse
nelbp=(n_elements(barpos0)>0)<5
case nelbp of
  0:    lbar=0
  1:    if barpos0 le 0 then lbar=0 else lbar=1
  4:    lbar=2
  else: lbar=1
endcase
if lbar eq 1 then barpos=[(sz(1)-256)/2,sz(2)+36,(sz(1)-256)/2+255,sz(2)+75] $
             else if lbar eq 2 then barpos=barpos0
;
if strpos(dev,'!') lt 0 then begin
   plot,indgen(25),/nodata,xstyl=4,ystyl=4,tickl=-0.02,charsi=1.2,$
   tit='T!C ',xtit='X',ytit='Y'
   erase
   px=!x.window * !d.x_vsize & py=!y.window * !d.y_vsize
   posscreen=[px(0),py(0),px(0)+sz(1)-1,py(0)+sz(2)-1]
   tv,bytscl(array,zmin,zmax),px(0),py(0)
   if lbar gt 0 then begin
      bpos=barpos & bpos(0)=bpos(0)+px(0) & bpos(2)=bpos(2)+px(0)
      bpos(1)=bpos(1)+py(0) & bpos(3)=bpos(3)+py(0)
      mkbar,zmin,zmax,barpos(2)-barpos(0)+1,barpos(3)-barpos(1)+1,bpos,0
   endif
   contour,array,xax,yax,/noerase,xstyle=1,ystyle=1,                     $
        position=posscreen,/device,   $
        xtitle=xtt,ytitle=ytt,title=ttm,/nodata,charsi=1.2,ticklen=-0.02
   print,string(fix(px(0)),fix(py(0)),$
   form='("******* Raster image offset (screen):",i4,",",i4," pix *******")')
endif
;
if strpos(strupcase(dev),'PS') ge 0 then begin
   if strpos(strupcase(dev),'E') ge 0 then psenc=1 else psenc=0
   if col ge 0 then begin
      lco=1
      n_old_colors=!d.n_colors
      if n_old_colors gt 2 then tvlct,red,green,blue,/get ; get actual col.tab.
   endif else lco=0
   yofs=27.-ysz & xofs=2.
;   print,xsz,ysz,col,prt,bit
   set_plot,'ps',/copy,/interpolate
   device,xsize=xsz,ysize=ysz,xoff=xofs,yoff=yofs,color=lco,bits=bit,$
          /portrait,encapsulated=psenc
;
; following plot actions will be overwritten later. Just to get window-size.
   contour,array,xax,yax,xstyle=1,ystyle=1,xtitle=xtt,ytitle=ytt,     $
           /nodata,charsi=1.2,ticklen=-0.02,ymarg=[8,2]   
   device,/close  ; forces ps-file to be overwritten by subsequent actions!
;
; now produce the PS-output!
   !psym=0 & !linetype=0 & px=!x.window & py=!y.window
   if lco then begin
      n_new_colors=!d.n_colors
      if n_old_colors gt 2 then begin
        if n_old_colors lt n_new_colors then begin
           red=[red,replicate(255b,n_new_colors-n_old_colors)]
           green=[green,replicate(255b,n_new_colors-n_old_colors)]
           blue=[blue,replicate(255b,n_new_colors-n_old_colors)]
        endif
     tvlct,red,green,blue      ; use actual color table
     endif else loadct,col     ; use (full) color table # <col>
   endif
;
   tv,bytscl(array,zmin,zmax),px(0),py(0),$
      xsize=px(1)-px(0),ysize=py(1)-py(0),/norm
   contour,array,xax,yax,/noerase,xstyle=1,ystyle=1,thick=3,ticklen=-0.02 $
          ,xtitle=xtt,ytitle=ytt,title=ttm,/nodata,charsi=1.2,font=-1 $
          ,ymarg=[8,2]
   if lbar gt 0 then begin
      if lbar eq 1 then begin 
         barpos(0)=0.2*sz(1) & barpos(2)=0.8*sz(1)
         barpos(1)=-4.17*sz(2)/ysz & barpos(3)=barpos(1)+0.12*sz(2)    
      endif
      bpos=float(barpos)
      fx=float(px(1)-px(0))/sz(1) & fy=float(py(1)-py(0))/sz(2)
      bpos(0)=px(0)+bpos(0)*fx & bpos(2)=px(0)+bpos(2)*fx
      bpos(1)=py(0)+bpos(1)*fy & bpos(3)=py(0)+bpos(3)*fy
      mkbar,zmin,zmax,barpos(2)-barpos(0)+1,barpos(3)-barpos(1)+1,bpos,1
   endif
   xyouts,0,0,strmid(!stime,0,17)+' '+getenv('USER'),charsize=0.6,/device
   device,/close
;
   if psenc then pprt=2 else pprt=(prt>0)<3
   if strlowcase(getenv('HOST')) eq 'goofy' and pprt eq 1 then pprt=2
   case pprt of
   0: print,'******* Do not forget to print the idl.ps file *******'
   1: begin
	if lco then pty='PJPS' else pty='LW'
        spawn,'lpr -h -P'+pty+' idl.ps; rm idl.ps'
	print,'******* idl.ps will be printed at '+pty+' and removed *******'
      end
   2: begin
        suff=-1 & ps0='idl_dsp.ps' & if psenc then ps0=ps0+'_enc'
        repeat begin 
           suff=suff+1 & psfil=string(ps0,suff,form='(a,i3.3)')
           ff=findfile(psfil,count=nff)
        endrep until nff le 0
        spawn,'mv idl.ps '+psfil
        print,'******* PS-file renamed: '+psfil+' *******'
      end
   3: begin
	if lco then begin 
           pty='tekps' & spawn,'lpr -h -P'+pty+' idl.ps; rm idl.ps'
        endif else begin
           pty='DeskJet' & spawn,'gs2hpd idl.ps; rm idl.ps'
        endelse
	print,'******* idl.ps will be printed at '+pty+' and removed *******'
      end
   endcase
;  
  set_plot,olddev & !P.COLOR=oldcol & !P.BACKGROUND=oldback
  if n_elements(posscreen) gt 0 then $
   contour,array,/nodata,/noerase,xax,yax,xstyle=1,ystyle=1,    $
        position=posscreen,/device,   $
        xtitle=xtt,ytitle=ytt,title=ttm,charsi=1.2,ticklen=-0.02
endif
;
return
end
