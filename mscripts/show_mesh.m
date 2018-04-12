function [r]=show_mesh(face,vertex)
% show_mesh - show mesh
%   [r]=show_mesh(face,vertex)
%
%   r is return value
%
%   Copyright (c) 2018 Wei Dai
figure;
hold on;
grid off
trisurf(face,vertex(:,1),vertex(:,2),vertex(:,3));
% axis([-15 15 -15 15 -5 15]);
view(2);
r=0;
%%
% show_watershed_label
%%