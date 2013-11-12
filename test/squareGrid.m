%% Occupance Grid plot
function squareGrid()

    X = [3,1,4,1,5]
    Y = [9,2,6,5,4]

    figure(4);
    plot(X,Y);
    xlim([-5,5]);
    ylim([-1,10]);
    
    set(gca,'xtick',-5:5);
    set(gca,'ytick',-5:5);
    axis square;

    diameter = .34;
    radius = diameter/2;

    size_of_grid = 18;
    w = diameter;
    h = diameter;
        
    for y_index = -size_of_grid-1:size_of_grid-1
    
        for x_index = -size_of_grid-1:size_of_grid
            
            x = (2*x_index+1)*radius;
            y = (2*y_index+1)*radius;
    
            rectangle('Position',[x,y,w,h]); 
        end
    
    end
                
    for m = 1:length(X)

        x_c = floor((X(m)+radius)/diameter)*diameter-radius;
        y_c = floor((Y(m)+radius)/diameter)*diameter-radius;

        rectangle('Position',[x_c,y_c,w,h],'FaceColor','r');

    end

end