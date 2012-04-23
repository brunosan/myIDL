;+
; NAME:
;       IMGFRM
; PURPOSE:
;       Puts a specified border around an image.
; CATEGORY:
; CALLING SEQUENCE:
;       imgfrm, img, vals
; INPUTS:
;       vals = array of frame values. in. 
; KEYWORD PARAMETERS:
; OUTPUTS:
;       img = Image to modify.        in, out. 
; COMMON BLOCKS:
; NOTES:
;       Notes: values in array vals are applied from 
;         outside border of the image inward.  A single 
;         scalar values just replace the border values 
;         in the image.  Good for zeroing image edge. 
; MODIFICATION HISTORY:
;       R. Sterner. 25 Sep, 1987.
;       Johns Hopkins University Applied Physics Laboratory.
;-
 
	PRO IMGFRM, IMG, VALD, help=hlp
 
	IF (N_PARAMS(0) LT 2) or keyword_set(hlp) THEN BEGIN
	  print,' Puts a specified border around an image.'
	  PRINT,' imgfrm, img, vals'
	  PRINT,'   img = Image to modify.        in, out.'
	  PRINT,'   vals = array of frame values. in.'
	  print,' Notes: values in array vals are applied from'
	  print,'   outside border of the image inward.  A single'
	  print,'   scalar values just replace the border values'
	  print,'   in the image.  Good for zeroing image edge.'
	  RETURN
	ENDIF
 
	VAL = ARRAY(VALD)
	NV = N_ELEMENTS(VAL)
	SZ = SIZE(IMG)
	NX = SZ(1)
	NY = SZ(2)
 
	FOR I = 0, NV-1 DO BEGIN
	  T = FLTARR(NX-I-I) + VAL(I)
	  IMG(I,I) = T
	  IMG(I,NY-1-I) = T
	  T = TRANSPOSE(FLTARR(NY-I-I) + VAL(I))
	  IMG(I,I) = T
	  IMG(NX-1-I,I) = T
	ENDFOR
 
	RETURN
	END
