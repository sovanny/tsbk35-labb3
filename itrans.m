function im = itrans(t,blocksize,imsize,method)

if strcmp(method,'wht')
    im = ibdwht(t, blocksize, imsize);
else
    im = ibdct(t, blocksize, imsize);
end
end