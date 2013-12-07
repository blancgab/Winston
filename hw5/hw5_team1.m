function hw5()

    global image;
    
    % Reading your image
    image = imread('http://192.168.1.100/snapshot.cgi?user=admin&pwd=&resolution=32&rate=0');
    
    resolution = size(image); 
	resolution = resolution(1:2) 

    figure(1);
    imshow(image);
    
    [y x] = getpts(1);
    
end
