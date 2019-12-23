imaqhwinfo
imaqreset
vid = videoinput('pointgrey', 1, 'F7_Raw8_1280x1024_Mode0');
preview(vid)
propinfo(vid)
propinfo(vid,'TriggerRepeat')

start(vid);
trigger(vid);
frame = getsnapshot(vid);
imshow(frame)
stop(vid)

%enregistrmeent images
imwrite

imshow(d,[],'InitialMagnification','fit');
prop = regionprops(fish(:,:,i),'Centroid');


