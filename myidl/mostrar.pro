pro mostrar,imagen,pausa=pausa,loop=loop,time=time,zoom=zoom,nimg=nimg,comm=comm,rot=rot, rec=rec,noframes=noframes,step=step

;little program to show a data cube
;use:
;mostrar,movie,pausa=0.3,loop=10,time=vector
;
;movie: the 3D data cube
;OPTIONAL:
; pausa  especifies a delay between frames (default=0)
; loop   especifies a number of loops to show before exit
; time   A vector with the same size as the number of frames with thetime of each frame, to show a time line at the bottom of the window
;zoom    rscale image cube using acongrid rutine zoom times the original
;img    use tvimg instead tvscl (scale to size of window and set plot coordinates)
;comm execute command on every frame
;
;Bruno SAN
;Agosto,06 added timeline (Bruno SAN)
;jun 07 added img option and single image case and comm option and rot option (Bruno SAN)


on_error,2

sl = string(byte([27, 91, 68, 27, 91, 68, 27, 91, 68]))
x=0
;mostrar en tvscl todas las imagenes de un cubo
IF NOT keyword_set(pausa) THEN pausa = 0
IF NOT keyword_set(time) THEN time = 0
IF NOT keyword_set(zoom) THEN zoom = 0
IF keyword_set(nimg) THEN img = 0 ELSE img=1
IF NOT keyword_set(comm) THEN comm=''
IF NOT keyword_set(rot) THEN rot = 0
IF NOT keyword_set(rec) THEN rec = 0 ELSE rec=1
IF NOT keyword_set(noframes) THEN label = 1 ELSE label=0
IF NOT keyword_set(step) THEN step = 0 ELSE step=1


IF rec NE 0 then begin
print,"saving WYSIWYG movie as ./mostrar-movie/frame-???.gif "
spawn,'pwd',folder
folder=folder+'/mostrar-movie'
spawn,"mkdir "+folder,exit=res
IF res NE 0 then print,"OVERWRITTING"
endif

imagen=reform(imagen)
sizes=size(imagen)
if sizes[0] EQ 2 then sizes[3]=1

if sizes[0] LT 2 then message,'no image found'

If zoom NE 0 then begin
imagen_o=imagen
imagen=congrid(imagen,sizes[1]*zoom,sizes[2]*zoom,sizes[3],/inter)
sizes=size(imagen)
endif

If rot NE 0 then begin
imagen=rot3d(imagen,rot,/int)
endif


stime=size(time)
IF total(time) NE 0 then begin
IF stime[1] NE sizes[3] then message,'time variable must have same size as data cube'
	fac=(time-time[0])/(time[sizes(3)-1]-time[0])*sizes[1]
endif
otra:
for cont=0,(sizes(3)-1) do begin
  IF img EQ 0 then tvscl,imagen(*,*,cont) ELSE IF cont EQ 0 then tvimg,reform(imagen(*,*,cont)),/aspect ELSE tvimg,reform(imagen(*,*,cont)),/noerase,/aspect
if label EQ 1 then xyouts,50,0,strtrim(string(cont),2),charsize=3,/dev
  if total(time) NE 0 then begin
	for j=0,(sizes(3)-1)-2 do xyouts,fac[j],0,'.',/dev,color=255,size=3
	for j=0,(sizes(3)-1)-2 do xyouts,fac[j]+1,0,'.',/dev,color=0,size=3
	xyouts,fac[cont],0,'|',/dev,color=0,size=2
	xyouts,fac[cont]+1,0,'|',/dev,color=255,size=2
  endif

IF comm NE '' then IF execute(comm) NE 1 then message,"error parsing command"   ;execute comm comand

IF rec NE 0 then write_gif,folder+'/frame-'+nnumber(cont,3)+".gif",tvrd() 

  writeu, -1,sl+string(cont+1, format="(i3)")
  if step EQ 1 then begin
  	null=GET_KBRD()
  	if null EQ '0' then step=0
  	if null EQ 'p' then if cont GT 2 then cont-=2
  endif else wait,pausa
  
  if label EQ 1 then xyouts,50,0,strtrim(string(cont),2),charsize=3,/dev,color=0
endfor
IF keyword_set(loop) then begin
x=x+1
writeu, -1,sl+string(x, format="(i3)")
print,''
if x GE loop then goto,salir
goto,otra
endif
salir:
If zoom NE 0 then begin
imagen=imagen_o
endif
end
