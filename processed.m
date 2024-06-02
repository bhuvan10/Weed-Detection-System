clear;
clc;

% Define the folders containing the NIR and RGB images
nirFolderPath = 'blue';
redFolderPath = 'red';
greenFolderPath = 'green';
outputFolderPath = 'rgb';

% List all the RGB image files in the RGB folder
redImageFiles = dir(fullfile(redFolderPath, '*.png'));

% Parameters for the bilateral filter
sigma_d = 12.0; % Spatial-domain standard deviation (can be adjusted)
sigma_r = 0.1; % Range-domain standard deviation (can be adjusted)

% Create output folder if it doesn't exist
if ~exist(outputFolderPath, 'dir')
    mkdir(outputFolderPath);
end

% Loop through each RGB image
for i = 1:length(redImageFiles)
    % Construct the full file path for the RGB image
    redImageName = redImageFiles(i).name;
    redImagePath = fullfile(redFolderPath, redImageName);
    
    % Construct the corresponding NIR image path
    nirImageName = redImageName;
    nirImagePath = fullfile(nirFolderPath, nirImageName);

    % Construct the corresponding green image path
    greenImageName = redImageName;
    greenImagePath = fullfile(greenFolderPath, greenImageName);

    % Load the images if they all exist
    if exist(redImagePath, 'file') && exist(nirImagePath, 'file') && exist(greenImagePath, 'file')
        % Read the images
        redImage = imread(redImagePath);
        greenImage = imread(greenImagePath);
        nirImage = imread(nirImagePath);

        % Debugging outputs
        disp(['Processing image: ', redImageName]);

        % Check dimensions
        disp(['Size of redImage: ', num2str(size(redImage))]);
        disp(['Size of greenImage: ', num2str(size(greenImage))]);
        disp(['Size of nirImage: ', num2str(size(nirImage))]);

        % Ensure the images are grayscale (2D matrices)
        if ndims(redImage) ~= 2
            error('redImage is not a 2D matrix');
        end
        if ndims(greenImage) ~= 2
            error('greenImage is not a 2D matrix');
        end
        if ndims(nirImage) == 3
            nirImage = rgb2gray(nirImage); % Convert NIR image to grayscale if it's an RGB image
            disp('Converted nirImage to grayscale.');
        elseif ndims(nirImage) ~= 2
            error('nirImage is not a 2D matrix');
        end

        % Convert images to double precision
        redChannel = double(redImage);
        greenChannel = double(greenImage);
        nirChannel = double(nirImage);

        % Debugging outputs
        disp(['Class of redChannel: ', class(redChannel)]);
        disp(['Class of greenChannel: ', class(greenChannel)]);
        disp(['Class of nirChannel: ', class(nirChannel)]);

        % Calculate NDVI
        ndvi = (nirChannel - redChannel) ./ (nirChannel + redChannel + eps);

        % Apply bilateral filter to the NIR image
        filteredNir = imbilatfilt(nirChannel, sigma_d, sigma_r);

        % Concatenate the green, filtered NIR, and NDVI images to create a 3-channel image
        threeChannelImage = cat(3, redChannel, greenChannel, nirChannel);

        % Construct the output file path
        outputImageName = redImageName;
        outputImagePath = fullfile(outputFolderPath, outputImageName);

        % Save the 3-channel image
        imwrite(mat2gray(threeChannelImage), outputImagePath); % Convert to grayscale image for saving

        disp(['Saved processed image to: ', outputImagePath]);
    else
        fprintf('Skipping image %s: corresponding NIR or RGB image not found.\n', redImageName);
    end
end
