%% Extract Centroids of Specular Reflections (Glints) and Generate Binary Map
% -------------------------------------------------------------------------
% MetaGaze: Optomechanical Alignment & Registration Pipeline
% 
% Description:
% This script isolates overexposed regions (corneal specular reflections) 
% to serve as physical fiducial markers for the deterministic geometric 
% registration strategy. It computes the sub-pixel centroids of these 
% glints and generates a sparse binary matrix where centroids are marked.
%
% Note: Please ensure your MATLAB current working directory is set to the 
% folder containing this script before running.
% -------------------------------------------------------------------------

clear; clc; close all;

%% ==================== 1. Configuration Parameters ====================
% Use relative paths for GitHub reproducibility (avoid absolute local paths)
% Example: Assuming images are stored in a 'dataset' folder in the same directory
dataDir   = fullfile('.', 'dataset'); 
imageName = 'sample_0100.png'; 
imagePath = fullfile(dataDir, imageName); 

glintThreshold = 200;  % Intensity threshold for specular reflection (0-255)
minArea        = 5;    % Minimum contiguous area (pixels) to filter sensor noise

%% ==================== 2. Data Loading & Verification ====================
if ~exist(imagePath, 'file')
    error('File not found: %s. Please check the dataset directory.', imagePath);
end

I_orig = imread(imagePath);

% Convert to grayscale if the input is an RGB image
if size(I_orig, 3) == 3
    I_gray = rgb2gray(I_orig);
else
    I_gray = I_orig;
end
I_double = double(I_gray);

%% ==================== 3. Binarization & Connected Components ==========
% Segment the overexposed regions
bwMap = (I_double >= glintThreshold);             

% Morphological filtering: remove isolated noise pixels
bwMap = bwareaopen(bwMap, minArea);               

% Extract connected components and calculate physical properties
cc    = bwconncomp(bwMap);                        
stats = regionprops(cc, 'Centroid', 'Area');      

if isempty(stats)
    warning('No valid overexposed regions detected with the current threshold.');
    centroids  = [];
    numRegions = 0;
else
    centroids  = vertcat(stats.Centroid); % Format: [x, y] -> [Column, Row]
    numRegions = size(centroids, 1);
end

fprintf('Detected %d valid specular reflection(s) (Area >= %d px).\n', numRegions, minArea);

%% ==================== 4. Generate Centroid Binary Map =================
[H, W] = size(I_gray);
centroidMap = zeros(H, W); % Initialize zero matrix

for i = 1:numRegions
    % Round the sub-pixel centroid coordinates to nearest integer index
    col = round(centroids(i, 1)); % x-coordinate
    row = round(centroids(i, 2)); % y-coordinate
    
    % Boundary safety check
    if row >= 1 && row <= H && col >= 1 && col <= W
        centroidMap(row, col) = 1;
    end
end

%% ==================== 5. Visualization ================================
figure('Name', 'Glint Centroid Extraction', 'Color', 'w');
imshow(I_gray, []);
hold on;

% Overlay extracted centroids as red crosses
for i = 1:numRegions
    plot(centroids(i,1), centroids(i,2), 'r+', 'MarkerSize', 12, 'LineWidth', 2.5);
end
hold off;

xlabel('Spatial Coordinate X (pixels)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Spatial Coordinate Y (pixels)', 'FontSize', 12, 'FontWeight', 'bold');
title(sprintf('Specular Reflection Centroids (Threshold: >= %d, Min Area: %d px)', ...
      glintThreshold, minArea), 'FontSize', 14);
axis on;

%% ==================== 6. Save Output (Optional) =======================
% Define output directory using relative paths
outputDir = fullfile('.', 'output');
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

% Save the binary matrix as a .mat file for downstream neural network processing
% save(fullfile(outputDir, 'centroid_map.mat'), 'centroidMap');

% Save visualization or binary mask
% imwrite(centroidMap, fullfile(outputDir, 'centroid_binary.png'));
% fprintf('Outputs successfully saved to: %s\n', outputDir);