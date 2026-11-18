
function [payload, payloadType, secretSize] = lsbDecode(stego)
% LSBDECODE Extract hidden text or image bytes from a stego image.

if ~isa(stego, 'uint8')
    error('Stego image must be uint8.');
end

flat = stego(:);

% Header is 18 bytes = 144 bits.
headerLength = 18;
headerBits = readBits(flat, headerLength * 8);
header = bitsToBytes(headerBits);

if ~isequal(char(header(1:4).'), 'LSB1')
    error('Header not found. This may not be a valid stego image.');
end

payloadType = double(header(5));
payloadLength = double(readU32(header(6:9)));
heightSecret = double(readU32(header(10:13)));
widthSecret = double(readU32(header(14:17)));
channelsSecret = double(header(18));

if payloadLength > floor(numel(flat)/8) || ...
        headerLength*8 + payloadLength*8 > numel(flat)
    error('Invalid header or insufficient image capacity.');
end

% Read payload bits after the header.
startBit = headerLength * 8 + 1;
endBit = startBit + payloadLength * 8 - 1;

payloadBits = readBitsRange(flat, startBit, endBit);
payload = bitsToBytes(payloadBits);

secretSize = [heightSecret, widthSecret, channelsSecret];

% Validate image payload dimensions.
if payloadType == 2 && ...
        prod(secretSize) ~= payloadLength
    error('Secret image dimensions do not match its payload.');
end

if ~ismember(payloadType, [1 2])
    error('Unknown payload type in header.');
end
end

function bits = readBits(flat, count)
bits = uint8(bitget(flat(1:count), 1));
end

function bits = readBitsRange(flat, first, last)
bits = uint8(bitget(flat(first:last), 1));
end

function bytes = bitsToBytes(bits)
bits = uint8(bits(:));

if mod(numel(bits), 8) ~= 0
    error('Bit count must be divisible by 8.');
end

groups = reshape(bits, 8, []).';
weights = uint8([128 64 32 16 8 4 2 1]);

bytes = uint8(sum(double(groups) .* double(weights), 2));
end

function n = readU32(b)
b = uint64(b(:));

n = b(1) + bitshift(b(2), 8) + ...
    bitshift(b(3), 16) + bitshift(b(4), 24);
end
