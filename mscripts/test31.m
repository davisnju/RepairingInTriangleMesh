% test hole on planar
% clear;clc;
%%

load('two_hole_planar.mat');

nvert=size(vertex_m,1);
nface=size(face_m,1);

face_bottom=[];
for i=1:nface
    if min(vertex_m(face_m(i,:),3))>5
        continue
    else
        face_bottom=[face_bottom;face_m(i,:)];
    end
end

show_mesh(face_bottom,vertex_m);

%% one planar hole
zmax=max(vertex_m(face_bottom(:,:),3));
idx=[];
for i=1:size(face_bottom,1)
    T=vertex_m(face_bottom(i,:),:);
    if mean(T(:,3)) > zmax-0.1
        [~,r,~]=cart2pol(T(:,1),T(:,2),T(:,3));
        if mean(r)<3.5
            idx=[idx;i];
        end
    end
end
face_bottom2=face_bottom;
face_bottom2(idx,:)=[];
%% two-ring planar hole

vidx=[475 481 467];
idx=[];
for i=1:size(face_bottom,1)    
    if ~isempty(intersect(face_bottom(i,:),vidx))
        idx=[idx;i];
    end
end
face_bottom2=face_bottom;
face_bottom2(idx,:)=[];

face=face_bottom2;
vertex=vertex_m;
%% one large hole

k=30;r=1;
seta=2*pi/k*(1:1:k);
x=r.*cos(seta);
y=r.*sin(seta);
z=zeros(1,k);
vo=[x;y;z]';

x2=r*0.9.*cos(seta);
y2=r*0.9.*sin(seta);
vi=[x2;y2;z]';
face=[];
for i=1:1:29
    face=[face;i i+1 i+31];
    face=[face;i i+31 i+30];    
end
face=[face;30 1 31];
face=[face;30 31 60];

vertex=[vo;vi;];
%%
% bn=length(border_l);
% if border_l(1)<30
%     border_l(1)=[];
%     border_vid{1}=border_vid{2};
% else
%     border_l(2)=[];
%     border_vid{2}=[];
% end

% show_mesh(face,vertex);
%%
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
nface=size(face_m,1);
idx=[];
for i=1:nface
    if min(vertex_m(face_m(i,:),3))>4%-1.1
        idx=[idx;i];
    end
end
face_h=face_m(idx,:);
figure(23);
hold off
trisurf(face_h,vertex_m(:,1),vertex_m(:,2),vertex_m(:,3),...
    'facecolor','blue');
hold on
grid off
view(2)
hold on;
color=['g','r','g','y','m','c','w','k'];

% fig 1
v0=447;

% fig 2
v0=477;

v0n=adj_list_m{v0};
v0n_border=v0n(isborder(v0n)==1);
v0n_nonborder=v0n(isborder(v0n)==0);


e_bli=[v0 v0n_border(1);v0 v0n_border(2);];
e_2=[v0 483;v0 485];

e_bli_n=size(e_bli,1);
for j=1:e_bli_n
    X=[vertex_m(e_bli(j,1),1);
        vertex_m(e_bli(j,2),1);];
    Y=[vertex_m(e_bli(j,1),2);
        vertex_m(e_bli(j,2),2);];
    Z=[vertex_m(e_bli(j,1),3);
        vertex_m(e_bli(j,2),3);];
    plot3(X,Y,Z,'r','LineWidth',2);
%     scatter3(X,Y,Z,'r','filled');
end
e_bli=e_2;
e_bli_n=size(e_bli,1);
for j=1:e_bli_n
    X=[vertex_m(e_bli(j,1),1);
        vertex_m(e_bli(j,2),1);];
    Y=[vertex_m(e_bli(j,1),2);
        vertex_m(e_bli(j,2),2);];
    Z=[vertex_m(e_bli(j,1),3);
        vertex_m(e_bli(j,2),3);];
    plot3(X,Y,Z,'g','LineWidth',2);
%     scatter3(X,Y,Z,'r','filled');
end
scatter3(vertex_m(v0,1),vertex_m(v0,2),vertex_m(v0,3),'y','filled');
for i=1:length(v0n_nonborder)
    scatter3(vertex_m(v0n_nonborder(i),1),...
        vertex_m(v0n_nonborder(i),2),vertex_m(v0n_nonborder(i),3),'c','filled');
end
for i=1:length(v0n_border)
    scatter3(vertex_m(v0n_border(i),1),...
        vertex_m(v0n_border(i),2),vertex_m(v0n_border(i),3),'r','filled');
end
    