%% repair hole

vertex_m=vertex_c;
vm_idx=find(ol);
vm_n=size(vm_idx,1);
face_m=outer_surface(:,:);

% Hole Boundary Identification
v_hb_idx=[];   % border vertex
A_m = triangulation2adjacency(face_m,vertex_m);
adj_list_m = adjmatrix2list(A_m);

for i=1:vm_n
    if find(ol(adj_list{vm_idx(i)})==0)
         v_hb_idx=[v_hb_idx;vm_idx(i)];
    end
end
isborder=zeros(nv,1);
isborder(v_hb_idx)=1;

v_hb_num=length(v_hb_idx);
% v_hb_idx_2=v_hb_idx;
e_hb=[];
for i=1:v_hb_num
    neighbor_idx=adj_list{v_hb_idx(i)};
%     [v_nb,~,id2] = intersect(neighbor_idx, v_hb_idx_2);
v_nb=intersect(neighbor_idx(neighbor_idx>v_hb_idx(i)),...
    neighbor_idx(isborder(neighbor_idx)==1));
    e_hb=[e_hb; [(ones(size(v_nb))*v_hb_idx(i))', v_nb']];
%     v_hb_idx_2(id2)=[];
%     v_hb_idx_2(v_hb_idx_2==v_hb_idx(i))=[];
end

%% hole segmentation
hv_u=table([1:nv]',zeros(nv,1),ones(nv,1));%[p,r,s]
hv_u.Properties.VariableNames = {'p','r','s'};
hv_u_size=nv;
neb=size(e_hb,1);
for i=1:neb
    edge_i=e_hb(i,:);
    [a,hv_u]=find_in_universe(hv_u,edge_i(1));
    [b,hv_u]=find_in_universe(hv_u,edge_i(2));
    if a~=b
        [hv_u]=join_dsu(hv_u,a,b);
        hv_u_size=hv_u_size-1;
    end
end
border_l=unique(hv_u.p(v_hb_idx));
border_num=length(border_l);

%% 

%% show Hole Boundary
figure(23);
grid off
trisurf(face_m,vertex_m(:,1),vertex_m(:,2),vertex_m(:,3));
view(3)
hold on;
color=['r','g','b','y','m','c','w','k'];
for i=1:border_num
    bli=border_l(i);
    v_bli=find(hv_u.p==bli);
    e_bli=e_hb(hv_u.p(e_hb(:,1))==bli,:);
    e_bli_n=size(e_bli,1);
    for j=1:e_bli_n
        X=[vertex_m(e_bli(j,1),1);
            vertex_m(e_bli(j,2),1);];
        Y=[vertex_m(e_bli(j,1),2);
            vertex_m(e_bli(j,2),2);];
        Z=[vertex_m(e_bli(j,1),3);
            vertex_m(e_bli(j,2),3);];
        plot3(X,Y,Z,color(border_l==bli));
        scatter3(X,Y,Z,color(border_l==bli),'filled');
    end
end