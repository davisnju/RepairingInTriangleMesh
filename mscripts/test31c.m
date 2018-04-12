% complex planar hole
% clear;clc;
addpath(genpath('./toolbox'));

x = gallery('uniformdata',[1 100],0);
y = gallery('uniformdata',[1 100],1);
tri = delaunay(x,y);
z=zeros(100,1);
vertex=[x' y' z];
face=tri;

nvert=size(vertex,1);
nface=size(face,1);
vertex_m=vertex;
face_m=face;
% vidx=[15 26 88 68 53 48 70 96 66 76 79 23]; % zigzag hole
% ====== island hole
vidx=[2 55 15 85 27 68 44 67 72]; 
vertex_m(8,:)=vertex_m(8,:)+[0.07 0.1 0];
vertex_m(21,:)=vertex_m(21,:)+[0.07 0.0 0];
vertex_m(95,:)=vertex_m(95,:)+[-0.04 0.0 0];
% ====== 

idx=[];
for i=1:size(face_m,1)
    if ~isempty(intersect(face_m(i,:),vidx))
        idx=[idx;i];
    end
end
face_m(idx,:)=[];
show_mesh(face_m,vertex_m);
axis([-0.5 1.5 -0.5 1.5]);
vertex=vertex_m;
face=face_m;
vertex_c=vertex;
face_c=face;
outer_surface=face_c;
nv=size(vertex,1);
ol=zeros(nv,1);
idx=unique(face(:));
ol(idx)=1;

A = triangulation2adjacency(face,vertex);
adj_list = adjmatrix2list(A);