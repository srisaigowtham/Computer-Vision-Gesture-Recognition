function output = luminanceComputation(inputImage)

[height, width] = size(inputImage);

segmentedImage = false(height,width);

% Treat for gaussian noise
sigma = 1.5;
inputImage = imgaussfilt(inputImage,sigma);

edgesImage = edge(inputImage,'canny');

for r = 1: height
    for c = 1 : width
        if (inputImage(r,c) >= 54 && inputImage(r,c) <= 190 && ~edgesImage(r,c))
            segmentedImage(r,c) = true;
        else
            segmentedImage(r,c) = false;
        end
    end
end

segmentedImage=bwareaopen(segmentedImage,200);
segmentedImage=imdilate(segmentedImage,strel('sphere',2));
segmentedImage=imfill(segmentedImage,'holes');

% Treat for salt and pepper like noise
segmentedImage = medfilt2(segmentedImage, [5,5]);

imwrite(segmentedImage,'Y segmentaion image.png');

output = segmentedImage;
end