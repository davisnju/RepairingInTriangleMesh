% test40ball2

addpath(genpath('./toolbox'));
load('res\test4-1\ball2.mat');
vertex=vertex_m;
face=face_m;

show_mesh(face,vertex);
%% create sample
load('ball_mesh300.mat');
% 
% vidx=[199 122 182 54 42 71 181 95 183 281 260 99 141 89 160 11 265 ...
%     50 166 292 19 168 48 97 113 58 214 190 60 170 123 274 243];
vidx=[ 122 182 54 42 71 181 95 183 281 260 99 141 89 160 11 265 ...
    166 292 19 168 48  ...
    58 60  214 190 274  ...
    113 170 123  ];
idx=[];
for i=1:size(face,1)    
    if ~isempty(intersect(face(i,:),vidx))
        idx=[idx;i];
    end
end

vertex_m=vertex;
face_m=face;
face_m(idx,:)=[];

%
face=face_m;
vertex=vertex_m;
% show_mesh(face,vertex);


%
idx=[];
idx2=[];
nface=size(face,1);
for i=1:nface
%     if min(vertex_m(face_m(i,:),3))>-0.3
    if max(face_m(i,:))>300
        idx=[idx;i];
    else
        idx2=[idx2;i];        
    end
end
face_h=face_m(idx,:);
face_h2=face_m(idx2,:);
figure(1);
hold off
trisurf(face_h2,vertex_m(:,1),vertex_m(:,2),vertex_m(:,3) );
%     ,'facecolor','blue'

% 
axis([-2 2 -2 2 -2 2]);
% axis([-15 15 -15 15 -15 15]);
grid off
view([124 8])
hold on;
trisurf(face_h,vertex_m(:,1),vertex_m(:,2),vertex_m(:,3) );
%     ,'facecolor','y'


xlabel('x');
ylabel('y');
zlabel('z');


%%
% vertex=vertex_m;
% face=face_m;
% save test40ball2-2.mat vertex face
vertex_c=vertex;
face_c=face;
outer_surface=face_c;
nv=size(vertex,1);
ol=zeros(nv,1);
idx=unique(face(:));
ol(idx)=1;

A = triangulation2adjacency(face,vertex);
adj_list = adjmatrix2list(A);
% 
%%


vpidx=[ 50 97 199 243];

idx=[];
for i=1:size(face_c,1)    
    if ~isempty(intersect(face_c(i,:),vpidx))
        idx=[idx;i];
    end
end
face_c1=face_c;
face_c1(idx,:)=[];
face_p1=[face_patch;face_c(idx,:)];
face_m1=[face_c1;face_p1];
figure(26);
trisurf(face_c1,vertex_m(:,1),vertex_m(:,2),vertex_m(:,3),...
'facecolor','b');
grid off
hold on
trisurf(face_p1,vertex_m(:,1),vertex_m(:,2),vertex_m(:,3),...
    'facecolor','y');

axis([-2 2 -2 2 -2 2]);
xlabel('x');
ylabel('y');
zlabel('z');
%%
border_num=length(border_l);
ma=ones(border_num,1);
for l=1:border_num
    ma(l)=length(border_vid{l});
end
for i=1:border_num
    v_bli=border_vid{i};%vertex on border Label=lli
    vn_bli=size(v_bli,1);
    bid=1:border_num;
    bid(i)=[];
    if border_num>1 && isempty(bid) || vn_bli<=4 ...
            || rotate_face_default==0
        rotate_face=0;
    else
        rotate_face=1;
        for j=1:vn_bli
            v1idx=v_bli(j);
            v1=vertex_m(v1idx,:);
            dir1=compute_growdir(v1idx,vertex_m,bid,border_vid,ma);
            
            quiver3(v1(1),v1(2),v1(3),...
                dir1(1)*0.2,dir1(2)*0.2,dir1(3)*0.2,'y','LineWidth',1);
        end
    end
end