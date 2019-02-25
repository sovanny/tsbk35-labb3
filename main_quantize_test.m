clear all; close all; clc

% Read an image
im=double(imread('image4.png'))/255;

% What blocksize do we want?
blocksize = [8 8];


n_stepsizes = 15;
stepsize_lower = 0.01;
stepsize_upper = 0.5;

bpp = zeros(n_stepsizes,2);
psnr = zeros(n_stepsizes,2);


%stepsizes = linspace(stepsize_lower,stepsize_upper,n_stepsizes)
stepsizes = logspace(log10(stepsize_lower),log10(stepsize_upper),n_stepsizes);


QL=repmat(1:8, 8, 1); 
QL=(QL+QL'-9)/8;


for i = 1:n_stepsizes
    tic
    fprintf('STEP NR: %i\n',i)
    
    
    qy = stepsizes(i);
    qc = stepsizes(i);
    
    k1=qy; 
    k2=0.8;
    Q2=k1*(1+k2*QL);
    
    fprintf('\tstepsize: %f\n',qy)
    
    [~,bpp(i,1),psnr(i,1)] = transcoder(im,blocksize,qy,qc,'coding','jpgrate','transform','dct');
    [~,bpp(i,2),psnr(i,2)] = transcoder(im,blocksize,Q2,Q2,'coding','jpgrate','transform','dct');
    toc

end



%% Find most similair bitrates
A = meshgrid(bpp(:,1)');
B = meshgrid(bpp(:,2))';

diff = abs(A-B);

m = min(min(diff));
[a,b] = find(diff==m);

qy = stepsizes(b);
qc = stepsizes(b);

k1=stepsizes(a); 
k2=0.8;
Q2=k1*(1+k2*QL);

[imr1,bpp1,psnr1] = transcoder(im,blocksize,qy, qc,'coding','jpgrate','transform','dct');
[imr2,bpp2,psnr2] = transcoder(im,blocksize,Q2,Q2,'coding','jpgrate','transform','dct');


%% Plot
figure
subplot(2,2,1), imshow(im), title('Original')
subplot(2,2,2)
plot(bpp(:,1),psnr(:,1),'-x')
hold on
plot(bpp(:,2),psnr(:,2),'-o')
legend('uniform','component wise')
xlabel('R'), ylabel('SNR')

subplot(2,2,3), imshow(imr1), title(sprintf('Decoded image (uniform), %5.2f bits/pixel, PSNR %5.2f dB', bpp1, psnr1))
subplot(2,2,4), imshow(imr2), title(sprintf('Decoded image (component wise), %5.2f bits/pixel, PSNR %5.2f dB', bpp2, psnr2))
