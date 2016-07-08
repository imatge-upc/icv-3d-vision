 clear;
 close all;
im1 = imread('0000_s.png');
im2 = imread('0001_s.png');
%give matching point
f1 =0.5;
f2 = 0.15;
%subplot (1,2,1);

%subplot (1,2,2);
button = 0;
i=0;
matching_points_1=[];
matching_points_2=[];
  disp('click on matching points in the two pictures. Right click when finish');
while true
    i = i+1;
   
      disp ((i-mod(i,2))/2);
    if mod (i,2) == 1
        imshow (im1);
      
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
K = [2362.12 0 1520.69; 0 2366.12 1006.81; 0 0 1];
scale = 0.3;
H = [scale 0 0; 0 scale 0; 0 0 1];
K = H * K;

E = K'*F*K;
[U,S,V] = svd(E);
Tra = V(:,3);
R = U*[0 1 0;1 0 0;0 0 1]*V';
if det (R) ==-1
    R = -R;
end
save Rot_tra.mat