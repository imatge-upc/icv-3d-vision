%cameraPose Compute relative rotation and translation between camera poses
%  [orientation, location] = cameraPose(F, cameraParams, 
%  inlierPoints1, inlierPoints2) returns the orientation and location of a 
%  calibrated camera relative to its previous pose. The two poses are related
%  by the fundamental matrix F. The function computes the pose up to scale 
%  and returns location as a unit vector. 
%
%  F is a 3-by-3 fundamental matrix. cameraParams is a
%  cameraParameters object returned by the Camera Calibrator app or the
%  estimateCameraParameters function. inlierPoints1 and inlierPoints2 are
%  matching inlier points from the two views corresponding to the two poses. 
%  F, inlierPoints1, and inlierPoints2 are returned by the 
%  estimateFundamentalMatrix function. orientation is a 3-by-3 rotation
%  matrix. location is a unit vector of size 3-by-1.
%
%  [...] = cameraPose(F, cameraParams1, cameraParams2, inlierPoints1, inlierPoints2) 
%  returns the orientation and location of camera 2 relative to camera 1. 
%  cameraParams1 and cameraParams2 are cameraParameters objects containing 
%  the parameters of camera 1 and camera 2 respectively. 
%
%  [..., validPointsFraction] = cameraPose(...) additionally returns the
%  fraction of the inlier points that project in front of both cameras. If
%  this fraction is too small (e. g. less than 0.9), that can indicate that
%  the fundamental matrix is incorrect.
%
%  Notes
%  -----
%  - You can compute the camera extrinsics as follows: 
%    rotationMatrix = orientation', 
%    translationVector = -location * rotationMatrix. You can then use 
%    rotationMatrix and translationVector as inputs to the cameraMatrix function.
%
%  - The cameraPose function uses inlierPoints1 and inlierPoints2 to
%    determine which one of the four possible solutions is physically 
%    realizable.
%
%  Class Support
%  -------------
%  F must be double or single. cameraParams must be a cameraParameters
%  object. inlierPoints1 and inlierPoints2 can be double, single, or any of
%  the <a href="matlab:helpview(fullfile(docroot,'toolbox','vision','vision.map'),'pointfeaturetypes')">point feature types</a>. location and orientation are the same class as F.
%
%  Example: Structure from motion from two views
%  ---------------------------------------------
%  % This example shows you how to build a point cloud based on features
%  % matched between two images of an object.
%  % <a href="matlab:web(fullfile(matlabroot,'toolbox','vision','visiondemos','html','StructureFromMotionExample.html'))">View example</a>
%
%  See also cameraCalibrator, estimateCameraParameters, estimateFundamentalMatrix, 
%    cameraMatrix, plotCamera, triangulate

% Copyright 2015 The MathWorks, Inc.

%#codegen

function [orientation, location, validPointsFraction] = ...
    cameraPose2(F, varargin)

[cameraParams1, cameraParams2, inlierPoints1, inlierPoints2] = ...
    parseInputs(F, varargin{:});

% Compute the essential matrix
K1 = cameraParams1.IntrinsicMatrix;
K2 = cameraParams2.IntrinsicMatrix;
E = K2 * F * K1';

[Rs, Ts] = decomposeEssentialMatrix(E);
[orientation, location, validPointsFraction] = chooseRealizableSolution(Rs, Ts, cameraParams1, cameraParams2, inlierPoints1, ...
    inlierPoints2);

% R and t are currently the transformation from camera1's coordinates into
% camera2's coordinates. To find the location and orientation of camera2 in
% camera1's coordinates we must take their inverse.
%  orientation = R';
% location = -t * orientation;


%--------------------------------------------------------------------------
function [cameraParams1, cameraParams2, inlierPoints1, inlierPoints2] = ...
    parseInputs(F, varargin)
narginchk(4, 5);
validateattributes(F, {'single', 'double'}, ...
    {'real', 'nonsparse', 'finite', '2d', 'size', [3,3]}, mfilename, 'F'); 

cameraParams1 = varargin{1};
if isa(varargin{2}, 'cameraParameters')
    cameraParams2 = varargin{2};
    paramVarName = 'cameraParams';
    idx = 2;
else
    paramVarName = 'cameraParams1';
    cameraParams2 = cameraParams1;
    idx = 1;
end
validateattributes(cameraParams1, {'cameraParameters'}, {}, mfilename, ...
    paramVarName);

points1 = varargin{idx + 1};
points2 = varargin{idx + 2};
[inlierPoints1, inlierPoints2] = ...
    vision.internal.inputValidation.checkAndConvertMatchedPoints(...
    points1, points2, mfilename, 'inlierPoints1', 'inlierPoints2');

coder.internal.errorIf(isempty(points1), 'vision:cameraPose:emptyInlierPoints');
    
%--------------------------------------------------------------------------
% Compute the 4 possible pairs of R and t, such that R * [Tx] = E
function [Rs, Ts] = decomposeEssentialMatrix(E)

% Fix E to be an ideal essential matrix
[U, D, V] = svd(E);
e = (D(1,1) + D(2,2)) / 2;
D(1,1) = e;
D(2,2) = e;
D(3,3) = 0;
E = U * D * V';

[U, ~, V] = svd(E);

W = [0 -1 0; 1 0 0; 0 0 1];
Z = [0 1 0; -1 0 0; 0 0 0];

% Possible rotation matrices
R1 = U * W * V';
R2 = U * W' * V';

% Force rotations to be proper, i. e. det(R) = 1
if det(R1) < 0
    R1 = -R1;
end

if det(R2) < 0
    R2 = -R2;
end

% Translation vector
Tx = U * Z * U';
t = [Tx(3, 2), Tx(1, 3), Tx(2, 1)];

Rs = cat(3, R1, R1, R2, R2);
Ts = cat(1, t, -t, t, -t);

%--------------------------------------------------------------------------
% Determine which of the 4 possible solutions is physically realizable.
% A physically realizable solution is the one which puts reconstructed 3D
% points in front of both cameras.
function [R, t, validFraction] = chooseRealizableSolution(Rs, Ts, cameraParams1, ...
    cameraParams2, points1, points2)
numNegatives = zeros(1, 4);

camMatrix1 = cameraMatrix(cameraParams1, eye(3), [0 0 0]);
for i = 1:size(Ts, 1)
    camMatrix2 = cameraMatrix(cameraParams2, Rs(:,:,i)', Ts(i, :));
    m1 = triangulateMidPoint(points1, points2, camMatrix1, camMatrix2);
    m2 = bsxfun(@plus, m1 * Rs(:,:,i)', Ts(i, :));
    numNegatives(i) = sum((m1(:,3) < 0) | (m2(:,3) < 0));
end

[val, idx] = min(numNegatives);

validFraction = 1 - (val / size(points1, 1));

R = Rs(:,:,idx)';
t = Ts(idx, :);

tNorm = norm(t);
if tNorm ~= 0
    t = t ./ tNorm;
end

%--------------------------------------------------------------------------
% Simple triangulation algorithm from 
% Hartley, Richard and Peter Sturm. "Triangulation." Computer Vision and
% Image Understanding. Vol 68, No. 2, November 1997, pp. 146-157
function points3D = triangulateMidPoint(points1, points2, P1, P2)

points3D = zeros(size(points1, 1), 3, 'like', points1);
P1 = P1';
P2 = P2';

M1 = P1(1:3, 1:3);
M2 = P2(1:3, 1:3);

c1 = -M1 \ P1(:,4);
c2 = -M2 \ P2(:,4);

for i = 1:size(points1, 1)
    u1 = [points1(i, :), 1]';
    u2 = [points2(i, :), 1]';
    
    a1 = M1 \ u1;
    a2 = M2 \ u2;
    A = [a1, -a2];
    y = c2 - c1;
    
    alpha = (A' * A) \ A' * y;
    
    p = (c1 + alpha(1) * a1 + c2 + alpha(2) * a2) / 2;
    
    points3D(i, :) = p';
end

