; file: prettyprint.pro
;
; Copyright 1993, Andrew T. Shapiro and the University of Colorado.
;
; There are two input files for this procedure. The tree file and the
; tree.procedures file. The tree file is a list of dependencies two words
; per line. The tree.procedures file is a list of all the procedures known
; one per line.


pro pp_recurs, level, name, already_used, see_above=see_above
common prettyprint, proc, uses, names, used, use_global
  output = ""
  if (level ne 0) then output = output + "    "
  for i = 2,level do output = output + "|   "
  if (keyword_set(see_above)) then begin
    output = output + "|  (see above)"
    print,output
  endif else begin
    final_out = output
    if (level ne 0) then begin
      another_out=output+'|   |'
      output = output + "+--"+name
    endif else begin
      another_out=output+'    |'
      output = output + name
    endelse
    print,output
    if (use_global) then index = where(used eq name) $
    else index = where(already_used eq name)
    if (index(0) eq -1) then begin
      index = where(proc eq name)
      if (index(0) eq -1) then return
      print,another_out
      for i = 0,n_elements(index)-1 do begin
        used = [used, name]
        pp_recurs,level+1,uses(index(i)),[already_used,name]
if (i ne n_elements(index)-1) then print,another_out
;print,final_out
      endfor
    endif else begin
      pp_recurs,level,name,alredy_used,/see_above
    endelse
  endelse
end ; pp_recurs

pro prettyprint, global=global
common prettyprint, proc, uses, names, used, use_global
  ;
  ; Set up some stuff.
  ;
  input = ''
  current_proc = "<none>"
  proc = ""
  names = ""
  used = ["<none>"]
  uses = ""
  use_global = keyword_set(global)
  ;
  ; Read the input files and make three stacks. The names of all the 
  ; procedures, and two parallel stacks which link procedure names to the
  ; procedures used therin.
  ;
  openr,1,'tree'
  while (not(eof(1))) do begin
    readf,1,input
    cut=strpos(input," ")
    proc = [proc,strmid(input,0,cut)]
    uses = [uses,strmid(input,cut+1,100)]
  endwhile
  close,1
  openr,1,'tree.procedures'
  while (not(eof(1))) do begin
    readf,1,input
    names = [names,input]
  endwhile
  close,1
  ;
  ; Clean up the stack.
  ;
  names = names(1:*)
  proc = proc(1:*)
  uses = uses(1:*)
;print,names,proc,uses
  ;
  ; Find all the roots and build trees.
  ;
  for i = 0,n_elements(names)-1 do begin
    index = where(uses eq names(i))
    if (index(0) ne -1) then begin
      pp_recurs,0,names(i),["<none>"]
      print
    endif
  endfor
end ; prettyprint
