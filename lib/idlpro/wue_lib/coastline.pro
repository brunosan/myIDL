pro coastline,alat,alon,map_file,color=color,thick=thick,remap=remap
;
;+
; ROUTINE:  coastline
;
; USEAGE:   coastline,alat,alon
;           coastline,alat,alon,map_file,color=color,thick=thick,remap=remap
;
; PURPOSE:  superpose coastal outlines over a satellite image 
;
; INPUTS:   
;    ALAT         2-D array of image latitude values (one value for
;                 each image pixel)
;    ALON         2-D array of image longitude values
; 
; OPTIONAL INPUTS:
;
;    MAP_FILE     name of map coordinate data file (default='coastline.dat')
;    COLOR        color of coastal outline
;    THICK        thickness of coast outline 
;    REMAP        If set, remap the coordinates in the MAP_FILE data base.
;                 This is useful when the data in a given MAP_FILE has
;                 been updated and you don't want to use the old mapping
;                 which has been saved in the MAPBLK common block.
;
; COMMON BLOCKS:  mapblk
;
; PROCEDURE:
; Coastline coordinates are read from file MAP_FILE.  When COASTLINE is first 
; called with a given map data file the lat-lon positions for that file are
; interpolated onto image coordinates using a newton-raphson search procedure 
; (LOCATE). The coastline image coordinates are stored in common block MAPBLK
; for use in subsequent calls.  Use the companion procedure, GEN_COASTLINE.PRO 
; to generate the map data files.
;
; AUTHOR:     Paul Ricchiazzi    oct92 
;             Earth Space Research Group, UCSB
;
;-
;
common mapblk,llbox,map_name,xcoast,ycoast
;
if keyword_set(map_file) eq 0 then map_file='coastline.dat'
if keyword_set(thick) eq 0 then thick=1.0
sz=size(alat)
nxm=sz(1)-1
nym=sz(2)-1
boxll=[alat(0,0),alon(0,0),alat(nxm,nym),alon(nxm,nym)]
;
readit=1
if keyword_set(map_name) ne 0 then begin
  gridtest=total(abs(boxll-llbox))
  if map_name eq map_file and gridtest eq 0 then readit=0
endif
llbox=boxll
map_name=map_file
if keyword_set(remap) then readit=1
;
if readit then begin
  print,form='(2a)','mapping ',map_file
  openu,1,map_file
  readf,1,nn
  f=fltarr(2,nn)
  readf,1,f
  lat=f(0,*)
  lon=f(1,*)  
  close,1
;
;   find lat and lon indices in image.
;
  xcoast=fltarr(nn)
  ycoast=fltarr(nn)
  xx=fix(nxm/2)
  yy=fix(nym/2)
;
  for i=0,nn-1 do begin
    loop=1
    if lat(i) eq 1000. then begin
      xcoast(i)=-1.
      ycoast(i)=-1. 
    endif else begin
      locate,lat(i),lon(i),alat,alon,xx,yy
      if xx eq -1 then xcoast(i)=-1 else xcoast(i)=float(xx/nxm)
      if yy eq -1 then ycoast(i)=-1 else ycoast(i)=float(yy/nym)
    endelse
  endfor
endif
ibrk=where(xcoast eq -1. or ycoast eq -1. ,nc)
i2=-2
sx0=!x.crange(0) & sx1=(!x.crange(1)-!x.crange(0))
sy0=!y.crange(0) & sy1=(!y.crange(1)-!y.crange(0))
if keyword_set(color) then begin
  for i=0,nc-1 do begin
    i1=i2+2
    i2=ibrk(i)-1
    if i2 gt i1 then oplot,sx0+sx1*xcoast(i1:i2),sy0+sy1*ycoast(i1:i2),$
                     thick=thick,color=color
  endfor
endif else begin
  for i=0,nc-1 do begin
    i1=i2+2
    i2=ibrk(i)-1
    if i2 gt i1 then oplot,sx0+sx1*xcoast(i1:i2),sy0+sy1*ycoast(i1:i2),$
                     thick=thick
  endfor
endelse
return
end




