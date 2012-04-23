;+
; NAME:
; 	MTSKIPF
; PURPOSE:
; 	Skip tape by <n> EOF(s) forward  (or to End-of-Medium) 
;	or backward by <n>-1 EOF(s). (UNIX version)
;*CATEGORY:            @CAT-# 43 40@
;       Magnetic Tape , Operating System Access
; CALLING SEQUENCE:
;	MTSKIPF [,n] [,DEVICE=device] [,HOST=hostname]
; INPUTS:
; 	none
; OPTIONAL INPUT PARAMETERS:
;	n : if integer > 0 : tape will be skipped forward by <n> EOF(s);
;           if integer < 0 : tape will be skipped backward by |<n>| EOF(s),
;			     then be skipped forward by 1 EOF;
;           if string 'EOM' : tape will be skipped forward to End-of-Medium;
;           Default: n = 1 .
; KEYWORD PARAMETERS:
;       DEVICE=device : tape device number (integer) (device: /dev/nrst<dev>)
;                       or tape device name (string) (leading /dev/ may be 
;                       omitted)
;                       Example: dev=1 or dev ='nrst1' or dev ='/dev/nrst1 are
;	                         valid specifications of device /dev/nrst1 .
;                       Default: /dev/nrst0 .
;       HOST=hostname : the tape drive is not the local host but <hostname>
;		        (mt command will be spawned with a remote shell).
; OUTPUTS:
;       none
; SIDE EFFECTS:
;       The requested action will be notified on standard print-out.
; RESTRICTIONS:
;
; PROCEDURE:
; 	UNIX command 'mt -f <device> <mt-option fsf | bsf | eom> |<n>| will be
;	spawned to the local host or to remote host (rsh <host> mt ...).
;       If n < 0, an additional 'mt -f <device> fsf 1' will be spawned.
; MODIFICATION HISTORY:
;       1992-Oct-09: WS (KIS) created.
;       1992-Oct-26: nlte (KIS) renamed ( SKIPF -> MTSKIPF), new option HOST,
;		                option "EOM".
;-
;
pro mtskipf,n,device=dev,host=host
on_error,1
;
if n_elements(dev) le 0 then tp='/dev/nrst0' else begin
   szdev=size(dev)
   case 1 of
     szdev(0) ne 0 : message,'DEVICE keyword must not be an array'
     szdev(1) le 3 : tp ='/dev/nrst'+strtrim(dev,2)
     szdev(1) eq 7 : begin
	               tp=strlowcase(dev)
		       if tp ge '0' and tp le '99' then tp='/dev/nrst'+tp
		       if strmid(tp,0,5) ne '/dev/' then tp='/dev/'+tp
                     end
     else          : message,'DEVICE keyword not a valid device'
   endcase
endelse
;
if n_params() gt 1 then message,$
   'USAGE: MTSKIP,nskip [,DEVICE=device] [,HOST=remote_host]'
if n_params() eq 0 then begin n=1 & nn='1' & endif else begin
   szn=size(n)
   case 1 of
     szn(0) ne 0 : message,'1st arg (nskip) must not be an array'
     szn(1) le 3 : nn=strtrim(n,2)
     szn(1) eq 7 : begin
	           nn=strtrim(strlowcase(n),2) 
		   if nn ne 'eom' then message,$
                      '1st arg (nskip) must be integer or string "eom"'
                   cmd='mt -f '+tp+' eom'
		   text='forward skipping to End-of-Medium (eom) at '+tp
		   goto,jmp1
                   end
     else        : message,'1st arg not a valid value'
   endcase
endelse
;
case 1 of 
  n eq 0 :  begin
               print,"nskip=0: !! this tape won't move very much !!" & return 
            end
  n gt 0 :  begin
               cmd='mt -f '+tp+' fsf '+nn+''
               text='forward skipping '+nn+' EOF(s) at '+tp
            end
  else   :  begin
               nn=strtrim(-n,2)
               cmd='mt -f '+tp+' bsf '+nn+''
           text='backward skipping '+nn+' EOF(s) then forward sk. 1 EOF at '+tp
	    end
endcase
;
jmp1:
if n_elements(host) eq 1 then begin 
   cmd='rsh '+strtrim(host,2)+' '+cmd & text=text+' on '+strtrim(host,2)
endif
print,text
spawn,cmd
if nn ne 'eom' then if n lt 0 then begin
   cmd='mt -f '+tp+' fsf 1'
   if n_elements(host) eq 1 then cmd='rsh '+strtrim(host,2)+' '+cmd
   spawn,cmd
endif
;
return
end
