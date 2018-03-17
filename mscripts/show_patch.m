%% show patch
figure(25);
clf
grid off
% trisurf(face_m,vertex_m(:,1),vertex_m(:,2),vertex_m(:,3));
view([-160 40])
hold on;
trisurf(face_patch,vertex_m(:,1),vertex_m(:,2),vertex_m(:,3));
color=['r','g','b','y','m','c','w','k'];
for i=1:border_num
    bli=border_l(i);
    p=hv_u_matrix(:,1);
    v_bli=find(p==bli);
    v_bli_n=length(v_bli);
    for j=1:v_bli_n
        
        neighbor_idx=adj_list_t{v_bli(j)};
        adj_edge_vertex=neighbor_idx(isborder(neighbor_idx)==1);
        v1idx=adj_edge_vertex(1);
        v2idx=adj_edge_vertex(2);        
        
        if cross(vertex_m(v1idx,:)-vertex_m(v_bli(j),:),...
                vertex_m(v2idx,:)-vertex_m(v_bli(j),:))*normalv1<0
            [v1idx, v2idx]=exchange(v1idx,v2idx);
        end
                
        X=[vertex_m(v1idx,1);
            vertex_m(v_bli(j),1);
            vertex_m(v2idx,1);];
        Y=[vertex_m(v1idx,2);
            vertex_m(v_bli(j),2);
            vertex_m(v2idx,2);];
        Z=[vertex_m(v1idx,3);
            vertex_m(v_bli(j),3);
            vertex_m(v2idx,3);];
        plot3(X,Y,Z,color(border_l==bli));
%         scatter3(X,Y,Z,color(border_l==bli),'filled');
    end
    %     e_bli=e_hb(p(e_hb(:,1))==bli,:);
    %     e_bli_n=size(e_bli,1);
    %     for j=1:e_bli_n
    %         X=[vertex_m(e_bli(j,1),1);
    %             vertex_m(e_bli(j,2),1);];
    %         Y=[vertex_m(e_bli(j,1),2);
    %             vertex_m(e_bli(j,2),2);];
    %         Z=[vertex_m(e_bli(j,1),3);
    %             vertex_m(e_bli(j,2),3);];
    %         plot3(X,Y,Z,color(border_l==bli));
    %         scatter3(X,Y,Z,color(border_l==bli),'filled');
    %     end
end
xlabel('x');
ylabel('y');
zlabel('z');
title(['loop idx=' num2str(loop_i)])