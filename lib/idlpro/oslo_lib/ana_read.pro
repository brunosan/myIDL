FUNCTION  ANA_READ,FIL,HEAD=HEAD,vms=vms
;+
; NAME:         ANARD
; PURPOSE:      Read data which is stored by "Fzwrite" in ANA
;               
; CATEGORY:
; CALLING SEQUENCE:
;       IM=ANA_READ(fil,[head= ])
; INPUTS:
;       fil   = File name
;
; KEYWORD PARAMETERS:
;       HEAD  = Header of file
;
; OUTPUTS:
;       Im
; COMMON BLOCKS:
;       None.
; SIDE EFFECTS:
;
; RESTRICTIONS:
;
; PROCEDURE:
; MODIFICATION HISTORY:
;       Z. Yi, 1990
;-

	on_error,2

	openr,1,fil
	a=assoc(1,bytarr(512))
	h=byte(a(0))

	typ=h(7)	&	dim=h(8)

	hd=512

case dim of
 1: begin
	 dx=long(h,192)
	 if typ eq 1 then a=assoc(1,intarr(dx,/nozero),hd) else a=assoc(1,fltarr(dx,/nozero),hd)
	 im=a(0)
 end

 2: begin
	 dx=long(h,192)	& dy=long(h,196)
	 if typ eq 1 then a=assoc(1,intarr(dx,dy,/nozero),hd) else a=assoc(1,fltarr(dx,dy,/nozero),hd)
	 im=a(0)
 end

 3: begin
	 dx=long(h,192) & dy=long(h,196) & dz=long(h,200)
	 if typ eq 1 then a=assoc(1,intarr(dx,dy,dz,/nozero),hd) else a=assoc(1,fltarr(dx,dy,dz,/nozero),hd)
	 im=a(0)
 end

 4: begin
	 dx=long(h,192) & dy=long(h,196)
	 dz=long(h,200) & dw=long(h,204)
 if typ eq 1 then a=assoc(1,intarr(dx,dy,dz,dw,/nozero),hd) else a=assoc(1,fltarr(dx,dy,dz,dw,/nozero),hd)
	 im=a(0)
 end
endcase

close,1
Head=STRARR(2,10)

;Head(0:1,0)=['WAVELENGTH:       ',STRING(H(397:400))]
;Head(0:1,1)=['POLARIZATION:     ',STRING(H(402:404))]
;Head(0:1,2)=['OBSERVATION TIME: ',STRING(H(256:278))]
;Head(0:1,3)=['OBSERVATION AT:   ',STRING(H(280:290))]
;Head(0:1,4)=['FILTER:           ',STRING(H(301:314))]
;Head(0:1,5)=['FLAT FIELD:       ',STRING(H(405:419))]
;Head(0:1,6)=['COMMENT:          ',STRING(H(421:446))]
;Head(0:1,7)=['REDUCTED TIME:    ',STRING(H(449:479))]
;Head(0:1,8)=['SCALE:            ',STRING(H(366:369))]
;Head(0:1,9)=['EXPOSURE TIME:    ',STRING(H(362:365))]
;PRINT,Head

a=0
if typ eq 1 then byteorder,im,/htons else byteorder,im,/xdrtof

return,im
end





