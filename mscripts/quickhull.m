%%
%quickhull
%Barber, C. B., D.P. Dobkin, and H.T. Huhdanpaa, “The Quickhull Algorithm for Convex Hulls,” ACM Transactions on Mathematical Software, Vol. 22, No. 4, Dec. 1996, p. 469-483.

X = vertex;
K = convhull(X);
figure;
trisurf(K,X(:,1),X(:,2),X(:,3));
% axis([XMIN XMAX YMIN YMAX])
axis([-15 15 -15 15 -5 15]);
view(2)          
title(['surface facets']);
%%
XMIN=-2; XMAX=1; YMIN=-5.5; YMAX=-3;

global CONVHULL_X;
global CONVHULL_K;

X = vertex;
CONVHULL_K=convhulln(X);
figure;
trisurf(CONVHULL_K,X(:,1),X(:,2),X(:,3));
% axis([XMIN XMAX YMIN YMAX])
axis([-15 15 -15 15 -5 15]);
view(2)          
title(['all vertexes']);

%%
CONVHULL_X = model_v;
CONVHULL_K=convhulln(CONVHULL_X);
ch_tp_n=length(CONVHULL_K);
figure;
trisurf(CONVHULL_K,CONVHULL_X(:,1),CONVHULL_X(:,2),CONVHULL_X(:,3));
xlabel(['\theta_d=' num2str(dis_e_theta)]);
axis([XMIN XMAX YMIN YMAX])
view(2)   
title('model vertexes');

%%
%convhull triangle
figure;
hold on;
for i=1:ch_tp_n 
        v=[CONVHULL_X(CONVHULL_K(i,1),:);
           CONVHULL_X(CONVHULL_K(i,2),:);
           CONVHULL_X(CONVHULL_K(i,3),:)];       
        plot3(v([1:end,1],1),v([1:end,1],2),v([1:end,1],3), 'b-'); 
end
grid on;

%%
%
mvn=length(model_v);
dis_ch_model=zeros(mvn,1);
di=zeros(ch_tp_n,1);
for i=1:1:mvn
    v=model_v(i,:); 
    for j=1:ch_tp_n   
        dj=distance2tp(v,...
        [CONVHULL_X(CONVHULL_K(j,1),:);...
            CONVHULL_X(CONVHULL_K(j,2),:);...
            CONVHULL_X(CONVHULL_K(j,3),:)]);
        di(j)=dj;
    end
    
    d_min=min(di);
    if d_min<0
        dis_ch_v=max(di(di<0));
    else
        dis_ch_v=d_min; 
    end
    dis_ch_model(i)=dis_ch_v;
end

dis_ch=zeros(nv,1);
di=zeros(ch_tp_n,1);
for i=1:1:nv
    v=vertex_set(i,:); 
    for j=1:ch_tp_n   
        dj=distance2tp(v,...
        [CONVHULL_X(CONVHULL_K(j,1),:);...
            CONVHULL_X(CONVHULL_K(j,2),:);...
            CONVHULL_X(CONVHULL_K(j,3),:)]);
        di(j)=dj;
    end
    
    d_min=min(di);
    if d_min<0
        dis_ch_v=max(di(di<0));
    else
        dis_ch_v=d_min; 
    end
    dis_ch(i)=dis_ch_v;
end
%%
max_dis = max(abs(dis_ch_model));
dis_ch_thred=quantile(dis_ch_model,0.975);
inner_point_idx=[];
model_point_idx=[];
dm=[];
%
color_ch=['c','m','b','g','y',...%in convhull
    'r'];                        %out convhull
figure;
view([0 0])
hold on;
for i=1:1:nv 
    v=vertex_set(i,:);
    color_idx = ceil(abs(dis_ch(i)/max_dis)*4);
    color_idx = max(1,min(color_idx,5));
    if dis_ch(i)<0 
        color_idx=6;
    elseif dis_ch(i)<dis_ch_thred
        color_idx=1;
        model_point_idx=[model_point_idx;i];
        dm=[dm;dis_ch(i)];
    else
        inner_point_idx=[inner_point_idx;i];
        color_idx=2;
    end
    plot3(v(1),v(2),v(3),[color_ch(color_idx) '+']);  
end
grid on;
figure;hold on
for i=1:length(model_point_idx)
    v=vertex_set(model_point_idx(i),:);
    plot3(v(1),v(2),v(3),[color_ch(6) '+']);  
end
for i=1:ch_tp_n 
        v=[CONVHULL_X(CONVHULL_K(i,1),:);
           CONVHULL_X(CONVHULL_K(i,2),:);
           CONVHULL_X(CONVHULL_K(i,3),:)];       
        plot3(v([1:end,1],1),v([1:end,1],2),v([1:end,1],3), 'b-'); 
end
grid on;
%%
figure;plot(dis_ch)
figure;histogram(dis_ch);
%%
%使用三角面片重心筛选
dis_tpch=zeros(tn2,1);
for i=1:tn2    
    vs=[vertex_set(tpis(i,1),:);
       vertex_set(tpis(i,2),:);
       vertex_set(tpis(i,3),:)];
   
    v=mean(vs);
    for j=1:ch_tp_n   
        dj=distance2tp(v,...
        [CONVHULL_X(CONVHULL_K(j,1),:);...
            CONVHULL_X(CONVHULL_K(j,2),:);...
            CONVHULL_X(CONVHULL_K(j,3),:)]);
        di(j)=dj;
    end
    
    d_min=min(di);
    if d_min<0
        dis_ch_tp=max(di(di<0));
    else
        dis_ch_tp=d_min; 
    end
    dis_tpch(i)=dis_ch_tp;
    
end

figure;plot(dis_tpch)
figure;histogram(dis_tpch);

%%
figure1 = figure;
% 创建 axes
axes1 = axes('Parent',figure1);
% 创建 hggroup
hggroup1 = hggroup('Parent',axes1,'Tag','boxplot');
%%
ch_idx=[];
dis_inch_tp=dis_tpch(dis_tpch>=0);
dis_tpch_thred=quantile(dis_inch_tp,0.975);
figure;
hold on;
for i=1:tn2    
    
        v=[vertex_set(tpis(i,1),:);
           vertex_set(tpis(i,2),:);
           vertex_set(tpis(i,3),:)];
        if dis_tpch(i)<0 
            color_idx=5;
        else 
            if dis_tpch(i)<dis_tpch_thred
                ch_idx=[ch_idx;i];
                color_idx=1;
            else
                color_idx=2;
            end
        end
       
        plot3(v([1:end,1],1),v([1:end,1],2),v([1:end,1],3),...
            [color_ch(color_idx)  '-']); 
   
end
grid on;

%%
figure;
scatter(dis_inch_tp,zeros(size(dis_inch_tp)),'.');
figure;histogram(dis_inch_tp);

%%
% 筛选三角面片

model_tp_k=[];
figure;
hold on;
for i=1:length(ch_idx)
    j=ch_idx(i);
    v=[vertex_set(tpis(j,1),:);
       vertex_set(tpis(j,2),:);
       vertex_set(tpis(j,3),:)];
    
    if 1 || isempty(find(model_point_idx==tpis(j,1), 1))...
        || isempty(find(model_point_idx==tpis(j,2), 2))...
        || isempty(find(model_point_idx==tpis(j,3), 3))
        model_tp_k=[model_tp_k;j];
        plot3(v([1:end,1],1),v([1:end,1],2),v([1:end,1],3),'b-'); 
    end
end
title(['n_tp=' num2str(length(model_tp_k))]);
grid on;
%%
edge_edge_idx=detect_edge(ne,edge_set,tpis(model_tp_k,:));
edge_edge_n=length(edge_edge_idx);
for i=1:edge_edge_n
    e=[vertex_set(edge_set(edge_edge_idx(i),1),:);
        vertex_set(edge_set(edge_edge_idx(i),2),:)];
    plot3(e(:,1),e(:,2),e(:,3),'r-'); 
end

%%
v=[-1.072 -4.591 -14.82];
for j=1:ch_tp_n   
        dj=distance2tp(v,...
        [CONVHULL_X(CONVHULL_K(j,1),:);...
            CONVHULL_X(CONVHULL_K(j,2),:);...
            CONVHULL_X(CONVHULL_K(j,3),:)]);
        di(j)=dj;
    end
d_min=min(di);

test_mv=model_v-v;
test_mvd=zeros(length(test_mv),1);
for i=1:length(test_mvd)
    test_mvd(i)=norm(test_mv(i,:));   
end
[min_mvd min_mvd_k]=min(test_mvd);
model_v(min_mvd_k,:);