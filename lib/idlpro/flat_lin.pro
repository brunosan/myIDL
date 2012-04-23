pro flat_lin,num,x,y

num=1
print,'Click on left  position of spectral line ',num
cursor,xl,yl,/down       
x=xl
y=yl      
print,'Click on right position of spectral line ',num
print,'  (left button: more lines; right button: last line) 
cursor,xr,yr,/down 
x=[x,xr]
y=[y,yr]
while(!mouse.button ne 4) do begin
   num=num+1
   print,'Click on left  position of spectral line ',num
   cursor,xl,yl,/down       
   x=[x,xl]
   y=[y,yl]
   print,'Click on right position of spectral line ',num
   print,'  (left button: more lines; right button: last line) 
   cursor,xr,yr,/down 
   x=[x,xr]
   y=[y,yl]
endwhile
print,'End of cursor entries'
return
end   
            
