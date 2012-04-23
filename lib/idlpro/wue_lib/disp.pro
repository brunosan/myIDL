;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; NAME:
;	DISP
; PURPOSE:
;       Display spectral data.
;       Use icons to scroll data with mouse (press left mouse
;       button on icon) in x- and y-direction. Points may be
;       marked (left mouse button in graphic area) or deleted
;       (middle mouse button in graphic area) interactively. 
;       Use right mouse button to exit program
; CATEGORY:
; CALLING SEQUENCE:
;	disp, x[,y,xex,yex,frac=f,cent=c,/append
; INPUTS:
;       x : x-coordinates of data, if specified without
;           corresponding y-coordinates, x-values are plotted
;           versus their index values.
; OPTIONAL INPUT PARAMETERS:
;	y     : y-coordinates of data (may be missing)
;       xex,yex   : points already marked (see OUTPUTS),
;                   if 'append' is specified
; KEYWORDS:
;       frac=f : fraction of the input vector (0<f<=1) to be 
;                visible when entering program
;       cent=c : center of visible data around c (0<=c<=1)
;	append : if given and nonzero, append interactively marked
;	          points to existing ones.
; OUTPUTS:
;       xex   : points marked interactively with cursor (x-coordinates)
;       yex   : points marked interactively with cursor (y-coordinates)
; COMMON BLOCKS:
;	-
; SIDE EFFECTS:
;	
; RESTRICTIONS:
;	-
; NOTES:
;	Do not resize the plot window while disp is active.
;
;	If disp is called with the append option and all points
;       are deleted, xex and yex will still hold one entry, which
;       is zero for both coordinates.
;
; --->  DISP will not compile until you set the program area
;       large enough (e.g. ".size 32768 32768")
;
; MODIFICATION HISTORY:
;	written July 1991 by Reinhold Kroll
;       last update 25.JAN.93
;-------------------------------------------------------------------
;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro no2de,x,y
;
; convert normalized to device coordinates
;
on_error,2
x=x*!d.x_vsize
if n_elements(y) ne 0 then y=y*!d.y_vsize
return
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pro no2da,x,y,z
;
;  convert normal to data coordinates
;
on_error,2
x=(x-!x.s(0))/!x.s(1)
if !x.type eq 1 then x=10^x

if n_elements(y) ne 0 then begin 
y=(y-!y.s(0))/!y.s(1)
if !y.type eq 1 then y=10^y
endif

if n_elements(z) ne 0 then begin 
z=(z-!z.s(0))/!z.s(1)
if !z.type eq 1 then z=10^z
endif

return
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function boxer, llur
;   
;  return a box polygon from lower left and upper right points
;
on_error,2	; return to caller on error
if n_elements(llur) ne 4 then return,-1     ; bad input
box=fltarr(2,5)
box(0,0)=llur(0)
box(0,1)=llur(2)
box(0,2)=llur(2)
box(0,3)=llur(0)
box(0,4)=llur(0)
box(1,0)=llur(1)
box(1,1)=llur(1)
box(1,2)=llur(3)
box(1,3)=llur(3)
box(1,4)=llur(1)
return,box
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function inrec, x,y,r
;
; return a 1 if coordinates x,y are in rectangle r
; return 0 if not. Used by "disp"
;
on_error,2
if (x ge r(0)) and (x le r(2)) and (y ge r(1)) and (y le r(3)) $
   then return, 1
return, 0
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

pro rect, rec,string,angle,fg,bg,mg
;
; draw a rectangle with centered text
; fg,bg,mg : background, foreground, medium colors
; used by disp
;
on_error,2

r=rec
r0=r(0)  &  r1=r(1)  &  r2=r(2)  &  r3=r(3)
no2de,r0,r1
no2de,r2,r3
r(0)=r0  &  r(1)=r1  &  r(2)=r2  &  r(3)=r3
x=boxer(r)     ; get a box from lower left and upper right corner
polyfill,x,/device,color=mg  ; fill box area
plots,x,/device,color=fg,thick=2.     ; outline box
r(0:1)=r(0:1)+2  &  r(2:3)=r(2:3)-2   ; box to pixels smaller
y=boxer(r)
plots,y,/device,color=bg,thick=1.,linestyle=0     ; outline box
xc=(x(0,1)-x(0,0))/2. + x(0,0)  ; center of box
yc=(x(1,2)-x(1,1))/2. + x(1,1)

if angle lt 45 then begin          ; centering correction for horiz. text
    xcorr=0  &  ycorr=-4  &  endif
if angle gt 45 then begin          ; centering correction for vert. text
    xcorr=+4  &  ycorr=0  &  endif

xyouts, xc+xcorr,yc+ycorr,string,/device,alignment=.5, $
        color=bg,charthick=2.0,charsize=1.5, $
        orientation=angle
return
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

pro disp,datax,datay,x,y,frac=frac,cent=cent,append=append 
;
;  This is the main program
;
on_error,2   ; return to caller on error
nelxdata=n_elements(datax)
locswitch=0
nex=0
if n_elements(append) eq 0 then append=0
ppos_save=!p.position		; save !p.position
!p.position=[.2,.2,.95,.95]     ; define plot area
plotbox=!p.position
margin=[-.02,-.02,.02,.02] 	; a margin around tickmarks
plotbx=!p.position+margin
;plotbx=[.18,.18,.97,.97]            ; plot area + margin
cl=[.195,.195,.955,.955]
xposti=(plotbx(2)+plotbx(0))/2.
yposti=plotbx(3)+.01
plotbox=boxer(plotbx)
clipbox=boxer(cl)
;
; Decide, how program is invoked :
; do we have x AND y values ? do we have
; buffers for extracted points ?
;
CASE n_params() OF
1: begin				; we have just 'y'-values
    pxmode=0				; do not allow interactive cursor
    xdata=findgen(n_elements(datax))	; fake x-values
    ydata=datax				; treat as y-values
    end

2: begin				; x- and y-values, no buffers
    pxmode=0				; do not allow interactive cursor
    xdata=datax
    ydata=datay
    end

3: begin				; only 'y'-values, but buffers
    pxmode=1				; allow interactive cursor
    xdata=findgen(n_elements(datax))	; fake x-values
    ydata=datax
    if append ne 0 then begin 
        nex=n_elements(datay)           ; here are x-coords of pixels!
        xi=fltarr(nex+250)
        yi=fltarr(nex+250)
        if nex ne 0 then begin       
            xi(0:nex-1)=datay(0:nex-1)
            yi(0:nex-1)=x(0:nex-1)
            endif
        endif
        if append eq 0 then begin
            xi=fltarr(250)
            yi=fltarr(250)
            endif
        end

4: begin				; x- and y-values as well as buffers
    pxmode=1				; allow interactive cursor
    xdata=datax
    ydata=datay
        if append ne 0 then begin 
        nex=n_elements(x)                 
        xi=fltarr(nex+250)
        yi=fltarr(nex+250)
            if nex ne 0 then begin       
            xi(0:nex-1)=x(0:nex-1)
            yi(0:nex-1)=y(0:nex-1)
            endif
        endif
        if append eq 0 then begin 
            xi=fltarr(250)
            yi=fltarr(250)
            endif
        end
ELSE: begin
    print,' *** wrong number of parameters !!!'
    print,' *** usage: DISP, x[,y,xex,yex,frac=f,cent=c,/append]'
    return
    end
ENDCASE

if pxmode eq 1 then  begin  ; prepare array for single pixel plottin
    xpx=fltarr(1)   
    ypx=fltarr(1)
    endif


xmax=max(xdata)      		; define x-range at entry
xmin=min(xdata) 
xspan=xmax-xmin  

ymax=max(ydata)			; define y-range at entry
ymin=min(ydata)

yspan=ymax-ymin
ymax=ymax+yspan/20.  &  ymaxsv=ymax
ymin=ymin-yspan/20.  &  yminsv=ymin

;
; visible fraction of data 
;
if n_elements(frac) eq 0 then frac=.1
if frac le 0. then frac=.1
if frac ge 1. then frac=1.
xwin=xspan*frac 
;
; centering of data
;
if n_elements(cent) eq 0 then cent=.5
if cent le 0. then cent=0.
if cent ge 1. then cent=1.
cent=xspan*cent+xmin

x1=cent-xwin/2
if x1 lt xmin then x1=xmin
if x1 gt xmax-xwin then x1=xmax-xwin
x2=x1+xwin
x1sv=x1  &  x2sv=x2
;
; defaults for scrolling speed
;
xsladd=xspan/n_elements(xdata) *2.
xfsadd=5*xsladd
xsladdsv=xsladd


bl=strarr(30)    ; for blank axis
for i=0,29 do bl(i)=' '
;
; lets open a big window, if there is none open !
;
if !d.window eq -1 then window,title='DISP',xpos=240,xsize=900,ysize=650
;
bg=!d.n_colors-1 	; background color
fg=0			; foreground color
mg=bg/2			; used for the buttons
fg_save=!p.color	; save fore- and background
bg_save=!p.background
!p.background=bg
!p.color=fg
erase,bg
;
; show initial data
;
plot,xdata,ydata,title='!5',color=bg,xrange=[x1,x2],xstyle=1, $
      yrange=[ymin,ymax],ystyle=1  ; 
; what a smart trick: invisible plot to set parameters
axis,0.,.18,/norm,xax=0,xrange=[x1,x2],xstyle=1,color=fg,title='!5 '
axis,0.,.97,/norm,xax=1,xrange=[x1,x2],xstyle=1,xtickname=bl,  $
     color=fg,/save
axis,.18,0.,/norm,yax=0,yrange=[ymin,ymax],ystyle=1,color=fg
axis,.97,0.,/norm,yax=1,yrange=[ymin,ymax],ystyle=1,ytickname=bl,  $
     color=fg,/save
plots,plotbox,/norm,/noclip,color=fg
xyouts,xposti,yposti,!p.title,alignment=.5,color=fg,/norm,charsize=1.4

oplot,xdata,ydata,color=fg,clip=cl,/norm
plots,clipbox,/norm,/noclip,color=fg,linestyle=0
;plot,xdata,ydata,color=fg,clip=cl,/norm,    $
;     xrange=[x1,x2],xstyle=1,               $
;     yrange=[ymin,ymax],ystyle=1,title='!5 '

if (pxmode eq 1) and (nex gt 0) then          $
     oplot,xi,yi,psym=1,symsize=3.,color=fg,clip=cl,/norm
;
;  place the buttons 
;
xlen=0.065  &  xsep=xlen/10.
ylo=.05    &  yhi=.10
xs=!p.position(0)
r9=[xs,ylo,xs+xlen,yhi]
xs=xs+xlen+xsep
r1=[xs,ylo,xs+xlen,yhi]
xs=xs+xlen+xsep
r2=[xs,ylo,xs+xlen,yhi]
xs=xs+xlen+2.*xsep
r5=[xs,ylo,xs+xlen,yhi]

xe=!p.position(2)
r10=[xe-xlen,ylo,xe,yhi]
xe=xe-xlen-xsep
r4=[xe-xlen,ylo,xe,yhi]
xe=xe-xlen-xsep
r3=[xe-xlen,ylo,xe,yhi]
xe=xe-xlen-2.*xsep
r6=[xe-xlen,ylo,xe,yhi]

xc=(!p.position(2) + !p.position(0)) / 2.
xs=xc-xlen-xsep/2.
r7=[xs,ylo,xs+xlen,yhi]
xs=xc+xsep/2.
r8=[xs,ylo,xs+xlen,yhi]
r11=[!p.position(0),plotbx(1),!p.position(3),!p.position(1)]
r12=[!p.position(0),!p.position(3),!p.position(3),plotbx(3)]

rect, r1,'!5<<', 0.,fg,bg,mg
rect, r2,'<',  0.,fg,bg,mg
rect, r3,'>',  0.,fg,bg,mg
rect, r4,'>>', 0.,fg,bg,mg
rect, r5,'< >',0.,fg,bg,mg
rect, r6,'> <',0.,fg,bg,mg
rect, r7,'!20d!5 !20c!5', 0.,fg,bg,mg
rect, r8,'!20b!5',  0.,fg,bg,mg
rect, r9,'!3<-!5', 0.,fg,bg,mg
rect, r10,'!3->!5', 0.,fg,bg,mg
xlo=.04  &  xhi=.08
ylen=.12
ysep=ylen/5.
ys=!p.position(1)

r21=[xlo,ys,xhi,ys+ylen]
ys=ys+ylen+ysep
r23=[xlo,ys,xhi,ys+ylen]
ye=!p.position(3)
r24=[xlo,ye-ylen,xhi,ye]
ye=ye-ylen-ysep
r22=[xlo,ye-ylen,xhi,ye]
yc=(!p.position(3)+!p.position(1))/2.
ys=yc-ylen/2.
r25=[xlo,ys,xhi,ys+ylen]
r31=[plotbx(0),!p.position(1),!p.position(0),!p.position(3)]
r32=[!p.position(2),!p.position(1),plotbx(2),!p.position(3)]
rect, r21,'<',90.,fg,bg,mg
rect, r22,'> <',90.,fg,bg,mg
rect, r23,'< >',90.,fg,bg,mg
rect, r24,'>',90.,fg,bg,mg
rect, r25,'!20b!5',90.,fg,bg,mg
xlen=xhi-xlo
r91=[xlo,ylo,xlo+3*xlen,yhi]
dyl=yhi-ylo
ylo=yhi
yhi=ylo+dyl
r41=[xlo,ylo,xlo+xlen,yhi]
xlo=xlo+xlen
r42=[xlo,ylo,xlo+xlen,yhi]
xlo=xlo+xlen
r43=[xlo,ylo,xlo+xlen,yhi]
rect, r91,'!3Ex!5',0.,fg,bg,mg
rect, r41,'!3P!5',0.,fg,bg,mg
rect, r42,'!5?!5',0.,fg,bg,mg
if locswitch eq  0 then rect, r43,'!5-!5',0.,fg,bg,mg
if locswitch eq  1 then rect, r43,'!93!5',0.,fg,bg,mg
if locswitch eq -1 then rect, r43,'!91!5',0.,fg,bg,mg
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  main program loop : wait for mouse button 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
button:
ret=0  &  !err=0            ; initialize return codes
cursor,a,b,/normal,/wait    ; get cursor position 
if !err eq 4 then goto,done ; middle mouse button, leave program
;
; if the cursor was at a button,
; assign a unique value to it
;
ret=ret+inrec(a,b,r1) 
ret=ret+inrec(a,b,r2)*2
ret=ret+inrec(a,b,r3)*3
ret=ret+inrec(a,b,r4)*4
ret=ret+inrec(a,b,r5)*5
ret=ret+inrec(a,b,r6)*6
ret=ret+inrec(a,b,r7)*7
ret=ret+inrec(a,b,r8)*8
ret=ret+inrec(a,b,r9)*9
ret=ret+inrec(a,b,r10)*10
ret=ret+inrec(a,b,r11)*11
ret=ret+inrec(a,b,r12)*12
ret=ret+inrec(a,b,r21)*21
ret=ret+inrec(a,b,r22)*22
ret=ret+inrec(a,b,r23)*23
ret=ret+inrec(a,b,r24)*24
ret=ret+inrec(a,b,r25)*25
ret=ret+inrec(a,b,r31)*31
ret=ret+inrec(a,b,r32)*32
ret=ret+inrec(a,b,r41)*41
ret=ret+inrec(a,b,r42)*42
ret=ret+inrec(a,b,r43)*43
ret=ret+inrec(a,b,r91)*91
ret=ret+inrec(a,b,!p.position)*99
if ret eq 0 then goto, button
;
;   X-buttons selected, do horizontal scrolling
;
if (ret ge 1) and (ret le 20) then begin
    if ret eq 1 then begin  		;  fast right
	x2n=x2+xfsadd
	x2n=x2n < xmax
        x1n=x2n - (x2-x1)
        endif
    if ret eq 2 then begin 		;  slow right
	x2n=x2+xsladd
	x2n=x2n < xmax
        x1n=x2n - (x2-x1)
        endif
    if ret eq 3 then begin 		;  slow left	
   	x1n=x1-xsladd
        x1n=x1n > xmin
        x2n=x1n + (x2-x1)
        endif
    if ret eq 4 then begin 		;  fast left	
   	x1n=x1-xfsadd
        x1n=x1n > xmin
        x2n=x1n + (x2-x1)
        endif
    if ret eq 5 then begin		;  stretch 
	x1n=x1 + (x2-x1)/50.
	x2n=x2 - (x2-x1)/50.
        x1n=x1n > xmin
        x2n=x2n < xmax
        endif
    if ret eq 6 then begin		;  squeeze 
	x1n=x1 - (x2-x1)/50.
	x2n=x2 + (x2-x1)/50.
        x1n=x1n > xmin
        x2n=x2n < xmax
        endif
    if ret eq 7 then begin 		;  maximal range
	x1n=xmin
	x2n=xmax
	endif
    if ret eq 8 then begin 		;  restore default
	x1n=x1sv
	x2n=x2sv
	endif	
    if ret eq 9 then begin  		;  jump right
	x2n=x2+(x2-x1)
	x2n=x2n < xmax
        x1n=x2n - (x2-x1)
        endif
    if ret eq 10 then begin 		;  jump left	
   	x1n=x1-(x2-x1)
        x1n=x1n > xmin
        x2n=x1n + (x2-x1)
        endif
    if (ret eq 11) or (ret eq 12) then begin	; interactive limits
	no2da,a,b
	x1n=x1
	x2n=x2
	if !err eq 1 then x1n=a		; left mouse button = new xlow
	if !err eq 2 then x2n=a		; middle mouse button = new xhigh
	endif

    if (x1n eq x1) and (x2n eq x2) then goto,button    ; nothing to do

    axis,0.,.18,/norm,xax=0,xrange=[x1,x2],xstyle=1,color=bg
    axis,0.,.18,/norm,xax=0,xrange=[x1n,x2n],xstyle=1,color=fg
    oplot,xdata,ydata,color=bg,clip=cl,/norm 
    if (pxmode eq 1) and (nex gt 0) then $
        oplot,xi,yi,psym=1,symsize=3.,color=bg,clip=cl,/norm
    axis,0.,.97,/norm,xax=1,xrange=[x1,x2],xstyle=1,xtickname=bl,color=bg
    axis,0.,.97,/norm,xax=1,xrange=[x1n,x2n],xstyle=1,xtickname=bl,  $
         color=fg,/save
    oplot,xdata,ydata,color=fg,clip=cl,/norm 
    if (pxmode eq 1) and (nex gt 0) then $ 
        oplot,xi,yi,psym=1,symsize=3.,color=fg,clip=cl,/norm
    plots,plotbox,/norm,/noclip,color=fg
    plots,clipbox,/norm,/noclip,color=fg,linestyle=0
    x1=x1n  &  x2=x2n
    if (ret eq 11) or (ret eq 12) then goto,waitup
    goto,button
    endif
;
;   Y-buttons selected, do vertical scrolling 
;
if (ret ge 21) and (ret le 40) then begin
    dadd=(ymax-ymin)/50.
    if ret eq 21 then begin        ; down
    yminn=ymin+dadd
    ymaxn=ymax+dadd
    endif

    if ret eq 22 then begin        ; stretch
    yminn=ymin-dadd
    ymaxn=ymax+dadd
    endif

    if ret eq 23 then begin	   ;  squeeze
    yminn=ymin+dadd
    ymaxn=ymax-dadd
    endif

    if ret eq 24 then begin	   ;  up
    yminn=ymin-dadd
    ymaxn=ymax-dadd
    endif

    if ret eq 25 then begin	   ;  restore default
    yminn=yminsv
    ymaxn=ymaxsv
    endif

    if (ret eq 31) or (ret eq 32) then begin ; interactive Y-limits 
	no2da,a,b			; convert to data coord
	ymaxn=ymax
	yminn=ymin
	if !err eq 1 then ymaxn=b	; left mouse button = new yhi
	if !err eq 2 then yminn=b	; right mouse button = new ylow
	endif


    if (yminn eq ymin) and (ymaxn eq ymax) then goto,button ; nothing to do
    axis,.18,0.,/norm,yax=0,yrange=[ymin,ymax],ystyle=1,color=bg
    axis,.18,0.,/norm,yax=0,yrange=[yminn,ymaxn],ystyle=1,color=fg
    oplot,xdata,ydata,color=bg,clip=cl,/norm 
    if (pxmode eq 1) and (nex gt 0) then $ 
        oplot,xi,yi,psym=1,symsize=3.,color=bg,clip=cl,/norm

    axis,.97,0.,/norm,yax=1,yrange=[ymin,ymax],ystyle=1,ytickname=bl,color=bg
    axis,.97,0.,/norm,yax=1,yrange=[yminn,ymaxn],ystyle=1,ytickname=bl,  $
         color=fg,/save
    oplot,xdata,ydata,color=fg,clip=cl,/norm 
    if (pxmode eq 1) and (nex gt 0) then $ 
        oplot,xi,yi,psym=1,symsize=3.,color=fg,clip=cl,/norm
    plots,plotbox,/norm,/noclip,color=fg
    plots,clipbox,/norm,/noclip,color=fg,linestyle=0
    ymin=yminn  &  ymax=ymaxn
    if (ret eq 31) or (ret eq 32) then goto,waitup
    goto,button
    endif

if ret eq 91 then goto,done              ; Quit selected
if ret eq 41 then begin                  ; Hardcopy
    print,' Making a hardcopy '
    psv=!p; save actual 
    xsv=!x
    ysv=!y
    !p.position=ppos_save	; restore original
    psinit,/land
    plot,xdata,ydata,xrange=[x1,x2],/xstyle, $
        yrange=[ymin,ymax],/ystyle
    if (pxmode eq 1) and (nex gt 0) then $ 
        oplot,xi,yi,psym=1,symsize=3.,color=fg,clip=cl,/norm
    psterm
    !p=psv		; restore actual
    !x=xsv
    !y=ysv
    goto,waitup
    endif
if ret eq 42 then begin                  ; Copyright
    winsave=!d.window                   ; save current
    windex=winsave+1
    window,windex,title='Copyright - Click to exit', $
           xpos=600,ypos=200,xsize=420,ysize=290
    erase,bg
    dummy=findfile('/usr/local/lib/idl/local/kroll.ras',count=krollpic)
    if not krollpic then begin
        xyouts,.2,.8,'GentleGiant',/norm,color=fg,charsize=2.
        xyouts,.2,.6,'Software',/norm,color=fg,charsize=2.
        xyouts,.2,.4,'Click me!!',/norm,color=fg,charsize=2.
        endif
    if krollpic then begin
        read_srf,'/usr/local/lib/idl/local/kroll.ras',im,r,g,b
        im=rotate(im,7)
        tv,im
        endif
    cursor,a1,b1
    wdelete,windex
    wset,winsave
    endif
if ret eq 43 then begin                  ; locator switch
    locswitch=locswitch-1 
    if locswitch lt -1 then locswitch=1
    if locswitch eq  1 then print,' Locate Maxima'
    if locswitch eq  0 then print,' Locator Facility turned off'
    if locswitch eq -1 then print,' Locate Minima'
    if locswitch eq  0 then rect, r43,'!5-!5',0.,fg,bg,mg
    if locswitch eq  1 then rect, r43,'!93!5',0.,fg,bg,mg
    if locswitch eq -1 then rect, r43,'!91!5',0.,fg,bg,mg
    goto,waitup
    endif
;	

;
;  pixel selection with cursor
;
if ret eq 99 then begin                  ; in the plot field !!!
    no2da,a,b	                         ; convert to data coordinates
    erbox=boxer([.0,.0,1.,.048])         ; erase coordinate display area
    polyfill,erbox,color=bg,/normal,/noclip 
    xyouts,.30,.01,'x = '+string(a),/normal,charsize=1.3   ; display x
    xyouts,.60,.01,'y = '+string(b),/normal,charsize=1.3   ; display y

    if !err ne 1 then goto,noleft        ; not left button -> delete a pixel
;
; insert a pixel. Is a location option selected?
;
if locswitch eq -1 then begin            ; locate a minimum
    dummy=min(abs(xdata-a),mpx)		 ; find closest pixel
    min0=ydata(mpx)
    i=mpx-1
    while (ydata(i) lt min0) and (i ge 0) do begin ; search min to left
	min0=ydata(i)
	mpx=i
	i=i-1
	endwhile
    i=mpx+1
    while (ydata(i) lt min0) and (i lt (nelxdata-1)) do begin ; search right
	min0=ydata(i)
	mpx=i
	i=i+1
	endwhile
; 
; that is the local minimum, now follow until next local max to left and
; right of this position.
;
;    print,'local mininum at ',mpx
    i=mpx
    while (ydata(i-1) gt ydata(i)) and ((i-1) gt 0) do i=i-1
;    while ( (i-1) ge 0 ) do while (ydata(i-1) gt ydata(i)) do i=i-1
    delmx=mpx-i
    i=mpx
    while (ydata(i+1) gt ydata(i)) and ((i+1) lt nelxdata-1) do i=i+1
    delpx=i-mpx
    lw= (delpx < delmx) - 1
    endif
	
if locswitch eq 1 then begin             ; locate a maximum
    dummy=min(abs(xdata-a),mpx)		 ; find closest pixel
    max0=ydata(mpx)
    i=mpx-1
    while (ydata(i) gt max0) and (i ge 0) do begin ; search max to left
	max0=ydata(i)
	mpx=i
	i=i-1
	endwhile
    i=mpx+1
    while (ydata(i) gt max0) and (i lt (nelxdata-1)) do begin ; search right
	max0=ydata(i)
	mpx=i
	i=i+1
	endwhile

; 
; that is the local maximum, now follow until next local min to left and
; right of this position.
;
;    print,'local maxinum at ',mpx
    i=mpx
    while (ydata(i-1) lt ydata(i)) and ((i-1) gt 0) do i=i-1
    delmx=mpx-i
    i=mpx
    while (ydata(i+1) lt ydata(i)) and ((i+1) lt nelxdata-1) do i=i+1
    delpx=i-mpx
    lw= (delpx < delmx) - 1
    endif
;
; fit the line
;
if locswitch ne 0 then begin 			; we have to fit min or max
    if lw gt 1 then begin			; fit, if enough points
       xfit=xdata(mpx-lw:mpx+lw)-xdata(mpx-lw)	; to avoids arith. problems
       yfit=ydata(mpx-lw:mpx+lw)
       par=poly_fit(xfit,yfit,2)
       pos=-par(1)/par(2)/2.
       val=poly(pos,par)
       rpos=pos+xdata(mpx-lw)
       yfitval=poly(xfit,par)
;;;;;;       oplot,xfit+xdata(mpx-lw),yfitval,linestyle=0,color=fg
       a=rpos
       b=val
       erbox=boxer([.0,.0,1.,.048])         ; erase coordinate display area
       polyfill,erbox,color=bg,/normal,/noclip 
       xyouts,.30,.01,'x = '+string(a),/normal,charsize=1.3   ; display x
       xyouts,.60,.01,'y = '+string(b),/normal,charsize=1.3   ; display y
       endif $
    else begin
	print,' line too narrow to fit \007'
	endelse
    endif



    if pxmode eq 0 then goto,waitup	 ; do not save (no buffers)
;
;  insert position 
;
    xi(nex)=a 
    yi(nex)=b
    xpx(0)=a
    ypx(0)=b
    oplot,xpx,ypx,psym=1,symsize=3.,color=fg,clip=cl,/norm
    nex=nex+1
    goto, waitup
;
; delete pixel with middle button
;
    noleft:
    if !err ne 2 then goto, button      ; should never happen !
    if nex le 0 then goto, waitup       ; no pixels!
    d=fltarr(nex)
    for i=0,nex-1 do begin              ; calculate distances
        d(i)=sqrt( (xi(i)-a)^2 + (yi(i)-b)^2)
        endfor 
    dm=min(d,md)		      ; least distance
    xpx(0)=xi(md)		      ; erase deleted pixel
    ypx(0)=yi(md)
    nex=nex-1
    oplot,xpx,ypx,psym=1,symsize=3.,color=bg,clip=cl,/norm
    if nex gt 0 then begin 
        for i=md,nex-1 do begin
            xi(i)=xi(i+1)
            yi(i)=yi(i+1)
            endfor
        endif
    if nex eq 0 then begin
	xi(0)=0.
	yi(0)=0.
	endif
    waitup :
    cursor,dummy,dummy,/nowait  ; wait for button release
    if !err ne 0 then goto, waitup
    endif

goto,button


done:
!p.color=fg_save		; restore fore- and background
!p.background=bg_save
!p.position=ppos_save		; restore !p.position
if pxmode eq 0 then return 	; there is nothing to return!
if nex le 0 then begin		; no pixels left to return!
    x=fltarr(1)
    y=fltarr(1)
    goto, threepar 
    endif

x=fltarr(nex)			; prepare pixel arrays for return
y=fltarr(nex)
x(0:nex-1)=xi(0:nex-1)
y(0:nex-1)=yi(0:nex-1)

y=y(sort(x))
x=x(sort(x))
threepar:			; we have to rearrange in this case!
if n_params() eq 3 then begin   ; return positional as on input
   datay=x
   x=y
   endif
return				; see you next time
end
