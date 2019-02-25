function t = trans(im,blocksize,method)

if strcmp(method,'wht')
    t = bdwht(im,blocksize);
else
    t = bdct(im, blocksize); 
end
end

