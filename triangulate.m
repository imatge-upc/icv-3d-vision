clear;
close all;

im1 = imread('0000_s.png');
im2 = imread('0001_s.png');
K= [2759.48 0 1520.69;0 2764.16 1006.81;0 0 1 ];
Rot1 = [0.14139 0.153155 0.978035;0.989608 -0.0479961 -0.135547; 0.0261821 0.987036 -0.15835 ];
Rot2 = [0.494514 0.150712 0.856003;0.869109 -0.0974071 -0.484935; 0.0102952 0.983767 -0.179154 ];
Tra1 = [-17.6081; -3.12802; 0.014307];
Tra2 = [-13.8177; 0.726613; 0.116081];
Rot = (Rot2'*Rot1);
Tra = Rot2'*(Tra1-Tra2);

%camera 2 base
xrot = Rot*[1;0;0];
yrot = Rot*[0;1;0];
zrot = Rot*[0;0;1];

width = 1;
f1 = K(1,1)/size(im1,2);
f2 = f1;
height = f1*size(im1,1) / K(2,2);


%Selection of a couple of points
figure(3)
imshow (im2);
[x1,y1,button1] = ginput(1);
imshow (im1);
[x2,y2,button2] = ginput(1);
%image points
m1Pix = [x1;y1;1];
m2Pix = [x2;y2;1];


%Cameras centers
c1 = [0;0;0];
c2 = Tra;
%Center of image 1
F1 = [0;0;f1];
%Center of image 2
F2 = c2+ f2*Rot(:,3);

%image Planes
p1 = [F1(1)-width/2;F1(2)-height/2;F1(3)];
p2 = [F1(1)+width/2;F1(2)-height/2;F1(3)];
p3 = [F1(1)+width/2;F1(2)+height/2;F1(3)];
p4 = [F1(1)-width/2;F1(2)+height/2;F1(3)];
%Image planes
p12 = F2 + Rot*[-width/2;-height/2;0];
p22 = F2 + Rot*[width/2;-height/2;0];
p32 = F2 + Rot*[width/2;height/2;0];
p42 = F2 + Rot*[-width/2;height/2;0];
p11 = Rot'*(p12-Tra);
p21 = Rot'*(p22-Tra);
p31 = Rot'*(p32-Tra);
p41 = Rot'*(p42-Tra);


%useful for image display
Px =[p1(1) p2(1) p3(1) p4(1)];
Px1 = [p11(1) p21(1) p31(1) p41(1)];
Px2 = [dot(p12,xrot) dot(p22,xrot) dot(p32,xrot) dot(p42,xrot)];
Py = [p1(2) p2(2) p3(2) p4(2)];
Py1 = [p11(2) p21(2) p31(2) p41(2)];
Py2 = [dot(p12,yrot) dot(p22,yrot) dot(p32,yrot) dot(p42,yrot)];
xmin = min (Px);
xmax = max (Px);
ymin = min(Py);
ymax = max (Py);
xmin2 = min (Px1);
xmax2 = max (Px1);
ymin2 = min(Py1);
ymax2 = max (Py1);
xImage = [xmin xmax;xmin xmax];
yImage=[ymin ymin; ymax ymax];
zImage = [f1 f1;f1 f1];
xImage2 = [p12(1) p22(1); p42(1),p32(1)];
yImage2 = [p12(2) p22(2); p42(2),p32(2)];
zImage2 = [p12(3) p22(3); p42(3),p32(3)];

%image points
m1 = [xmin+(xmax-xmin)*(x1-1)/(size(im1,2)-1);ymin+(ymax-ymin)*(y1-1)/(size(im1,1)-1);f1];
m2 = [xmin2+(xmax2-xmin2)*(x2-1)/(size(im1,2)-1);ymin2+(ymax2-ymin2)*(y2-1)/(size(im1,1)-1);f1];
m2 = Rot*m2+Tra;

%Lines

M1 = c1+10*(m1-c1);
M2 = c2+10*(m2-c2);

% Find closest points
distmin = Inf;
for i = 1:1000
    for j = 1:1000
        Point1 = ((i-1)/999)*M1+(1-(i-1)/999)*m1;
        Point2 = ((j-1)/999)*M2+(1-(j-1)/999)*m2;
        
        dist = sqrt((Point1(1)-Point2(1))^2+(Point1(2)-Point2(2))^2+(Point1(3)-Point2(3))^2);
        if dist < distmin
            distmin = dist;
            besti=i;
            bestj=j;
        end
    end
end
% Choose the middle of the two points
M = (((besti-1)/999)*M1+(1-(besti-1)/999)*m1+((bestj-1)/999)*M2+(1-(bestj-1)/999)*m2)/2;

%Plot the 3D figure
clf
figure(2)
%x,y view
view(0,-270);

xlabel('X');
ylabel('Y');
zlabel('Z');
hold on;
rotate3d on;
%image display
surface(xImage,yImage,zImage,'CData',im2,'FaceColor','texturemap');
surface(xImage2,yImage2,zImage2,'CData',im1,'FaceColor','texturemap');


plot3([c1(1), m1(1), M(1)], [c1(2) m1(2) M(2)],[c1(3) m1(3) M(3)],'+');
plot3([p4(1) p1(1), p2(1), p3(1), p4(1)], [p4(2) p1(2) p2(2), p3(2), p4(2)],[p4(3) p1(3) p2(3), p3(3), p4(3)],'-','color','g');
plot3([p42(1) p12(1), p22(1), p32(1), p42(1)], [p42(2) p12(2) p22(2), p32(2), p42(2)],[p42(3) p12(3) p22(3), p32(3), p42(3)],'-','color','g');
% Plot image points
plot3([c1(1) m1(1) M1(1)], [c1(2) m1(2) M1(2)],[c1(3) m1(3) M1(3)],'-','color','b');
plot3([c2(1) m2(1)], [c2(2) m2(2)],[c2(3) m2(3)],'+');
plot3([c2(1) m2(1) M2(1)], [c2(2) m2(2) M2(2)],[c2(3) m2(3) M2(3)],'-','color','b');
plot3([c1(1) c2(1)], [c1(2) c2(2)], [c1(3) c2(3)],'+');
plot3([c1(1) c2(1)], [c1(2) c2(2)], [c1(3) c2(3)],'-','color',[0 0 0]);
%Point names
text(c1(1),c1(2),c1(3),'c1');
text(m1(1),m1(2),m1(3),'m1');
text(c2(1),c2(2),c2(3),'c2');
text(m2(1),m2(2),m2(3),'m2');
text(M(1),M(2), M(3),'M');