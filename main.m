
clc;
clear;
close all;

while true
    choice = menu('Image Steganography & LSB System', ...
        'Hide Text Message', ...
        'Hide Secret Image', ...
        'Extract Hidden Data', ...
        'Exit');

    if choice == 4 || choice == 0
        disp('Application closed.');
        break;
    end

    try
        if choice == 1 || choice == 2
            % Select the cover image.
            [file, path] = uigetfile( ...
                {'*.png;*.bmp;*.tif;*.tiff', ...
                'Supported lossless images'}, ...
                'Select Cover Image');

            if isequal(file, 0)
                continue;
            end

            cover = imread(fullfile(path, file));

            if ~isa(cover, 'uint8')
                if isa(cover, 'uint16')
                    cover = uint8(round(double(cover) / 257));
                elseif islogical(cover)
                    cover = uint8(cover) * 255;
                else
                    error('Unsupported cover image data type.');
                end
            end

            if ~(ismatrix(cover) || ...
                    (ndims(cover) == 3 && size(cover, 3) == 3))
                error('Choose a grayscale or RGB cover image.');
            end

            if choice == 1
                % Hide text.
                answer = inputdlg( ...
                    'Enter the secret text:', ...
                    'Text Steganography', [5 50]);

                if isempty(answer)
                    continue;
                end

                secretText = answer{1};
                payload = unicode2native(secretText, 'UTF-8');
                payloadType = 1;
                secretSize = [0 0 0];

            else
                % Hide an entire image.
                [secretFile, secretPath] = uigetfile( ...
                    {'*.png;*.bmp;*.tif;*.tiff', ...
                    'Supported lossless images'}, ...
                    'Select Secret Image');

                if isequal(secretFile, 0)
                    continue;
                end

                secret = imread(fullfile(secretPath, secretFile));

                if ~isa(secret, 'uint8')
                    if isa(secret, 'uint16')
                        secret = uint8(round(double(secret) / 257));
                    elseif islogical(secret)
                        secret = uint8(secret) * 255;
                    else
                        error('Unsupported secret image data type.');
                    end
                end

                if ~(ismatrix(secret) || ...
                        (ndims(secret) == 3 && size(secret, 3) == 3))
                    error('Choose a grayscale or RGB secret image.');
                end

                secretSize = [size(secret, 1), ...
                              size(secret, 2), size(secret, 3)];

                payload = secret(:);
                payloadType = 2;
            end

            % Encode the secret data.
            stego = lsbEncode(cover, payload, ...
                              payloadType, secretSize);

            % Show original and stego images.
            figure('Name', 'Encoding Result');
            subplot(1, 2, 1);
            imshow(cover);
            title('Original Cover Image');

            subplot(1, 2, 2);
            imshow(stego);
            title('Stego Image');

            % Save output as PNG to preserve hidden bits.
            [outFile, outPath] = uiputfile( ...
                '*.png', 'Save Stego Image', 'stego.png');

            if isequal(outFile, 0)
                continue;
            end

            imwrite(stego, fullfile(outPath, outFile));

            msgbox('Secret data embedded successfully!', ...
                   'Encoding Complete');

        elseif choice == 3
            % Select a stego image.
            [file, path] = uigetfile( ...
                {'*.png;*.bmp;*.tif;*.tiff', ...
                'Supported lossless images'}, ...
                'Select Stego Image');

            if isequal(file, 0)
                continue;
            end

            stego = imread(fullfile(path, file));

            if ~isa(stego, 'uint8')
                error('Stego image must be an 8-bit image.');
            end

            [payload, payloadType, secretSize] = ...
                lsbDecode(stego);

            if payloadType == 1
                % Reconstruct UTF-8 text.
                recoveredText = native2unicode( ...
                    payload(:).', 'UTF-8');

                disp('Recovered secret message:');
                disp(recoveredText);

                msgbox(recoveredText, 'Recovered Secret Text');

            elseif payloadType == 2
                % Reconstruct the secret image.
                recoveredImage = reshape(payload, secretSize);

                figure('Name', 'Recovered Secret Image');
                imshow(recoveredImage);
                title('Extracted Secret Image');

                [outFile, outPath] = uiputfile( ...
                    '*.png', 'Save Recovered Image', ...
                    'recovered.png');

                if ~isequal(outFile, 0)
                    imwrite(recoveredImage, ...
                        fullfile(outPath, outFile));
                end
            end

        end

    catch ME
        errordlg(ME.message, 'Operation Failed');
    end
end
