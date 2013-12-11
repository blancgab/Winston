function [offset, A] = door_find(blue)
   %find door in the blue-binarized mask and get its offset
    [h, w] = size(blue);
    center = w/2;

    blobs = regionprops(blue, 'Area', 'Extrema', 'Centroid');
    %simply with largest Area 
    A = max([blobs.Area])
	biggest = find([blobs.Area] == A)
    xval = blobs(biggest).Centroid(1);

    offset = xval - center;

    imshow(blue)
    hold on
    plot([xval xval], [0 h])

end
