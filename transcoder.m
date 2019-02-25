function [imr,bpp,psnr]=transcoder(im,blocksize,qy,qc,varargin)

% This is a very simple transform coder and decoder. Copy it to your directory
% and edit it to suit your needs.
% You probably want to supply the image and coding parameters as
% arguments to the function instead of having them hardcoded.

parser = inputParser;

addOptional(parser,'coding','huffman');
addOptional(parser,'transform','dct');
addOptional(parser,'quantmethod','uniform');
addOptional(parser,'subsampling',1);
parse(parser,varargin{:});

% Change colourspace 
imy=rgb2ycbcr(im);

bits=0;

% Somewhere to put the decoded image
imyr=zeros(size(im));

% First we code the luminance component
% Here comes the coding part
sampl_factor = parser.Results.subsampling;



tmp = trans(imy(:,:,1), blocksize,parser.Results.transform);

% DCT
tmp = bquant(tmp, qy);             % Simple quantization
p = ihist(tmp(:));                 % Only one huffman code

bits = bits + entropy_encode(p,tmp,blocksize,parser.Results.coding);


% Here comes the decoding part
tmp = brec(tmp, qy);               % Reconstruction
% imyr(:,:,1) = ibdct(tmp, blocksize, [512 768]);  % Inverse DCT
imyr(:,:,1) = itrans(tmp,blocksize,[512 768],parser.Results.transform);

% Next we code the chrominance components
for c=2:3                          % Loop over the two chrominance components
  % Here comes the coding part
  tmp = imresize(imy(:,:,c),sampl_factor);
  dims = size(tmp);
  % If you're using chrominance subsampling, it should be done
  % here, before the transform.

%   tmp = bdct(tmp, blocksize);      % DCT
  tmp = trans(tmp, blocksize,parser.Results.transform);
  tmp = bquant(tmp, qc);           % Simple quantization
  p = ihist(tmp(:));               % Only one huffman code
  bits = bits + entropy_encode(p,tmp,blocksize,parser.Results.coding);
			
  % Here comes the decoding part
  tmp = brec(tmp, qc);            % Reconstruction
  %tmp = ibdct(tmp, blocksize, [512 768]);  % Inverse DCT
  tmp = itrans(tmp,blocksize,dims,parser.Results.transform);
  % If you're using chrominance subsampling, this is where the
  % signal should be upsampled, after the inverse transform.
  imyr(:,:,c) = imresize(tmp, 1/sampl_factor);
  
end

% Display total number of bits and bits per pixel
bpp = bits/(size(im,1)*size(im,2));

% Revert to RGB colour space again.
imr=ycbcr2rgb(imyr);

% Measure distortion and PSNR
dist = mean((im(:)-imr(:)).^2);
psnr = 10*log10(1/dist);


end

