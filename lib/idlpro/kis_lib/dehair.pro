FUNCTION dehair,img,hair,badright=badr,badleft=badl,badtop=badt,$
                badbottom=badb,width=wsearch
;+
; NAME:
;	DEHAIR
; PURPOSE:
;       Removes slit hairs from image (2-dim spectrum).
;*CATEGORY:            @CAT-# 16  6@
;	Image Processing , Data Editing
; CALLING SEQUENCE:
;       img_clean = DEHAIR(img,y_hair [,optional parameters])
; INPUTS:
;       img = 2-dim array containing spectrum with hair(s);
;	y_hair = vector with approximate slit-positions (image row numbers) of
;		 hair location(s).
; OPTIONAL INPUTS:
;       BADLEFT=n : avoid 1st <n> image columns for localization of hair;
;	BADRIGHT=n : avoid last <n> image columns for localization of hair;
;	BADBOTTOM=n : avoid 1st <n> image rows for localization of hair;
;	BADTOP=n : avoid last <n> image rows for localization of hair;
;	      defaults: take full image for localization of hair.
;       WIDTH=wsearch: width of "hair search intervall" in y-direction (pixel);
;                    default: 40
; OUTPUTS:
;       Image with hairs "removed".
; RESTRICTIONS:
;	A hair should be well positioned within "search strip" around 
;	approximate position specified in vector y_hair and should deviate by
;	more than 1 sigma from line-averaged run of intensity within this
;	search strip.
;	See begin of code for actual specifications of ixa,ixe,iya,iye,wsearch.
; SIDE EFFECTS:
;	-1. will be returned if input is invalid. 
; PROCEDURE:
; 	for the k-th hair-position specified in y_hair(k):
;       1. s(y) = average run of intensity along slit direction (avoiding 
;	   points near boundaries) within "search intervall" (width in y-dir.:
;	   wsearch) around approx. hair position y_hair(k);
;	2. central hair position = minimum position in s(y);
;	3. find those image rows iy* where s(iy*) gt <s(iy*)>-sigma (after an 
;	   additional iteration) = "non-hair lines";
;	4. replace img(ix,[search-strip]) by linear least square fit of
;	   img(ix,[iy*]).
; MODIFICATION HISTORY:
;       nlte, 1998-??-?? 
;	nlte, 1990-03-19: specification wsearch and boundary at begin of code.
;	nlte, 1992-02-10: bad margins, search-width : optional keyword-input,
;	                  bug: replacement-loop in x-dir was restricted to 319.
;-
;
on_error,1
if n_params() ne 2 then begin 
  err='%DEHAIR Usage: new_img=dehair(image,y_hair_vect [,optional parameters])'
   goto,jmperr
endif
sz=size(img)
if sz(0) ne 2 then begin 
   err='%DEHAIR 1st argument must be 2-dim array' & goto,jmperr
endif
;
if n_elements(wsearch) lt 1 then wsearch=40   ; width of search intervall
;
; avoid margin region when for hair detection:
if n_elements(badl) lt 1 then ixa=0 else ixa=badl
if n_elements(badr) lt 1 then ixe=sz(1)-1 else ixe=sz(1)-badr-1
if n_elements(badb) lt 1 then iya=0 else iya=badb
if n_elements(badt) lt 1 then iye=sz(2)-1 else iye=sz(2)-badt-1
if ixe le ixa or iye le iya then begin
   err='%DEHAIR img dimensions must be at least'+string(ixe-ixa+1,iye-iya+1,$
        form='(i0," , ",i0)')
   goto,jmperr
endif
;
count=n_elements(hair)
if count lt 1 then begin
   err='%DEHAIR no approx. y-positions for hair(s).' & goto,jmperr
endif
;
dh=img
;
for khair=0,count-1 do begin
yhair=hair(khair)
j1=max([iya,yhair-wsearch/2])
j2=min([j1+wsearch,iye])
if j2 ge j1 then begin
   s=avx_y(img(*,j1:j2),ixa,ixe)
   ym=min(s,xm)
   sig=stdev(s,yav)
    x=where(s gt yav-sig)
    sig=stdev(s(x),yav)
    x=where(s gt yav-sig)
    sig=stdev(s(x),yav)
    ii=where(s(0:xm) gt yav-sig, n)
    if n lt 1 then k1=0 else k1=ii(n-1)
    ii=where(s(xm:*) gt yav-sig ,n)
    if n lt 1 then k2=(size(s(xm:*)))(1) else k2=ii(0)
    k2=k2+xm
    k11=k1+1
    k22=k2-1
    j3=j1+k11
    j4=j1+k22
    x=indgen(k1)
    if (size(s))(1)-k2 gt 0 then x=[x,k2+indgen((size(s))(1)-k2)]
    xj1=x+j1
    x=float(x)
    xx=findgen(k2-k1-1)+float(k11)
    for i=0,sz(1)-1 do begin
        c=poly_fit(x,img(i,xj1),1,yfit,yb,sig)
        dh(i,j3:j4)=c(0)+xx*c(1)
    endfor ; x-loop
endif
;
endfor ; hair-loop
return,dh
;
jmperr: return,-1.
end
