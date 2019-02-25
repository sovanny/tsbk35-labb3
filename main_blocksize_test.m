clear all; close all; clc

% Quantization steps for luminance and chrominance
qy = 0.1;
qc = 0.1;

% Read an image
im=double(imread('image1.png'))/255;

% What blocksize do we want?
blocksize1 = [4 4];
blocksize2 = [8 8];
blocksize3 = [16 16];
n_stepsizes = 15;
stepsize_lower = 0.01;
stepsize_upper = 0.5;

bpp = zeros(n_stepsizes,3);
psnr = zeros(n_stepsizes,3);

%stepsizes = linspace(stepsize_lower,stepsize_upper,n_stepsizes)
stepsizes = logspace(log10(stepsize_lower),log10(stepsize_upper),n_stepsizes);
for i = 1:n_stepsizes
    tic
    fprintf('STEP NR: %i\n',i)
    
    
    qy = stepsizes(i);
    qc = stepsizes(i);
    fprintf('\tstepsize: %f\n',qy)
    
    [~,bpp(i,1),psnr(i,1)] = transcoder(im,blocksize1,qy,qc,'coding','jpgrate','transform','dct');
    [~,bpp(i,2),psnr(i,2)] = transcoder(im,blocksize2,qy,qc,'coding','jpgrate','transform','dct');
    [~,bpp(i,3),psnr(i,3)] = transcoder(im,blocksize3,qy,qc,'coding','jpgrate','transform','dct');
    toc

end



%% Find most similair bitrates

A = meshgrid(bpp(:,1)');
B = meshgrid(bpp(:,2))';


diff = abs(A-B);

m = min(min(diff));
[a,b] = find(diff==m);

[imr1,bpp1,psnr1] = transcoder(im,blocksize1,stepsizes(11)+0.02,stepsizes(11)+0.02,'coding','jpgrate','transform','dct');
[imr2,bpp2,psnr2] = transcoder(im,blocksize2,stepsizes(9),stepsizes(9),'coding','jpgrate','transform','dct');
[imr3,bpp3,psnr3] = transcoder(im,blocksize3,stepsizes(8)+0.005,stepsizes(8)+0.005,'coding','jpgrate','transform','dct');


%% Plot
figure
imshow(im), title('Original')

%%
close all
figure
plot(bpp(:,1),psnr(:,1),'-x')
hold on
plot(bpp(:,2),psnr(:,2),'-o')
plot(bpp(:,3),psnr(:,3),'-*')
legend('4 4','8 8 ','16 16')
xlabel('R'), ylabel('PSNR')

figure, imshow(imr1), title(sprintf('Decoded image (4 4), %5.2f bits/pixel, PSNR %5.2f dB', bpp1, psnr1))
figure, imshow(imr2), title(sprintf('Decoded image (8 8), %5.2f bits/pixel, PSNR %5.2f dB', bpp2, psnr2))
figure, imshow(imr3), title(sprintf('Decoded image (16 16), %5.2f bits/pixel, PSNR %5.2f dB', bpp3, psnr3))
