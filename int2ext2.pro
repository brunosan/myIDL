;
;	returns a 4 character extension string for an 
;	integer argument
;
function int2ext2,num
str=string(num)
str=strcompress(str,/REMOVE_ALL)
if strlen(str) EQ 0 then return,'0000'
if strlen(str) EQ 1 then return,'000'+str
if strlen(str) EQ 2 then return,'00'+str
if strlen(str) EQ 3 then return,'0'+str
return,str
end
