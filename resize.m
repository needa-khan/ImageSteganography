% resize.m
% Shrinks the secret image just enough to fit inside the cover image,

clc;

coverFile  = 'image2.png';
secretFile = 'image1.png';

outSecret = 'secret_small.png';

HEADER_BYTES = 18;   % size of the header lsbEncode adds

cover  = imread(coverFile);
secret = imread(secretFile);

capacityBytes = floor(numel(cover) / 8) - HEADER_BYTES;
[secretH, secretW, secretC] = size(secret);

if numel(secret) <= capacityBytes
    smallSecret = secret;
    fprintf('The secret image already fits, so it was not resized.\n');
else
    % The payload grows with height x width, so scale both sides by the
    % square root of the size ratio.
    scale = sqrt(capacityBytes / numel(secret));
    newH  = floor(secretH * scale);
    newW  = floor(secretW * scale);

    % Guard against rounding: shrink until it definitely fits.
    while newH * newW * secretC > capacityBytes
        newH = newH - 1;
        newW = max(1, floor(newH * secretW / secretH));
    end

    smallSecret = imresize(secret, [newH newW]);
    imwrite(smallSecret, outSecret);
    fprintf('Saved %s\n',  outSecret);

end

%imwrite(smallSecret, outSecret);

fprintf('Cover image : %s\n', mat2str(size(cover)));
fprintf('Original secret: %s  (%d bytes)\n', mat2str(size(secret)), numel(secret));
fprintf('Resized secret : %s  (%d bytes)\n', mat2str(size(smallSecret)), numel(smallSecret));
fprintf('Cover capacity : %d bytes\n', capacityBytes);
