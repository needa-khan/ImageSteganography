% imageSize.m
% Prints the size of the cover image and the secret image, and checks
% whether the secret image fits inside the cover image with lsbEncode.
%
% lsbEncode stores 1 bit in every channel value of the cover, plus an
% 18-byte header, so:
%   capacity (bytes) = floor(numel(cover) / 8) - 18

clc;

coverFile  = 'image1.png';
secretFile = 'image2.png';   

HEADER_BYTES = 18;

cover  = imread(coverFile);
secret = imread(secretFile);

[coverH,  coverW,  coverC]  = size(cover);
[secretH, secretW, secretC] = size(secret);

capacityBytes = floor(numel(cover) / 8) - HEADER_BYTES;
requiredBytes = numel(secret);

fprintf('Cover image  (%s): %d x %d x %d  (%d pixel values)\n', ...
    coverFile, coverH, coverW, coverC, numel(cover));
fprintf('Secret image (%s): %d x %d x %d  (%d pixel values)\n', ...
    secretFile, secretH, secretW, secretC, numel(secret));
fprintf('\n');
fprintf('Maximum secret payload : %d bytes\n', capacityBytes);
fprintf('Required secret payload: %d bytes\n', requiredBytes);

if requiredBytes <= capacityBytes
    fprintf('Result: the secret image FITS (%.1f%% of capacity used).\n', ...
        100 * requiredBytes / capacityBytes);
else
    fprintf('Result: the secret image is TOO LARGE by %d bytes. Run resize.m.\n', ...
        requiredBytes - capacityBytes);
end
