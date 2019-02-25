function [] = subjective_compare(im,imr,bpp,psnr)
% Display the original image
figure, imshow(im)
title('Original image')

%Display the coded and decoded image
figure, imshow(imr);
title(sprintf('Decoded image, %5.2f bits/pixel, PSNR %5.2f dB', bpp, psnr))

end

