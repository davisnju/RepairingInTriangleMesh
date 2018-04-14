% connect two vertex

v1_idx=setdiff(adj_list_m{v1idx},[v2idx v3idx]);
if length(v1_idx)==1
    
    
end
% v_can_del=0;
% if v1idx>nvert_r
%     v_can_del=1;
% end

if check_pyramid()
    return;
end

% ======= update border ======
% border_vid
border_vid{i}(border_vid{i}==v1idx)=[];
%   isborder
isborder(v1idx)=0;
%   hv_u_matrix
v1p=hv_u_matrix(v1idx,1);
hv_u_matrix(v1p,3)=hv_u_matrix(v1p,3)-1;
if v1p==v1idx
    % v1 is root !!!!!!
    this_border_vid=hv_u_matrix(:,1)==v1p;
    v1p=max([v2idx v3idx]);
    hv_u_matrix(this_border_vid,1)=v1p;
    hv_u_matrix(v1p,2)=1;
    hv_u_matrix(v1p,3)=hv_u_matrix(v1idx,3);
    
    border_l(border_l==v1idx)=v1p;
end
hv_u_matrix(v1idx,1)=v1idx;  % v1 no longer on border
hv_u_matrix(v1idx,2)=0;
hv_u_matrix(v1idx,3)=1;

%   adj_list_m
adj_list_m{v2idx}=[adj_list_m{v2idx}, v3idx];
adj_list_m{v3idx}=[adj_list_m{v3idx}, v2idx];

new_patch=[v1idx v2idx v3idx];
face_patch=[face_patch;new_patch];
face_m=[face_m;new_patch];
fmn=size(face_m,1);
vertex_adj_face{v2idx}=[vertex_adj_face{v2idx};fmn];
vertex_adj_face{v3idx}=[vertex_adj_face{v3idx};fmn];