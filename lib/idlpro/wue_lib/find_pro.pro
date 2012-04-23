PRO FIND_PRO, proc_name, result, PATH=inpath, ADD_TO_PATH=addpath
;+
; NAME:
;       FIND_PRO
; PURPOSE:
;       Find and list complete pathnames of a procedure in the current !path .
; CATEGORY:
;       Help, documentation.
; CALLING SEQUENCE:
;       FIND_PRO, Proc_name [,Result] [,PATH=...] [,ADD_TO_PATH=...]
; INPUTS:
;       Proc_name = string expression containing a procedure name (without
;		'.pro' extension).   All occurences of that name will be
;		found in the current !path and listed.
;		Unix-wildcards may be used (see examples below).
; OPTIONAL OUTPUT PARAMETER:
;	Result = variable name ; string-array, that will contain the output.
; KEYWORD PARAMETERS:
;       PATH =  scalar string containing a list directories (separated by
;		colon or space)  that will be used instead of !path .
;		Unix-wildcards may be used (see examples below).
;	ADD_TO_PATH = scalar string that will be added to !path (or PATH).
; OUTPUTS:
;       If the argument Result is not present, a list of pathnames is printed
;	on the terminal. Otherwise, the output is placed into a string array
;	(one pathname per array element) and assigned to Result.
; COMMON BLOCKS:
;       None.
; SIDE EFFECTS:
;       Output is produced on the terminal.
; RESTRICTIONS:
;       Unix-systems only.
; PROCEDURE:
;       Simply the Unix-command "ls -1 dir_name/Proc_name" is used to list
;	all matching pathnames.
; EXAMPLES:
;	find_pro,'find_pro' : prints the pathname(s) of this procedure.
;	find_pro,'*fit*'    : will probably find some procedures for curve-
;			      fitting (and possibly others).
;	find_pro,'*fit*',path='/home/*/idl'    : searches for fitting routines
;			in all directories named /home/*/idl ( possibly private
;			idl-directories of other users).
;	find_pro,'*',result : the pathnames of all procedures in the current
;			      path are stored in result.
; MODIFICATION HISTORY:
;       Written by  A. Welz, Uni. Wuerzburg, Germany, December 1991
;-
on_error,2

if !version.os ne 'sunos' then begin
   print,'% sorry, currently only a Unix-version of find_pro is available'
   return
endif

if n_elements(proc_name) ne 1 then begin
    print,'% use FIND_PRO,scalar_string_expression'
    return
endif

path = '. '
if n_elements(inpath) eq 1 then path=path+inpath else path=path+!path
if n_elements(addpath) eq 1 then path=path + ' ' + addpath

dir_list = "`echo "  +  path  +  " | tr ':' ' ' `"
name     = strcompress(strlowcase(proc_name),/remove)  +  ".pro"
ls_cmd   = "ls -1 $dir/"  +   name  + " 2>/dev/null"

cmd = "for dir in "  +  dir_list  +  " ; do "  +  ls_cmd  +  " ; done"

case n_params() of
   1:  spawn,/sh,cmd
else:  spawn,/sh,cmd,result
endcase

return
end
