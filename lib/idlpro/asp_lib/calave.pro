pro calave, infile, outfile
;+
;
;	procedure:  calave
;
;	purpose:  calculate average and rms values for set of cal. matrices
;
;==============================================================================
;
;	Check parameters.
;
if n_params() lt 1 then begin
	print
	print, "usage:  calave, infile [, outfile]"
	print
	print, "	Calculate average and rms values for set of"
	print, "	calibration matrices."
	print
	print, "	Arguments"
	print, "		infile	 - input file containing list of"
	print, "			   calx files"
	print, "		outfile	 - output file (def='calave.out')"
	print
	print
	print, "   ex:  calave, 'mat.list'"
	print
	return
endif
;-
;
;	Define and zero arrays.
;
;x_matrix = fltarr(5,4,64)
;x_mean   = fltarr(5,4)
;x_sigma  = fltarr(5,4)
x_matrix = fltarr(6,4,64)
x_mean   = fltarr(6,4)
x_sigma  = fltarr(6,4)
;
;	Open output log file.
;
if n_elements(outfile) eq 0 then outfile = 'calave.out'
openw, outunit, outfile, /get_lun
;
;	Open input file of filenames.
;
openr, inunit, infile, /get_lun
;
;	Loop until no more filenames.
;
num = 0
while (not EOF(inunit)) do begin
	fnm = 'string'
	readf, inunit, fnm
	openr, tunit, fnm, /get_lun
	print
;
	for i=0,5 do begin
		hdr = 'string'
		readf, tunit, hdr
		print, hdr
		if num eq 0 then begin
			if i ne 3 then begin
				printf, outunit, hdr
			endif else begin
				printf, outunit, hdr + $
				'		--- Average X Matrix ---'
				print,hdr + $
				'		--- Average X Matrix ---'
			endelse
		endif
	endfor
;
	for j=0,3 do begin
		readf,tunit,a,b,c,d,e,f
		x_matrix(0,j,num)=a
		x_matrix(1,j,num)=b
		x_matrix(2,j,num)=c
		x_matrix(3,j,num)=d
		x_matrix(4,j,num)=e
		x_matrix(5,j,num)=f
;		print,x_matrix(*,j,num)
	endfor
;
	num = num + 1
	free_lun, tunit
end
num1 = num - 1
print
;
;	compute means of x matrix elements
;
for i=0,5 do for j=0,3 do  x_mean(i,j) = mean(x_matrix(i, j, 0:num1))
;
;	compute variances of x matrix elements
;
for i=0,5 do begin
	for j=0,3 do begin

		for k=0,num1 do begin
			diff = x_matrix(i,j,k) - x_mean(i,j)
			x_sigma(i,j) = x_sigma(i,j) + diff*diff
		endfor

		x_sigma(i,j) = sqrt( x_sigma(i,j)/num1 )
	endfor
endfor
;
;
print, format = '(4f10.5, 1f10.3, 1f10.5)', x_mean
print
print,'	--- % Standard Deviations ---'
print,format ='(4f10.2, 1f12.2, 1f10.2)', abs(x_sigma/x_mean * 100.0)
printf, outunit, format = '(4f10.5, 1f10.3, 1f10.5)', x_mean
printf, outunit
printf, outunit, '	--- % Standard Deviations ---'
printf, outunit, format ='(4f10.2, 1f12.2, 1f10.2)',abs(x_sigma/x_mean * 100.0)
;
;	close files and free unit numbers
;
free_lun, inunit, outunit
;
end

