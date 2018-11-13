function output = findGesture(binary)
%binary = (imread('binary.png'));

image = binary;

image=bwareaopen(image,200);
image = imclose(image,strel('sphere',5));
image=imfill(image,'holes');

% Flood fill largest area face to make hand the largest area
CC = bwconncomp(image);
numPixels = cellfun(@numel,CC.PixelIdxList);
[maxPixels, idx] = max(numPixels);
image(CC.PixelIdxList{idx}) = false;


% Retain largest area (now hand)
CC = bwconncomp(image);
numPixels = cellfun(@numel,CC.PixelIdxList);

newImage = false(size(image));
[maxPixels, idx] = max(numPixels);
newImage(CC.PixelIdxList{idx}) = true;

perimeterImage = bwperim(newImage);
imwrite(perimeterImage,'outline.png');

%select region of interest
[height, width] = size(image);
minRow = height;
maxRow = 1;
minCol = width;
maxCol = 1;

for r=1:height
    for c=1:width
        if perimeterImage(r,c)
            if r < minRow
                minRow = r;
            end
            if c < minCol
                minCol = c;
            end
            if r > maxRow
                maxRow = r;
            end
            if c > maxCol
                maxCol = c;
            end
        end
    end
end

perimeterImage = perimeterImage(minRow:maxRow,minCol:maxCol);

ROI = image(minRow:maxRow,minCol:maxCol);
[height, width] = size(ROI);
minPerimeterDistance = zeros(height,width);

perimeterIndexList = find(perimeterImage);

% Find center of palm

for row=1:height
    for col = 1:width
        if(ROI(row,col))
            % Initialised to farthest distance in image
            minPerimeterDistance(row,col) = sqrt((height)^2 + (width)^2);
            for i = 1:4:length(perimeterIndexList)
                r = mod(perimeterIndexList(i),height);
                if r == 0
                    r = height;
                end
                c = ceil(perimeterIndexList(i)/height);
                perimeterDistance = sqrt((r-row)^2 + (c-col)^2);
                if (perimeterDistance < minPerimeterDistance(row,col))
                    minPerimeterDistance(row,col) = perimeterDistance;
                end
            end
        end
    end
end

maxPerimeterDistance = max(minPerimeterDistance(:));

palmCenterIndex = find(minPerimeterDistance == maxPerimeterDistance);
cY = mod(palmCenterIndex(1),height);
if r == 0
    r = height;
end
cX = ceil(palmCenterIndex(1)/height);

% Find point where sum of radii (minRadius) is min
radius = zeros(height,width);

for i = 1:4:length(perimeterIndexList)
    r = mod(perimeterIndexList(i),height);
    if r == 0
        r = height;
    end
    c = ceil(perimeterIndexList(i)/height);
    radius(r,c) = sqrt((r-cY)^2 + (c-cX)^2);
end

% Find max and min radius
sortedRadius = sort(unique(radius(:)));
minRadius = sortedRadius(2);

% to limit ROI
maxRadius = max(radius(:));

% Compute the features

%find finger tips

fingerTips = false(size(ROI));
noOfTips = 1;
fingerTipPoint = zeros(1,2);
windowSize = round(width/10); % size is actually (2*  size + 1)
window = zeros(2*windowSize+1,2*windowSize+1);

for i = 1:length(perimeterIndexList)
    r = mod(perimeterIndexList(i),height);
    if r == 0
        r = height;
    end
    c = ceil(perimeterIndexList(i)/height);
    rowStart = r-windowSize;
    if rowStart < 1
        rowStart = 1;
    end
    
    rowEnd = r+windowSize;
    if rowEnd > height
        rowEnd = height;
    end
    
    colStart = c-windowSize;
    if colStart <= 0
        colStart = 1;
    end
    
    colEnd = c+windowSize;
    if colEnd > width
        colEnd = width;
    end
    window = radius(rowStart:rowEnd,colStart:colEnd);
    
    if (radius(r,c)==max(window(:)) & radius(r,c) > 2*minRadius)
        rad = radius(r,c);
        
        noOfTips = noOfTips + 1;
        fingerTipPoint(noOfTips,:) = [r,c];
    end
end

[noOfTips points] = size(fingerTipPoint);

%imshow(ROI), hold on,
%for n=2:noOfTips
%    try
%        P = fingerTipPoint(n,:);
%        plot([P(2) round(cX)], [P(1) round(cY)],'LineWidth',1,'Color','Yellow');
%    catch
%        fprintf("No tips found");
%        output = 0;
%    end
%end

%saveas(figure,'result.jpg');

% first finger tip is default 0,0 so it is invalid
noOfFingers = noOfTips - 1;

output = noOfFingers;

end