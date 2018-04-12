%create ball surface sample
load ball_vertex300.mat
% vertex=rn;

DT=delaunayTriangulation(vertex(:,1),vertex(:,2),vertex(:,3));
[K,~] = convexHull(DT);
vertex=DT.Points(:,:);
face=K;
% figure(1);
% hold on;
% grid off
% trisurf(face,vertex(:,1),vertex(:,2),vertex(:,3),'FaceColor','blue');
% axis([-1.5 1.5 -1.5 1.5 -1.5 1.5]);
%%
z_max=max(vertex(:,3));
z_min=min(vertex(:,3));
z_th=z_min+0.94*(z_max-z_min);

fn=size(face,1);
face_bottom=[];
face_top=[];
BottomFace_idx=[];
nv=size(vertex,1);
ol=zeros(nv,1); %on surface

for i=1:fn
    if ~(vertex(face(i,1),3)>z_th || vertex(face(i,2),3)>z_th ...
            || vertex(face(i,3),3)>z_th)
        face_bottom=[face_bottom;face(i,:)]; 
        BottomFace_idx=[BottomFace_idx;i];
        ol(face(i,:))=1;
    else
        face_top=[face_top;face(i,:)]; 
    end
end
%%
figure(2);
hold on;
grid off
trisurf(face_bottom,vertex(:,1),vertex(:,2),vertex(:,3),'FaceColor','blue');
axis([-1.5 1.5 -1.5 1.5 -1.5 1.5]);

% save ball_mesh300.mat vertex face