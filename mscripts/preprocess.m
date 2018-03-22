% pre-process for repair hole
%input: vertex face

addpath(genpath('./toolbox'));

vertex_c=vertex;
face_c=face_bottom;
outer_surface=face_c;
nv=size(vertex,1);
A = triangulation2adjacency(face,vertex);
adj_list = adjmatrix2list(A);

