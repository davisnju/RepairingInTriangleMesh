function [vertex,face]=create_defected_cylinder_sample(r, h,BO,factor,vertical_pn,circle_pn)
% create_defected_cylinder_sample - compute cylinder sample vertex and delaunay face
%
%   [vertex,face]=create_defected_cylinder_sample(r, h,BO,factor,vertical_pn,circle_pn)
%
%   BO is the center of bottom surface
%   factor stand for integrity of model
%   vertical_pn is num of vertical part
%   circle_pn is num of part the circle been decomposed

%Copyright (c) 2018 Wei Dai
vertex=[];
h=double(h);
k=30;
rk=r*0.9*rand(1,k);
seta=2*pi*rand(1,k);
x=rk.*cos(seta)+BO(1);
y=rk.*sin(seta)+BO(2);
z=BO(3)*ones(1,k);
bv=[x;y;z]';
tv=[x;y;z+h]';
vertex=[vertex;bv;];
n=20;
m=50;%0,1,..,19
hd=0;
m2=floor(m*factor)-1;%16, gap vertex can fill 1 level
ll=m;ul=-1;
gl=m-m2-1;%3
if factor<1.0
    %1 2 ... 16   % middle gap
    ll=unidrnd(m2);
    ul=ll+gl;
end

for i=0:1:m-1
    if i<ll || i>=ul
        seta=2*pi/n*(1+i*hd:1:n+i*hd);
        x=r.*cos(seta)+BO(1);
        y=r.*sin(seta)+BO(2);
        z=BO(3)*ones(1,n);
    else%ll<=i<ul
        if i==ll || i==(ul-1)
            n2=floor(n/3);
            r2=r*2/3;
        elseif i==ll+1 || i==ul-2
            n2=floor(n/6);
            r2=r/6;
        else
            n2=0;
            r2=r;
        end
        seta=2*pi/n2*(1+i*hd:1:n2+i*hd);
        x=r2.*cos(seta)+BO(1);
        y=r2.*sin(seta)+BO(2);
        z=BO(3)*ones(1,n2);
        
    end
    iv=[x' y' z'+i/(m-1)*h];
    vertex=[vertex; iv ];
end
vertex=[vertex;tv];

vt=[];
idx=[];
L=size(vt,1);
face=[];
for i=1:vertical_pn
    level_i_zmin=BO(3)+(i-1)*h/vertical_pn;
    level_i_zmax=BO(3)+i*h/vertical_pn + (i==vertical_pn);
    level_i_idx=find(vertex(:,3)>=level_i_zmin & vertex(:,3)<level_i_zmax);
    
    for ci=1:circle_pn
        angle_ci_thmin=(ci-1)*2*pi/circle_pn-pi;
        angle_ci_thmax=(ci)*2*pi/circle_pn-pi+(ci==circle_pn);
        angle_ci_idx=find_cp(vertex(level_i_idx,:),angle_ci_thmin,angle_ci_thmax);
        
        
        idx=level_i_idx(angle_ci_idx);  
        L=size(vt,1);
        DT=delaunayTriangulation(vertex(idx,1),vertex(idx,2),vertex(idx,3));
        [K,~] = convexHull(DT);
        vt=[vt;DT.Points(:,:)];      
        face=[face;K+L];
    end
end
vertex=vt;
end
%%
% figure;
% hold on;
% trisurf(face,vertex(:,1),vertex(:,2),vertex(:,3));
% axis([-15 15 -15 15 -5 15]);
% view(0,0);