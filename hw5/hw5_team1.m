function hw5()

    % Reading your image
    image = imread('http://192.168.1.100/snapshot.cgi?user=admin&pwd=&resolution=32&rate=0');
    
    resolution = size(img); 
	resolution = resolution(1:2) 

    figure(1);
    imshow(image);

    
end

