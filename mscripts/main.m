
clear
clc

addpath(genpath('./toolbox'));

% load vertex.mat
% % load m.mat;
% vertexes=vertexm;
% x = vertexes(:,1);
% nx = length(x);
% y = vertexes(:,2);
% z = vertexes(:,3);
% tn = nx / 3;

load defected_cylinder_sample2.mat

vertex_raw=vertex;
face_raw=face;

vertexes=vertex;
tn=size(face,1);

tps=table(zeros(tn,1),zeros(tn,1),zeros(tn,1),zeros(tn,3));
%vertex/edge/normal
tps.Properties.VariableNames = {'v1','v2','v3','n'};

%
% vertex_set = [];
% for i = 1:nx
%     if idx_of_vertex(vertex_set,vertexes(i,:)) < 0
%         vertex_set = [vertex_set; vertexes(i,:)];
%     end
% end
vertex_set=vertex;
nv = length(vertex_set);

%%
edge_set=[];

for i=1:tn
    %     vertexes_i=vertexes(3*i-2:3*i,:);
    id1 = face(i,1);%idx_of_vertex(vertex_set,vertexes_i(1,:));
    id2 = face(i,2);%idx_of_vertex(vertex_set,vertexes_i(2,:));
    id3 = face(i,3);%idx_of_vertex(vertex_set,vertexes_i(3,:));
    ids = [id1,id2,id3];
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
%face adj list
tpn=tn2;
tpadjlist=cell(tpn,1);
for i=1:ne
    tp_has_ei=[];
    for j=1:tpn
        if tphasedge(edge_set(i,:),tpis(j,:))
            tp_has_ei=[tp_has_ei;j];
        end
    end
    if length(tp_has_ei)>1
        l=length(tp_has_ei);
        adj_matrix=ones(l,1)*tp_has_ei';
        for k=1:l
            j=tp_has_ei(k);
            neighbors_idx=adj_matrix(k,[1:k-1,k+1:end]);
            tpadjlist{j}=[tpadjlist{j};neighbors_idx'];
        end
    else
        %         assert(0);   %error:isolated face
    end
end
%%
% di
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


%
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
vertex=vertex_set;
face=tpis;
%%
% calculate sub model vertex,face
ln=length(vertex_ds_label);
sub_vertexes=cell(ln,1);
vertex_sub_idx=zeros(nv,2);
for i=1:ln
    sub_vertexes{i}=[];
end
for i=1:nv
    lid=find(vertex_ds_label==ds_u.p(i));
    sub_vertexes{lid}=[sub_vertexes{lid};i];
    vertex_sub_idx(i,1)=lid;
    vertex_sub_idx(i,2)=length(sub_vertexes{lid});
end
sub_model=cell(ln,1);
for i=1:ln
    sub_model{i}=cell(2,1);
    sub_model{i}{1}=vertex_set(sub_vertexes{i},:);%vertex   n-by-3
    sub_model{i}{2}=[];%face   n-by-3
end
for i=1:tn
    id1 = face(i,1);
    id2 = face(i,2);
    id3 = face(i,3);
    lid=find(vertex_ds_label==ds_u.p(id1));
    sub_model{lid}{2}=[sub_model{lid}{2};
        vertex_sub_idx(id1,2),vertex_sub_idx(id2,2),vertex_sub_idx(id3,2)];
end

%%
%   more complex sample
vertex_sub=[];
for i=1:ln
    vertex_sub=sub_model{i}{1};
    face_sub=sub_model{i}{2};
    
    for k=1:3
        %   add g
        face_n=size(face_sub,1);
        for t=1:face_n
            T=vertex_sub(face_sub(t,:),:);
            [~,r,z]=cart2pol(T(:,1),T(:,2),T(:,3));
            flag=0;
            for j=1:3
                if r(j)<5 && (z(j) > 0 && z(j) < 10)
                    flag=1;
                    break
                end
            end
            if flag
                g=[sum(T(:,1)),sum(T(:,2)),sum(T(:,3))]./3;
                vertex_sub=[vertex_sub;g];
            end
        end
        %   update face
        DT=delaunayTriangulation(vertex_sub(:,1),vertex_sub(:,2),vertex_sub(:,3));
        [K,~] = convexHull(DT);
        vertex_sub=DT.Points(:,:);
        face_sub=K;
    end
    sub_model{i}{1}=vertex_sub;
    sub_model{i}{2}=face_sub;
end

vt=[];
face_c=[];
for i=1:ln    
    L=size(vt,1);
    vt=[vt;sub_model{i}{1}];
    face_c=[face_c;sub_model{i}{2}+L];
end
vertex_c=vt;
%%
%model curvature analysis
[normalv_c,normalf_c]=compute_normal(vertex_c,face_c);
figure;
quiver3(vertex_c(:,1),vertex_c(:,2),vertex_c(:,3),...
    normalv_c(1,:)',normalv_c(2,:)',normalv_c(3,:)');
hold on;
trisurf(face_c,vertex_c(:,1),vertex_c(:,2),vertex_c(:,3));
axis([-15 15 -15 15 -5 15]);
view(0,0);
%%
% divide and conquer
for sub_i=1:1
    vertex_sub_i=sub_model{sub_i}{1};%vertex   n-by-3
    face_sub_i=sub_model{sub_i}{2};%face   n-by-3
    vertex=vertex_sub_i;
    face=face_sub_i;
    [normalv,normalf]=compute_normal(vertex,face);
    
    figure;
    quiver3(vertex(:,1),vertex(:,2),vertex(:,3),normalv(1,:)',normalv(2,:)',normalv(3,:)');
    hold on;
    trisurf(face,vertex(:,1),vertex(:,2),vertex(:,3));
    axis([-15 15 -15 15 -5 15]);
    view(0,0);
    
    name='cylinder';
    clear options;
    options.name = name; % useful for displaying
    % compute the curvature
    options.curvature_smoothing = 2;
    options.verb = 0;
    [Umin,Umax,Cmin,Cmax,Cmean,Cgauss,Normal] = compute_curvature(vertex,face,options);
    % display
    figure;
    clf;
    subplot(1,2,1);
    options.face_vertex_color = perform_saturation(Cgauss,1.2);
    plot_mesh(vertex,face, options); shading interp; colormap jet(256);
    title('Gaussian curvature');
    subplot(1,2,2);
    options.face_vertex_color = perform_saturation(abs(Cmin)+abs(Cmax),1.2);
    plot_mesh(vertex,face, options); shading interp; colormap jet(256);
    title('Total curvature');
    %
    figure;
    clear options;
    options.name = name; % useful for displaying
    clf;
    subplot(2,2,1);
    plot_mesh(vertex,face,options); shading interp; axis tight;
    hold on;
    q=quiver3(vertex(:,1),vertex(:,2),vertex(:,3),Umin(1,:)',Umin(2,:)',Umin(3,:)');
    q.Color='b';
    q.ShowArrowHead='off';
    
    q=quiver3(vertex(:,1),vertex(:,2),vertex(:,3),Umax(1,:)',Umax(2,:)',Umax(3,:)');
    q.Color='r';
    q.ShowArrowHead='off';
    
    subplot(2,2,2)
    plot_mesh(vertex,face,options); shading interp; axis tight;
    hold on;
    q=quiver3(vertex(:,1),vertex(:,2),vertex(:,3),Umin(1,:)',Umin(2,:)',Umin(3,:)');
    q.Color='b';
    q.ShowArrowHead='off';
    title('min direction of curvature')
    subplot(2,2,4)
    plot_mesh(vertex,face,options); shading interp; axis tight;
    hold on;
    q=quiver3(vertex(:,1),vertex(:,2),vertex(:,3),Umax(1,:)',Umax(2,:)',Umax(3,:)');
    q.Color='r';
    q.ShowArrowHead='off';
    title('max direction of curvature')
    
    %
    face_n=size(face,1);
    nv=size(vertex,1);
    
    theta_sharp=0.5;
    phi_corner=0.6;
    n_m0=zeros(1,3);
    n_m1=zeros(1,3);
    angle_max=0;
    mintheta=ones(nv,1).*-1;
    maxphi=zeros(nv,1);
    for i=1:face_n
        v1=face(i,1);
        v2=face(i,2);
        v3=face(i,3);
        n1=normalv(:,v1);
        n2=normalv(:,v2);
        n3=normalv(:,v3);
        dot12=n1'*n2;
        dot23=n3'*n2;
        dot31=n1'*n3;
        a12=myangle(n1,n2);
        a23=myangle(n2,n3);
        a31=myangle(n3,n1);
        [angle_max, idx]=max([angle_max a12 a23 a31]);
        switch(idx)
            case 2
                n_m0=n1;n_m1=n2;
            case 3
                n_m0=n2;n_m1=n3;
            case 4
                n_m0=n3;n_m1=n1;
            otherwise
                
        end
        if mintheta(v1)<0
            mintheta(v1)=min([dot12,dot31]);
        else
            mintheta(v1)=min([mintheta(v1),dot12,dot31]);
        end
        if mintheta(v2)<0
            mintheta(v2)=min([dot12,dot23]);
        else
            mintheta(v2)=min([mintheta(v2),dot12,dot23]);
        end
        if mintheta(v3)<0
            mintheta(v3)=min([dot31,dot23]);
        else
            mintheta(v3)=min([mintheta(v3),dot31,dot23]);
        end
    end
    
    n_star=cross(n_m0,n_m1);
    for i=1:nv        
        maxphi(i)=max([maxphi(i) abs(normalv(:,i)'*n_star)]);
    end
    
    %
    figure(11);
    clf;
    hold on;
    grid on;
    for i=1:face_n
        v1=face(i,1);
        v2=face(i,2);
        v3=face(i,3);
        vs=[vertex(v1,:);
            vertex(v2,:);
            vertex(v3,:)];
        
        plot3tr(vs(:,1), vs(:,2),vs(:,3),'g-');
    end
    for i=1:nv        
        if mintheta(i)<theta_sharp
            if maxphi(i)>phi_corner
                s='m*';      % corner feature
            else
                s='b*';      % edge feature   
            end
            scatter3(vertex(i,1), vertex(i,2),vertex(i,3),s);
        end
    end
    
end
function beta = myangle(u,v)
% beta vary [0,2*pi)
du = sqrt( sum(u.^2) );
dv = sqrt( sum(v.^2) );
du = max(du,eps); dv = max(dv,eps);
beta = acos( sum(u.*v) / (du*dv) );
end

%%


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
% other validation

% ior = 0;
% for i=2:1:length(vertex_set)
%     if ~vec3compare(vertex_set(i-1,:),vertex_set(i,:))
%         ior = ior + 1;
%     end
% end
% assert(ior==0);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

