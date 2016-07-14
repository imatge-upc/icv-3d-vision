 clear;
 close all;
im1 = imread('0000_s.png');
im2 = imread('0001_s.png');
%give matching point

button = 0;
i=0;
matchedPoints1=[];
matchedPoints2=[];
  disp('click on matching points in the two pictures. Right click when finish');
while true
    i = i+1;
   
      disp ((i-mod(i,2))/2);
    if mod (i,2) == 1
        imshow (im1);
      
        [x,y,button] = ginput(1);
        if button ~=3
            matchedPoints1 = [matchedPoints1;[x y]];
        else break
        end
        
    else
        imshow (im2);
        disp('click on matching points in the two pictures. Right click when finish');
        
        [x,y,button] = ginput(1);
        
        if button ~=3
            matchedPoints2 = [matchedPoints2;[x y]];
        else break
        end
        
    end
end
[F,inliersIndex] = estimateFundamentalMatrix(matchedPoints1,matchedPoints2,'Method','MSAC');
K = [2362.12 0 1520.69; 0 2366.12 1006.81; 0 0 1];
scale = 0.3;
H = [scale 0 0; 0 scale 0; 0 0 1];
K = H * K;

% E = K'*F*K;
% [U,S,V] = svd(E);
% Tra = V(:,3);
% Rot = U*[0 1 0;1 0 0;0 0 1]*V';
% if det (Rot) ==-1
%     Rot(:,3) = -Rot(:,3);
% end

  CameraParams = cameraParameters('IntrinsicMatrix',K);
   [Rot, Tra] = cameraPose(F,CameraParams,CameraParams,matchedPoints1, matchedPoints2);
      Tra = Tra';
save Rot_tra.mat