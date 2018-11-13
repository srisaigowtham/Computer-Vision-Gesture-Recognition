clear all;

video = videoinput('macvideo',1,'YCbCr422_1280x720');
set(video,'FramesPerTrigger',Inf);
set(video,'ReturnedColorSpace','rgb');
set(video,'FrameGrabInterval',5);

preview(video);
frame = (getsnapshot(video));


imshow(frame);
