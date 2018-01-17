%repair with samples

clear
clc

addpath(genpath('./toolbox'));
% load cylinder sample
load cylinder_sample.mat
% %%
% %create new cylinder sample
% r=5;h=10;BO=[0,0,0];factor=0.65;
% [vertex,face]=create_cylinder_sample(r,h,BO,factor);

figure;
trisurf(face,vertex(:,1),vertex(:,2),vertex(:,3));
axis([-15 15 -15 15 -5 15]);
view(0,0);
save cylinder_sample vertex face
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