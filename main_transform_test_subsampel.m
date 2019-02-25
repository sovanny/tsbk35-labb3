clear all; close all; clc

% Quantization steps for luminance and chrominance
qy = 0.1;
qc = 0.1;

% Read an image
im=double(imread('image2.png'))/255;

% What blocksize do we want?
blocksize = [8 8];

n_stepsizes = 15;
stepsize_lower = 0.01;
stepsize_upper = 0.5;

bpp = zeros(n_stepsizes,2);
psnr = zeros(n_stepsizes,2);

%stepsizes = linspace(stepsize_lower,stepsize_upper,n_stepsizes)
stepsizes = logspace(log10(stepsize_lower),log10(stepsize_upper),n_stepsizes);
for i = 1:n_stepsizes
    tic
    fprintf('STEP NR: %i\n',i)
    
    
    qy = stepsizes(i);
    qc = stepsizes(i);
    fprintf('\tstepsize: %f\n',qy)
    
    [~,bpp(i,1),psnr(i,1)] = transcoder(im,blocksize,qy,qc,'coding','jpgrate','transform','dct','subsampling',1);
    [~,bpp(i,2),psnr(i,2)] = transcoder(im,blocksize,qy,qc,'coding','jpgrate','transform','dct','subsampling',0.5);
    toc

end



%% Find most similair bitrates
A = meshgrid(bpp(:,1)');
B = meshgrid(bpp(:,2))';


diff = abs(A-B);

m = min(min(diff));
[a,b] = find(diff==m);

[imr1,bpp1,psnr1] = transcoder(im,blocksize,stepsizes(b),stepsizes(b),'coding','jpgrate','transform','dct','subsampling',1);
[imr2,bpp2,psnr2] = transcoder(im,blocksize,stepsizes(a),stepsizes(a),'coding','jpgrate','transform','dct','subsampling',0.5);


%% Plot
figure
subplot(2,2,1), imshow(im), title('Original')
subplot(2,2,2)
plot(bpp(:,1),psnr(:,1),'-x')
hold on
plot(bpp(:,2),psnr(:,2),'-o')
legend('no subsampling','subsampling 0.5')
xlabel('R'), ylabel('SNR')

subplot(2,2,3), imshow(imr1), title(sprintf('Decoded image (no subsampling), %5.2f bits/pixel, PSNR %5.2f dB', bpp1, psnr1))
subplot(2,2,4), imshow(imr2), title(sprintf('Decoded image (subsampling 0.5), %5.2f bits/pixel, PSNR %5.2f dB', bpp2, psnr2))
