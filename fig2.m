% clear;
close all;

%%New version: to move M, just clic on the figure where M should be placed,
%%then press return. Press return without clic to finish. Then the figure
%%can be rotated
 Rot1 = [0.14139 0.153155 0.978035;0.989608 -0.0479961 -0.135547; 0.0261821 0.987036 -0.15835 ];
 Rot2 = [0.494514 0.150712 0.856003;0.869109 -0.0974071 -0.484935; 0.0102952 0.983767 -0.179154 ];
 Tra1 = [-17.6081; -3.12802; 0.014307];
 Tra2 = [-13.8177; 0.726613; 0.116081];
 Rot = (Rot2'*Rot1);
 Tra = Rot2'*(Tra1-Tra2);
%parameters
f1 =K(1,1)/1000;
f2 = K(2,2)/1000;
%f1 = 2.75948;

width = 3.072;
heigth = 2.048;

xrot = Rot*[1;0;0];
yrot = Rot*[0;1;0];
zrot = Rot*[0;0;1];

M1 = [4; 0; 30];
c1 = [0;0;0];
c2 = Tra;
F1 = [0;0;f1];
Mw = Rot1*M1+Tra1;
%cw = Rot1*c1+Tra1;
M2 = Rot2'*(Mw-Tra2);
%c2 = Rot2'*(M2-Tra2);
M = M1;
m1 = (M-c1)/norm(M-c1);
m1=m1*f1/(m1(3));
%F2 = c2 - (f2/f1)*Rot*F1;
F2 = c2+ f2*Rot(:,3);
e1 = (c2-c1)/norm(c2-c1);
e1=e1*f1/(e1(3));

m2 = (M-c2)/norm(M-c2);
m2=Tra +m2*f2/dot(m2,zrot);

e2 = (c1-c2)/norm(c1-c2);
e2 = Tra-e2*f2/dot(e2,zrot);

%Planes
p1 = [F1(1)-width/2;F1(2)-heigth/2;F1(3)];
p2 = [F1(1)+width/2;F1(2)-heigth/2;F1(3)];
p3 = [F1(1)+width/2;F1(2)+heigth/2;F1(3)];
p4 = [F1(1)-width/2;F1(2)+heigth/2;F1(3)];

p12 = F2 + Rot*[-width/2;-heigth/2;0];
p22 = F2 + Rot*[width/2;-heigth/2;0];
p32 = F2 + Rot*[width/2;heigth/2;0];
p42 = F2 + Rot*[-width/2;heigth/2;0];
Px =[p1(1) p2(1) p3(1) p4(1)];
Px2 = [dot(p12,xrot) dot(p22,xrot) dot(p32,xrot) dot(p42,xrot)];
Py = [p1(2) p2(2) p3(2) p4(2)];
Py2 = [dot(p12,yrot) dot(p22,yrot) dot(p32,yrot) dot(p42,yrot)];
%xmin2()
xmin = min (Px);
xmax = max (Px);
ymin = min(Py);
ymax = max (Py);
xImage = [xmin xmax;xmin xmax];
yImage=[ymin ymin; ymax ymax];
zImage = [f1 f1;f1 f1];
xImage2 = [p12(1) p22(1); p42(1),p32(1)];
yImage2 = [p12(2) p22(2); p42(2),p32(2)];
zImage2 = [p12(3) p22(3); p42(3),p32(3)];

%check m2 is in the rectangle
m2_in_image = abs(dot (m2-F2,xrot))<=width/2 && abs(dot (m2-F2,yrot))<=heigth/2;



epipolar_lane1 = [m1 e1];
epipolar_lane2 = [m2 e2];
% %plot
while true
    clf
    figure(1)
    view(0,-270);
    
    
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    hold on;
    rotate3d on;
    
    surface(xImage,yImage,zImage,'CData',im2,'FaceColor','texturemap');
    surface(xImage2,yImage2,zImage2,'CData',im1,'FaceColor','texturemap');
    plot3(F1(1),F1(2),F1(3),'+','color','r');
    
    plot3([c1(1), m1(1), M(1) e1(1) ], [c1(2) m1(2) M(2) e1(2)],[c1(3) m1(3), M(3) e1(3)],'+');
    plot3([p4(1) p1(1), p2(1), p3(1), p4(1)], [p4(2) p1(2) p2(2), p3(2), p4(2)],[p4(3) p1(3) p2(3), p3(3), p4(3)],'-','color','g');
    plot3([p42(1) p12(1), p22(1), p32(1), p42(1)], [p42(2) p12(2) p22(2), p32(2), p42(2)],[p42(3) p12(3) p22(3), p32(3), p42(3)],'-','color','g');
    if (abs(F1(1)-m1(1))<=width/2 && abs(F1(2)-m1(2))<=heigth/2)
        plot3([c1(1) m1(1), M(1)], [c1(2) m1(2), M(2)],[c1(3) m1(3), M(3)],'-','color','b');
    end
    plot3([c2(1) m2(1), M(1)], [c2(2) m2(2), M(2)],[c2(3) m2(3), M(3)],'+');
    if m2_in_image
        plot3([c2(1) m2(1), M(1)], [c2(2) m2(2), M(2)],[c2(3) m2(3), M(3)],'-','color','b');
    end
    plot3([c1(1) c2(1)], [c1(2) c2(2)], [c1(3) c2(3)],'+');
    plot3([c1(1) c2(1)], [c1(2) c2(2)], [c1(3) c2(3)],'-','color',[0 0 0]);
    
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
    
    for i = 1:floor(norm(M-[x;y;M(3)])/0.5)
        j = (i-1)/(floor(norm(M-[x;y;M(3)])/0.5)-1);
        Mtemp = ((1-j)*M+j*[x;y;M(3)]);
        
        m1 = (Mtemp-c1)/norm(Mtemp-c1);
        m1=m1*f1/m1(3);
        m2 = (Mtemp-c2)/norm(Mtemp-c2);
        m2=Tra+m2*f2/dot(m2,zrot);
        epipolar_lane1 = [m1 e1];
        epipolar_lane2 = [m2 e2];
        clf;
        figure(1)
        axis ([-5 10 -3 10 -3 10]);
        view(0,-270);
        hold on;
        rotate3d on;
        
        plot3([c1(1), m1(1), Mtemp(1) e1(1)], [c1(2) m1(2), Mtemp(2) e1(2)],[c1(3) m1(3), Mtemp(3) e1(3)],'+');
        plot3([p4(1) p1(1), p2(1), p3(1), p4(1)], [p4(2) p1(2) p2(2), p3(2), p4(2)],[p4(3) p1(3) p2(3), p3(3), p4(3)],'-','color','g');
        plot3([p42(1) p12(1), p22(1), p32(1), p42(1)], [p42(2) p12(2) p22(2), p32(2), p42(2)],[p42(3) p12(3) p22(3), p32(3), p42(3)],'-','color','g');
        if (abs(F1(1)-m1(1))<=width/2 && abs(F1(2)-m1(2))<=heigth/2)
            plot3([c1(1) m1(1), Mtemp(1)], [c1(2) m1(2), Mtemp(2)],[c1(3) m1(3), Mtemp(3)],'-','color','b');
        end
        m2_in_image = abs(dot (m2-F2,xrot))<=width/2 && abs(dot (m2-F2,yrot))<=heigth/2;
        
        if m2_in_image
            plot3([c2(1) m2(1), Mtemp(1)], [c2(2) m2(2), Mtemp(2)],[c2(3) m2(3), Mtemp(3)],'-','color','b');
        end
        plot3([c2(1) m2(1),Mtemp(1)], [c2(2) m2(2), Mtemp(2)],[c2(3) m2(3), Mtemp(3)],'+');
        
        plot3([c1(1) c2(1)], [c1(2) c2(2)], [c1(3) c2(3)],'+');
        plot3([c1(1) c2(1)], [c1(2) c2(2)], [c1(3) c2(3)],'-','color',[0 0 0]);
        surface(xImage,yImage,zImage,'CData',im1,'FaceColor','texturemap');
        surface(xImage2,yImage2,zImage2,'CData',im2,'FaceColor','texturemap');
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
    m2 = (M-c2)/norm(M-c2);
    m2=Tra+m2*f2/dot(m2,zrot);
    
    clf;
end
clf
figure(1)
axis ([-5 10 -3 10 -3 10]);
view(0,-270);
xlabel('X');
ylabel('Y');
zlabel('Z');
hold on;
rotate3d on;
m2_in_image = abs(dot (m2-F2,xrot))<=width/2 && abs(dot (m2-F2,yrot))<=heigth/2;

plot3([c1(1), m1(1), M(1) e1(1) ], [c1(2) m1(2) M(2) e1(2)],[c1(3) m1(3), M(3) e1(3)],'+');
plot3([p4(1) p1(1), p2(1), p3(1), p4(1)], [p4(2) p1(2) p2(2), p3(2), p4(2)],[p4(3) p1(3) p2(3), p3(3), p4(3)],'-','color','g');
plot3([p42(1) p12(1), p22(1), p32(1), p42(1)], [p42(2) p12(2) p22(2), p32(2), p42(2)],[p42(3) p12(3) p22(3), p32(3), p42(3)],'-','color','g');
if (abs(F1(1)-m1(1))<=width/2 && abs(F1(2)-m1(2))<=heigth/2)
    plot3([c1(1) m1(1), M(1)], [c1(2) m1(2), M(2)],[c1(3) m1(3), M(3)],'-','color','b');
end
plot3([c2(1) m2(1), M(1)], [c2(2) m2(2), M(2)],[c2(3) m2(3), M(3)],'+');
surface(xImage,yImage,zImage,'CData',im1,'FaceColor','texturemap');
surface(xImage2,yImage2,zImage2,'CData',im2,'FaceColor','texturemap');
if m2_in_image
    plot3([c2(1), m2(1), M(1)], [c2(2) m2(2), M(2)],[c2(3) m2(3), M(3)],'-','color','b');
end
plot3([c1(1) c2(1)], [c1(2) c2(2)], [c1(3) c2(3)],'+');
plot3([c1(1) c2(1)], [c1(2) c2(2)], [c1(3) c2(3)],'-',color,[0 0 0]);
text(c1(1),c1(2),c1(3),'c1');
text(m1(1),m1(2),m1(3),'m1');
text(M(1),M(2),M(3),'M');
text(c2(1),c2(2),c2(3),'c2');
text(m2(1),m2(2),m2(3),'m2');xlabel('X');
ylabel('Y');
zlabel('Z');