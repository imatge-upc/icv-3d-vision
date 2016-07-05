clear;
close all;
im1 = imread('0000_s.png');
im2 = imread('0001_s.png');
%give matching point

%subplot (1,2,1);

%subplot (1,2,2);
button = 0;
i=0;
matching_points_1=[];
matching_points_2=[];
while true
    i = i+1;
    
    
    
    if mod (i,2) == 1
        imshow (im1);
        disp('click on matching points in the two pictures. Right click when finish');
        [x,y,button] = ginput(1);
        if button ~=3
            matching_points_1 = [matching_points_1;[x y]];
        else break
        end
        
    else
        imshow (im2);
        disp('click on matching points in the two pictures. Right click when finish');
        
        [x,y,button] = ginput(1);
        
        if button ~=3
            matching_points_2 = [matching_points_2;[x y]];
        else break
        end
        
    end
end
[F,inliersIndex] = estimateFundamentalMatrix(matching_points_1,matching_points_2,'Method','MSAC');
