function door_RGB_local()
    
    image = imread('images/snapshot-1.jpg');

    figure(1);
    imshow(image);
    
    [c, r] = getpts(1);
    rgb1 = impixel(image, c, r);
    hsv1 = rgb2hsv(rgb1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    image = imread('images/snapshot-2.jpg');

    figure(1);
    imshow(image);
    
    [c, r] = getpts(1);
    rgb2 = impixel(image, c, r);
    hsv2 = rgb2hsv(rgb2);    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    image = imread('images/snapshot.jpg');

    figure(1);
    imshow(image);
    
    [c, r] = getpts(1);
    rgb3 = impixel(image, c, r);
    hsv3 = rgb2hsv(rgb3);
    
    hsv3(:,3)
    
    max_h = max([max(hsv1(:,1)), max(hsv2(:,1)), max(hsv3(:,1))]);    
    max_s = max([max(hsv1(:,2)), max(hsv2(:,2)), max(hsv3(:,2))]);    
    max_v = max([max(hsv1(:,3)), max(hsv2(:,3)), max(hsv3(:,3))]);
    
    min_h = min([min(hsv1(:,1)), min(hsv2(:,1)), min(hsv3(:,1))]);
    min_s = min([min(hsv1(:,2)), min(hsv2(:,2)), min(hsv3(:,2))]);
    min_v = min([min(hsv1(:,3)), min(hsv2(:,3)), min(hsv3(:,3))]);    
    
    fprintf('h:\t[%.2f %.2f]\n',min_h, max_h);
    fprintf('s:\t[%.2f %.2f]\n',min_s, max_s);
    fprintf('v:\t[%.2f %.2f]\n',min_v, max_v);

    H = [min_h max_h];        
    S = [min_s max_s];

    hsv = rgb2hsv(image);
    hue = hsv(:,:,1);
    sat = hsv(:,:,2);    
    
    sv = (sat >= S(1)) & (sat <= S(2));
    blue = ((hue > H(1))&(hue <= H(2)))&(sv) ;    
    
    while(1)
        
        image = imread('http://192.168.1.102/img/snapshot.cgi?');
        
        hsv = rgb2hsv(image);
        hue = hsv(:,:,1);
        sat = hsv(:,:,2);    
        
        sv = (sat >= S(1)) & (sat <= S(2));
        blue = ((hue > H(1))&(hue <= H(2)))&(sv) ;         
        
        subplot(1,2,1); imshow(image);
        
        G = fspecial('gaussian',[5 5],2);
        bi = imfilter(blue,G,'same');
        subplot(1,2,2); imshow(bi); % imshow(pixel_mask);
        drawnow;
        
    end
    

end