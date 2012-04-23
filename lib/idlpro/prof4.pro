pro prof4, file, crosstalk=crosstalk,factorx=factorx,factory=factory,$
   factorim=factorim,xoffset=xoffset
;+
;
;	procedure:  prof4
;
;	purpose:  set up and do "profile4" on four images
;
;	author:  rob@ncar, 2/93
;
;	notes:  - see profile4.pro
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 1 then begin
	print
	print, "usage: prof4, file"
	print
	print, "	Set up and do 'profile4' on four images."
	print
	print, "	Arguments"
	print, "		i,q,u,v	  - the four images; data need not be"
	print, "			    scaled into bytes (i.e., they"
	print, "			    may be floating point arrays)"
	print
	print, "	Keywords"
	print, "		(none)"
	print
	return
endif

if(keyword_set(crosstalk) eq 0) then crosstalk=0
if(keyword_set(factorx) eq 0) then factorx=1
if(keyword_set(factory) eq 0) then factory=1
if(keyword_set(factorim) eq 0) then factorim=1
if(keyword_set(xoffset) eq 0) then xoffset=1
restore,file+'m'
im1=toti
im2=totq
im3=totu
im4=totv

;-
;
;	Get image dimensions.
;
;factor=2
tam=size(im1)
nn=min([tam(1),fix(600/factorx)])

iin=xoffset>0
ifin=(iin+nn)<(tam(1)-1)
nn=ifin-iin+1

im1=im1(iin:ifin,*)
im2=im2(iin:ifin,*)
im3=im3(iin:ifin,*)
im4=im4(iin:ifin,*)

nx = fix(factorx*sizeof(im1, 1))
ny = fix(factory*sizeof(im1, 2))
nx1=nx/factorx
ny1=ny/factory

im1=rebin(im1(0:nx1-1,0:ny1-1),nx,ny)
im2=rebin(im2(0:nx1-1,0:ny1-1),nx,ny)
im3=rebin(im3(0:nx1-1,0:ny1-1),nx,ny)
im4=rebin(im4(0:nx1-1,0:ny1-1),nx,ny)

;
;	Set general parameters.
;
true = 1
false = 0
do_tv = false
border = 20
x1 = border
x2 = border * 2 + nx
x3 = x1
x4 = x2
y1 = border * 2 + ny
y2 = y1
y3 = border
y4 = y3
xsize = border*3 + nx*2
ysize = border*3 + ny*2

if(crosstalk ne 0) then xtalk,file+'c',xv2q,xv2u
;
;	Open window and display images.
;
window, /free, xsize=xsize, ysize=ysize,title='Maps'
window_ix = !d.window

im2=alog(abs(im2))*signo(im2)
im3=alog(abs(im3))*signo(im3)
im4=alog(abs(im4))*signo(im4)
im4=im4		
tvscl, im1, x1, y1
tvscl, im2, x2, y2
tvscl, im3, x3, y3
tvscl, im4, x4, y4

;
;	Do profiling.
;
profile4, do_tv, file, factorx,factory,factorim,im1, im2, im3, im4, x1, $
   y1, x2, y2, x3, y3, x4, y4, /generic,xv2q=xv2q,xv2u=xv2u,xi2quv=xi2quv,$
   xoffset=xoffset
;wdelete, window_ix
;
end
