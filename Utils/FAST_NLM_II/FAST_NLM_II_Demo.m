% Fast NLM denoising parameters
NLM_patch_size  = 4;
NLM_window_size = 2;
NLM_sigma       = 0.1;

mse = @(a,b) (a(:)-b(:))'*(a(:)-b(:))/numel(a);
snr = @(clean,noisy) 20*log10(mean(noisy(:))/mean(abs(clean(:)-noisy(:))));

I = im2double(imread('cameraman.tif'));

I = imresize(I, [152 152]);

fprintf('Image is %d x %d pixels\n', size(I,1), size(I,2));

N = imnoise(I,'gaussian',0,.001);

tic
D = FAST_NLM_II(N, NLM_patch_size, NLM_window_size, NLM_sigma);
toc

subplot(1,3,1),imshow(I,[]),title('Clean Image')
subplot(1,3,2),imshow(N,[]),title(['Noisy Image, mse = ' num2str(mse(I,N)), ', snr = ', num2str(snr(I,N))])
subplot(1,3,3),imshow(D,[]),title(['Denoised Image, mse = ' num2str(mse(I,D)), ', snr = ', num2str(snr(I,D))])
