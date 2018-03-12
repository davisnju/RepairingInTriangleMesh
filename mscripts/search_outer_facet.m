% search outer surface facet after segmentation

%% convhull
X = vertex;
K = convhull(X);


%% segmentation of mesh

L=Lm;

Labels=sort(unique(L));
Lnum=length(Labels);
for i=1:Lnum
    L(L==Labels(i))=i;
end
sur_vertexes=cell(Lnum,1);
vertex_idx=zeros(nv,2);
for i=1:Lnum
    sur_vertexes{i}=[];
end
nv=size(vertex,1);
for i=1:nv
    lid=L(i);
    sur_vertexes{lid}=[sur_vertexes{lid};i];
    vertex_idx(i,1)=lid;
    vertex_idx(i,2)=length(sur_vertexes{lid});
end
sur_mesh=cell(Lnum,1);
for i=1:Lnum
    sur_mesh{i}=cell(3,1);
    sur_mesh{i}{1}=vertex(sur_vertexes{i},:);%vertex   n-by-3
    sur_mesh{i}{2}=[];%face   n-by-3
    sur_mesh{i}{3}=[];%face   n-by-3, total vertex index
end
facen=size(face,1);
for i=1:facen
    id1 = face(i,1);
    id2 = face(i,2);
    id3 = face(i,3);
    lid=L(id1);
    sur_mesh{lid}{2}=[sur_mesh{lid}{2};
        vertex_idx(id1,2),vertex_idx(id2,2),vertex_idx(id3,2)];
    sur_mesh{lid}{3}=[sur_mesh{lid}{3}; face(i,:)];
end
%%  divide and donquer
outer_surface=[];
ol=zeros(size(L));
for i=1:Lnum
    faceni=size(sur_mesh{i}{3},1);
    for j=1:faceni
        if on_surface(sur_mesh{i}{3}(j,:),K)
            outer_surface=[outer_surface;sur_mesh{i}{3}];
            vm=unique(sur_mesh{i}{3}(:,:));
            ol(vm)=1;
            break;
        end
    end
end
% display(['ol num :' num2str(size(unique(ol),1))]);

face_color=zeros(size(face,1),1);
ol_idx=find(ol);
for i=1:facen
    l=unique(ol(face(i,:)));
    if length(l)==1 && l(1)==1
        face_color(i)=1;
    else       
    end
end
%% post process
% vertex on outer_surface boundary may wrongly classified
outer_vertex_idx=unique(K(:));
fake_vo = setdiff(find(ol), outer_vertex_idx); 
for i=1:length(fake_vo)
    ol(fake_vo(i))=0;
end
outer_surface_n=size(outer_surface,1);
idx=[];
for i=1:outer_surface_n
    fi=outer_surface(i,:);
    if ~isempty(intersect(fi(:),fake_vo))
        idx=[idx;i];
    end
end
outer_surface(idx,:)=[];
%% show result,outer and inner mesh for different color

face_color_fixed=zeros(size(face,1),1);
ol_idx=find(ol);
for i=1:facen
    l=unique(ol(face(i,:)));
    if length(l)==1 && l(1)==1
        face_color_fixed(i)=1;
    else       
    end
end

% display(['face_color num :' num2str(size(unique(face_color),1))]);

figure(22);
clf;
ax1=subplot(3,2,1);
trisurf(face,X(:,1),X(:,2),X(:,3),Lrms);
axis([-8 8 -8 8 -1 11]);grid off
colormap(ax1, parula(11));%colorbar
title('segmentation before merge');

ax2=subplot(3,2,2);
trisurf(face,X(:,1),X(:,2),X(:,3),L);
axis([-8 8 -8 8 -1 11]);grid off
colormap(ax2, parula(7));%colorbar
title('segmentation after merge');

ax3=subplot(3,2,3);
trisurf(K,X(:,1),X(:,2),X(:,3));
% axis([XMIN XMAX YMIN YMAX])
axis([-8 8 -8 8 -1 11]);grid off
% view(2)
title(['wrap surface facets']);

ax5=subplot(3,2,5);
trisurf(face,X(:,1),X(:,2),X(:,3),...
    'FaceVertexCData',face_color,'FaceColor','flat');
axis([-8 8 -8 8 -1 11]);grid off
mmap = [0.2, 0.1, 0.5
    0.1, 0.5, 0.8
    0.2, 0.7, 0.6
    0.8, 0.7, 0.3
    0.9, 1, 0];
title('outer and inner mesh');
colormap(ax5, mmap);

ax6=subplot(3,2,6);
trisurf(face,X(:,1),X(:,2),X(:,3),...
    'FaceVertexCData',face_color_fixed,'FaceColor','flat');
axis([-8 8 -8 8 -1 11]);grid off
title('outer and inner mesh after post process');
colormap(ax6, mmap);





