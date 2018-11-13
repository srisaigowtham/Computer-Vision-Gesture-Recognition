function output = blueChrominanceComputation(inputImage)

[height, width] = size(inputImage);

segmentedImage = false(height,width);

% Treat for gaussian noise
sigma = 1.5;
gaussianFilteredInputImage = imgaussfilt(inputImage,sigma);
edgesImage = edge(gaussianFilteredInputImage,'canny');
edgesImage = imdilate(edgesImage, strel('sphere',2));

for r = 1: height
    for c = 1 : width
        if (inputImage(r,c) >= 100 && inputImage(r,c) <= 120 && ~edgesImage(r,c))
            segmentedImage(r,c) = true;
        else
            segmentedImage(r,c) = false;
        end
    end
end

segmentedImage=bwareaopen(segmentedImage,200);
segmentedImage=imdilate(segmentedImage,strel('sphere',2));
segmentedImage=imfill(segmentedImage,'holes');

% avoiding to flood fill back ground by eliminating large areas as it was
% removing skin segments as well

% Treat for salt and pepper like noise
segmentedImage = medfilt2(segmentedImage, [5,5]);

imwrite(segmentedImage,'Cb segmentaion image.png');

output = segmentedImage;
end