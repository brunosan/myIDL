FUNCTION margin,rawimg,badleft=nl,badright=nr,badbottom=nb,badtop=nt,$
	               avrage=navrg
;+
; NAME:
;	MARGIN
; PURPOSE:
;	replacing bad image-margin columns or rows by "reasonable" values
;*CATEGORY:            @CAT-# 16  6@
;	Image Processing , Data Editing
; CALLING SEQUENCE:
;	new_image = MARGIN (raw_image [,BADLEFT=nl] [,BADRIGHT=nr] ...
;		            [,BADBOTTOM=nb] [,BADTOP=nt] [,AVRAGE=navrg] )
; INPUTS:
;	raw_image : 2-dim array containing an image with bad margins.
; OPTIONAL INPUT PARAMETER:
;	BADLEFT=nl : 1st <nl> columns of raw_image: raw_img(0:nl-1,*)  
;		     are no good and shall be replaced;
;		     default: left margin is o.k.
;	BADRIGHT=nr: last <nr> columns of raw_image are no good and 
;	             shall be replaced; default: right margin is o.k.
;	BADBOTTOM=nb: 1st <nb> rows of raw_image: raw_img(*,0:nb-1)
;		     are no good and shall be replaced;
;		     default: bottom margin is o.k.
;	BADTOP=nt  : last <nt> rows of raw_image are no good and 
;	             shall be replaced; default: bottom margin is o.k.
;       AVRAGE=navrg : take the average of the 1st <navrg> pixel values
;		     inside of the "bad" ones and fill the "bad" with this
;		     constant value; default: navrg = 3. 
; OUTPUTS:
;	new_image  : image-array (size same as input raw_image) with 
;		     margins "restaurated".
;	
; COMMON BLOCKS:
;	none
; SIDE EFFECTS:
;	error messages if invalid input
; RESTRICTIONS:
;	none
; PROCEDURE:
;	straight foreward
; MODIFICATION HISTORY:
;	nlte (KIS), 1992-Feb-11 
;-
;on_error,1
if n_params() ne 1 then begin 
   err='Usage: new_image = MARGIN (raw_image [,keyword parameters] )'
   goto,jmperr & endif
;
sz=size(rawimg)
if sz(0) ne 2 then begin 
   err='1st argument must be a 2-dim. array' & goto,jmperr & endif
;
mx=sz(1) & my=sz(2)
;
if keyword_set(navrg) then nav=navrg>1 else nav=3 & fmean=1./float(nav)
;
img=rawimg
;
; left margin:
if keyword_set(nl) then begin
   if n_elements(nl) ne 1 then begin
      err='BADLEFT=nl: nl undefined or not single value.' & goto,jmperr & endif
   if nl gt 0 then begin
      if nl ge mx-nav then begin
         err=string(mx-nav,form='("BADLEFT=nl: nl must be less than ",i0)')
	 goto,jmperr & endif
      av=img(nl,*) 
      if nav gt 1 then begin
         av=float(av)
         for i=nl+1,nl+nav-1 do av=av+float(img(i,*)) & av=av*fmean
      endif
      for i=0,nl-1 do img(i,*)=av
   endif
endif
;
; right margin:
if keyword_set(nr) then begin
   if n_elements(nr) ne 1 then begin
     err='BADRIGHT=nr: nr undefined or not single value.' & goto,jmperr & endif
   if nr gt 0 then begin
      if nr gt mx-nav then begin
         err=string(mx-nav+1,form='("BADRIGHT=nr: nr must be less than ",i0)')
	 goto,jmperr & endif
      av=img(mx-nr-nav,*) 
      if nav gt 1 then begin
         av=float(av)
         for i=mx-nr-nav+1,mx-nr-1 do av=av+float(img(i,*)) & av=av*fmean
      endif
      for i=mx-nr,mx-1 do img(i,*)=av
   endif
endif
;
; bottom margin:
if keyword_set(nb) then begin
   if n_elements(nb) ne 1 then begin
    err='BADBOTTOM=nb: nb undefined or not single value.' & goto,jmperr & endif
   if nb gt 0 then begin
      if nb ge my-nav then begin
         err=string(my-nav,form='("BADBOTTOM=nb: nb must be less than ",i0)')
	 goto,jmperr & endif
      av=img(*,nb)
      if nav gt 1 then begin
         av=float(av)
         for i=nb+1,nb+nav-1 do av=av+float(img(*,i)) & av=av*fmean
      endif
      for i=0,nb-1 do img(*,i)=av
   endif
endif
;
; top margin:
if keyword_set(nt) then begin
   if n_elements(nt) ne 1 then begin
    err='BADTOP=nt: nt undefined or not single value.' & goto,jmperr & endif
   if nt gt 0 then begin
      if nt gt my-nav then begin
         err=string(my-nav+1,form='("BADTOP=nt: nt must be less than ",i0)')
	 goto,jmperr & endif
      av=img(*,my-nt-nav)
      if nav gt 1 then begin
         av=float(av)
         for i=my-nt-nav+1,my-nt-1 do av=av+img(*,i) & av=av/nav
      endif
      for i=my-nt,my-1 do img(*,i)=av
   endif
endif
;
return,img
;
jmperr: 
printf,-2,'%MARGIN: '+err
return,-1
end
