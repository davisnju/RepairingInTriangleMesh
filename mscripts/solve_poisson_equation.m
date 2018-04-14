% solve poisson equation

%% 
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

vertex_rot2=vertex_rot;
vertex_rot=vertex;
for i=1:nvert
    vertex_rot(i,:)=vertex_rot2(vids(i),:);
end
%
figure(28);
clf;
subplot(1,2,1)
hold off
trisurf(face,vertex(:,1),vertex(:,2),vertex(:,3),...
    'facecolor','b');
axis([-1 1 -1 1 0 1]);
grid off
subplot(1,2,2)
for i=1:nface    
    trisurf([1 2 3],vertex_face(i,:,1),vertex_face(i,:,2),vertex_face(i,:,3),...
        'facecolor','r');
    hold on
end
grid off
axis([-1 1 -1 1 0 1]);
xlabel('x');
ylabel('y');
zlabel('z');

%%
nv=size(vertex_m,1);
pvn=patch_v_num;     % new vertex num

vertex_ref=vertex_m;

isborder=zeros(nv,1);
isborder(v_hb_idx)=1;
border_idx=v_hb_idx;
vertex_id_ref=[border_idx;patch_v_idx'];
% vn_raw=size(vertex_c,1);
face_n= size(face_m,1);
% facen_raw=size(face_c,1);
% patch_v_num=size(vertex_m,1)-vn_raw;
% patch_v_idx=vn_raw+1:size(vertex_m,1);

% face include patch vertex
bvn=length(border_idx);
face_ref_idx=(facen_raw+1):1:face_n;
for i=1:bvn
    vid=border_idx(i);
    nf_idx=[find(face_m(:,1)==vid);
        find(face_m(:,2)==vid);
        find(face_m(:,3)==vid);];
    nf_idx=nf_idx(nf_idx<=facen_raw);
    face_ref_idx=[face_ref_idx nf_idx'];
end
face_ref_idx=unique(face_ref_idx);
face_ref=face_m(face_ref_idx,:);
face_ref_num=size(face_ref,1);
%%
%% grad
grad_face=zeros(face_n,3,3);
for i=1:face_n
    face_i=face_m(i,:);
    if i<=facen_raw
        vs=vertex_m(face_i,:);
    else
        vs=vertex_rot(face_i,:);
    end
    vij=vs(2,:)-vs(1,:);
    vik=vs(3,:)-vs(1,:);
    nf=cross(vij,vik);
    d=norm(nf);d=max(d,eps);
    nf=nf/d;
    a=area_tri(vs(1,:),vs(2,:),vs(3,:));
    for xyz=1:3  %three v for fi
        grad_face(i,xyz,:)=[0 0 0];
        for j=1:3
            ei=vertex_rot(face_i(mod(j+1,3)+1),:)-...
                vertex_rot(face_i(mod(j,3)+1),:);
            grad=vertex_rot(face_i(j),xyz)*0.5/a*cross(nf,ei);
            grad_face(i,xyz,1)=grad_face(i,xyz,1)+grad(1);
            grad_face(i,xyz,2)=grad_face(i,xyz,2)+grad(2);
            grad_face(i,xyz,3)=grad_face(i,xyz,3)+grad(3);
        end
    end
end

%% Divergence

% calc div_h_vb of border vertex
dim=pvn+bvn;
divergence_pb=zeros(nv,3);
for i=1:nv
    vid=i;%vertex_id_ref(i);
    nf_idx=[find(face_m(:,1)==vid);
        find(face_m(:,2)==vid);
        find(face_m(:,3)==vid);];
    bfn=length(nf_idx);
    for j=1:bfn
        %     deltaik  3x1
        fi=face_m(nf_idx(j),:);
        if nf_idx(j)<=facen_raw
            vs=vertex_m(fi,:);
        else
            vs=vertex_rot(fi,:);
        end
        a=area_tri(vs(1,:),vs(2,:),vs(3,:));
        for k=1:3
            if fi(k)==vid
                %                 ei = vertex_m(fi(mod(k+1,3)+1),:)-...
                %                     vertex_m(fi(mod(k,3)+1),:);
                %                 e1 = vertex_m(fi(mod(k,3)+1),:)-...
                %                     vertex_m(fi(k),:);
                %                 e2 = vertex_m(fi(mod(k+1,3)+1),:)-...
                %                     vertex_m(fi(k),:);
                %                 cot_a1=cot(vec3theta(e2,ei));
                %                 cot_a2=cot(vec3theta(-e1,ei));
                for xyz=1:3
                    grad=[grad_face(nf_idx(j),k,1);
                        grad_face(nf_idx(j),k,2);
                        grad_face(nf_idx(j),k,3);];
                    %                     divergence_pb(i,xyz)=divergence_pb(i,xyz)+...
                    %                         0.5*(cot_a1*(e1*grad)+...
                    %                         cot_a2*(e2*grad));
                    
                    divergence_pb(i,xyz)=divergence_pb(i,xyz)+...
                        h(vid,:)*grad*a;
                end
                break;
            end
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
A = compute_mesh_laplacian(vertex_p,face_p,type,options); % use cot wij

%%
vx=zeros(nv,3);
flags=[0 0 0];
% Ax
Ax=zeros(nv,nv);

SAx=sparse(Ax);

for coord=1:3
    % solve poisson equation
    % ================ solve x ==========================
    [x,flag]=gmres(SAx,b(:,coord),40,1e-7,1000);
    disp(['co ' num2str(coord) ' flag ' num2str(flag)])
    flags(coord)=flag;
    if ~flag
        vx(:,coord)=x;
    end
end
%% update patch vertex
for i=1:pvn
    vid=patch_v_idx(i);
    for coord=1:3
        if ~flags(coord) || 1
            vertex_ref(vid,coord)=vx(vid,coord);
        end
    end
end

%%
% show
figure(4);

subplot(1,2,1)
hold off
trisurf(face_c,vertex_m(:,1),vertex_m(:,2),vertex_m(:,3),...
    'facecolor','b');
hold on
grid off
trisurf(face_patch,vertex_m(:,1),vertex_m(:,2),vertex_m(:,3),...
    'facecolor','y');
axis([-2 2 -2 2 -2 2]);
% view([-160 40])
xlabel('x');
ylabel('y');
zlabel('z');
hold off

subplot(1,2,2)
hold off
trisurf(face_c,vertex_m(:,1),vertex_m(:,2),vertex_m(:,3),...
    'facecolor','b');
grid off
hold on
trisurf(face_patch,vertex_ref(:,1),vertex_ref(:,2),vertex_ref(:,3),...
    'facecolor','y');

axis([-2 2 -2 2 -2 2]);
% view([-160 40])
xlabel('x');
ylabel('y');
zlabel('z');