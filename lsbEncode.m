
function stego = lsbEncode(cover, payload, payloadType, secretSize)
% LSBENCODE Hide text or image bytes inside a cover image.
%
% payloadType = 1 for text
% payloadType = 2 for a secret image
% secretSize  = [height, width, channels] for an image

if ~isa(cover, 'uint8')
    error('Cover image must be converted to uint8.');
end

if ~(ismatrix(cover) || ...
        (ndims(cover) == 3 && size(cover, 3) == 3))
    error('Cover must be a grayscale or RGB image.');
end

payload = uint8(payload(:));
payloadLength = numel(payload);

% Header: magic (4), type (1), payload length (4),
%         image height (4), width (4), channels (1).
header = [uint8('LSB1'), uint8(payloadType), ...
    u32bytes(payloadLength), ...
    u32bytes(secretSize(1)), ...
    u32bytes(secretSize(2)), ...
    uint8(secretSize(3))];

% Add header and payload together.
allBytes = [header(:); payload];

% Convert bytes to bits, most significant bit first.
bits = bytesToBits(allBytes);

% One bit is stored in each pixel channel.
flat = cover(:);

if numel(bits) > numel(flat)
    error('Secret data is too large for this cover image.');
end

% Replace each selected channel value's LSB.
flat(1:numel(bits)) = bitset( ...
    flat(1:numel(bits)), 1, bits);

stego = reshape(flat, size(cover));
end

function bits = bytesToBits(bytes)
bits = zeros(numel(bytes) * 8, 1, 'uint8');

for k = 1:numel(bytes)
    idx = (k-1)*8 + (1:8);
    bits(idx) = uint8(bitget(bytes(k), 8:-1:1));
end
end

function b = u32bytes(n)
% Encode a nonnegative integer as four little-endian bytes.
n = uint64(n);
b = uint8([ ...
    bitand(n, 255), ...
    bitand(bitshift(n, -8), 255), ...
    bitand(bitshift(n, -16), 255), ...
    bitand(bitshift(n, -24), 255)]);
end
