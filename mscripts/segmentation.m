%segmentation 
nv=size(vertex,1);
global ds_u;
ds_u=table([1:nv]',zeros(nv,1),ones(nv,1));%[p,r,s]
ds_u.Properties.VariableNames = {'p','r','s'};
% global ds_u_size;
ds_u_size=nv;
for i=1:ne
    edge_i=edge_set(i,:);
    a=find_in_universe(ds_u,edge_i(1));
    b=find_in_universe(ds_u,edge_i(2));
    if a~=b
        join_dsu(ds_u,a,b);
        ds_u_size=ds_u_size-1;
    end
end


%·Ö¸î
vertex_ds_label= unique(ds_u.p);
[max_size_u,large_u_label_idx]=max(ds_u.s(vertex_ds_label));
large_u_label = vertex_ds_label(large_u_label_idx);

large_u=[];
for i=1:nv
    v=vertex_set(i,:);
    tp_label = find_in_universe(ds_u,i);
    if tp_label == large_u_label
        large_u = [large_u;v];
    end    
end
