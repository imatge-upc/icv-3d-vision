clear;
close all;

%%New version: to move M, just clic on the figure where M should be placed,
%%then press return. Press return without clic to finish. Then the figure
%%can be rotated

%parameters
f1 =1;
f2 = 1;
heigth = 1;
width = 1;
Rot = [ 0 0 1;cos(pi/3) -sin(pi/3) 0; sin(pi/3) cos(pi/3) 0];
xrot = Rot*[1;0;0];
yrot = Rot*[0;1;0];
zrot = Rot*[0;0;1];
M = [3; 3; 3];
c1 = [0;0;0];
c2= [5;5;0];
Tra = c2-c1;
m1 = f1*(M-c1)/norm(M-c1);
m2 = c2+f2*(M-c2)/norm(M-c2);

%Planes
p1 = [m1(1)-width/2;m1(2)-heigth/2;m1(3)];
p2 = [m1(1)+width/2;m1(2)-heigth/2;m1(3)];
p3 = [m1(1)+width/2;m1(2)+heigth/2;m1(3)];
p4 = [m1(1)-width/2;m1(2)+heigth/2;m1(3)];

p12 = [(m2(1)-width/2);m2(2)-heigth/2;m2(3)];
p22 = [m2(1)+width/2;m2(2)-heigth/2;m2(3)];
p32 = [m2(1)+width/2;m2(2)+heigth/2;m2(3)];
p42 = [m2(1)-width/2;m2(2)+heigth/2;m2(3)];

%plot
while true
figure(1)
hold on;
rotate3d on;

plot3([c1(1), m1(1), M(1)], [c1(2) m1(2), M(2)],[c1(3) m1(3), M(3)],'+');
plot3([p4(1) p1(1), p2(1), p3(1), p4(1)], [p4(2) p1(2) p2(2), p3(2), p4(2)],[p4(3) p1(3) p2(3), p3(3), p4(3)],'-');
plot3([p42(1) p12(1), p22(1), p32(1), p42(1)], [p42(2) p12(2) p22(2), p32(2), p42(2)],[p42(3) p12(3) p22(3), p32(3), p42(3)],'-');
plot3([c1(1) m1(1), M(1)], [c1(2) m1(2), M(2)],[c1(3) m1(3), M(3)],'-');
plot3([c2(1) m2(1), M(1)], [c2(2) m2(2), M(2)],[c2(3) m2(3), M(3)],'+');
plot3([c2(1) m2(1), M(1)], [c2(2) m2(2), M(2)],[c2(3) m2(3), M(3)],'-');
plot3([c1(1) c2(1)], [c1(2) c2(2)], [c1(3) c2(3)],'+');
plot3([c1(1) c2(1)], [c1(2) c2(2)], [c1(3) c2(3)],'-');
[x,y] = ginput;
if size(x,1) < 1
    break;
end
n = length(x);
M = [x(n);y(n);M(3)];
m1 = f1*(M-c1)/norm(M-c1);
m2 = c2+f2*(M-c2)/norm(M-c2);

%Planes
p1 = [m1(1)-width/2;m1(2)-heigth/2;m1(3)];
p2 = [m1(1)+width/2;m1(2)-heigth/2;m1(3)];
p3 = [m1(1)+width/2;m1(2)+heigth/2;m1(3)];
p4 = [m1(1)-width/2;m1(2)+heigth/2;m1(3)];

p12 = [(m2(1)-width/2);m2(2)-heigth/2;m2(3)];
p22 = [m2(1)+width/2;m2(2)-heigth/2;m2(3)];
p32 = [m2(1)+width/2;m2(2)+heigth/2;m2(3)];
p42 = [m2(1)-width/2;m2(2)+heigth/2;m2(3)];
clf;
end
clf
figure(1)
hold on;
rotate3d on;
if size(M,1) ~= 3
    break;
end
plot3([c1(1), m1(1), M(1)], [c1(2) m1(2), M(2)],[c1(3) m1(3), M(3)],'+');
plot3([p4(1) p1(1), p2(1), p3(1), p4(1)], [p4(2) p1(2) p2(2), p3(2), p4(2)],[p4(3) p1(3) p2(3), p3(3), p4(3)],'-');
plot3([p42(1) p12(1), p22(1), p32(1), p42(1)], [p42(2) p12(2) p22(2), p32(2), p42(2)],[p42(3) p12(3) p22(3), p32(3), p42(3)],'-');
plot3([c1(1) m1(1), M(1)], [c1(2) m1(2), M(2)],[c1(3) m1(3), M(3)],'-');
plot3([c2(1) m2(1), M(1)], [c2(2) m2(2), M(2)],[c2(3) m2(3), M(3)],'+');
plot3([c2(1) m2(1), M(1)], [c2(2) m2(2), M(2)],[c2(3) m2(3), M(3)],'-');
plot3([c1(1) c2(1)], [c1(2) c2(2)], [c1(3) c2(3)],'+');
plot3([c1(1) c2(1)], [c1(2) c2(2)], [c1(3) c2(3)],'-');