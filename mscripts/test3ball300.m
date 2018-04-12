% test hole on ball300
% clear;clc;
addpath(genpath('./toolbox'));
load('ball_mesh300.mat');


%% one ball hole
vidx=[4 42 43 93 94 126 128 153 177 180 184 187 202 255 171 162 ]; % 162 178
idx=[];
for i=1:size(face,1)    
    if ~isempty(intersect(face(i,:),vidx))
        idx=[idx;i];
    end
end

vertex_m=vertex;
face_m=face;
face_m(idx,:)=[];
% show_mesh(face_m,vertex_m);
%% two-ring ball hole

vidx=[vidx 206 299 218 113 227];
idx=[];
for i=1:size(face,1)    
    if ~isempty(intersect(face(i,:),vidx))
        idx=[idx;i];
    end
end

vertex_m=vertex;
face_m=face;
face_m(idx,:)=[];
% show_mesh(face_m,vertex_m);
%%
face=face_m;
vertex=vertex_m;
% show_mesh(face,vertex);


vertex_c=vertex;
face_c=face;
outer_surface=face_c;
nv=size(vertex,1);
ol=zeros(nv,1);
idx=unique(face(:));
ol(idx)=1;

A = triangulation2adjacency(face,vertex);
adj_list = adjmatrix2list(A);

%%
idx=[];
idx2=[];
nface=size(face,1);
for i=1:nface
    if min(vertex_m(face_m(i,:),3))>-0.3
        idx=[idx;i];
    else
        idx2=[idx2;i];        
    end
end
face_h=face_m(idx,:);
face_h2=face_m(idx2,:);
figure;
hold off
trisurf(face_h,vertex_m(:,1),vertex_m(:,2),vertex_m(:,3));
% ,'facecolor','blue'
axis([-2 2 -2 2 -2 2]);
% axis([-15 15 -15 15 -15 15]);
grid off
view([-90 80])
hold on;
trisurf(face_h2,vertex_m(:,1),vertex_m(:,2),vertex_m(:,3));
% ,'facecolor','blue'

