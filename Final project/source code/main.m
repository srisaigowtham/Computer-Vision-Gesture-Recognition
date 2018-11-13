close all;
clc;
clear all;

vid = imaq.VideoDevice('macvideo',1,'YCbCr422_1280x720');
vid.ReturnedDataType = 'uint8';


preview(vid);
%YCbCr image
image = step(vid);
pause(0.01);

closepreview(vid);

imwrite(image,'ybcbr image.jpg');
imwrite(ycbcr2rgb(image),'rgb image.jpg');

% segmentation based on luminance
inputImageY = image(:,:,1);
Y = luminanceComputation(inputImageY);

% segmentation based on blue chrominance
inputImageCb = image(:,:,2);
Cb = blueChrominanceComputation(inputImageCb);

% segmentation based on red chrominance
inputImageCr = image(:,:,3);
Cr = redChrominanceComputation(inputImageCr);

combined = Y & (Cb | Cr);

combined=imdilate(combined,strel('sphere',2));
combined=imfill(combined,'holes');

imwrite(combined,'binary.png');

noOfFingers = findGesture(combined);

if (noOfFingers > 5)
    fprintf("Improper computation. Try again.");
    fprintf("\n");
else
    fprintf("No of fingers = %d",noOfFingers);
    fprintf("\n");
end

release(vid);
