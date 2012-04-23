;+
; NAME:
;	pdp2sun_idl   (f77)
; PURPOSE:
;	FORTRAN_77 program: Reads **one** RCA-CCD-file from PDP-1/2"-tape,
;       converts contents to 32-bit-Format and writes contents into a
;       disk-file (f77 unformatted "SUNCCD"). 
;	$$$ NO user-interaction $$$
;	$$$ This program is suitable to be called from IDL. $$$
;*CATEGORY:            @CAT-#  2@
;	CCD Tools
; CALLING SEQUENCE:
;	pdp2sun_idl [output_disk_file]
; INPUTS:
;	(none)
; OPTIONAL INPUT PARAMETER:
;	output_disk_file : (optional) name of disk file into which
;         the processed image shall be stored; this string may  
;         include a full directory-path (starting with character 
;         "/") for the (existing) directory where the file shall
;         be placed (actual working directory if no path        
;         specified). The program will append the tape-file-no. 
;         (obtained from INFO-block written by PDP) to the file-
;         name; if neccessary, the program will additionally     
;         append a "suffix" to the file-name in order to avoid  
;         overwriting existing files; this suffix will be selec-
;         ted from set {.001, .002, ..., .999} (the highest suf-
;         fix not be used for the specified file-name           
;         '<output_disc_file>.<fileno>' .                       
;         If pdp2sun_idl is started without parameter, the pro- 
;         cessed image will set:                                
;         output_disk_file = '<cwd>/<user>-RCA-SUNCCD' ,         
;         where <cwd> is the current working directory and      
;         <user> is the USER-name; this file-name will be appen-
;         ded in the same manner.
; OUTPUTS:
;	1) Some informational output to standard-out; if read-action
;	   was successful, the last 3 text-lines will be:
;	      'image written on disk-file:'
;	      <name-of-SUNCCD-file>
;	      'NO tape rewind!'
;       2) A disk-file of "SUNCCD-format" containing the converted
;	   image data incl. header-informations.
;	
; COMMON BLOCKS:
;	(internal)
; SIDE EFFECTS:
;	
; RESTRICTIONS:
;	This program must be started on a SUN-RISC-host equipped with
;	a magnetic tape unit.
; PROCEDURE:
; 	UNIX-command 'mt' is spawned to position tape ahead of the 1st
;	tape-file to be read;
;	SUN-Library-routines topen, tskipf, tread, tclose are used to
;       read tape-files.	
; MODIFICATION HISTORY:
;	1991-Apr-29  H. Schleicher, KIS
;       1991-May-23  H.S., KIS: modified call to wrbild 
;-
