%%
%sample normal filter
for i=1:tn2
    for j=1:length(tpadjlist{i})
        
        if normals(i,:)

        end
    end
end

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
%convex hull filter
dis_tpch=zeros(tn2,1);
vars=zeros(tn2,1);
figure;
hold on;
grid on;
for i=1:tn2    
    vs=[vertex_set(tpis(i,1),:);
       vertex_set(tpis(i,2),:);
       vertex_set(tpis(i,3),:)];
   
    v_barycenter=mean(vs);
    n=normals(i,:);
    %Ln=lambda*n+v;
    d_barycenter=distance_p2ch(v_barycenter,ch_tp_n);
    d_v1=distance_p2ch(vs(1,:),ch_tp_n);
    d_v2=distance_p2ch(vs(2,:),ch_tp_n);
    d_v3=distance_p2ch(vs(3,:),ch_tp_n);
    
    vars(i)=std([d_v1,d_v2,d_v3,d_barycenter]);
    
    if abs(vars(i))>0.12 && d_barycenter>=0 && d_barycenter<0.1656
        display([num2str(i) ':(' num2str(normals(i,1)) ',' num2str(normals(i,2)) ',' num2str(normals(i,3)) ')  '...
            num2str(d_barycenter) ',' num2str(d_v1) ',' num2str(d_v2) ',' num2str(d_v3)])
        
        plot3tr(vs(:,1), vs(:,2),vs(:,3),'g-');
    end
end
%%
figure;plot(vars)
figure;histogram(vars);
