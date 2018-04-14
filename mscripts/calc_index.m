function [r]=calc_index(vertex1,face_m,patch_v_idx)
%% r index

[~,~,r]=cart2sph(real(vertex1(patch_v_idx,1)),...
    real(vertex1(patch_v_idx,2)),real(vertex1(patch_v_idx,3)));

return
%% curvature index
name='ball300-84';
clear options;
options.name = name; % useful for displaying
% compute the curvature
options.curvature_smoothing = 0;
options.verb = 0;
[~,~,Cmin,Cmax,~,~,~] = compute_curvature(vertex1,face_m,options);
Crms=sqrt((Cmin.^2+Cmax.^2)./2);
r=Crms(patch_v_idx);
end