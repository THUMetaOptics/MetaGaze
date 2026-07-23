%% Batch ROI Extraction for Raw Image Dataset
% -------------------------------------------------------------------------
% MetaGaze: Optomechanical Alignment & Registration Pipeline
% 
% Description:
% This script performs batch cropping on the raw captured images to extract 
% the precise Region of Interest (ROI). It implements a natural numeric 
% sorting algorithm to guarantee chronological frame processing and includes 
% strict boundary checks for out-of-bounds sensor capture anomalies.
%
% Note: Please ensure your MATLAB current working directory is set to the 
% root of this repository before execution.
% -------------------------------------------------------------------------

clear; clc; close all;

%% ==================== 1. Configuration Parameters ====================
% Utilize relative paths for cross-platform reproducibility
srcDir = fullfile('.', 'dataset', 'raw_captured');  % Source folder
dstDir = fullfile('.', 'output', 'cropped_roi');    % Destination folder

if ~exist(dstDir, 'dir')
    mkdir(dstDir);
end

% Define the geometric Region of Interest (ROI)
% Format: [x_min, y_min, width, height] (Note: x corresponds to columns, y to rows)
roiBox   = [127, 55, 1500, 1500]; 
colStart = roiBox(1);
rowStart = roiBox(2);
roiWidth = roiBox(3);
roiHeight= roiBox(4);
colEnd   = colStart + roiWidth - 1;
rowEnd   = rowStart + roiHeight - 1;

%% ==================== 2. Dataset Parsing & Natural Sorting ===========
% Validate source directory
if ~exist(srcDir, 'dir')
    error('Source directory not found: %s. Please verify the dataset path.', srcDir);
end

filePattern = fullfile(srcDir, '*.png');
fileList    = dir(filePattern);

if isempty(fileList)
    error('No PNG images found in the specified source directory.');
end

fprintf('Initializing batch process. Found %d raw images.\n', length(fileList));

% Natural Numeric Sorting:
% OS default sorting may erroneously order files as '1.png, 10.png, 2.png'. 
% We extract the exact numeric sequence via RegEx to ensure absolute chronological order.
fileNames = {fileList.name}; 
fileNums  = cellfun(@(x) str2double(regexp(x, '\d+', 'match', 'once')), fileNames);
[~, idx]  = sort(fileNums);
fileList  = fileList(idx);

fprintf('Natural numeric sorting applied successfully. Commencing ROI extraction...\n');

%% ==================== 3. Batch Cropping Execution ====================
numFiles = length(fileList);

for k = 1:numFiles
    % Load the original raw image
    srcPath = fullfile(srcDir, fileList(k).name);
    I = imread(srcPath);
    
    % Acquire native sensor resolution
    [sensorH, sensorW, ~] = size(I);
    
    % Boundary limit checks (Safeguard against out-of-bounds ROI configurations)
    validRowStart = max(1, rowStart);
    validRowEnd   = min(sensorH, rowEnd);
    validColStart = max(1, colStart);
    validColEnd   = min(sensorW, colEnd);
    
    % Skip invalid ROIs completely outside the sensor domain
    if validRowStart > validRowEnd || validColStart > validColEnd
        warning('ROI exceeds sensor bounds for image: %s. Skipping.', fileList(k).name);
        continue;
    end
    
    % Execute physical cropping
    I_cropped = I(validRowStart:validRowEnd, validColStart:validColEnd, :);
    
    % Optional: Strict dimensional padding (Zero-padding if cropped area is smaller than target)
    % if size(I_cropped,1) ~= roiHeight || size(I_cropped,2) ~= roiWidth
    %     tempImg = zeros(roiHeight, roiWidth, size(I,3), class(I));
    %     tempImg(1:size(I_cropped,1), 1:size(I_cropped,2), :) = I_cropped;
    %     I_cropped = tempImg;
    % end
    
    % Construct output path and save
    dstPath = fullfile(dstDir, fileList(k).name);
    imwrite(I_cropped, dstPath);
    
    % Progress tracking
    if mod(k, 100) == 0 || k == numFiles
        fprintf('Processing progress: %d / %d frames completed.\n', k, numFiles);
    end
end

fprintf('ROI extraction pipeline terminated successfully.\nOutputs saved to: %s\n', dstDir);