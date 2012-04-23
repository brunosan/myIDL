;-------------------------------------------------------------
;+
; NAME:
;      SMOOTHE
; PURPOSE:
;      This program will smooth an array, including the edges,
;      using the SMOOTH function of IDL by surrounding the array
;      with duplicates of itself and then smoothing the large
;      array. 
; CATEGORY:
;      IMAGE PROCESSING
; CALLING SEQUENCE:
;      done=smoothe(aray,smoonum)
; INPUTS:
;      aray = The array that you wish to smooth.
;        type: array, any type
;      smoonum = smoonum specifies the width of the smoothing window.
;        type: scalar,integer
; KEYWORD PARAMETERS:
; OUTPUTS:
;      done = The smoothed array.
;        type: array, any type
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;      H. Cohl,  23 Sep, 1991    --- Generalization.
;      K. Reardon,  19 Jun, 1991 --- Initial programming.
;-
;-------------------------------------------------------------

function smoothe,aray,smoonum,help=help

  ;Display idl header if help is required.
  if keyword_set(help) or n_params() lt 2 then begin
    get_idlhdr,'smoothe.pro'
    done=-1
    goto,finishup
  endif

  s=size(aray)
  dim=s(0)
  border=smoonum*2

  if (dim eq 0) then begin
    print,"That ain't an array!  Its a scalar."
    done=-1
    goto,finishup
  endif

  if (dim eq 1) then goto,oned
  if (dim eq 2) then goto,twod
  if (dim ge 3) then begin
    print,'Sorry, I am too tired to process such a large array.'
    done=-1
    goto,finishup
  endif

  ;1-d 

  oned:
  eg1=s(1) + (smoonum-1)
  bigarr=fltarr(border + s(1))
  bigarr(smoonum:eg1)=aray
  rott=rotate(aray,5)
  bigarr(0:smoonum-1)=rott(s(1) - smoonum:s(1)-1)
  bigarr(s(1)+smoonum:s(1)+(2*smoonum)-1)=rott(0:smoonum-1)
  sbigarr=smooth(bigarr,smoonum)
  done=sbigarr(smoonum:eg1)
  goto,finishup

  ;2-d

  twod:
  if s(1) eq 1 then begin
    arr2=fltarr(s(2),s(1))
    arr2(*,0)=aray(0,*)
    aray=arr2
    s=size(aray)
    goto,oned
  endif

  eg1=s(1) + (smoonum-1)
  eg2=s(2) + (smoonum-1)
  max1=s(1) + border - 1
  max2=s(2) + border - 1

  bigarr=fltarr(border + s(1),border+s(2))
  bigarr(smoonum:eg1,smoonum:eg2)=aray
  rott=rotate(aray,5)
  bigarr(0:smoonum-1,smoonum:eg2)=rott(s(1)-smoonum:s(1)-1,*)
  bigarr(s(1)+smoonum:max1,smoonum:eg2)=rott(0:smoonum-1,*)
  rott=rotate(aray,7)
  bigarr(smoonum:eg1,0:smoonum-1)=rott(*,s(2)-smoonum:s(2)-1)
  bigarr(smoonum:eg1,s(2)+smoonum:max2)=rott(*,0:smoonum-1)
  rott=rotate(aray,2)
  bigarr(0:smoonum-1,0:smoonum-1)=rott(s(1)-smoonum:s(1)-1,s(2)-smoonum:s(2)-1)
  bigarr(s(1)+smoonum:max1,s(2)+smoonum:max2)=rott(0:smoonum-1,0:smoonum-1)
  bigarr(0:smoonum-1,s(2)+smoonum:max2)=rott(s(1)-smoonum:s(1)-1,0:smoonum-1)
  bigarr(s(1)+smoonum:max1,0:smoonum-1)=rott(0:smoonum-1,s(2)-smoonum:s(2)-1)
  sbigarr=smooth(bigarr,smoonum)
  done=sbigarr(smoonum:eg1,smoonum:eg2) 
  goto,finishup

  finishup:

  return, done 


end

