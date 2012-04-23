function compress, im, factor

tam=size(im)
n_out=long(tam(1)/factor)
m_out=long(tam(2)/factor)

return,rebin(im(0:n_out*factor-1,0:m_out*factor-1),n_out,m_out,/sample)
end
