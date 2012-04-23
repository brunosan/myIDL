FUNCTION mkfilnam,strein
;+
; NAME:
;	MKFILNAM
; PURPOSE:
;	Modifies input_string such to make result a valid UNIX file-name:
;	leading & trailing blanks will be removed without replacement,
;	each blank substring will be replaced by a single underline;
;       Characters !$&*|\(){}[];`'",<>? will be replaced by @ (several
;	adjacent @ will be replaced by a single @).
;*CATEGORY:            @CAT-# 35@
;	String Processing Routines
; CALLING SEQUENCE:
;	out_string = MKFILNAM(input_string)
; INPUTS:
;	input_string : string to be converted.
; OUTPUTS:
;	converted string.
; COMMON BLOCKS:
;	none
; SIDE EFFECTS:
;	none
; RESTRICTIONS:
;	none
; PROCEDURE:
;	straight
; MODIFICATION HISTORY:
;	nlte (KIS), 1992-04-07
;	nlte (KIS), 1992-08-26  accept /
;-
on_error,1
;
; blanks:
straus=strcompress(strtrim(strein,2))
if strlen(straus) lt 1 then begin
   straus='_' & goto,ret 
endif
pos=strpos(straus,' ')
while pos gt 0 do begin
   strput,straus,'_',pos
   pos=pos+1 & pos=strpos(straus,' ',pos)
endwhile
;
;other non valid characters:
b=byte(straus)
nogood=-1
ii=where(b lt 35b or b gt 126b,nii) ; non_char's and !"
if nii gt 0 then nogood=[nogood,ii]
ii=where(b eq 36b or b eq 44b or b eq 96b,nii)  ; $,` 
if nii gt 0 then nogood=[nogood,ii]
ii=where(b gt 37b and b lt 43b,nii) ; &'()*
if nii gt 0 then nogood=[nogood,ii]
ii=where(b gt 58b and b lt 61b,nii) ; ;<
if nii gt 0 then nogood=[nogood,ii]
ii=where(b gt 61b and b lt 64b,nii) ; >?
if nii gt 0 then nogood=[nogood,ii]
ii=where(b gt 90b and b lt 94b,nii) ; [\]
if nii gt 0 then nogood=[nogood,ii]
ii=where(b gt 122b and b lt 126b,nii) ; {|}
if nii gt 0 then nogood=[nogood,ii]
if n_elements(nogood) eq 1 then goto,ret
;
for i=1,n_elements(nogood)-1 do strput,straus,'@',nogood(i)
pos=strpos(straus,'@@') & pose=strlen(straus)-1
while pos gt -1 do begin 
  i=pos+1 & c='@' & while i lt pose and c eq '@' do begin 
                        i=i+1 & c=strmid(straus,i,1) 
                  endwhile
  straus=strmid(straus,0,pos+1)+strmid(straus,i,pose-i+1)
  pose=strlen(straus)-1
  pos=strpos(straus,'@@')
  if pos eq pose-1 then begin 
     straus=strmid(straus,0,pose) & pose=-1 & goto,ret
  endif
endwhile
;   
ret: return,straus
end
