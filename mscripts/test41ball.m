% test 4-1 
% clear;clc;
addpath(genpath('./toolbox'));
load('res\test4-1\ball3.mat');
vertex=vertex_m;
name='ball-3-piece-3-hole';
npface=size(face_patch,1);
idx=[];
for i=1:npface
    if max(face_patch(i,:))<=300
        idx=[idx;i];
    end
end
face_patch2=face_patch;
face_patch2(idx,:)=[];
face=[face_o;
    face_patch2
    ];

nvert=size(vertex,1);
for i=301:nvert
    [th,r,z]=cart2pol(vertex(i,1),vertex(i,2),vertex(i,3));
    [x,y,z]=pol2cart(th,0.6*r,z);
    vertex(i,:)=[x,y,z];    
end
%% create sample
% load('ball_mesh300.mat');
% 
% vidx=[206 299 218 113 227 ...
%     4 42 43 93 94 126 128 153 177 180 184 187 202 255 171 162 178 ...
%     176 285 157  106 252 96 141 236 44 ...
%     278 269 7 201 30 123 281 28 146 272 86 134 38 169]; 
vidx=[131 233 283];
idx=[];
for i=1:size(face,1)    
    if ~isempty(intersect(face(i,:),vidx))
        idx=[idx;i];
    end
end

vertex_m=vertex;
face_m=face;
face_m(idx,:)=[];

%
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

%
idx=[];
idx2=[];
nface=size(face,1);
for i=1:nface
%     if min(vertex_m(face_m(i,:),3))>-0.3
    if max(face_m(i,:))>300
        idx=[idx;i];
    else
        idx2=[idx2;i];        
    end
end
face_h=face_m(idx,:);
face_h2=face_m(idx2,:);
figure(1);
hold off
trisurf(face_h2,vertex_m(:,1),vertex_m(:,2),vertex_m(:,3) ...
    ,'facecolor','blue');
% 
axis([-2 2 -2 2 -2 2]);
% axis([-15 15 -15 15 -15 15]);
grid off
view([-90 80])
hold on;
trisurf(face_h,vertex_m(:,1),vertex_m(:,2),vertex_m(:,3) ...
    ,'facecolor','y');
% 
%%
% vertex=vertex_m;
% face=face_m;
% save test41ball3.mat vertex face