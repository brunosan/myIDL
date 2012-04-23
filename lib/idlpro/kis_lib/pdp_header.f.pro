;+
; NAME:
;	pdp_header  (f77)
; PURPOSE:
;	Reads INFO-blocks of a sequence of RCA-CCD-files from PDP-
;	1/2"-tape. The contents will be outputted on standard_out and
;	into an ASCII-file.
;	           $$$ For interactive use $$$                   
;*CATEGORY:            @CAT-#  2@
;	CCD Tools
; CALLING SEQUENCE:
;	pdp_header
; INPUTS:
;	(via standard-input on request of the program: 1st, last 
;	 tape-file to be read).
; OUTPUTS:
;	(file-header-info's to standard-out and into an ASCII-disk-file)
; COMMON BLOCKS:
;	
; SIDE EFFECTS:
;	Output to an ASCII-file (append-mode)
; RESTRICTIONS:
;	This program must be started on a SUN-RISC-host equipped with
;	a magnetic tape unit.
; PROCEDURE:
;	Mag.-tape is positioned by spawning UNIX-command 'mt';
;	the file is read in using SUN-library-routines topen, tskipf,
;	tread, tclose.
; MODIFICATION HISTORY:
;	1991-Apr-29  H. Schleicher, KIS  
;-
  

