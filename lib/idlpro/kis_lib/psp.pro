PRO PSP, DESKJET=deskjet, THERMO=thermo, KEEP=save, NO_PLOT=no_plot
;+
; NAME:
;	PSP
; PURPOSE:
;	Sends b/w-PostScript output (idl.ps) to laserwriter, HP-DeskJet,
;       or color-PostScript output to PaintJet or to PHASER color thermo-
;	printer;
;	encapsulated PostScript file will be re-named and kept on disk;
;	re-sets plot-device to "old_device" = active device 
;*CATEGORY:            @CAT-# 25@
;	Plotting
; CALLING SEQUENCE:
;	PSP [,/DESKJET] [,KEEP=save] [,NO_PLOT]  ; for b/w-Postscript,
;       PSP [,/THERMO] [,KEEP=save] [,NO_PLOT]   ; for color-Postscript.
; INPUTS:
;	none
; OPTIONAL INPUT PARAMETER:
;       /DESKJET : PostScript file idl.ps will be printed on (lokal) HP-DeskJet
;		   (default: idl.ps will be sent to laserwriter "LW"); 
;		   only for non-encapsulated b/w-PostScript files.
;	/THERMO	   non-encapsulated color-PostScript file idl.ps will be 
;		   printed on THERMO-printer TEKTRONIX PHASER II ("tekps");
;		   (default for color-PostScript: idl.ps will be sent to 
;		   PaintJet-printer "pjps");
;       /KEEP    : PostScript file idl.ps will be NOT be removed but
;		   re-named to idl.ps.<datetime> 
;		   (default: non-encapsulated idl.ps will be removed, 
;		             encapsulated idl.ps will be renamed to 
;			     idl.ps_enc.<datetime>).
;	KEEP=save: save (string): PostScript file idl.ps will be NOT be 
;	           removed but re-named to <save>.
;       /NO_PLOT : do not send plot-file to output device
;		   (default: non-encapsulated idl.ps will be sent to printer,
;		             encapsulated ps will be stored on disk).
; OUTPUTS:
;	none
; COMMON BLOCKS:
;	ODEVCOM,old_device,old_backgrnd,old_color,old_chsz,pscolor
;       old_device: string containing the name of device which was
;	            active on previous call to PSS (set by PSS);
;	old_backgrnd: contains !p.background as saved by previous call
;	            to PSS;
;       old_color:  contains !p.color as saved by previous call to PSS;
;	old_chsz :  contains !p.charsize as saved by previous call to PSS;
;	pscolor  : =1 if color-PS, else =0;
;	psenc    : =1 if encapsulated PostScript, else =0.
; SIDE EFFECTS:
;	Unless NO_PLOT was set or ENCAPSULATED was requested, the PostScript-
;	file will be sent to queue of the selected printer and will
;	then be removed (unless KEEP was set); 
;	in case of ENCAPSULATED PostScript, the PostScript-file will be
;	renamed and not be removed from disk (as in case of /KEEP).
; RESTRICTIONS:
;	Plot-device must be set to 'PS' by a previous call of
;	            to PSS;
; PROCEDURE:
;	spawns UNIX command 'lpr -P{lw|tekps} -h idl.ps' or 'gs2hpd idl.ps'
; MODIFICATION HISTORY:
;	nlte, ?
;       nlte, 1991-08-13 : !p.background, !p.color saved too.
;	nlte, 1992-02-06 : spawning "rm idl.ps" if not /KEEP .
;	R. Hammer, 1992-Aug-18 : DeskJet option.
;       nlte, 1992-Aug-24: merging Reiner's version; KEEP=file.
;       nlte, 1992-Sep-09: output device TEKTRONIX PHASER II if color-ps.
;       nlte, 1993-Jun-18: default for color output: PaintJet; Phaser II
;			   only if /THERMO specified; renaming & keeping
;			   file in case of encapsulated PostScript (no
;			   spooling to device).
;-
on_error,1 
common odevcom,old_device,old_backgrnd,old_color,old_chsz,pscolor,psenc
;
if !d.name ne 'PS' then begin 
   mess='Active plot-device: '+!d.name+'. NO ACTION.'
   goto,jerr2
endif
;
device,/close
;
fi0=findfile('idl.ps',count=i)
if i eq 0 then begin
   mess='Plotfile idl.ps not found.'
   goto,jerr1
endif
;
cmd=''
if keyword_set(no_plot) or psenc then goto,jmp1
;
if pscolor then $
   if keyword_set(thermo) then cmd='lpr -Ptekps -h idl.ps' $
                          else cmd='lpr -Ppjps -h idl.ps' $
else $
   if keyword_set(deskjet) then cmd='gs2hpd idl.ps' $
                           else cmd='lpr -Plw -h idl.ps'
;
jmp1: newname=''
if keyword_set(save) or psenc then begin
   case 1 of 
     (size(save))(1) ne 7 : tnam=1
      save eq ' '         : tnam=1
   else                   : tnam=0
   endcase
   if tnam then begin
      if psenc then newnam0='idl.ps_enc.' else newnam0='idl.ps.'
      jmp: newname=newnam0+blnk2ulin(strmid(systime(),4,16))
      fi0=findfile(newname,count=i)
      if i gt 0 then begin wait,1 & goto,jmp & endif
   endif else newname=blnk2ulin(save)
   if cmd eq '' then cmd='mv idl.ps '+newname else $
                     cmd = cmd + '; mv idl.ps '+newname 
endif else if cmd eq '' then cmd='rm -f idl.ps' else cmd=cmd + '; rm -f idl.ps'
;printf,-2,'Executing:  ' + cmd
spawn,cmd
;
if not keyword_set(no_plot) and not psenc then begin
   if keyword_set(deskjet) then mess='idl.ps -> HP DekJet.' else $
   if pscolor then $
      if keyword_set(thermo) then mess='idl.ps -> PHASER II' $
                             else mess='idl.ps -> PaintJet' $
   else $
      if keyword_set(deskjet) then mess='idl.ps -> HP DekJet.' $
                              else mess='idl.ps -> Laserprinter.'
endif else mess=''
if newname ne '' then mess=mess+' Renamed: '+newname
jerr1:
mess=mess+' Device reset to '+old_device
;
set_plot,old_device
!p.background=old_backgrnd
!p.color=old_color
!p.charsize=old_chsz
;
jerr2: printf,-2,'PSP: '+mess
end
