function STD,x
;return,sqrt(total((x-mean(x))^2)/(n_elements(x);-1))
return,sqrt(total((x-mean(x))^2)/(n_elements(x)))
end
