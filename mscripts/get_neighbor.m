function [vpn1idx,vpn2idx]=get_neighbor(vp_idx,bli,adj_list_t,isborder,vertex_m,vertex_adj_face,face_m,hv_u_matrix)

neighbor_idx=adj_list_t{vp_idx};
border_neighbor=neighbor_idx(isborder(neighbor_idx)==1);
this_border_neighbor=border_neighbor(hv_u_matrix(border_neighbor,1)==bli);
adj_edge_vertex=this_border_neighbor;
vpn1idx=adj_edge_vertex(1);
vpn2idx=adj_edge_vertex(2);
vpn1=vertex_m(vpn1idx,:);
vpn2=vertex_m(vpn2idx,:);
%==== hole on left along border ==========
% adj facet
v1_adj_facet_idx=vertex_adj_face{vpn1idx};
v1_adj_facet=face_m(v1_adj_facet_idx,:);
v12face_idx=find(v1_adj_facet(:,1)==vp_idx);
v12face_idx=[v12face_idx;find(v1_adj_facet(:,2)==vp_idx)];
v12face_idx=[v12face_idx;find(v1_adj_facet(:,3)==vp_idx)];
v12face=v1_adj_facet(v12face_idx,:);
vx=setdiff(v12face,[vp_idx vpn1idx]);
n=normal4plane(vertex_m(v12face(1,1),:),vertex_m(v12face(1,2),:),vertex_m(v12face(1,3),:));
flip=n*normal4plane(vp,vpn1,vertex_m(vx,:))'>0;
if flip
    [vpn1idx,vpn2idx]=exchange(vpn1idx,vpn2idx);
end

end