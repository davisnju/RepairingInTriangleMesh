%%
clear
clc
load m.mat

%%
normals=zeros(tn2,3);
for i=1:tn2
    v=[vertex_set(tpis(i,1),:);
       vertex_set(tpis(i,2),:);
       vertex_set(tpis(i,3),:)];
   
    ab = v(1,:) - v(2,:);
    bc = v(2,:) - v(3,:);
    normal = cross(ab,bc)';
    normal = normal / norm(normal);
    if normal(3)<0
        normal=-normal;
    end 
    normals(i,:) =normal;
end

%%
%搜索边界边？
edge_deg = zeros(ne,1);
for i=1:ne
    for j=1:tn2
        if length(intersect(tpis(j,:)',edge_set(i,:)','rows'))>1
            edge_deg(i) = edge_deg(i)+1;
        end
    end
end
% except_e_id=find(edge_deg==3);
% except_tp=union(edge_set(except_e_id(1),:),edge_set(except_e_id(2),:));
% tpis=setdiff(tpis,except_tp,'rows');
% tn3=length(tpis);
colors=['r','g','b','c','m'];
figure;
hold on;
for i=1:ne     
    v=[vertex_set(edge_set(i,1),:);
       vertex_set(edge_set(i,2),:)];
   if edge_deg(i)>0
    plot3(v(:,1),v(:,2),v(:,3),[colors(edge_deg(i)),'.-']); 
   end
end
grid on;
%%
%构建并查集进行区域划分
%theta_e
global threshold;
threshold = 0.02;
global tp_ds_u;
tp_ds_u=table([1:tn2]',zeros(tn2,1),ones(tn2,1));%[p,r,s]
tp_ds_u.Properties.VariableNames = {'p','r','s'};
tp_ds_u_size=tn2;
for i=1:ne
    edge_i=edge_set(i,:);
    tp_a=find_in_tp_u(tp_ds_u,tpis,edge_i,-1);
    v = setdiff(tpis(tp_a,:),edge_i);
    tp_b=find_in_tp_u(tp_ds_u,tpis,edge_i,v);
    if tp_a~=tp_b && vec3theta(normals(tp_a,:),normals(tp_b,:)) < threshold
        join_dsu(tp_ds_u,tp_a,tp_b);
        tp_ds_u_size=tp_ds_u_size-1;
    end
end

tp_ds_label= unique(tp_ds_u.p);
[max_size_u,large_tp_u_label_idx]=max(tp_ds_u.s(tp_ds_label));
large_tp_u_label = tp_ds_label(large_tp_u_label_idx);

%%
% 聚类分析
%k-means聚类
data = normals;
[u re]=KMeans(data,5);  
[m n]=size(re);

%最后显示聚类后的法向量数据
figure;
hold on;
for i=1:m 
    if re(i,4)==1   
         plot3(re(i,1),re(i,2),re(i,3),'ro'); 
    elseif re(i,4)==2
         plot3(re(i,1),re(i,2),re(i,3),'go'); 
    elseif re(i,4)==3
         plot3(re(i,1),re(i,2),re(i,3),'bo'); 
    elseif re(i,4)==4
         plot3(re(i,1),re(i,2),re(i,3),'yo'); 
    else 
         plot3(re(i,1),re(i,2),re(i,3),'ms'); 
    end
end
grid on;
%%
l = re(:,4);
figure;
hist(l,5);
%%
Z_AXIS = [0,0,1];
Y_AXIS = [0,1,0];
X_AXIS = [1,0,0];

theta_e = 0.2;
theta_z = [0.,0.,0.,0.,0.];
for i=1:length(u)
    theta_z(i) = vec3theta(u(i,:),Z_AXIS);
end
[~,idx]=min(theta_z(:));

%%
%聚类中心法向量
figure;
hold on;
for i=1:length(u)   
    q = quiver3(0,0,0,u(i,1),u(i,2),u(i,3),1); 
    if i~=idx
        q.Color = 'm';
    else
        q.Color = 'g';
    end
end

grid on;
%%
%最后显示聚类后的顶点数据
hlabel=idx;
vlabel=[1:idx-1,idx+1:length(u)];
label_color=['r','g','m','c','b'];
figure;
hold on;
for i=0:1:m - 1     
    j = find(vlabel==re(i+1,4));
    if vlabel(j)~=hlabel            
        subplot(2,2,j);
        hold on;
         plot3(x([3*i+1:3*i+3,3*i+1]),y([3*i+1:3*i+3,3*i+1]),...
             z([3*i+1:3*i+3,3*i+1]),[label_color(j) '.-']); 
         q = quiver3(0,0,0,u( vlabel(j),1),u( vlabel(j),2),u( vlabel(j),3),1); 
         q.Color = 'm';
         xlabel([num2str(u(vlabel(j),1)),',',num2str(u(vlabel(j),2)),',',...
             num2str(u(vlabel(j),3))]);
    end
end
grid on;


 
 