%repair with samples

clear
clc

addpath(genpath('./toolbox'));
%%
load m0319ball.mat;

fn=size(face,1);

idx=[];
for i=1:fn
    if vertex(face(i,1),3)>3||vertex(face(i,2),3)>3||vertex(face(i,3),3)>3
        idx=[idx;i];
    end
end


face_c=face(idx,:);

face_2=face([1:857 859:end],:);
face_3=face_between([1 3:end],:);
figure;
hold on;
grid off
trisurf(face_2,vertex(:,1),vertex(:,2),vertex(:,3),'FaceVertexCData',0);
% trisurf(face_inside,vertex(:,1),vertex(:,2),vertex(:,3),'FaceVertexCData',0);
trisurf(face_3,vertex_between(:,1),vertex_between(:,2),vertex_between(:,3),'FaceVertexCData',1);
% trisurf(face_outside,vertex(:,1),vertex(:,2),vertex(:,3),'FaceVertexCData',2);
axis([-15 15 -15 15 -5 15]);
view(2);

%%
% load cylinder sample
load cylinder_sample.mat
%% create new cylinder sample
r=5;h=10;BO=[0,0,0];factor=0.8;
[vertex,face]=create_cylinder_sample(r,h,BO,factor);

figure;
% quiver3(vertex(:,1),vertex(:,2),vertex(:,3),normalv(1,:)',normalv(2,:)',normalv(3,:)');
hold on;
trisurf(face,vertex(:,1),vertex(:,2),vertex(:,3));
axis([-15 15 -15 15 -5 15]);
view(0,0);
grid off
save cylinder_sample2 vertex face
%%

% load defected cylinder sample
load defected_cylinder_sample.mat
load defected_cylinder_sample2.mat

%%
% create new defected cylinder sample
r=5;h=15;BO=[0,0,0];factor=0.84;r=5;vertical_pn=4;circle_pn=6;
k=30;n=20;m=30;
[vertex,face]=create_defected_cylinder_sample(r,h,BO,factor,vertical_pn,circle_pn,k,n,m);
save defected_cylinder_sample5.mat vertex face

figure;
trisurf(face,vertex(:,1),vertex(:,2),vertex(:,3));
grid off
axis([-15 15 -15 15 -5 15]);
view(0,0);
%%
%   计算两个三维凸包之间的最短距离

% compute the adjacency matrix of a given triangulation.
f=face;
A = sparse([f(:,1); f(:,1); f(:,2); f(:,2); f(:,3); f(:,3)], ...
           [f(:,2); f(:,3); f(:,1); f(:,3); f(:,1); f(:,2)], ...
           1.0);
% avoid double links
A = -double(A>0);

return; 

%%
K=convhulln(vertex);
figure;
trisurf(K,vertex(:,1),vertex(:,2),vertex(:,3));
axis([-15 15 -15 15 -5 15]);
view(0,0);
 

%%
% m=20;
% m2=floor(m*factor)-1;%16, gap vertex can fill 1 level
% gl=m-m2-1;%3
% 
% if gl>3
%     face_lower = delaunayTriangulation(vertex(lower_part,:));
%     face_higher = delaunayTriangulation(vertex(higher_part,:));
%     figure(2);subplot(1,2,1);
%     triplot(face_lower);
%     title('lower')
%     axis([-15 15 -15 15 -5 15]);
%     view(0,0);
%     figure(2);subplot(1,2,2);
%     triplot(face_higher);
%     title('higher')
%     axis([-15 15 -15 15 -5 15]);
%     view(0,0);
%     face=[face_lower; face_higher];
% else
%     lower_part=[];
%     higher_part=[];
%     face=delaunay(vertex);
% end
% 
% %%
% n=30;
% R=5;
% t=0:0.02:2*pi;
% plot(R*cos(t),R*sin(t),'r');
% axis square
% hold on
% r=R;
% i=0;
% hd=0.3;
% seta=2*pi/n*(1+hd*i:1:n+hd*i);
% x=r.*cos(seta);
% y=r.*sin(seta);
% plot(x,y,'*');
% ans=[x',y']