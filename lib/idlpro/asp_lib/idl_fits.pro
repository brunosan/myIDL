pro IDL_FITS, array, ffile, comm1 = comm_1,  comm2 = comm_2, $
			    comm3 = comm_3 , comm4 = comm_4
;+
;
;	procudure:  idl_fits
;
;	purpose:  write 2D array from IDL to FITS file
;
;	author:  Jorge Sanchez IAC, 1/21/92	(minor mod's by rob@ncar)
;
;==============================================================================
;
;       Check number of parameters.
;
if n_params() ne 2 then begin
	print
	print, "usage:  idl_fits, array, ffile"
	print
	print, "	Arguments"
	print, "		array	- input 2D array to write out"
	print, "		ffile	- output FITS file name (string)"
	print
	return
endif
;-

; let's go
on_error,1	; on error it returns to the main program level
escala=1.1d9
;
get_lun,unit
openw,unit,ffile
;
; writing the header
hdr=bytarr(80,36)
;
	hdr(*,0)=byte('SIMPLE  =                    T / Standard FITS                                  ') 
	hdr(*,1)=byte('BITPIX  =                   32 / 32 bits integer with sign per pixel            ')
	hdr(*,2)=byte('NAXIS   =                    2 / Image                                          ') 
; 	dimensions of the matrix
	comodo=size(image)
	naxis1=comodo(1)
	naxis2=comodo(2)
	hdr(*,3)=byte('NAXIS1  =                      / Image                                          ') 
	hdr(*,4)=byte('NAXIS2  =                      / Image                                          ') 
	n_1=strlen(string(naxis1))
	n_2=strlen(string(naxis2))
	hdr(10:9+n_1,3)=byte(string(naxis1))
	hdr(10:9+n_2,4)=byte(string(naxis2))
;	scaling from floating to integers
	dat_max=0.d0+max(image)
	dat_min=0.d0+min(image)
	bzero=dat_min
	bscale=(dat_max-dat_min)/escala
	data=long((image-bzero)/bscale)
	hdr(*,5)=byte('BZERO   =                      / offset of the written image                    ') 
	hdr(*,6)=byte('BSCALE  =                      / true = fits_ima * bscale + bzero               ') 
	n_1=strlen(string(bzero))
	n_2=strlen(string(bscale))
	hdr(10:9+n_1,5)=byte(string(bzero))
	hdr(10:9+n_2,6)=byte(string(bscale))
; 	adding comments to the header
	if n_elements(comm_1) gt 0 then n_1=strlen(comm_1) else n_1=0
	if n_elements(comm_2) gt 0 then n_2=strlen(comm_2) else n_2=0
	if n_elements(comm_3) gt 0 then n_3=strlen(comm_3) else n_3=0
	if n_elements(comm_4) gt 0 then n_4=strlen(comm_4) else n_4=0
	ind=0
	if n_1 gt 0 then begin
		hdr(0:11+n_1,7)=byte('COMM    = / '+comm_1)
		ind=1
	endif else $
	if n_2 gt 0 then begin
		hdr(0:11+n_2,8)=byte('COMM    = / '+comm_2)
		ind=2
	endif else $
	if n_3 gt 0 then begin
		hdr(0:11+n_3,9)=byte('COMM    = / '+comm_3)
		ind=3
	endif else $
	if n_4 gt 0 then begin
		hdr(0:11+n_4,10)=byte('COMM    = / '+comm_4)
		ind=4
	endif 
; 	end of the header
	if(ind eq 1) then hdr(0:2,8)=byte('END') else $
	if(ind eq 2) then hdr(0:2,9)=byte('END') else $
	if(ind eq 3) then hdr(0:2,10)=byte('END') else hdr(0:2,11)=byte('END') 
; 
writeu,unit,hdr
;
;
; writing the image
writeu,unit,data
;
close,unit
free_lun,unit
return
end
