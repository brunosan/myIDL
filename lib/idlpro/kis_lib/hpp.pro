PRO HPP
;+
; NAME:
;	HPP
; PURPOSE:
;	closes current HP-plotfile idl.hp,
;       renames it to idl.hp.<mmm_dd_hh:mm:ss>,
;       re-sets plot-device to "old_device" = active device 
;               on previous call to HPS.
;*CATEGORY:            @CAT-# 25@
;	Plotting
; CALLING SEQUENCE:
;	HPP
; INPUTS:
;	none
; OUTPUTS:
;	none
; COMMON BLOCKS:
;	ODEVCOM,old_device,old_backgrnd,old_color
;       old_device: string containing the name device which was active
;	            on previous call to HPS (set by HPS).
;       old_backgrnd: !p.background as saved by previous call to HPS.
;	old_color:  !p.color as saved by previous call to HPS. 
;	old_chsz: !p.charsize as saved by previous call to HPS. 
;	pscolor: (unused here).           
; SIDE EFFECTS:
;	renames plotfile idl.hp (if exists).
; RESTRICTIONS:
;	Plot-device must be set to 'HP' by a previous call of
;       procedure HPS.
; PROCEDURE:
;	spawns UNIX command 'mv idl.hp idl.hp.<suffix>
; MODIFICATION HISTORY:
;	nlte, 1990-03-17
;       nlte, 1991-08-13 : !p.background, !p.color saved too.
;       nlte, 1992-09-23 : ODEVCOM extended for compatibility with pss/psp.
;-
on_error,1
common odevcom,old_device,old_backgrnd,old_color,old_chsz,pscolor
;
if !d.name ne 'HP' then begin 
   mess='Active plot-device: '+!d.name+'. NO ACTION.'
   goto,jerr2
endif
device,/close
fi0=findfile('idl.hp',count=i)
if i eq 0 then begin
   mess='Plotfile idl.hp not found. NO ACTION'
   goto,jerr1
endif
;
jmp:fi='idl.hp.'+blnk2ulin(strmid(systime(),4,16))
fi0=findfile(fi,count=i) 
if i gt 0 then begin wait,1 & goto,jmp & endif
mess='New HP-Plotfile: '+fi
;
cmnd='mv idl.hp '+fi
spawn,cmnd
;
jerr1:
set_plot,old_device
!p.background=old_backgrnd
!p.color=old_color
!p.charsize=old_chsz
mess=mess+'. Device reset to '+old_device
;
jerr2:printf,-2,'HPP: '+mess
end
