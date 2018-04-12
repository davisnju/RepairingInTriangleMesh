%% show patch
figure(29);
% subplot(2,1,2)
hold off
trisurf(face_bottom,vertex_c(:,1),vertex_c(:,2),vertex_c(:,3),...
'facecolor','b');

grid off
hold on
trisurf(face_top,vertex_c(:,1),vertex_c(:,2),vertex_c(:,3),...
    'facecolor','y');

axis([-2 2 -2 2 -2 2]);
% view([-160 40])
view(2)
xlabel('x');
ylabel('y');
zlabel('z');
title(['loop idx=' num2str(loop_i)])

%%
color=['r','g','b','y','m','c','w','k'];
if isempty(border_l)
    return; 
end
border_num=length(border_l);
for i=1:border_num
    bli=border_l(i);
    v_bli=border_vid{i};
    v_bli_n=length(v_bli);
    for j=1:v_bli_n 
        
        v1idx=v_bli(j);
        v2idx=v_bli(calc_next_idx(j,v_bli_n));
        
        X=[vertex_m(v1idx,1);
            vertex_m(v2idx,1);];
        Y=[vertex_m(v1idx,2);
            vertex_m(v2idx,2);];
        Z=[vertex_m(v1idx,3);
            vertex_m(v2idx,3);];
        ev=[X(2)-X(1),Y(2)-Y(1),Z(2)-Z(1)];
        ev=ev/norm(ev);
        plot3(X,Y,Z,color(border_l==bli));
%         quiver3(vertex_m(v1idx,1),vertex_m(v1idx,2),vertex_m(v1idx,3),...
%             ev(1),ev(2),ev(3),'b','LineWidth',1);
%          scatter3(X,Y,Z,color(border_l==bli),'filled');
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