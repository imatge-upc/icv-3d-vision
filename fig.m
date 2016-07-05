clear;
close all;

%%New version: to move M, just clic on the figure where M should be placed,
%%then press return. Press return without clic to finish. Then the figure
%%can be rotated

%parameters
f1 =0.5;
f2 = 0.15;
heigth = 1.2;
width = 2;
Rot = [ 0 0 1;cos(pi/3) -sin(pi/3) 0; sin(pi/3) cos(pi/3) 0];
% xrot = Rot*[1;0;0];
% yrot = Rot*[0;1;0];
% zrot = Rot*[0;0;1];
M = [1; 2; 4];
c1 = [0;0;0];
F1 = [0;0;f1];
Tra= [3;1;4];
c2 = c1+Tra;
M2 = Rot*M+Tra;
m1 = (M-c1)/norm(M-c1);
m1=m1*f1/(m1(3));
F2 = c2 - (f2/f1)*Rot*F1;
e1 = (c2-c1)/norm(c2-c1);
e1=e1*f1/(e1(3));
lambda = (f2)/(c2(1)-M(1));
%m2 = inv(Rot)*(m1-Tra)
m2 = lambda*M+(1-lambda)*c2;
% m2=(M2-c2)/norm(M2-c2);
% m2=m2*f2/(m2(1));
% m2 = Rot\(m2-Tra);
%m2 = -Rot*m1+Tra;
lambda2 = (f2)/(c2(1)-c1(1));
e2= lambda*c1 + (1-lambda2)*c2;
%Planes
p1 = [F1(1)-width/2;F1(2)-heigth/2;F1(3)];
p2 = [F1(1)+width/2;F1(2)-heigth/2;F1(3)];
p3 = [F1(1)+width/2;F1(2)+heigth/2;F1(3)];
p4 = [F1(1)-width/2;F1(2)+heigth/2;F1(3)];

p12 = F2 - Rot*[width/2;heigth/2;0];
p22 = F2 - Rot*[-width/2;heigth/2;0];
p32 = F2 + Rot*[width/2;heigth/2;0];
p42 = F2 - Rot*[width/2;-heigth/2;0];
m2_visible = (dot(m2-p12,p42-p12)>=0 && dot(m2-p42,p32-p12)>=0 && dot(m2-p32,p22-p32)>=0);

epipolar_lane1 = [m1 e1];
epipolar_lane2 = [m2 e2];
% %plot
while true
    clf
    figure(1)
    view(-90,-90);
    axis([-1 6 -1 6 -1 6])
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    hold on;
    rotate3d on;
    plot3(F1(1),F1(2),F1(3),'+','color','r');
    
    plot3([c1(1), m1(1), M(1) e1(1) ], [c1(2) m1(2) M(2) e1(2)],[c1(3) m1(3), M(3) e1(3)],'+');
    plot3([p4(1) p1(1), p2(1), p3(1), p4(1)], [p4(2) p1(2) p2(2), p3(2), p4(2)],[p4(3) p1(3) p2(3), p3(3), p4(3)],'-','color','g');
    plot3([p42(1) p12(1), p22(1), p32(1), p42(1)], [p42(2) p12(2) p22(2), p32(2), p42(2)],[p42(3) p12(3) p22(3), p32(3), p42(3)],'-','color','g');
    if (abs(F1(1)-m1(1))<=width/2 && abs(F1(2)-m1(2))<=heigth/2)
        plot3([c1(1) m1(1), M(1)], [c1(2) m1(2), M(2)],[c1(3) m1(3), M(3)],'-','color','b');
    end
    plot3([c2(1) m2(1), M(1)], [c2(2) m2(2), M(2)],[c2(3) m2(3), M(3)],'+');
    if m2_visible
        plot3([c2(1) m2(1), M(1)], [c2(2) m2(2), M(2)],[c2(3) m2(3), M(3)],'-','color','b');
    end
    plot3([c1(1) c2(1)], [c1(2) c2(2)], [c1(3) c2(3)],'+');
    plot3([c1(1) c2(1)], [c1(2) c2(2)], [c1(3) c2(3)],'-','color',[0 0 0]);
    plot3(epipolar_lane1(1,:),epipolar_lane1(2,:),epipolar_lane1(3,:),'-','color','r');
    plot3(epipolar_lane2(1,:),epipolar_lane2(2,:),epipolar_lane2(3,:),'-','color','r');
    text(c1(1),c1(2),c1(3),'c1');
    text(m1(1),m1(2),m1(3),'m1');
    text(M(1),M(2),M(3),'M');
    text(c2(1),c2(2),c2(3),'c2');
    text(m2(1),m2(2),m2(3),'m2');
    
    pause();
    [x,y] = ginput;
    if size(x,1) < 1
        break;
    end
    
    for i = 1:floor(norm(M-[x;y;M(3)])/0.2)
        j = (i-1)/(floor(norm(M-[x;y;M(3)])/0.2)-1);
        Mtemp = ((1-j)*M+j*[x;y;M(3)]);
        lambda = (f2)/(c2(1)-Mtemp(1));
        m2 = lambda*Mtemp + (1-lambda)*c2;
        m1 = (Mtemp-c1)/norm(Mtemp-c1);
        m1=m1*f1/m1(3);
        epipolar_lane1 = [m1 e1];
        epipolar_lane2 = [m2 e2];
        clf;
        figure(1)
        axis ([-1 6 -1 6 -1 6]);
        view(-90,-90);
        hold on;
        rotate3d on;
        
        plot3([c1(1), m1(1), Mtemp(1) e1(1)], [c1(2) m1(2), Mtemp(2) e1(2)],[c1(3) m1(3), Mtemp(3) e1(3)],'+');
        plot3([p4(1) p1(1), p2(1), p3(1), p4(1)], [p4(2) p1(2) p2(2), p3(2), p4(2)],[p4(3) p1(3) p2(3), p3(3), p4(3)],'-','color','g');
        plot3([p42(1) p12(1), p22(1), p32(1), p42(1)], [p42(2) p12(2) p22(2), p32(2), p42(2)],[p42(3) p12(3) p22(3), p32(3), p42(3)],'-','color','g');
        if (abs(F1(1)-m1(1))<=width/2 && abs(F1(2)-m1(2))<=heigth/2)
            plot3([c1(1) m1(1), Mtemp(1)], [c1(2) m1(2), Mtemp(2)],[c1(3) m1(3), Mtemp(3)],'-','color','b');
        end
        m2_visible = (dot(m2-p12,p42-p12)>=0 && dot(m2-p42,p32-p12)>=0 && dot(m2-p32,p22-p32)>=0);
        if m2_visible
            plot3([c2(1) m2(1), Mtemp(1)], [c2(2) m2(2), Mtemp(2)],[c2(3) m2(3), Mtemp(3)],'-','color','b');
        end
        plot3([c2(1) m2(1),Mtemp(1)], [c2(2) m2(2), Mtemp(2)],[c2(3) m2(3), Mtemp(3)],'+');
        
        plot3([c1(1) c2(1)], [c1(2) c2(2)], [c1(3) c2(3)],'+');
        plot3([c1(1) c2(1)], [c1(2) c2(2)], [c1(3) c2(3)],'-','color',[0 0 0]);
        plot3(epipolar_lane1(1,:),epipolar_lane1(2,:),epipolar_lane1(3,:),'-','color','r');
        plot3(epipolar_lane2(1,:),epipolar_lane2(2,:),epipolar_lane2(3,:),'-','color','r');
        text(c1(1),c1(2),c1(3),'c1');
        text(m1(1),m1(2),m1(3),'m1');
        text(Mtemp(1),Mtemp(2),Mtemp(3),'M');
        text(c2(1),c2(2),c2(3),'c2');
        text(m2(1),m2(2),m2(3),'m2');
        pause(0.25);
    end
    
    n = length(x);
    M = [x(n);y(n);M(3)];
    m1 = (M-c1)/norm(M-c1);
    m1=m1*f1/m1(3);
    lambda = (f2)/(c2(1)-M(1));
    m2 = lambda*M + (1-lambda)*c2;
    
    clf;
end
clf
figure(1)
axis ([-1 6 -1 6 -1 6]);
view(-90,-90);
xlabel('X');
ylabel('Y');
zlabel('Z');
hold on;
rotate3d on;

plot3([c1(1), m1(1), M(1) e1(1) ], [c1(2) m1(2) M(2) e1(2)],[c1(3) m1(3), M(3) e1(3)],'+');
plot3([p4(1) p1(1), p2(1), p3(1), p4(1)], [p4(2) p1(2) p2(2), p3(2), p4(2)],[p4(3) p1(3) p2(3), p3(3), p4(3)],'-','color','g');
plot3([p42(1) p12(1), p22(1), p32(1), p42(1)], [p42(2) p12(2) p22(2), p32(2), p42(2)],[p42(3) p12(3) p22(3), p32(3), p42(3)],'-','color','g');
if (abs(F1(1)-m1(1))<=width/2 && abs(F1(2)-m1(2))<=heigth/2)
    plot3([c1(1) m1(1), M(1)], [c1(2) m1(2), M(2)],[c1(3) m1(3), M(3)],'-','color','b');
end
plot3([c2(1) m2(1), M(1)], [c2(2) m2(2), M(2)],[c2(3) m2(3), M(3)],'+');
if m2_visible
    plot3([c2(1) m2(1), M(1)], [c2(2) m2(2), M(2)],[c2(3) m2(3), M(3)],'-','color','b');
end
plot3([c1(1) c2(1)], [c1(2) c2(2)], [c1(3) c2(3)],'+');
plot3([c1(1) c2(1)], [c1(2) c2(2)], [c1(3) c2(3)],'-',color,[0 0 0]);
plot3(epipolar_lane1(1,:),epipolar_lane1(2,:),epipolar_lane1(3,:),'-','color','r');
plot3(epipolar_lane2(1,:),epipolar_lane2(2,:),epipolar_lane2(3,:),'-','color','r');
text(c1(1),c1(2),c1(3),'c1');
text(m1(1),m1(2),m1(3),'m1');
text(M(1),M(2),M(3),'M');
text(c2(1),c2(2),c2(3),'c2');
text(m2(1),m2(2),m2(3),'m2');xlabel('X');
ylabel('Y');
zlabel('Z');