% laplace smoothing

% name='ballv300hole2';
% name='ballv300hole1-84';
name='ballv300p2';

rep = 'res/test4-1/';

if not(exist(rep))
    mkdir(rep);
end


vn_raw=size(vertex_c,1);
facen_raw=size(face_o,1);
patch_v_num=size(vertex_m,1)-vn_raw;
patch_v_idx=vn_raw+1:size(vertex_m,1);

A_m = triangulation2adjacency(face_m,vertex_m);
adj_list_m = adjmatrix2list(A_m);
[vertex,face] = check_face_vertex(vertex_m,face_m);
clear options
%% un-symmetric laplacian

nvert = size(vertex,2);
nface = size(face,2);
laplacian_type = 'conformal';
% laplacian_type='distance';
options.symmetrize = 1;
options.normalize = 1;
disp('--> Computing laplacian');
L = compute_mesh_laplacian(vertex,face,laplacian_type,options);

%%
param_k=0.05;
lambda=0.3;
niter=50;
miu=1/(param_k-1/lambda);%<0

mavc0=1;

vidx=[];
nvf=length(unique(face(:)));
for i=1:nvf
    if vertex(3,i)<0%.1 && vertex(3,i)>-0.1
        vidx=[vidx;i];
    end
end

mavc=mavc0;%max(abs(vertex(:)));
show_patch_func(1,vertex',face_o,face_patch);
[vertex,VO]=mesh_normalize(vertex,mavc);
vertex_smooth=vertex';

sr=[];
[index]=calc_index(vertex_m,face_m,vidx);
exp_index=mean(index);
[index]=calc_index(vertex_smooth,face_m,patch_v_idx);
sr=[sr;exp_index-mean(index)];


for i=1:niter
    
    for vid=1:nvert
        vi=vertex_smooth(vid,:);
        neighbors=adj_list_m{vid};
        
        for k=1:3
            x=vi(k);
            grad1=0;
            nn=length(neighbors);
            for j=1:nn
                vjid=neighbors(j);
                vj=vertex_smooth(vjid,:);
                grad1=grad1+L(vid,vjid)*(vj(k)-vi(k));
            end
            vertex_smooth(vid,k)=x+lambda*grad1;    %x1
        end
    end
    
    for vid=1:nvert
        vi=vertex_smooth(vid,:);
        neighbors=adj_list_m{vid};
        
        for k=1:3
            x=vi(k);
            grad2=0;
            nn=length(neighbors);
            for j=1:nn
                vjid=neighbors(j);
                vj=vertex_smooth(vjid,:);
                grad2=grad2+L(vid,vjid)*(vj(k)-vi(k));
            end
            vertex_smooth(vid,k)=x+miu*grad2;    %x2
        end
    end
    
    if 1 || i==10 || i==50 || i==70 || i==niter
%         show_patch_func(i,vertex_smooth,face_o,face_patch);
%         show_patch_func(i+1,vertex1,face_o,face_patch);
%         show_patch_func(i+2,real(vertex_s),face_o,face_patch);
        % ===== inormalize ========
        % update mavc
        
%         [~,r,~]=cart2pol(vertex_smooth(vidx,1),...
%             vertex_smooth(vidx,2),vertex_smooth(vidx,3));
        [~,~,r]=cart2sph(real(vertex_smooth(vidx,1)),...
            real(vertex_smooth(vidx,2)),real(vertex_smooth(vidx,3)));
        
        mavc=mavc0/mean(r);
        
        vertex1=vertex_smooth';
        vertex1=mesh_inormalize(vertex1,mavc,VO);
        vertex1=vertex1';
        
        vertex_s=vertex_m;
        vertex_s(patch_v_idx,:)=vertex1(patch_v_idx,:);
        
        [vertex2,VO]=mesh_normalize(vertex_s',mavc0);
        vertex_smooth=vertex2';
        
        
        [index]=calc_index(vertex_smooth,face_m,patch_v_idx);
        sr=[sr;exp_index-mean(index)];
        
    end
    
    
end

figure(2);
plot(1:length(sr),sr/exp_index);


function [vertex,VO]=mesh_normalize(vertex,mavc)
% [vertex]=mesh_normalize(vertex,macv)
%   normalize mesh
% VO=mean(vertex,2);
VO=[0;0;0];
nvert = size(vertex,2);
vertex = vertex - repmat(VO, [1 nvert]);
% mavc=5;%max(abs(vertex(:)));
vertex = vertex ./ repmat(mavc, size(vertex));
end

function [vertex]=mesh_inormalize(vertex,mavc,VO)
% [vertex]=mesh_normalize(vertex,macv)
%   normalize mesh
nvert = size(vertex,2);
vertex = vertex .* repmat(mavc, size(vertex));
vertex = vertex + repmat(VO, [1 nvert]);
% mavc=5;%max(abs(vertex(:)));
end