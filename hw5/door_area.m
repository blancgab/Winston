function area = door_area(blue)
    %find the height of the door

    [h, w] = size(blue);
    center = w/2;

    blobs = regionprops(blue, 'Area');
    %simply with largest Area
    biggest = find([blobs.Area] == max([blobs.Area]))
    xval = blobs(biggest).Centroid(1)
    height = blobs(biggest).BoundingBox(4)

    imshow(blue)
    hold on

    plot([xval xval], [0 height])


end