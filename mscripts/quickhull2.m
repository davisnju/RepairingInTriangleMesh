test_vertex_set=[0 0 0;1 0 0;0 1 0;0 0 1];
X = [0 0 0;1 0 0;0 1 0;0 0 1];
CONVHULL_K=convhulln(X);
clc;
v=[1 1 0];
d=[0 0 0 0];
for i=1:1:4
d(i)=distance2tp(v,...
        [X(CONVHULL_K(i,1),:);...
            X(CONVHULL_K(i,2),:);...
            X(CONVHULL_K(i,3),:)]);
        display(['d' num2str(i) '=' num2str(d(i))])
end
d_min=min(d);
if d_min<0
    vdt=max(d(d<0));
else
    vdt=d_min; 
end
%%
figure;
XMIN=-1; XMAX=2; YMIN=-1; YMAX=2;
trisurf(CONVHULL_K,X(:,1),X(:,2),X(:,3));
        
axis([XMIN XMAX YMIN YMAX])
xlabel('x');
ylabel('y');
zlabel('z');

hold on;
plot3(v(1),v(2),v(3),'ro');
text(v(1),v(2),v(3)+0.2, num2str(vdt));
%%
%quickhull
%Barber, C. B., D.P. Dobkin, and H.T. Huhdanpaa, ¡°The Quickhull Algorithm for Convex Hulls,¡± ACM Transactions on Mathematical Software, Vol. 22, No. 4, Dec. 1996, p. 469-483.

% XMIN=-2; XMAX=1; YMIN=-5.5; YMAX=-3;

X = test_vertex_set;
CONVHULL_K=convhulln(X);
figure;
trisurf(CONVHULL_K,X(:,1),X(:,2),X(:,3));
axis([XMIN XMAX YMIN YMAX])
view(2)          
title(['all vertexes']);


%%
%
test_vertex_set=[test_vertex_set;1 1 0;0.2 0.2 0.2;-0.2 0.2 0;
    0.6 0.2 0; 0.6 0. 0;0 0.7 0;0 0 0.8;];
ne=length(test_vertex_set);
ch_tp_n=length(CONVHULL_K);
dis_ch=zeros(ne,1);
di=zeros(ch_tp_n,1);
for i=1:1:ne
    v=test_vertex_set(i,:); 
    for j=1:ch_tp_n   
        dj=distance2tp(v,...
        [test_vertex_set(CONVHULL_K(j,1),:);...
            test_vertex_set(CONVHULL_K(j,2),:);...
            test_vertex_set(CONVHULL_K(j,3),:)]);
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

max_dis = max(abs(dis_ch));
%
color_ch=['b','c','y','m','r','g'];
figure;

axis([XMIN XMAX YMIN YMAX])
hold on;
for i=1:1:ne    
    v=test_vertex_set(i,:);
    color_idx = ceil(abs(dis_ch(i)/max_dis)*4) + 1 + (dis_ch(i)<0)*3;
    color_idx = min(color_idx,5);
    if dis_ch(i)>0 
        color_idx=6;
    end
    if  dis_ch(i)>=0 
        s='+';
    else
        s='o';
    end
    plot3(v(1),v(2),v(3),[color_ch(color_idx) s]);  
end

for i=1:ch_tp_n
    v=[test_vertex_set(CONVHULL_K(i,1),:);...
            test_vertex_set(CONVHULL_K(i,2),:);...
            test_vertex_set(CONVHULL_K(i,3),:)];
    plot3(v([1:end 1],1),v([1:end 1],2),v([1:end 1],3),...
        'm-');  
end
grid on;
