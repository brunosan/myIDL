;+
; NAME:
;	pdp2sun_user  (f77)
; PURPOSE:
;	FORTRAN_77-program:
;       Reads one or more PDP-RCA-CCD-files from PDP-tape, converts
;	contents to 32-bit-Format and writes contents to SUN-disk
;	("SUNCCD"-format).
;	$$$ For interactive use $$$ :
;           tape moves and copy-actions will be done interactively:
;           user specifies directory for copied files, part of filename,
;           number of files to be copied, and tape-move-actions. 
;*CATEGORY:            @CAT-#  2@
;	CCD Tools
; CALLING SEQUENCE:
;	pdp2sun_user
; INPUTS:
;	(via standard-input on request of program)
;	
; OUTPUTS:
;	input-requests to terminal; ASCII-disk-file ("Logfile")
;	    './<username>-PDP2SUN_USER.log' (append-mode);
;       unformatted disk-file(s) ("SUNCCD-format") containing the
;       converted data from tape-file(s).
;     Format of these disk-file(s):
;     FORTRAN-unformatted, sequential ("SUNCCD").
;     Logical record 1: it,(text(i),i=1,50)  text: CHAR.*80 observers's
;                                          comments (it lines non-blnk)
;     Logical record 2: ib  (integer-array size 50 exposure parameters)
;     Logical record 3: nx,ny  (size of image)
;     Logical record 4: image  (integer*2 -array, size (nx,ny))
; COMMON BLOCKS:
;	(internal)
; SIDE EFFECTS:
;	Creation of disk-files.
; RESTRICTIONS:
;	Program must be started on a SUN-RISC-host equipped with
;       a magnetic tape unit.
; PROCEDURE:
; 	UNIX-command 'mt' is spawned to position tape ahead of the 1st
;	tape-file to be read;
;	SUN-Library-routines topen, tskipf, tread, tclose are used to
;       read tape-files.
; MODIFICATION HISTORY:
;       1991-Apr-29  H. Schleicher, KIS 
;       1991-May-23  H.S., KIS : modified call to wrbild 
;-

