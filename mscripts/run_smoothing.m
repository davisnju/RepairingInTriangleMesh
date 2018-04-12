% smoothing
name='cylinder2';
rep = 'res/mesh-smoothing/';
if not(exist(rep))
    mkdir(rep);
end

[vertex,face] = check_face_vertex(vertex_m,face_m);
clear options
%% un-symmetric laplacian

nvert = size(vertex,2);
nface = size(face,2);
laplacian_type = 'conformal';
options.symmetrize = 0;
options.normalize = 1;
disp('--> Computing laplacian');
L = compute_mesh_laplacian(vertex,face,laplacian_type,options);

%% heat diffusion flow
Tlist = [0 10 40 200];
options.dt = 0.3;
% clf;
ptv_idx=patch_v_idx;
figure(30);
clf;

ndepl = 5;
VO=mean(vertex,2);
vertex = vertex - repmat(VO, [1 nvert]);
mavc=max(abs(vertex(:)));
vertex = vertex ./ repmat(mavc, size(vertex));
vertex_movepos=vertex';
show_patch_func(1,vertex_m,face_o,face_patch);
vertex1=vertex;
for i=1:ndepl
    
    delta = .08/ndepl;
    
    vertex1 = perform_normal_displacement(vertex1,face,delta);
    
    % display
    %     subplot(1,length(Tlist),i);
    %     plot_mesh(vertex1,face,options);
    %     shading interp; camlight; axis tight;
    %
    if size(vertex1,1)==3
        vertex2=vertex1';
    else
        vertex2=vertex1;
    end
%     vertex1 = vertex1 .* repmat(mavc, size(vertex1));
    vertex_movepos=vertex';
    vertex_movepos(ptv_idx,:)=vertex2(ptv_idx,:);%+repmat(VO', [patch_v_num 1]);
    vertex_movepos=vertex_movepos*mavc;%.* repmat(mavc, size(vertex_smooth));
    vertex_movepos=vertex_movepos+repmat(VO', [nvert 1]);
    show_patch_func(1+i,vertex_movepos,face_o,face_patch);
    hold on;
end
saveas(gcf, [rep name '-move-pos-' laplacian_type '.png'], 'png');

