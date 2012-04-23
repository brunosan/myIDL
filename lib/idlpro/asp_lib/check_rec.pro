pro check_rec, dummy
;+
;
;	procedure:  check_rec
;
;	purpose:  check record (scan) header problem
;
;	author:  rob@ncar, 2/93
;
;==============================================================================
;
;	Check parameters.
;
if n_params() ne 0 then begin
	print
	print, "usage:  check_rec"
	print
	print, "	Check record (scan) header problem."
	print
	print, "	[Parameters are hardwired.]"
	print
	return
endif
;-

infile = '../92.06.18/21.fa.map'
fscan = 94

;;infile = '../92.06.19/12.fa.map'
;;fscan = 33

;;infile = '../92.06.21/10.fa.map'
;;fscan = 20

;---------

; open file
openr, in_unit, infile, /get_lun

; set header array
header = lonarr(128)

; set variables
ans = ' '
seq = 0
done = 0
seqscan = fscan

; skip to first scan
psn = 512L + long(fscan) * (512L + 4L * 2L * 256L * 256L)
point_lun, in_unit, psn

; -------- LOOP READING 512 BYTES AT A TIME --------
;
while (not done) do begin 

	if (seq mod 1025) eq 0 then begin
		print, 'scan ' + stringit(seqscan) + $
			'----------------------------------------------------'
		seqscan = seqscan + 1
	endif

	print, 'seq:  ' + stringit(seq)

	readu, in_unit, header

	year = stringit(header(2))

	if year eq '92' then begin
		print, '   ....year is: ', stringit(header(2))
		print, '   ...month is: ', stringit(header(3))
		print, '   .....day is: ', stringit(header(4))
		read,  '   continue ? [y/n] ', ans
		if ans eq 'n' then done = 1
	endif

	seq = seq + 1
endwhile

; done
end
