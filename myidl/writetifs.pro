; writetifs.pro			11-2-98 Eric Weeks
;
; this will write out a cube as a series of tif files
; designed so that a cube-movie can be converted to an SGI movie
;

pro writetifs,cube,fname,header=header,threshold=threshold,gif=gif
; set header=5 to duplicate first & last frames 5 times
; set threshold to print out only bright pixels (using gt); see below
; /gif to write gifs instead

n=n_elements(cube(0,0,*))
j=0

; write a header
if (keyword_set(header)) then begin
	if (header gt 1) then begin
		for k=0,header-2 do begin
			image=reform(cube(*,*,0))
			if (keyword_set(threshold)) then image = (image gt threshold)*255b
			if (not keyword_set(gif)) then begin
				write_tiff, fname + int2ext2(j) + ".tif", image
			endif else begin
				write_gif, fname + int2ext2(j) + ".gif", image
			endelse
			j = j + 1
		endfor
	endif
endif

; write the cube
for i=0,n-1 do begin
	image=reform(cube(*,*,i))
	if (keyword_set(threshold)) then image = (image gt threshold)*255b
	if (not keyword_set(gif)) then begin
		write_tiff, fname + int2ext2(j) + ".tif", image
	endif else begin
		write_gif, fname + int2ext2(j) + ".gif", image
	endelse
	j = j + 1
endfor

; write a trailer
if (keyword_set(header)) then begin
	if (header gt 1) then begin
		for k=0,header-2 do begin
			image=reform(cube(*,*,n-1))
			if (keyword_set(threshold)) then image = (image gt threshold)*255b
			if (not keyword_set(gif)) then begin
				write_tiff, fname + int2ext2(j) + ".tif", image
			endif else begin
				write_gif, fname + int2ext2(j) + ".gif", image
			endelse
			j = j + 1
		endfor
	endif
endif

end

