
clear
clc

% load m.mat;
load vertex.mat

x = vertexes(:,1);
nx = length(x);
y = vertexes(:,2);
z = vertexes(:,3);
tn = nx / 3;
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
%%
vadjlist=cell(nv,1);
for i=1:tn
    idx_of_vertex_a=idx_of_vertex(vertex_set,vertexes(3*i-2,:));
    idx_of_vertex_b=idx_of_vertex(vertex_set,vertexes(3*i-1,:));
    idx_of_vertex_c=idx_of_vertex(vertex_set,vertexes(3*i-0,:));    
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
%%
eadjlist=cell(ne,1);
for i=1:tn
    idx_of_vertex_a=idx_of_vertex(vertex_set,vertexes(3*i-2,:));
    idx_of_vertex_b=idx_of_vertex(vertex_set,vertexes(3*i-1,:));
    idx_of_vertex_c=idx_of_vertex(vertex_set,vertexes(3*i-0,:));    
    
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
%构建并查集
global ds_u;
ds_u=table([1:nv]',zeros(nv,1));%[p,r]
ds_u.Properties.VariableNames = {'p','r'};
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

%%
%分割
vertex_ds_label= unique(ds_u.p);
colors_r=0.2:0.2:0.8;
colors_g=0.2:0.2:0.8;
colors_b=0.2:0.2:0.8;
[R,G,B] = meshgrid(colors_r,colors_g,colors_b);  
color_RGB = [R(:) G(:) B(:)];  

figure;
hold on;
for i=1:nv       
    plot3(vertex_set(i,1),vertex_set(i,2),vertex_set(i,3),'.-',...
        'Color',color_RGB(vertex_ds_label==find_in_universe(ds_u,i),:)); 
end
grid on;


figure;
hold on;
for i=0:tn-1    
    
    idx_of_vertex_a=idx_of_vertex(vertex_set,vertexes(3*i+1,:));
    
    plot3(x([3*i+1:3*i+3,3*i+1]),y([3*i+1:3*i+3,3*i+1]),...
        z([3*i+1:3*i+3,3*i+1]),'-',...
        'Color',color_RGB(vertex_ds_label==find_in_universe(ds_u,idx_of_vertex_a),:)); 
end
grid on;

%%

%计算三角面片法向量
normals = [];
for i=0:1:tn-1
    ab = [x(i*3+1) - x(i*3+2) 
        y(i*3+1) - y(i*3+2) 
        z(i*3+1) - z(i*3+2)
        ];
    bc = [x(i*3+2) - x(i*3+3) 
        y(i*3+2) - y(i*3+3) 
        z(i*3+2) - z(i*3+3)
        ];
    normal = cross(ab,bc)';
    normal = normal / norm(normal);
    if normal(3) < 0
        normal = -normal;
    end
    normals = [normals; normal];
end

figure;
scatter3(x, y, z, '*');
figure;
scatter3(normals(:,1), normals(:,2), normals(:,3), 'o');



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