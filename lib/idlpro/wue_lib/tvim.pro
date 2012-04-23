pro tvim,a,scale=scale,range=range,xrange=xrange,yrange=yrange,aspect=aspect,$
           title=title,xtitle=xtitle,ytitle=ytitle,noframe=noframe
;+
; ROUTINE   tvim
;
; USEAGE:   tvim,a
;
;           tvim,a,title=title,xtitle=xtitle,ytitle=ytitle,$
;                              xrange=xrange,yrange=yrange,$
;                              scale=scale,range=range,noframe=noframe,aspect
;
; PURPOSE:  Display an image with provisions for
;               
;            1. numbered color scale 
;            2. plot title
;            3. annotated x and y axis 
;            4. simplified OPLOT capability
;
; INPUT    a           image quantity
;
; Optional keyword input:
;
;          title       plot title
;
;          xtitle      x axis title
; 
;          ytitle      y axis title
;
;          xrange      array spanning entire x axis range.  
;                      NOTE:  TVIM only uses min(XRANGE) and max(XRANGE).
;
;          yrange      array spanning entire y axis range.  
;                      NOTE:  TVIM only uses min(YRANGE) and max(YRANGE).
;
;          scale       if set draw color scale.  SCALE=2 causes steped
;                      color scale
;
;          range       two or three element vector indicating physical
;                      range over which to map the color scale.  The
;                      third element of RANGE, if specified, sets the
;                      step interval of the displayed color scale.  It
;                      has no effect when SCALE is not set. E.g.,
;                      RANGE=[0., 1., 0.1] will cause the entire color
;                      scale to be mapped between the physical values
;                      of zero and one; the step size of the displayed 
;                      color scale will be set to 0.1.
;
;          aspect      the x over y aspect ratio of the output image
;                      if not set aspect is set to (size_x/size_y) of the
;                      input image.  
;
;          noframe     if set do not draw axis box around image
;
;
; SIDE EFFECTS:        Setting SCALE=2 changes the color scale using the
;                      STEP_CT procedure.  The color scale may be returned
;                      to its original state by the command, STEP_CT,/OFF
;
; PROCEDURE            TVIM first determins the size of the plot data window
;                      with a dummy call to PLOT.  When the output device is
;                      "X", CONGRID is used to scale the image to the size of
;                      the available data window.  Otherwise, if the output
;                      device is Postscript, scaleable pixels are used in the
;                      call to TV.  PUT_COLOR_SCALE draws the color scale and
;                      PLOT draws the x and y axis and titles.
;
; DEPENDENCIES:        PUT_COLOR_SCALE, STEP_CT
;
; AUTHOR:              Paul Ricchiazzi    oct92 
;                      Earth Space Research Group, UCSB
;-
sz=size(a)
nx=sz(1)
ny=sz(2)
nxm=nx-1
nym=ny-1
plot, [0,1],[0,1],/nodata,xstyle=4,ystyle=4
px=!x.window*!d.x_vsize
py=!y.window*!d.y_vsize
xsize=px(1)-px(0)
ysize=py(1)-py(0)
if keyword_set(scale) then xsize=xsize-50*!d.x_vsize/700.
if keyword_set(aspect) eq 0 then aspect=float(nx)/ny
if xsize gt ysize*aspect then xsize=ysize*aspect else ysize=xsize/aspect 
px(1)=px(0)+xsize
py(1)=py(0)+ysize
;
;
max_color=!d.n_colors-1
;
if keyword_set(title) eq 0 then title=''
amax=float(max(a))
amin=float(min(a))
print, 'a      min and max  ',   amin,amax
if keyword_set(range) eq 0 then range=[amin,amax]
;
;     draw color scale
;
if keyword_set(scale) then begin
  s0=float(range(0))
  s1=float(range(1))
  if n_elements(range) eq 3 then begin
    s2=range(2)
    range=range(0:1)
  endif else begin
    rng=alog10(s1-s0)
    if rng lt 0. then pt=fix(alog10(s1-s0)-.5) else pt=fix(alog10(s1-s0)+.5)
    s2=10.^pt
    tst=[.05,.1,.2,.5,1.,2.,5.,10]
    ii=where((s1-s0)/(s2*tst) le 16)
    s2=s2*tst(ii(0))
  endelse 
  xs=px(1)+9*!d.x_vsize/700.
  ys=py(0)
  ysize=py(1)-py(0)
  if scale eq 2 then step_ct,[s0,s1],s2
endif
;
aa=(max_color-1)*((float(a)-range(0))/(range(1)-range(0)) > 0. < 1.)
;
if !d.name eq 'X' then begin
  tv,congrid(aa,xsize,ysize),px(0),py(0)
  pos=[px(0),py(0),px(1),py(1)]
endif else begin
  pos=[px(0),py(0),px(1),py(1)]
  tv,aa,px(0),py(0),xsize=xsize,ysize=ysize,/device
endelse

if keyword_set(scale) then put_color_scale,xs,ys,range,s2,ysize=ysize
;
if (keyword_set(xtitle) eq 0) then xtitle=''
if (keyword_set(ytitle) eq 0) then ytitle=''
if (keyword_set(xrange) eq 0) then $
  xrng=[0,nxm] else xrng=[min(xrange), max(xrange)]
if (keyword_set(yrange) eq 0) then $
  yrng=[0,nym] else yrng=[min(yrange), max(yrange)]
if keyword_set(noframe) then begin
  plot,[0,0],[0,0],xstyle=5,ystyle=5,title=title,xtitle=xtitle,ytitle=ytitle, $
       xrange=xrng,yrange=yrng,position=pos,/noerase,/device,/nodata
endif else begin
  plot,[0,0],[0,0],xstyle=1,ystyle=1,title=title,xtitle=xtitle,ytitle=ytitle, $
       xrange=xrng,yrange=yrng,position=pos,/noerase,/device,/nodata
endelse
;
end





