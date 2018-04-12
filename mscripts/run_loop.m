%% run advancing front mesh generation loop
% load m201803171811.mat
% load m201803172000.mat
% load m201803172126.mat
% load m201803172200.mat
% load 201803172339.mat
% load m03222145.mat
% load m0329.mat
% load one_hole_m03291630.mat
% load two_hole.mat
load m0402.mat

figure(25);clf;
% show_patch

%%
%
li=loop_i;
for loop_i=li+1:14
    % for loop_i=1:1
    loop
end % while(1)
figure(25);clf;
show_patch

%%
load('bunny-repair.mat');
while front_size>0

    loop
    
    front_size=0;
    border_num=length(border_l);
    for i=1:border_num
        front_size=front_size+length(border_vid{i});
    end
    
    disp(['front size:' num2str(front_size)])
    loop_i=loop_i+1;
end % while(1)
figure(25);clf;
show_patch
%%

rotate_face=0;
%%
% load two_hole_planar.mat
% load res\test4-1\test41ball3repair.mat

% load m04021700.mat
% figure(25);clf;
% show_patch
% load('bunny-repair.mat')
% load m0411.mat
loop_i=loop_i+1;
loop

figure(25);clf;
show_patch

%%
figure(25)
clf;
hold off
trisurf(face_m,vertex_m(:,1),vertex_m(:,2),vertex_m(:,3));
view([-160 40])
hold on;
show_patch