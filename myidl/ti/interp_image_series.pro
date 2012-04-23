FUNCTION INTERP_IMAGE_SERIES,t_orig,t_equi,img_orig_series
;+
;  NAME:
;     INTERP_IMAGE_SERIES
;  PURPOSE:
;     Interpolation of an image-series with non-equidistant time-steps
;     to an equidistant time-scale.
;  USAGE:
;     result = INTERP_IMAGE_SERIES ( t_orig, t_equi, img_orig_series )
;  INPUTS:
;     t_orig: vector of the original, non-equidistant "time"-steps;
;             must increase monotonically.
;     t_equi: vector of the equidistant "time"-steps onto which the interpolation
;             is required;  The two time-scales must overlap.
;     img_orig_series: data-cube containing the set of images to be interpolated;
;             the 3rd dim. of the cube is the time-dimansion; its size must be the same
;             as the size of vector t_orig.
;  OUTPUTS:
;     result:  the function returns the interpolated data-cube; the size of the first
;              two dimensions are that of the input cube, the size of the 3rd dimension
;              is the size of t_equi. The data-type is that of the input cube.
;              In case that the determination of image-shift between adjacent images of
;              the original image set fails, a zero will be returned. 
;  METHOD:
;     For each time-step t of the eqidistant time-scale:
;     -- Determination of the image shift between the two images imgo1, imgo2 of the original
;        set that are adjacent to time-step t. The shift is determined by calling routine
;        IMAGE_DISPLACE, which correlates imgo2 with imgo1 after applying shifts in
;        x- and y-direction and searching the shift-vector [dx,dy] that gives the 
;        maximal correlation.  
;     -- Shifting the second original image imgo2 according to [dx,dy] (fractional shift 
;        with linear interpolation) -> img_s .
;     -- Linear interpolation in time between imgo1, img_s -> img_i .
;     -- Back-shift of img_i by -[dx,dy]*(t-t1)/(t2-t1) .
;  RESTRICTIONS:
;     The features in the images adjacent in time should not be displaced by more than
;     1/10 of the image size and must be similar enough so that the maximal correlation
;     is > 0.2 .
;  NON-IDL routines required:
;     IMAGE_DISPLACE, SHIFT_FRAC, NINT, WHERE2, CORREL_IMAGES
;  HISTORY:
;     H. Schleicher @ KIS 2007-June-07: created.
;-   
;on_error,1
;
sl = string(byte([27, 91, 68, 27, 91, 68, 27, 91, 68]))


nxnynt=size(img_orig_series,/dim)
if n_elements(t_orig) ne nxnynt(2) then begin
   message,/info,'size t_orig doesnt match size of 3rd dimension of image cube'
   return,0
endif
if min(t_orig) ge max(t_equi) or max(t_orig) le min(t_equi) then begin
    message,/info,"time intervals don't overlap" ;'
    return,0
endif
img_type=size(img_orig_series,/type)
if img_type gt 5 then begin
   message,/info,'input image cube has invalid data-type'
   return,0
endif
interp_ser=MAKE_ARRAY(nxnynt(0),nxnynt(1),n_elements(t_equi),type=img_type)
;
i1_prev=-1
for i=0,n_elements(t_equi)-1 do begin
writeu,-1,sl+nnumber(i,2)
    t=t_equi(i)
    i2=(where(t_orig ge t))(0)
    i1=(i2-1) > 0
    if i2 eq i1 then i2=i1+1
    if i1 gt i1_prev then begin
       if img_type eq 4 or img_type eq 5 then begin
                 img1=reform(img_orig_series(*,*,i1))
                 img2=reform(img_orig_series(*,*,i2))
                 i1_prev=i1
       endif else begin
                 img1=float(reform(img_orig_series(*,*,i1)))
                 img2=float(reform(img_orig_series(*,*,i1)))
       endelse
    ;-- new pair of original images: shift img2 to img1
       IMAGE_DISPLACE,img1,img2,xoff,yoff,MAXCC=maxcc,flag=flag ; ,CC=cc
       if flag eq -2 then begin
           message,/info,'IMAGE_DISPLACE encounters formal error for t-step '+$
                          string(i,form='(i0)')
           if i gt 0 then begin
              print,'   last interpolated image in returned cube '+string(i-1,form='(i0)') 
              return, interp_ser(*,*,0:i-1)   
          endif else begin
              print,'   no images interpolated'
              return,0
          endelse
       endif
       img_s=SHIFT_FRAC(img2,xoff,yoff) ; shift img2 onto img1
       d_img=float(img_s)-img1
    endif
;
    ;-- interpolate between img1 and shifted img2:
    t_fak=(t-t_orig(i1))/(t_orig(i2)-t_orig(i1))
    img = img1 + d_img*t_fak
    ;-- partial back-shift interpolated image:
    xback=-xoff*t_fak & yback=-yoff*t_fak
    img = SHIFT_FRAC(img,xback,yback)
;
    case img_type of
         1: interp_ser(*,*,i) = byte(round(img))
         2: interp_ser(*,*,i) = nint(img)
         3: interp_ser(*,*,i) = round(img)
         4: interp_ser(*,*,i) = img
         5: interp_ser(*,*,i) = img
     endcase
;
 endfor
;
return,interp_ser
;
end
