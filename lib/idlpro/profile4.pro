pro profile4, special, file, factorx, factory, factorim,$
              im1, im2, im3, im4, xi, yi, xq,$
              yq, xu, yu, xv, yv, $
	      im2_byte, im3_byte, wsize=wsize, order=order, generic=generic,$
	      xv2q=xv2q,xv2u=xv2u,xi2quv=xi2quv,xoffset=xoffset
;+
;
;	procedure:  profile4
;
;	purpose:  do "profiles" on 4 images at a time (e.g., ASP I,Q,U,V)
;
;	author:  rob@ncar, 2/92
;
;	notes:  used code from RSI's "profiles" procedure
;
;==============================================================================
;
;	Check number of parameters.
;
print,n_params()
if (n_params() ne 17) and (n_params() ne 19) then begin
	print
	print, "usage: profile4, s, i, q, u, v, xi, yi, xq, yq, xu, yu, xv, yv"
	print, "		 [, q_byte, u_byte]"
	print
	print, "	Do profiles on 4 images."
	print
	print, "	Arguments"
	print, "		s	  - 0 = do tvscl; 1 = do tv;"
	print, "			    2 = do tvscl on i,v and tv on q,u"
	print, "			        ... must specify q_byte,u_byte"
	print, "			    3 = do newct_tvscl; 4 = do tvasp"
	print, "		i,q,u,v	  - the four images; data need not be"
	print, "			    scaled into bytes (i.e., they"
	print, "			    may be floating point arrays)."
	print, "		xi - xv,"
	print, "		yi - yv	  - lower left corners of 4 images"
	print
	print, "		q_byte,	  - byte images for 's=2' option"
	print, "		 u_byte"
	print
	print, "	Keywords"
	print, "		wsize	  - size of new window as a fraction"
	print, "			    or multiple of (640, 640)"
	print, "			    (def = 0.5)"
	print, "		order	  - set to 1 for images written top"
	print, "			    down, 0 for bottom up."
	print, "			    (def = current !ORDER)"
	print, "		generic	  - if set, use generic labels rather"
	print, "			    than I, Q, U, V"
	print
	return
endif
;-
;
;	Set to return to caller on error.
;
on_error,2
;
;	Specify common blocks.
;
common profile4, p4_qu_range, p4_v_range, p4_ngray
@iquv_label.com
;
;	Set keywords.
;
if n_elements(wsize) eq 0 then wsize = 1
if n_elements(order) eq 0 then order = !order
if (keyword_set(xv2q) eq 0) then xv2q=0
if (keyword_set(xv2u) eq 0) then xv2u=0
if (n_elements(xi2quv) ne 3) then xi2quv=[0,0,0]
;
;	Set parameters.
;
s = size(im1)
nx = s(1)				;Cols in image
ny = s(2)				;Rows in image
orig_w = !d.window
xbord = 0.05
ybord = 0.05
ybias = 0.03
p1 = [0.0 + xbord, 0.5 + ybord + ybias, 0.5 - xbord, 1.0 - ybord]
p2 = [0.5 + xbord, 0.5 + ybord + ybias, 1.0 - xbord, 1.0 - ybord]
p3 = [0.0 + xbord, 0.0 + ybord + ybias, 0.5 - xbord, 0.5 - ybord]
p4 = [0.5 + xbord, 0.0 + ybord + ybias, 1.0 - xbord, 0.5 - ybord]
ans = string(' ',format='(a1)')
tickl = 5
;
;	Set extrema.
;
imi=median(rfits_im(file+'c',1,dd,hdr,nrhdr),3)
imq=median(rfits_im(file+'c',2),3)	;/imi
imu=median(rfits_im(file+'c',3),3)	;/imi
imv=median(rfits_im(file+'c',4),3)	;/imi

imi2=compress(imi,factorim)
imq2=compress(imq,factorim)
imu2=compress(imu,factorim)
imv2=compress(imv,factorim)

get_lun,unit
openr,unit,file+'c'
if(dd.bitpix eq 8) then begin
   datos=assoc(unit,bytarr(dd.naxis1,dd.naxis2),long(2880)*nrhdr)
endif else if(dd.bitpix eq 16) then begin   
   datos=assoc(unit,intarr(dd.naxis1,dd.naxis2),long(2880)*nrhdr)
endif else if(dd.bitpix eq 32) then begin   
   datos=assoc(unit,lonarr(dd.naxis1,dd.naxis2),long(2880)*nrhdr)
endif

tam=size(imi)
nxi=tam(1)
nyi=tam(2)
minv1 = min(imi, max=maxv1)
maxv1=maxv1*1.2
minv2 = -0.3*maxv1 ;min(imq, max=maxv2)
minv3 = -0.3*maxv1 ;min(imu, max=maxv3)
minv4 = -0.3*maxv1 ;min( 'imv, max=maxv4)
maxv2= 0.3*maxv1
maxv3= 0.3*maxv1
maxv4= 0.3*maxv1
if special eq 2 then begin		;Will plot same Q,U range if special=2
	minv2 = min([minv2, minv3])
	minv3 = minv2
	maxv2 = max([maxv2, maxv3])
	maxv3 = maxv2
endif
;
;	Set generic vs. I,Q,U,V parameters.
;
if keyword_set(generic) then begin
	xtitle1 = 'I'
	xtitle2 = 'Q'
	xtitle3 = 'U'
	xtitle4 = 'V'
endif else begin
	xtitle1 = 'I'
	xtitle2 = 'Q'
	xtitle3 = 'U'
	xtitle4 = 'V'
endelse
;
;	Set for hardware font.
;
old_font = !p.font
!p.font = 0
;
first_time = 1
;
;-------------------------
;	MAIN LOOP
;-------------------------
;
vecx1old=[0,0]
vecy1old=[0,0]
vecx2old=[0,0]
vecy2old=[0,0]
vecx3old=[0,0]
vecy3old=[0,0]
vecx4old=[0,0]
vecy4old=[0,0]
xold=-1
yold=-1
mode=0
factorplot=3
while 1 do begin
;
;	Set image window to current window.
;
	wset,orig_w
;
;	Handle 1st time (user selects what to interact with) or later picks.
;
	if first_time then begin
		first_time = 0
		print
		print, 'Click on image to interact with (I, Q, U, or V).'
		print
		print, '    Left Mouse Button - row profile'
		print, '  Middle Mouse Button - column profile'
		print, '   Right Mouse Button - exit'
		print
		cursor, x, y, 3, /dev 		;Read button down position
		if (x lt xq) and (y ge yi) then begin
			print, '	Interacting with I ...'
			sx = xi
			sy = yi
		endif else if (x ge xq) and (y ge yq) then begin
			print, '	Interacting with Q ...'
			sx = xq
			sy = yq
		endif else if (x lt xq) and (y lt yq) then begin
			print, '	Interacting with U ...'
			sx = xu
			sy = yu
		endif else begin
			print, '	Interacting with V ...'
			sx = xv
			sy = yv
		endelse
;
;		Set the cursor position and window.
;		window, /free , xs=wsize*640, ys=wsize*640, title=''
;		win_index = !d.window
		window, 0 , xs=wsize*550, ys=wsize*550, title='Profiles'
		nrayas=10
		wset,32
		wxoffset=!d.x_size
		wyoffset=!d.y_size
		
		window,3,xsize=dd.naxis1/factorim,$
		   ysize=dd.naxis2/factorim*4+3*nrayas,$
		   xpos=wxoffset+10,ypos=0,title='Spectral Images'
		win_index = orig_w	;!d.window
		
;
	endif else begin
		cursor,x,y,3,/dev,/change  ;/nowait	 	;Read position if button down
	endelse
;
;
;	PERFORM ACTION BASED ON MOUSE CLICK.
;
;--------
;
;	Quit if mouse button 3 pushed.
;
;        noerase=0
	facch=0
	if !err eq 4 then begin
	   print,'Cambiar escalas o Salir'
	   cursor,x,y,3,/dev,/down
	   if !err eq 4 then begin
	      wset,orig_w		;Original window becomes current one
	      tvcrs,nx/2,ny/2,/dev	;Move cursor to old window
	      tvcrs,0			;Make cursor invisible
	      wdelete, win_index	;Delete profile window
	      wdelete, 0	;Delete profile window
	      wdelete, 3	;Delete profile window
	      !p.font = old_font	;Return original font
              free_lun,unit
              !p.multi=0
	      return
	   endif else if(!err eq 2) then  begin	
	      facch=1
	      factorplot=factorplot*3.
;	      noerase=0
;	      print,'factorplot= ',factorplot
;	      stop
	   endif else if(!err eq 1) then  begin
	      facch=1
	      factorplot=factorplot/3.
;	      noerase=0
;              print,'factorplot= ',factorplot
	   endif
	endif else if(!err eq 2) then  begin
	        facch=1
	 	factorplot=factorplot*3.
;		noerase=0
;		print,'factorplot= ',factorplot
;		stop
	endif else if(!err eq 1) then  begin
	        facch=1
	 	factorplot=factorplot/3.
;		noerase=0
;		print,'factorplot= ',factorplot
	endif
	
;
;--------
;
;	Set up for row or column profiling based on mouse click.
;
;	mode = 0
;	if !err eq 2 then mode = 1	;Mouse1 = row; Mouse2 = column
;
;--------
;
;	Draw profile if mouse pointer is within range.
;
	x = x - sx		;Remove bias
	y = y - sy
	x=fix(x/factorx)
	y=fix(y/factory)
	wset,win_index		;Graph window becomes current window

	if (x lt fix(nx/factorx)) and (y lt fix(ny/factory)) and $
	   (x ge 0) and (y ge 0) then begin

		if order then y = (ny-1)-y		;Invert y
		value = strmid(x,8,4)+strmid(y,8,4)
		imi=median(rfits_im2(datos,dd,4*(x+xoffset)+1),3)
		imq=median(rfits_im2(datos,dd,4*(x+xoffset)+2),3)	;/imi
		imu=median(rfits_im2(datos,dd,4*(x+xoffset)+3),3)	;/imi
		imv=median(rfits_im2(datos,dd,4*(x+xoffset)+4),3)	;/imi
		imi2=compress(imi,factorim)
		imq2=compress(imq,factorim)
		imu2=compress(imu,factorim)
		imv2=compress(imv,factorim)
;		print,'posicion= ',4*x+1,4*x+2,4*x+3,4*x+4
;		print,'rendija= ',y
		imq=imq-xv2q*imv-xi2quv(0)
		imu=imu-xv2u*imv-xi2quv(1)
		imv=imv-xi2quv(2)
;		imv=imu+0.15*imq-0.97*imu
		if mode then begin			;Get column
			vecy1 = findgen(nyi)
			vecy2 = vecy1
			vecy3 = vecy1
			vecy4 = vecy1
			vecx1 = imi(x,*)
			vecx2 = imq(x,*)
			vecx3 = imu(x,*)
			vecx4 = imv(x,*)
			dibujo=0
			if(x ne xold) then dibujo=1
			xold=x
		endif else begin			;Get row
			vecx1 = findgen(nxi)
			vecx2 = vecx1
			vecx3 = vecx1
			vecx4 = vecx1
			vecy1 = imi(*,y)
			vecy2 = imq(*,y)
			vecy3 = imu(*,y)
			vecy4 = imv(*,y)
			dibujo=0
			if(x ne xold or y ne yold or facch eq 1) then dibujo=1
			yold=y
		endelse
;
;		Set up and plot profiles.
;
	     if dibujo then begin
		        wset,0
		if mode then begin			;Column profile
		        !p.multi=[4,2,2]
			plot,[minv1,maxv1],[0,nyi-1],/nodata, $
				xtitle=xtitle1, position=p1
			oplot,vecx1old,vecy1old,color=0
			oplot,vecx1,vecy1
		        !p.multi=[3,2,2]
			plot,factorplot*[minv2,maxv2],[0,nyi-1],/nodata, noerase=noerase, $
				xtitle=xtitle2, position=p2
			oplot,vecx2old,vecy2old,color=0
			oplot,vecx2,vecy2
		        !p.multi=[2,2,2]
			plot,factorplot*[minv3,maxv3],[0,nyi-1],/nodata, noerase=noerase, $
				xtitle=xtitle3, position=p3
			oplot,vecx3old,vecy3old,color=0
			oplot,vecx3,vecy3
		        !p.multi=[1,2,2]
			plot,factorplot*[minv4,maxv4],[0,nyi-1],/nodata, noerase=noerase, $
				xtitle=xtitle4, position=p4
			oplot,vecx4old,vecy4old,color=0
			oplot,vecx4,vecy4
			str = 'Column Profile,' + string(value)
			xyouts, .5, .975, /norm, align=.5, str

		end else begin				;Row profile
		        !p.multi=[0,2,2]
;			print,'noerase=',noerase
;		print,'factorplot= ',factorplot
			plot,[0,nxi-1],[minv1,maxv1],/nodata, $
				xtitle=xtitle1, position=p1
			oplot,vecx1old,vecy1old,color=0
			oplot,vecx1,vecy1
		        !p.multi=[2,2,2]
			plot,[0,nxi-1],factorplot*[minv2,maxv2],/nodata,$; noerase=noerase, $
				xtitle=xtitle2, position=p2
			oplot,vecx2old,vecy2old,color=0
			oplot,vecx2,vecy2
		        !p.multi=[2,2,2]
			plot,[0,nxi-1],factorplot*[minv3,maxv3],/nodata,$; noerase=noerase, $
				xtitle=xtitle3, position=p3
			oplot,vecx3old,vecy3old,color=0
			oplot,vecx3,vecy3
		        !p.multi=[1,2,2]
			plot,[0,nxi-1],factorplot*[minv4,maxv4],/nodata,$; noerase=noerase, $
;			plot,[0,nxi-1],[-0.2,0.2],/nodata,$; noerase=noerase, $
				xtitle=xtitle4, position=p4
			oplot,vecx4old,vecy4old,color=0
			oplot,vecx4,vecy4
			str = 'Row Profile,' + string(value)
			str = 'Scan Position:' + strtrim(x+xoffset,2) + $
                              '  ; Slit position:' + strtrim(y,2)
			xyouts, .5, .975, /norm, align=.5, str
		endelse
		vecx1old=vecx1
		vecy1old=vecy1
		vecx2old=vecx2
		vecy2old=vecy2
		vecx3old=vecx3
		vecy3old=vecy3
		vecx4old=vecx4
		vecy4old=vecy4
;
;		Plot crosshairs.
;
		wset, orig_w

		case special of				;Replot images
		   0: begin
			tvscl, im1, xi, yi
			tvscl, im2, xq, yq
			tvscl, im3, xu, yu
			tvscl, im4, xv, yv
			wset,3

			imqq=bytscl(imq2,min=factorplot*minv2,$
			   max=factorplot*maxv2,top=!d.n_colors)
			imuu=bytscl(imu2,min=factorplot*minv3,$
		           max=factorplot*maxv3,top=!d.n_colors)
			imvv=bytscl(imv2,min=factorplot*minv4,$
			   max=factorplot*maxv4,top=!d.n_colors)
;			imqq=(factorplot*minv2)>imq<(factorplot*maxv2)
;			imuu=(factorplot*minv3)>imu<(factorplot*maxv3)
;			imvv=(factorplot*minv4)>imv<(factorplot*maxv4)
			tvscl,imi2,0,3*(dd.naxis2/factorim+nrayas)
			tv,imqq,0,2*(dd.naxis2/factorim+nrayas)
			tv,imuu,0,1*(dd.naxis2/factorim+nrayas)
			tv,imvv,0,0*(dd.naxis2/factorim+nrayas)
			wset,orig_w
		      end
		   1: begin
			tv, im1, xi, yi
			tv, im2, xq, yq
			tv, im3, xu, yu
			tv, im4, xv, yv
		      end
		   2: begin
			tvscl, im1, xi, yi
			tv, im2_byte, xq, yq
			tv, im3_byte, xu, yu
			tvscl, im4, xv, yv
		      end
		   3: begin
			newct_tvscl, im1, xi, yi
			newct_tvscl, im2, xq, yq
			newct_tvscl, im3, xu, yu
			newct_tvscl, im4, xv, yv
		      end
		   4: begin
			tvasp, im1, xi, yi, /red, center=p4_ngray, /gray
			tvasp, im2, xq, yq, /red, center=p4_ngray, $
				min=(-p4_qu_range), max=p4_qu_range
			tvasp, im3, xu, yu, /red, center=p4_ngray, $
				min=(-p4_qu_range), max=p4_qu_range
			tvasp, im4, xv, yv, /red, center=p4_ngray, $
				min=(-p4_v_range), max=p4_v_range
		      end
		   else:  message, "improper 'special' value"
		endcase

		xx=factorx*x
		yy=factory*y
		x1 = xx - tickl				;Do crosshairs
		x2 = xx + tickl
		y1 = yy - tickl
		y2 = yy + tickl
		plots, [xi + x1, xi + x2], [yi + yy, yi + yy], /device
		plots, [xi + xx, xi + xx], [yi + y1, yi + y2], /device
		plots, [xq + x1, xq + x2], [yq + yy, yq + yy], /device
		plots, [xq + xx, xq + xx], [yq + y1, yq + y2], /device
		plots, [xu + x1, xu + x2], [yu + yy, yu + yy], /device
		plots, [xu + xx, xu + xx], [yu + y1, yu + y2], /device
		plots, [xv + x1, xv + x2], [yv + yy, yv + yy], /device
		plots, [xv + xx, xv + xx], [yv + y1, yv + y2], /device
		
		wset,3
		x1=dd.naxis1/2/factorim - tickl
		x2=dd.naxis1/2/factorim + tickl
		xm=dd.naxis1/2/factorim
		y1=y/factorim - tickl
		y2=y/factorim + tickl
		plots, [x1, x2], [y, y]/factorim, /device
		plots, [xm, xm], [y1, y2], /device
		plots, [x1, x2], [y, y]/factorim+(dd.naxis2/factorim+nrayas), /device
		plots, [xm, xm], [y1, y2]+(dd.naxis2/factorim+nrayas), /device
		plots, [x1, x2], [y, y]/factorim+2*(dd.naxis2/factorim+nrayas), /device
		plots, [xm, xm], [y1, y2]+2*(dd.naxis2/factorim+nrayas), /device
		plots, [x1, x2], [y, y]/factorim+3*(dd.naxis2/factorim+nrayas), /device
		plots, [xm, xm], [y1, y2]+3*(dd.naxis2/factorim+nrayas), /device
		
	   endif
	endif
endwhile
end
