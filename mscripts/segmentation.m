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

%%
% Cgauss,Cmean,Crms,Cabs
Crms=sqrt((Cmin.^2+Cmax.^2)./2);
Cabs=abs(Cmin)+abs(Cmax);
Lgauss=fast_watershed(nv,Cgauss,vadjlist);
Lmean=fast_watershed(nv,Cmean,vadjlist);
Lrms=fast_watershed(nv,Crms,vadjlist);
Labs=fast_watershed(nv,Cabs,vadjlist);
%%

face_n=size(face,1);

figure;
% subplot(2,2,1)
hold on;
L=Lrms;
for i=1:face_n
    vid=face(i,:);
    v=[vertex(vid(1),:);
        vertex(vid(2),:);
        vertex(vid(3),:)];
    if L(vid(1))==L(vid(2)) && L(vid(1))==L(vid(3))
        fill(v(:,1),v(:,2),v(:,3));%,'cdata',L(vid(1))*ones(3,1,'int32'));
    else        
    end
end
hold on;
scatter3(vertex(:,1),vertex(:,2),vertex(:,3),...
    'filled',...
    'cdata',Lrms);
axis([-15 15 -15 15 -5 15]);
view(0,0);
%%
figure;
subplot(2,2,1);
hold on;
scatter3(vertex(:,1),vertex(:,2),vertex(:,3),...
    'filled',...
    'cdata',Lgauss);
axis([-15 15 -15 15 -5 15]);
view(0,0);title('Lgauss');
subplot(2,2,2);
hold on;
scatter3(vertex(:,1),vertex(:,2),vertex(:,3),...
    'filled',...
    'cdata',Lmean);
axis([-15 15 -15 15 -5 15]);
view(0,0);title('Lmean');
subplot(2,2,3);
hold on;
scatter3(vertex(:,1),vertex(:,2),vertex(:,3),...
    'filled',...
    'cdata',Lrms);
axis([-15 15 -15 15 -5 15]);
view(0,0);title('Lrms');
subplot(2,2,4);
hold on;
scatter3(vertex(:,1),vertex(:,2),vertex(:,3),...
    'filled',...
    'cdata',Labs);
axis([-15 15 -15 15 -5 15]);
view(0,0);
title('Labs');
