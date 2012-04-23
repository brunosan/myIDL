pro make_png_cube,file,map=map,showpic=showpic

;make a True Color PNG file with 1:1 resolution
;file is input file (optionally with full path)
;file can be a fits file to read, or a variable, in wich case the output will be Bild0.png, Bild1.png, .. on the current folder
;/map output image is a plot_map figure
;/showpic open image (Mac OS only)

;needs Image Magic to rescale

;version Jan. 09 Bruno S-AN (NRL/SSD)

IF size(file) EQ 0 then begin
;file is fits file to read
pos=strpos(file,'/',/reverse_search)+1
name=strmid(file,pos)
out=strmid(file,0,pos)
pos=strpos(name,'.f',/reverse_search)+1
filenamenoext=strmid(name,0,pos)
png=filenamenoext+'png'


mreadfits,file,a,b
;mreadfits,file,a,b
ssize=size(b)
set_plot,'z'
device,SET_PIXEL_DEPTH=24, $
SET_RESOLUTION= [ssize[1], ssize[2]], $
SET_CHARACTER_SIZE = [16, 20], decomposed=0
loadct,3
;xloadct

!X.margin=[-1,-1]
!y.margin=0
if ~keyword_set(map) then begin
;b=sigrange(alog(b))
b=hist_equal((b),per=0.1)
plot_image,b
endif else begin
index2map,a,b,map
;map.data=(alog(map.data))
map.data=hist_equal((map.data),per=0.1)

plot_map,map
endelse

tvlct,rr,gg,bb,/get

write_png,out+png,tvrd(/true),rr,gg,bb

spawn,'convert -resize 50% '+out+png+' '+out+png
message,'PNG written into: '+out+png,/cont
if keyword_set(showpic) then spawn,'open '+out+png
set_plot,'x'

end