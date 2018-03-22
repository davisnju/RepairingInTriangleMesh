function [vertex,face]=create_ball_sample(r, BO, factor)

% create_ball_sample - compute ball sample vertex and delaunay face
%
%   [vertex,face]=create_ball_sample(r, BO, factor)
%
%   BO is the center of bottom surface
%   factor stand for integrity of model

%   Copyright (c) 2018 Wei Dai
r=5;BO=[0 0 0];
vertex=[];
k=30;

% help sph2cart
elevation=2*pi*rand(1,k);
for i=1:k
    k2=floor(k*cos(elevation(i))+1);
    azimuth=2*pi*rand(1,k2);
    x = r * cos(elevation(i)) * cos(azimuth) + BO(1);
    y = r * cos(elevation(i)) * sin(azimuth) + BO(2);
    z = r * sin(elevation(i)) + BO(3);
    z = z * ones(1,k2);
    
    bv=[x;y;z]';
    %     bv=bv(bv(:,3) < 4.6,:);
    vertex=[vertex; bv;];
end
vertex=uniquetol(vertex,'ByRows',true);

DT=delaunayTriangulation(vertex(:,1),vertex(:,2),vertex(:,3));
[K,~] = convexHull(DT);
vertex_inside=DT.Points(:,:);
face_inside=K;
face_inside_len=size(face_inside,1);
idx=[];
th=max(vertex_inside(:,3))-0.01;
for i=1:face_inside_len
    if max(vertex_inside(face_inside(i,:),3))>th
        idx=[idx;i];
    end
end
face_inside(idx,:)=[];

vertex=[];
r=1.2*r;
for i=1:k
    k2=floor(k*cos(elevation(i))+1);
    azimuth=2*pi*rand(1,k2);
    x = r * cos(elevation(i)) * cos(azimuth) + BO(1);
    y = r * cos(elevation(i)) * sin(azimuth) + BO(2);
    z = r * sin(elevation(i)) + BO(3);
    z = z * ones(1,k2);
    
    bv=[x;y;z]';
    %     bv=bv(bv(:,3) < 5.671,:);
    vertex=[vertex; bv;];
end
vertex=uniquetol(vertex,'ByRows',true);

DT=delaunayTriangulation(vertex(:,1),vertex(:,2),vertex(:,3));
[K,~] = convexHull(DT);
vertex_outside=DT.Points(:,:);
face_outside=K;
face_outside_len=size(face_outside,1);
idx=[];
th=max(vertex_outside(:,3))-0.01;
for i=1:face_outside_len
    if max(vertex_outside(face_outside(i,:),3))>th
        idx=[idx;i];
    end
end
face_outside(idx,:)=[];

vertex=[vertex_inside;vertex_outside];
face=[face_inside;face_outside+size(vertex_inside,1)];

show_mesh(face,vertex);

% load('ball_sample.mat')
l1=size(vertex_inside,1);
[num,~]=sort(unique(vertex_inside(:,3)));
top_th=num( find(num>4.89, 1 )-1);
% top_th=max(num)-0.1;
idx1=[];
for i=1:l1
    v_in=vertex_inside(i,:);
    if float_eq(v_in(3),top_th,0.01)
        idx1=[idx1;i];
%         X=vertex_outside(:,:)-v_in;
%         d=sum(abs(X).^2,2).^(1/2);
%         [~,idx]=sort(d);
%         face=[face;i idx(1)+l1 idx(2)+l1;];
    end
end

l2=size(vertex_outside,1);
[num,~]=sort(unique(vertex_outside(:,3)));
top_th=num( find(num>5.866, 1 )-1);
% top_th=max(num)-0.1;
idx2=[];
for i=1:l2
    v_out=vertex_outside(i,:);
    if float_eq(v_out(3),top_th,0.01)
        idx2=[idx2;i];
%         X=vertex_inside(:,:)-v_out;
%         d=sum(abs(X).^2,2).^(1/2);
%         [~,idx]=sort(d);
%         face=[face;i+l1 idx(1) idx(2);];
    end
end
vertex_t=vertex([idx1 idx2+l1],:);

DT=delaunayTriangulation(vertex_t(:,1),vertex_t(:,2),vertex_t(:,3));
[K,~] = convexHull(DT);
vertex_between=DT.Points(:,:);
face_between=K;
face_between_len=size(face_between,1);
idx=[];
th1=max(vertex_between(:,3))-0.01;
th2=min(vertex_between(:,3))+0.01;
for i=1:face_between_len
    fz=vertex_between(face_between(i,:),3);
    if mean(fz)>th1 || mean(fz)<th2
        idx=[idx;i];
    end    
end
face_between(idx,:)=[];
show_mesh(face_between,vertex_between);

face_between_t=face_between;

face_between_len=size(face_between_t,1);
% li1=length(idx1);
for i=1:face_between_len
    for j=1:3
        v=vertex_between(face_between(i,j),:);
        [~,id,~]=intersect(vertex,v,'rows');
        face_between_t(i,j)=id;
%         i1=face_between_t(i,j);
%         if i1<=li1
%             face_between_t(i,j)=idx1(i1);
%         else
%             face_between_t(i,j)=idx2(i1-li1);
%         end
%         display([num2str(i) ' ' num2str(j) ':' num2str(i1) ...
%             '->' num2str(face_between_t(i,j))]);
    end
end
face_t=[face;face_between_t];
show_mesh(face_t,vertex);

face=face_t;
end