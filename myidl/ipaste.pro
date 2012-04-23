function ipaste,mos,s,xs,ys,frame
;version 1.2.1


;"mos" is the BIG image
;"s" is the small image wich will be pasted into pst
;"xs,ys" coordinates (xs,ys) are lower left corner
;OPTIONAL 
;"frame" apodisation width frame (15 default, 1 minimun)



;HISTORY
;Oct,05 B S-AN renamed to function "paste"
;              less parameters needed
;              corrected corner points
;              frame is optional(if not it takes 15)
;              do some checkings
;              scaling bug fixed

;on message, return to main level
on_error,1


pst=mos
siz=size(pst)
pst3=siz(3)-1
pst1=siz(1)-1
pst2=siz(2)-1
IF siz(0) EQ 2 then pst3=0
IF siz(0) GE 4 then message,'ONLY 2-D or 3-D'
ss=size(s)
xe=xs+ss(1)-1
ye=ys+ss(2)-1
IF ss(0) EQ 2 then ss(3)=0
IF siz(0) EQ 2 then siz(3)=0
IF ss(0) GE 4 then message,'ONLY 2-D or 3-D'
IF siz(3) NE ss(3) then message,'Different number of frames'

IF (siz(1) LE ss(1))+(siz(2) LE ss(2)) NE 0 then message,'second image bigger than first'

IF (xe GE siz(1))+(ye GE siz(2)) NE 0 then message,'pasted image out of first image'

masc=fltarr(pst1+1,pst2+1)


;frame apodisation width
IF NOT keyword_set(frame) THEN frame=15


;masc: Find common edges, different to 0, and make frame apodisation function
;lan i the frame taken to check common zones (to scale intensities)
lan=0

psts=fltarr(pst1+1,pst2+1)
psts(xs:xe,ys:ye)=s(*,*,lan)
for i=1,frame do begin
j=i-1
val=sin(!PI/2/frame*i)^2
masc(xs+i:xe-i,ys+j:ys+i)=val*((pst(xs+i:xe-i,ys+j:ys+i,lan) NE 0) AND ( psts(xs+i:xe-i,ys+j:ys+i) NE 0))
masc(xs+i:xe-i,ye-i:ye-j)=val*((pst(xs+i:xe-i,ye-i:ye-j,lan) NE 0) AND ( psts(xs+i:xe-i,ye-i:ye-j) NE 0))
masc(xs+j:xs+i,ys+i:ye-i)=val*((pst(xs+j:xs+i,ys+i:ye-i,lan) NE 0) AND ( psts(xs+j:xs+i,ys+i:ye-i) NE 0))
masc(xe-i:xe-j,ys+i:ye-i)=val*((pst(xe-i:xe-j,ys+i:ye-i,lan) NE 0) AND ( psts(xe-i:xe-j,ys+i:ye-i) NE 0))
endfor        

;scale intesity of small image, considerin only common parts.
sie=s
for i=0,pst3 do begin
   psti=pst(*,*,i)
   si=fltarr(pst1+1,pst2+1)
   si(xs:xe,ys:ye)=s(*,*,i)
   comun=masc NE 0 ;common area
   psti=psti*comun ;only common area
   si=si*comun     ;
   mediapst=mean(psti(where(psti NE 0)))
   mediasi=mean(si(where(si NE 0)))
   sie(*,*,i)=(reform(s(*,*,i))/mediasi*mediapst)
endfor
;sie is the scaled intesity
;masc is the blending area

pattern=fltarr(pst1+1,pst2+1)
;now pattern has to be
;1    where small image only
;masc in the common zone
;0    out of paste area
pattern(xs+1:xe-1,ys+1:ye-1)=1

;now multiplication of masc and 1-masc in common zone
;sin^2 + cos^2 =1 so the intesity remains constant
for i=xs,xe do for j=ys,ye do IF (masc(i,j) NE 0) then pattern(i,j)=masc(i,j)


for i=0,pst3 do pst(*,*,i)=pst(*,*,i)*(1-pattern)
;DO THE PASTING
for i=0,pst3 do pst(xs:xe,ys:ye,i)=pst(xs:xe,ys:ye,i)+(sie(*,*,i)*pattern(xs:xe,ys:ye))


return,pst
end
