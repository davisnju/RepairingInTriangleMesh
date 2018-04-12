%compare cot and dis weight
nvert = size(vertex,1);
nface = size(face,1);
disp(['nv:' num2str(nvert) ', nface:' num2str(nface)]);
tic
laplacian_type = 'conformal';
% laplacian_type='distance';
options.symmetrize = 1;
options.normalize = 1;
% disp('--> Computing laplacian');
L = compute_mesh_laplacian(vertex,face,laplacian_type,options);
toc
tic
% laplacian_type = 'conformal';
laplacian_type='distance';
options.symmetrize = 1;
options.normalize = 1;
% disp('--> Computing laplacian');
L = compute_mesh_laplacian(vertex,face,laplacian_type,options);
toc