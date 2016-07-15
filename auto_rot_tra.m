 clear;
 close all;
im1 = imread('0000_s.png');
im2 = imread('0001_s.png');
 K = [2362.12 0 1520.69; 0 2366.12 1006.81; 0 0 1];
 scale = 0.3;
 H = [scale 0 0; 0 scale 0; 0 0 1];
%K= [2759.48 0 1520.69;0 2764.16 1006.81;0 0 1 ];
K =H*K;

cameraParams = K;

I1 = rgb2gray(im1);
I2 = rgb2gray(im2);
prevPoints = detectSURFFeatures(I1,'NumOctaves',8);
prevFeatures = extractFeatures(I1,prevPoints,'Upright',true);

% Create an empty viewSet object to manage the data associated with each
% view.
%vSet = viewSet;

% Add the first view. Place the camera associated with the first view
% and the origin, oriented along the Z-axis.
viewId = 1;
%vSet = addView(vSet, viewId, 'Points', prevPoints, 'Orientation', eye(3),...
%    'Location', [0 0 0]);


    currPoints   = detectSURFFeatures(I2, 'NumOctaves', 8);
    currFeatures = extractFeatures(I2, currPoints, 'Upright', true);
    indexPairs = matchFeatures(prevFeatures, currFeatures, ...
        'MaxRatio', .7, 'Unique',  true);
    
        % Select matched points.
    matchedPoints1 = prevPoints(indexPairs(:, 1));
    matchedPoints2 = currPoints(indexPairs(:, 2));
    F = estimateFundamentalMatrix(matchedPoints1, matchedPoints2,'Method','MSAC');
  E = K'*F*K;
  [U,S,V] = svd(E);
  CameraParams = cameraParameters('IntrinsicMatrix',K);
  
  
% Tra = V(:,3);
% Rot = U*[0 1 0;1 0 0;0 0 1]*V';
% if det (Rot) ==-1
%     Rot(:,3) = -Rot(:,3);
% end
     [Rot, Tra] = cameraPose2(F,CameraParams,CameraParams,matchedPoints1, matchedPoints2);
      
      Tra = (-Tra*Rot^-1)';
Rot = Rot';      
% 

% orientation = R';
% location = -t * orientation;

%     % Add the current view to the view set.
%     %vSet = addView(vSet, 2, 'Points', currPoints);
% 
%     % Store the point matches between the previous and the current views.
%     %vSet = addConnection(vSet, 1, 2, 'Matches', indexPairs(inlierIdx,:));
%     
%      % Get the table containing the previous camera pose.
%     %prevPose = poses(vSet, 1);
%     prevOrientation = eyes(3);
%     prevLocation    = zeros(3,1);
%     
%      % Compute the current camera pose in the global coordinate system
%     % relative to the first view.
%     Rot = relativeOrient;
%     Tra    = relativeLoc;
%     
