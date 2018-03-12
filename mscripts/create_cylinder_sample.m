function [vertex,face]=create_cylinder_sample(r, h,BO,factor)

% create_cylinder_sample - compute cylinder sample vertex and delaunay face
%
%   [vertex,face]=create_cylinder_sample(r, h,BO,factor)
%
%   BO is the center of bottom surface
%   factor stand for integrity of model

%   Copyright (c) 2018 Wei Dai

vertex=[];
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
m=20;%0,1,..,19
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


if gl>3
    llz=BO(3)+(ll+1)*h/(m-1);
    ulz=BO(3)+(ul-2)*h/(m-1);
    lower_part=vertex(:,3)<=llz;
    higher_part=vertex(:,3)>=ulz;
    DT_lower = delaunayTriangulation(vertex(lower_part,1),vertex(lower_part,2),vertex(lower_part,3));
    DT_higher = delaunayTriangulation(vertex(higher_part,1),vertex(higher_part,2),vertex(higher_part,3));
    
    [K,~] = convexHull(DT_lower);
    vt=DT_lower.Points(:,:);
    face=K;
    L=size(vt,1);    
    [K,~] = convexHull(DT_higher);    
    vt=[vt;DT_higher.Points(:,:)];
    face=[face;K+L];
    vertex=vt;
else
    DT=delaunayTriangulation(vertex(:,1),vertex(:,2),vertex(:,3));
    [K,~] = convexHull(DT);
    vertex=DT.Points(:,:);
    face=K;
end

end