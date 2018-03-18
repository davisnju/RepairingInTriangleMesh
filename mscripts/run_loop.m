%% run advancing front mesh generation loop
% load m201803171811.mat
% load m201803172000.mat
% load m201803172126.mat
% load m201803172200.mat
% load 201803172339.mat
% show_patch
li=loop_i;
for loop_i=li+1:197
% for loop_i=1:1
    loop
end % while(1)

%%
loop_i=loop_i+1;
loop

% show_patch

%%
figure(25)
clf;
hold off
trisurf(face_m,vertex_m(:,1),vertex_m(:,2),vertex_m(:,3));
view([-160 40])
hold on;
show_patch