;+
; NAME:
; 	MTREWIND
; PURPOSE:
;       Rewinds (and optionally unloads) tape on specified device
;	(UNIX version; spawns UNIX command mt)
;*CATEGORY:            @CAT-# 43 40@
;       Magnetic Tape , Operating System Access
; CALLING SEQUENCE:
;       MTREWIND [,dev] [,/OFFLINE] [,HOST=hostname]
; INPUTS:
; 	none
; OPTIONAL INPUT PARAMETERS:
; 	dev :  tape device number (integer) (device: /dev/nrst<dev>) or 
;	       tape device name (string) (leading /dev/ may be omitted)
;              Example: dev=1 or dev ='nrst1' or dev ='/dev/nrst1 are
;	                valid specifications of device /dev/nrst1 .
;              Default: /dev/nrst0
; KEYWORD PARAMETERS:
;	/OFFLINE : if set, tape will be rewound and drive unit will be taken
;		   off-line (unloading the tape).
;       HOST=hostname : the tape drive is not the local host but <hostname>
;		        (mt command will be spawned with a remote shell).
; OUTPUTS:
;       none
; SIDE EFFECTS:
;       
; RESTRICTIONS:
;
; PROCEDURE:
;       UNIX command 'mt -f <device> rew' or 'mt <device> offline' will be
;	spawned to the local host or to remote host (rsh <host> mt ...).
; MODIFICATION HISTORY:
;       1992-Oct-09: WS (KIS) created.
;       1992-Oct-26: nlte (KIS) renamed (REWIND -> MTREWIND), new option HOST.
;-
;
pro mtrewind,dev,offline=offline,host=host
on_error,1
if n_elements(dev) le 0 then begin tp='/dev/nrst0' & goto,jmp1 & endif
szdev=size(dev)
case 1 of
  szdev(0) ne 0 : message,'1st arg must not be an array'
  szdev(1) le 3 : tp ='/dev/nrst'+strtrim(dev,2)
  szdev(1) eq 7 : begin
	             tp=strlowcase(dev)
		     if tp ge '0' and tp le '99' then tp='/dev/nrst'+tp
		     if strmid(tp,0,5) ne '/dev/' then tp='/dev/'+tp
                  end
  else          : message,'1st arg not a valid device'
endcase
;
jmp1:
if keyword_set(offline) then cmd='mt -f '+tp+' offline' $
                        else cmd='mt -f '+tp+' rewind'
if n_elements(host) eq 1 then cmd='rsh '+strtrim(host,2)+' '+cmd
spawn,cmd
return
end
