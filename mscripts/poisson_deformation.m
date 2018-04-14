% poisson deformation

%
load res\test3-2\m0414.mat

vids=sort(unique(face_patch(:)));
vertex=vertex_m(vids,:);
nvert=size(vertex,1);
nface=size(face_patch,1);
nbv=length(v_hb_idx);
face=zeros(nface,3);
for i=1:nface
    face(i,:)=[find(vids==face_patch(i,1)) ...
        find(vids==face_patch(i,2)) ...
        find(vids==face_patch(i,3))];
end
border_idx=zeros(size(v_hb_idx));
for i=1:nbv
    border_idx(i)=find(vids==v_hb_idx(i));
end
isborder=zeros(nvert,1);
isborder(border_idx)=1;

%%
%% h guidance field, new gradient vector fields
h=zeros(nface,3,3);
%% grad
grad_face=zeros(nface,3,3);
for i=1:nface
    face_i=face(i,:);
    
    % use point after transform
    vs=[vertex_face(i,1,1) vertex_face(i,1,2) vertex_face(i,1,3); ...
        vertex_face(i,2,1) vertex_face(i,2,2) vertex_face(i,2,3); ...
        vertex_face(i,3,1) vertex_face(i,3,2) vertex_face(i,3,3);];
    
    vij=vs(2,:)-vs(1,:);
    vik=vs(3,:)-vs(1,:);
    nf=my_normalize(cross(vij,vik));
    a=area_tri(vs(1,:),vs(2,:),vs(3,:));
    for xyz=1:3
        grad_face(i,:,xyz)=[0 0 0];
        for j=1:3 %three v for fi
            ei=vs((mod(j+1,3)+1),:)-vs((mod(j,3)+1),:);
            grad=vs(j,xyz)*0.5/a*cross(nf,ei);
            h(i,j,:)=my_normalize(grad);
            grad_face(i,1,xyz)=grad_face(i,1,xyz)+grad(1);
            grad_face(i,2,xyz)=grad_face(i,2,xyz)+grad(2);
            grad_face(i,3,xyz)=grad_face(i,3,xyz)+grad(3);
        end
    end
end

%% Divergence
% calc of border vertex
divergence_pb=vertex;
for i=1:nvert
    vid=i;%vertex_id_ref(i);
    
    if isborder(i)  % fix border
        continue;
    end
    
    nf_idx=[find(face(:,1)==vid);
        find(face(:,2)==vid);
        find(face(:,3)==vid);];
    bfn=length(nf_idx);
    for j=1:bfn
        %     deltaik  3x1
        fidx=nf_idx(j);
        fi=face(fidx,:);
        
        % use point after transform
        vs=[vertex_face(fidx,1,1) vertex_face(fidx,1,2) vertex_face(fidx,1,3); ...
            vertex_face(fidx,2,1) vertex_face(fidx,2,2) vertex_face(fidx,2,3); ...
            vertex_face(fidx,3,1) vertex_face(fidx,3,2) vertex_face(fidx,3,3);];
        
        a=area_tri(vs(1,:),vs(2,:),vs(3,:));
        k=find(fi==vid);
        hk=[h(fidx,k,1) h(fidx,k,2) h(fidx,k,3)];%1x3
        r=calc_next_idx(k,3);
        l=calc_prev_idx(k,3);
        hl=[h(fidx,l,1) h(fidx,l,2) h(fidx,l,3)];%1x3
        hr=[h(fidx,r,1) h(fidx,r,2) h(fidx,r,3)];%1x3
        l2s=vs(l,:)-vs(k,:);
        r2s=vs(r,:)-vs(k,:);
        for xyz=1:3
            
            gradxyz=hl*l2s(xyz)+hr*r2s(xyz);
            divergence_pb(i,xyz)=divergence_pb(i,xyz)+...
                hk*gradxyz'*a;
            
            %                     grad=[grad_face(nf_idx(j),k,xyz)];%3x1
            %                     divergence_pb(i,xyz)=divergence_pb(i,xyz)+...
            %                         0.5*(cot_a1*(e1*grad)+...
            %                         cot_a2*(e2*grad));
            
        end
    end
end
%%
% calc b
b=divergence_pb;
%% calc A
%L = compute_mesh_weight(vertex,face,type,options)
clear option
type='conformal';
options.symmetrize=1;
options.normalize=0;
A = compute_mesh_laplacian(vertex,face,type,options); % use cot wij
for i=1:nbv
    vi=border_idx(i);
    A(vi,:)=zeros(1,nvert);
    A(vi,vi)=1;
end
%%
vx=zeros(nvert,3);
% Ax
SAx=sparse(A);
[Rchol]=chol(SAx);
[Q,R]=qr(SAx);
for coord=1:3
    % solve poisson equation
    % ================ solve x ==========================
    [x,flag]=gmres(SAx,b(:,coord),nvert,0.001,nvert);
    disp(['co ' num2str(coord) ' flag ' num2str(flag)])
    if ~flag
        vx(:,coord)=x;
    else
        vx(:,coord)=R*(Q*b(:,coord));
    end
end
%% update patch vertex
vertex_ref=vertex;
for i=1:nvert
    if isborder(i)
        continue;
    end
    vertex_ref(i,:)=vx(i,:);
end

%%
%show

figure(28);
clf;
subplot(2,2,1)
hold off
trisurf(face,vertex(:,1),vertex(:,2),vertex(:,3),...
    'facecolor','b');
hold on
for i=1:nface
    show_tri_normal(vertex(face(i,1),:),vertex(face(i,2),:),...
        vertex(face(i,3),:));
end
grid off
axis([-1 1 -1 1 0.5 1.5]);
% view([-90 0])
view(3)
xlabel('x');
ylabel('y');
zlabel('z');
subplot(2,2,2)
for i=1:nface
    trisurf([1 2 3],vertex_face(i,:,1),vertex_face(i,:,2),vertex_face(i,:,3),...
        'facecolor','r');
    hold on
    fidx=i;
    vs=[vertex_face(fidx,1,1) vertex_face(fidx,1,2) vertex_face(fidx,1,3); ...
        vertex_face(fidx,2,1) vertex_face(fidx,2,2) vertex_face(fidx,2,3); ...
        vertex_face(fidx,3,1) vertex_face(fidx,3,2) vertex_face(fidx,3,3);];
    
    show_tri_normal(vs(1,:),vs(2,:),vs(3,:));
end
grid off
axis([-1 1 -1 1 0.5 1.5]);
% view([-90 0])
view(3)
xlabel('x');
ylabel('y');
zlabel('z');

subplot(2,2,3)
hold off
trisurf(face,vx(:,1),vx(:,2),vx(:,3),...
    'facecolor','b');
grid off
bv=vx(border_idx,:);
hold on
scatter3(bv(:,1),bv(:,2),bv(:,3),'y','filled');
axis([-1 1 -1 1 0.5 1.5]);
% view([-90 0])
view(3)
xlabel('x');
ylabel('y');
zlabel('z');
subplot(2,2,4)
hold off
bv=vertex_ref(border_idx,:);
scatter3(bv(:,1),bv(:,2),bv(:,3),'y','filled');
hold on
trisurf(face,vertex_ref(:,1),vertex_ref(:,2),vertex_ref(:,3),...
    'facecolor','b');
grid off
axis([-1 1 -1 1 0.5 1.5]);
% view([-90 0])
view(3)
xlabel('x');
ylabel('y');
zlabel('z');
for i=1:nface
    show_tri_normal(vertex_ref(face(i,1),:),vertex_ref(face(i,2),:),...
        vertex_ref(face(i,3),:));
end
%%

vertex_d=vertex_m;
vertex_d(vids,:)=vertex_ref(:,:);
show_patch_func(30,vertex_d,face_c,face_patch)