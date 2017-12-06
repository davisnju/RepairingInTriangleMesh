
clear
clc

load vertex.mat
% load m.mat;

vertexes=vertexm;
x = vertexes(:,1);
nx = length(x);
y = vertexes(:,2);
z = vertexes(:,3);
tn = nx / 3;

tps=table(zeros(tn,1),zeros(tn,1),zeros(tn,1),zeros(tn,3));
%vertex/edge/normal
tps.Properties.VariableNames = {'v1','v2','v3','n'};

%%
vertex_set = [];
for i = 1:nx
    if idx_of_vertex(vertex_set,vertexes(i,:)) < 0
        vertex_set = [vertex_set; vertexes(i,:)];
    end
end
nv = length(vertex_set);

%%
edge_set=[];

for i=1:tn
    vertexes_i=vertexes(3*i-2:3*i,:);
    id1 = idx_of_vertex(vertex_set,vertexes_i(1,:));
    id2 = idx_of_vertex(vertex_set,vertexes_i(2,:));
    id3 = idx_of_vertex(vertex_set,vertexes_i(3,:));
    ids = sort([id1,id2,id3]);
    tps.v1(i)=ids(1);
    tps.v2(i)=ids(2);
    tps.v3(i)=ids(3);
    
%     ab = vertexes_i(1,:) - vertexes_i(2,:);
%     bc = vertexes_i(2,:) - vertexes_i(3,:);
%     normal = cross(ab,bc)';
%     tps.n(i,:) = normal / norm(normal);
     
    edge_i=sort([id1,id2]);
    if idx_of_edge(edge_set,id1,id2)<0
        edge_set = [edge_set; edge_i];
    end
    edge_i=sort([id1,id3]);
    if idx_of_edge(edge_set,id1,id3)<0
        edge_set = [edge_set; edge_i];
    end
    edge_i=sort([id2,id3]);
    if idx_of_edge(edge_set,id3,id2)<0
        edge_set = [edge_set; edge_i];
    end
end
ne=length(edge_set);
edge_length = zeros(ne,1);
for i=1:ne
    vi = vertex_set(edge_set(i,1),:);
    vj = vertex_set(edge_set(i,2),:);
    edge_length(i) = sqrt(sum((vi-vj).^2));
end

tpis=[tps.v1(:),tps.v2(:),tps.v3(:)];
tpis=unique(tpis,'rows');
tn2=length(tpis);  


% %%
% %用周长筛选
% tp_perimeter = zeros(tn,1);
% for i=1:tn
%     v1 = vertex_set(tps.v1(i),:);
%     v2 = vertex_set(tps.v2(i),:);
%     v3 = vertex_set(tps.v3(i),:);
%     tp_perimeter(i) = sqrt(sum((v1-v2).^2))+sqrt(sum((v2-v3).^2))+sqrt(sum((v1-v3).^2));
% end
% max_tp_perimeter=quantile(tp_perimeter,0.80);
% tp_idx1=find(tp_perimeter<=max_tp_perimeter);
% tn1=length(tp_idx1);
% tps1=table(tps.v1(tp_idx1),tps.v2(tp_idx1),tps.v3(tp_idx1),tps.n(tp_idx1,:));
% %vertex/edge/normal
% tps1.Properties.VariableNames = {'v1','v2','v3','n'};
% 
% tp_perimeter1 = zeros(tn1,1);
% for i=1:tn1
%     v1 = vertex_set(tps1.v1(i),:);
%     v2 = vertex_set(tps1.v2(i),:);
%     v3 = vertex_set(tps1.v3(i),:);
%     tp_perimeter1(i) = sqrt(sum((v1-v2).^2))+sqrt(sum((v2-v3).^2))+sqrt(sum((v1-v3).^2));
% end
% 
% % draw_tps(vertex_set,tps1);
% 
% tpis=[tps1.v1(:),tps1.v2(:),tps1.v3(:)];
% tpis=unique(tpis,'rows');
% tn2=length(tpis);    
% figure;
% hold on;
% for i=1:tn2
%     v=[vertex_set(tpis(i,1),:);
%        vertex_set(tpis(i,2),:);
%        vertex_set(tpis(i,3),:)];
%     plot3(v([1:end,1],1),v([1:end,1],2),v([1:end,1],3),'g.-'); 
% end
% grid on;
% 
% %%
% %用面积筛选
% 
% tp_areas = zeros(tn,1);
% for i=1:tn
%     v1 = vertex_set(tps.v1(i),:);
%     v2 = vertex_set(tps.v2(i),:);
%     v3 = vertex_set(tps.v3(i),:);
%     tp_areas(i) = tp_area(v1,v2,v3);
% end
% max_tp_area=quantile(tp_areas,0.80);
% tp_idx21=find(tp_areas<=max_tp_area);
% tn21=length(tp_idx21);
% tps21=table(tps.v1(tp_idx21),tps.v2(tp_idx21),tps.v3(tp_idx21),tps.n(tp_idx21,:));
% %vertex/edge/normal
% tps21.Properties.VariableNames = {'v1','v2','v3','n'};
% 
% tp_area1 = zeros(tn21,1);
% for i=1:tn1
%     v1 = vertex_set(tps1.v1(i),:);
%     v2 = vertex_set(tps1.v2(i),:);
%     v3 = vertex_set(tps1.v3(i),:);
%     tp_area1(i) = tp_area(v1,v2,v3);
% end
% 
% % draw_tps(vertex_set,tps1);
% 
% tpis2=[tps1.v1(:),tps1.v2(:),tps1.v3(:)];
% tpis2=unique(tpis2,'rows');
% tn2=length(tpis2);    
% figure;
% hold on;
% for i=1:tn2
%     v=[vertex_set(tpis2(i,1),:);
%        vertex_set(tpis2(i,2),:);
%        vertex_set(tpis2(i,3),:)];
%     plot3(v([1:end,1],1),v([1:end,1],2),v([1:end,1],3),'g.-'); 
% end
% grid on;
% 

%%
vadjlist=cell(nv,1);
for i=1:tn2
    idx_of_vertex_a=tpis(i,1);%idx_of_vertex(vertex_set,vertexes(3*i-2,:));
    idx_of_vertex_b=tpis(i,2);%idx_of_vertex(vertex_set,vertexes(3*i-1,:));
    idx_of_vertex_c=tpis(i,3);%idx_of_vertex(vertex_set,vertexes(3*i-0,:));    
    vadjlist{idx_of_vertex_a}=[vadjlist{idx_of_vertex_a};idx_of_vertex_b];
    vadjlist{idx_of_vertex_a}=[vadjlist{idx_of_vertex_a};idx_of_vertex_c];
    vadjlist{idx_of_vertex_b}=[vadjlist{idx_of_vertex_b};idx_of_vertex_a];
    vadjlist{idx_of_vertex_b}=[vadjlist{idx_of_vertex_b};idx_of_vertex_c];
    vadjlist{idx_of_vertex_c}=[vadjlist{idx_of_vertex_c};idx_of_vertex_a];
    vadjlist{idx_of_vertex_c}=[vadjlist{idx_of_vertex_c};idx_of_vertex_b];
end
for i=1:nv
    vadjlist{i}=unique(vadjlist{i});
    vadjlist{i}=sort(vadjlist{i});
end

eadjlist=cell(ne,1);
for i=1:tn2
    idx_of_vertex_a=tpis(i,1);%idx_of_vertex(vertex_set,vertexes(3*i-2,:));
    idx_of_vertex_b=tpis(i,2);%idx_of_vertex(vertex_set,vertexes(3*i-1,:));
    idx_of_vertex_c=tpis(i,3);%idx_of_vertex(vertex_set,vertexes(3*i-0,:));    
    
    idx_of_edge_a=idx_of_edge(edge_set,idx_of_vertex_a,idx_of_vertex_b);
    idx_of_edge_b=idx_of_edge(edge_set,idx_of_vertex_c,idx_of_vertex_b);
    idx_of_edge_c=idx_of_edge(edge_set,idx_of_vertex_a,idx_of_vertex_c);   
    
    eadjlist{idx_of_edge_a}=[eadjlist{idx_of_edge_a};idx_of_edge_b];
    eadjlist{idx_of_edge_a}=[eadjlist{idx_of_edge_a};idx_of_edge_c];
    eadjlist{idx_of_edge_b}=[eadjlist{idx_of_edge_b};idx_of_edge_a];
    eadjlist{idx_of_edge_b}=[eadjlist{idx_of_edge_b};idx_of_edge_c];
    eadjlist{idx_of_edge_c}=[eadjlist{idx_of_edge_c};idx_of_edge_a];
    eadjlist{idx_of_edge_c}=[eadjlist{idx_of_edge_c};idx_of_edge_b];
end
for i=1:ne
    eadjlist{i}=unique(eadjlist{i});
    eadjlist{i}=sort(eadjlist{i});
end
%%
%三角面片邻接表
tpn=tn2;
tpadjlist=cell(tpn,1);
for i=1:ne
    tp_has_ei=[];
    for j=1:tpn
        if tphasedge(edge_set(i,:),tpis(j,:))
           tp_has_ei=[tp_has_ei;j];
        end
    end
    if ~isempty(tp_has_ei)
            for k=1:length(tp_has_ei)
                tpadjlist{j}=[tpadjlist{j};k];
            end
    else
        assert(0);   %error:存在孤立边
    end
end
%%
%构建并查集
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


%分割
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
colors_r=0.2:0.2:0.8;
colors_g=0.2:0.2:0.8;
colors_b=0.2:0.2:0.8;
[R,G,B] = meshgrid(colors_r,colors_g,colors_b);  
color_RGB = [R(:) G(:) B(:)];  

figure;
hold on;
for i=1:tn2    
    v=[vertex_set(tpis(i,1),:);
       vertex_set(tpis(i,2),:);
       vertex_set(tpis(i,3),:)];
    plot3(v([1:end,1],1),v([1:end,1],2),v([1:end,1],3),'.-',...
        'Color',color_RGB(vertex_ds_label==find_in_universe(ds_u,tpis(i,1)),:)); 
end
grid on;

figure;
hold on;
for i=1:tn2     
    v=[vertex_set(tpis(i,1),:);
       vertex_set(tpis(i,2),:);
       vertex_set(tpis(i,3),:)];
    tp_label = find_in_universe(ds_u,tpis(i,1));
    if tp_label == large_u_label
        plot3(v([1:end,1],1),v([1:end,1],2),v([1:end,1],3),'.-',...
            'Color',color_RGB(vertex_ds_label==tp_label,:)); 
    end
end
grid on;
%%

%%
% other validation

% ior = 0;
% for i=2:1:length(vertex_set)
%     if ~vec3compare(vertex_set(i-1,:),vertex_set(i,:))
%         ior = ior + 1;
%     end
% end
% assert(ior==0);

%%
% functions 
%%
function id=idx_of_vertex(vs,v)
sn=size(vs,1);
id=-1;
for i=1:sn
    if sum(abs(vs(i,:)-v(:,:)))<0.0008
        id=i;
        break;
    end
end
end

function id=idx_of_edge(es,ea,eb)
id=-1;
sn=size(es,1);
if sn<1
    return;
end
if ea > eb
    t=ea;
    ea=eb;
    eb=t;
end
[~,ia,~]=intersect(es,[ea,eb],'rows');
if ia
    id=ia(1);
end
end