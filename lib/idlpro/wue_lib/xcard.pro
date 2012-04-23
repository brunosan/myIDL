;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; NAME:
;		XCARD
; PURPOSE:
;		Simulate a card stack 	
; CATEGORY:
;		Data bases
; CALLING SEQUENCE:
;		XCARD, FILE
; INPUTS:
;		FILE - The cardfile, format compatible with Xcard 1.2
;		by Ken Nelson
; OPTIONAL INPUT PARAMETERS:
;
; KEYWORDS:
;		XTERM - A string which specifies calls to xterm
;			made by the program
;		EDITOR - A string which specifies the editor to
;			 use, including options.
;		xcards spawns windows for user i/o typically with
;		the string:  XTERM+' -e '+EDITOR [+temp. file]
; OUTPUTS:
;
; COMMON BLOCKS:
;		idl_xcard_comm - all parameters crunched together
; SIDE EFFECTS:
;
; RESTRICTIONS:
;		256 cards with 128 lines each, 64 comment and
;		64 template lines
; NOTES:
;		Actually, xcard shows two card stacks, the left one
;		with all cards in the stack, and the right one with
;		the cards that contain a search string in their 
;		bodies. This string can be entered interactively,
;		but no wildcards are allowed (blame 'strpos').
;		A template is provided, with which each new card
;		is preset. A stack comment may be used to describe
;		the contents of the card stack.
;		This Program was inspired by Ken Nelson's X11 program
;		"Xcard" (Vers. 1.2) and written as an exercise in
;		IDL widgets
; EXAMPLES:
;	xcard,'/usr/local/lib/idl/local/ToDo.cf'
;              call xcard with Ken Nelsons demo cardstack
; MODIFICATION HISTORY:
;		Written October 1992 Reinhold Kroll
;		last update 04-NOV-1992
;-----------------------------------------------------------------------
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  function read_line reads on line from an input file
;  return -1 if at eof, +1 if line is a field separator line, 0 else
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
function read_line,unit,line
by=bytarr(256)			; max charact. per line
line=string()
sepline=string('&&##$$')	; seperator line 
if eof(unit) then return, -1	; are we at eof?
readf,unit,line			; read one line
by(0)=byte(line)		; is it a separator line?
first_chars=string(by(0:5))
if first_chars eq sepline then return,1 else return,0	
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Save cardfile to disk
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
pro save_cardfile
common idl_xcard_comm,ntempl,ncomm,ncards,cardno,items,bodies,bodycount, $
	selcard,cardfile,template,comm,info,xt,edt,newfile
	
sepline=string('&&##$$')		; separator line
spawn,'cp '+cardfile+' '+cardfile+'%'	; make a backup
get_lun,lun
openw,lun,cardfile,err=errstat		; open file for write
printf,lun,'VALID_XCARD'		; two lines to be compatible
printf,lun				;    with Ken Nelson's Xcard
for i=0,ntempl do begin		; write the template
	printf,lun,template(i)
	endfor
printf,lun,sepline			; write the comment
for i=0,ncomm do begin
	printf,lun,comm(i)
	endfor
printf,lun,sepline
for i=0,ncards do begin		; write the individual cards
	printf,lun,items(i)		;    the header	
	for j=0,bodycount(i) do begin	;    the body
		printf,lun,bodies(i,j)
		endfor
	printf,lun,sepline
	endfor
close,lun				; close file and free lun
free_lun,lun
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Xcard event handler routine
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
pro xcard_event,ev
on_error,2
common idl_xcard_comm,ntempl,ncomm,ncards,cardno,items,bodies,bodycount, $
	selcard,cardfile,template,comm,info,xt,edt,newfile

type=tag_names(ev,/structure)
;
; card selected with mouse
;
if type eq 'WIDGET_LIST' then begin
	if newfile then return
	widget_control,ev.id,get_uvalue=listno
	if listno eq 'list1' then cardno=ev.index
	if listno eq 'list2' then begin
		sel=where(selcard ge 0)
		cardno=sel(ev.index)
		endif
	head=items(cardno)			; header
	text=bodies(cardno,0:bodycount(cardno))  ; body
	widget_control, info(1), set_value=items(cardno); disp. header
	widget_control, info(2), set_value=text		; disp. body
	endif
;
; header changed in the header text display
;
if type eq 'WIDGET_TEXT' then begin
	if newfile then begin
		widget_control, info(1), set_value='no cards !'
		return
		endif
	widget_control, ev.id, get_value=txt
	items(cardno)=txt
	widget_control, info(0), set_value=items(0:ncards)
	endif
;
; one of the action buttons pressed
;
if type eq 'WIDGET_BUTTON' then begin
	widget_control,ev.id,get_value=val
;	print,val
;
; edit a card, call vi in an xterm and read back
;
	if val eq 'edit card' then begin
		if newfile then begin
			widget_control, info(1), set_value='no cards !'
			return
			endif
		tmpfile=strcompress(!stime,/remove_all)+'-idl.tmp'
		get_lun,lun
		openw,lun,tmpfile
		printf,lun,bodies(cardno,0:bodycount(cardno))
		close,lun
		free_lun,lun
		spw=xt+' -e '+edt+' '+tmpfile
		spawn,spw
                get_lun,lun
                openr,lun,tmpfile
		iline=0
		szbd=size(bodies)
		while (read_line(lun,line) ne -1) and  $
				(iline lt szbd(2)) do begin
			bodies(cardno,iline)=line
			iline=iline+1
			endwhile
		close,lun
		free_lun,lun
		bodycount(cardno)= (iline-1) > 0
		widget_control, info(1), set_value=items(cardno)
		widget_control, info(2),  $
			set_value=bodies(cardno,0:bodycount(cardno))
		spawn,'rm '+tmpfile
		endif
;
; enter a new card, call vi in an xterm and read 
;
	if val eq 'new card'  then begin
		tmpfile=strcompress(!stime,/remove_all)+'-idl.tmp'
		get_lun,lun
		openw,lun,tmpfile
		for i=0,ntempl do printf,lun,template(i)
		close,lun
		free_lun,lun
		spw=xt+' -e '+edt+' '+tmpfile
		spawn,spw
		widget_control,info(6),set_value='Header: '
		widget_control,info(1),set_value=''
                qbut=widget_button(info(3),value='OK')
                dbut=widget_button(info(3),value='Dismiss')
	        ret=widget_event(info(3))
		ret_type=tag_names(ret,/structure)
		widget_control,ret.id,get_value=stat
		if ret_type eq 'WIDGET_TEXT' then stat='OK'
		if ret_type eq 'WIDGET_BUTTON' then $
			widget_control,ret.id,get_value=stat
		szbd=size(bodies)
		if (stat eq 'OK') and (ncards+1 lt szbd(1)) then begin
		    if not newfile then ncards=ncards+1
                    get_lun,lun
                    openr,lun,tmpfile
		    iline=0
		    while (read_line(lun,line) ne -1) $
				and (iline lt szbd(2)) do begin
		    	bodies(ncards,iline)=line
			iline=iline+1
			endwhile
		    close,lun
		    free_lun,lun
		    widget_control,info(1),get_value=str
		    items(ncards)=str
		    bodycount(ncards)=(iline-1) > 0
		    cardno=ncards
		    newfile=0
		    endif
		if stat eq 'Dismiss' then begin
		    endif
		spawn,'rm '+tmpfile
		widget_control, info(0), set_value=items(0:ncards)
		widget_control, info(1), set_value=items(cardno)
		widget_control, info(2), $ 
		    set_value=bodies(cardno,0:bodycount(cardno))
		widget_control,info(6),set_value=''
		widget_control,qbut,/destroy
		widget_control,dbut,/destroy
		endif
;
; delete one card from stack
;	
	if val eq 'delete card' then begin
		if newfile then begin
			widget_control, info(1), set_value='no cards !'
			return
			endif
		if cardno ne ncards then begin
			nxc= (cardno+1) < ncards
			items(cardno:ncards-1)=items(nxc:ncards)
			bodies(cardno:ncards-1,*)=bodies(nxc:ncards,*)
			bodycount(cardno:ncards-1)=bodycount(nxc:ncards)
			endif
		ncards=ncards-1
		cardno = 0 > (cardno-1)
		cardno = cardno < ncards
                widget_control, info(0), set_value=items(0:ncards)
		widget_control, info(1), set_value=items(cardno)
		widget_control, info(2),  $
			set_value=bodies(cardno,0:bodycount(cardno))
		endif
;
; sort cards in ascending order
;
	if val eq 'sort asc.' then begin
		if newfile then begin
			widget_control, info(1), set_value='no cards !'
			return
			endif
		si=sort(items(0:ncards))
		items(0:ncards)=items(si)
		bodies(0:ncards,*)=bodies(si,*)
		bodycount(0:ncards)=bodycount(si)
                widget_control, info(0), set_value=items(0:ncards)
		endif
;
; sort cards in descending order
;
	if val eq 'sort desc.' then begin
		if newfile then begin
			widget_control, info(1), set_value='no cards !'
			return
			endif
		si=rotate(sort(items(0:ncards)),2)
		items(0:ncards)=items(si)
		bodies(0:ncards,*)=bodies(si,*)
		bodycount(0:ncards)=bodycount(si)
                widget_control, info(0), set_value=items(0:ncards)
		endif
;
; show comments
;
	if val eq 'show comments' then begin
		widget_control, info(1), set_value='Comments: '
		widget_control, info(2), set_value=comm(0:ncomm)
		endif
;
; show Template
;
	if val eq 'show template' then begin
		widget_control, info(1), set_value='Template: '
		widget_control, info(2), set_value=template(0:ntempl)
		endif
;
; edit template
;
	if val eq 'edit template' then begin
		tmpfile=strcompress(!stime,/remove_all)+'-idl.tmp'
		get_lun,lun
		openw,lun,tmpfile
		for i=0,ntempl do printf,lun,template(i)
		close,lun
		free_lun,lun
		spw=xt+' -e '+edt+' '+tmpfile
		spawn,spw
                get_lun,lun
                openr,lun,tmpfile
		iline=0
		while read_line(lun,line) ne -1 do begin
			template(iline)=line
			iline=iline+1
			endwhile
		close,lun
		free_lun,lun
		spawn,'rm '+tmpfile
		ntempl=(iline-1) > 0
		endif
;
; edit comments
;
	if val eq 'edit comments' then begin
		tmpfile=strcompress(!stime,/remove_all)+'-idl.tmp'
		get_lun,lun
		openw,lun,tmpfile
		for i=0,ncomm do printf,lun,comm(i)
		close,lun
		free_lun,lun
		spw=xt+' -e '+edt+' '+tmpfile
		spawn,spw
                get_lun,lun
                openr,lun,tmpfile
		iline=0
		while read_line(lun,line) ne -1 do begin
			comm(iline)=line
			iline=iline+1
			endwhile
		close,lun
		free_lun,lun
		spawn,'rm '+tmpfile
		ncomm=(iline-1) > 0
		endif
;
; save cardfile and quit
;
	if val eq 'save & quit' then begin
		save_cardfile
		widget_control,ev.top,/destroy
		endif
;
; quit, leaving cardfile unchanged
;
	if val eq 'quit' then begin
		widget_control,ev.top,/destroy
		endif
	if val eq 'save file' then begin
		save_cardfile
		endif
;
; search in all cards
;
	if val eq 'all' then begin
		widget_control,info(4),get_value=str
		sst=string(byte(strtrim(str)))
		for i=0,ncards do begin
			ps=where(strpos(bodies(i,*),sst) ge 0,count)
			if count gt 0 then selcard(i)=i else selcard(i)=-1
			endfor
		widget_control,info(5),set_value=items(where(selcard ge 0))
		endif
;
; search in selected cards
;
	if val eq 'selected' then begin
		widget_control,info(4),get_value=str
		sst=string(byte(strtrim(str)))
		for i=0,ncards do begin
			if selcard(i) ge 0 then begin
			    ps=where(strpos(bodies(i,*),sst) ge 0,count)
			    if count gt 0 then selcard(i)=i else selcard(i)=-1
			    endif
			endfor
		widget_control,info(5),set_value=items(where(selcard ge 0))
		endif 



	endif
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Xcard main program 
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
pro xcard,cf,editor=editor,xterm=xterm
common idl_xcard_comm,ntempl,ncomm,ncards,cardno,items,bodies,bodycount, $
	selcard,cardfile,template,comm,info,xt,edt,newfile
on_error,2
max_comm=64		; max. number of comment lines	
max_templ=64		; max. number of template names
max_cards=256		; max. number of cards in stack
max_lines=128		; max. number of lines per card
template=strarr(max_templ)		; template	
comm=strarr(max_comm)			; comment	
items=strarr(max_cards)			; card headers
bodies=strarr(max_cards,max_lines)	; card bodies
bodycount=intarr(max_cards)		; lines per card
selcard=intarr(max_cards)-1		; cards matching search
if not keyword_set(editor) then editor='vi'
if not keyword_set(xterm)  then xterm='xterm -geometry 80x24+400+500 -fn 9x15'
xt=xterm
edt=editor

;line=string()
cardno=0
ncards=0
ncomm=0
ntempl=0
hits=0
cardfile=cf
;
; read the cardfile
;
get_lun,lun
openr,lun,cardfile,err=oerr	; open read only
if oerr ne 0 then begin
	newfile=1
	endif
if oerr eq 0 then begin
	newfile=0
	dummy=read_line(lun,line) 	; skip first line
	dummy=read_line(lun,line) 	; skip second line
	itempl=0			; read template
	while (read_line(lun,line) eq 0) and (itempl lt max_templ) do begin
		template(itempl)=line
		itempl=itempl+1
		endwhile
	ntempl=(itempl-1) > 0

	icomm=0				; read comments
	while (read_line(lun,line) eq 0) and (itempl lt max_comm) do begin
		comm(icomm)=line
		icomm=icomm+1
		endwhile
	ncomm=(icomm-1) > 0

	iitems=0			; read cards
	while (read_line(lun,line) ne -1) and (iitems lt max_cards) do begin
		items(iitems)=line	; headers 
		ibodies=0
		while (read_line(lun,line) eq 0) and (ibodies lt max_lines) $
						do begin	; bodies
			bodies(iitems,ibodies)=line
			ibodies=ibodies+1
			endwhile
			bodycount(iitems)=(ibodies-1)>0	; # lines for card
			selcard(iitems)=iitems
		iitems=iitems+1
		endwhile
	if iitems eq 0 then newfile=1		; no cards!
	ncards=(iitems-1) > 0			; number of cards read
	close,lun
	free_lun,lun
	endif
;
; make the widgets
;
base=widget_base(/column)	; root window	
  up=widget_base(base,/row)	; row oriented subwindows
    up1=widget_base(up,/column)	; second column of buttons
    up2=widget_base(up,/column)	; third column of buttons
      up2a=widget_base(up2,/row,frame=1) ;
	up2a1=widget_base(up2a,/column)
	up2a2=widget_base(up2a,/column)
	up2a3=widget_base(up2a,/column)
      up2b=widget_base(up2,/column,frame=1) ;
	up2b1=widget_base(up2b,/row) ;
	up2b2=widget_base(up2b,/row)
    up3=widget_base(up,/column)	; second list
  mi=widget_base(base,/column)
  dw1=widget_base(base,/row,frame=1)
  dw2=widget_base(base,/row)
lab1=widget_label(up1,value='all cards',frame=1)
list=widget_list(up1,value=items(0:ncards), $  ; the card selector
		uvalue='list1',ysize=12)
eb=widget_button(up2a1,value='edit card')
nb=widget_button(up2a1,value='new card')
db=widget_button(up2a1,value='delete card')
sb=widget_button(up2a1,value='sort asc.')
sb=widget_button(up2a1,value='sort desc.')
dw3al=widget_label(up2b1,value='search for: ')
srch=widget_text(up2b1,value='',/editable,ysize=1,xsize=24)
dw3b1=widget_button(up2b2,value='all')
dw3b2=widget_button(up2b2,value='selected')
q2b=widget_button(up2a2,value='show template')
q2b=widget_button(up2a2,value='show comments')
q2b=widget_button(up2a2,value='edit comments')
q2b=widget_button(up2a2,value='edit template')
db=widget_button(up2a3,value='save file')
q1b=widget_button(up2a3,value='quit')
q2b=widget_button(up2a3,value='save & quit')
lab2=widget_label(up3,value='selected cards',frame=1)
list2=widget_list(up3,value=items(0:ncards), $  ; the card selector
		uvalue='list2',ysize=12)
headlab=widget_label(dw1,value='')
head=widget_text(dw1,value=items(0), $	; card header display
		xsize=60,ysize=1,/editable)
txt=widget_text(dw2,frame=1,value=bodies(0,0:bodycount(0)), $ ; card body
	xsize=96,ysize=20,/scroll)
info=[list,head,txt,dw1,srch,list2,headlab]
if newfile then begin
	text='Creating new cardfile : '+cardfile
	widget_control, head, set_value=text
	endif
widget_control,base,/realize	; display it
xmanager,'XCARD',base		; and wait for user action
end


