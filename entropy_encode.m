function R = entropy_encode(p,tmp,blocksize,method)
if strcmp(method,'jpgrate')
    R = sum(jpgrate(tmp,blocksize));  
else
    R = huffman(p); 
end
end

