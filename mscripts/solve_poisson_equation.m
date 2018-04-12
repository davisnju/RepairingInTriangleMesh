% solve poisson equation

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

% h guidance field
h=vertex_rot-vertex_m;

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
    nf=nf/norm(nf);
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
%
% calc b
b=divergence_pb;
%% calc A
%L = compute_mesh_weight(vertex,face,type,options)
clear option
type='conformal';
Laplace_w = compute_mesh_laplacian(vertex_m,face_m,type,options); % cot wij

%%
vx=zeros(nv,3);
flags=[0 0 0];
for coord=1:3
    % Ax  bvnxpvn% 2.7
    Ax=zeros(nv,nv);
%     for i=1:nv
%         vid=i;%vertex_id_ref(i);
%         neighbor_idx=adj_list_aa{vid};
%         nn=length(neighbor_idx);
%         vi=vertex_m(vid,:);
%         for j=1:nn
%             neighbor_idx2=adj_list_aa{neighbor_idx(j)};
%             t2=intersect(neighbor_idx,neighbor_idx2);
%             if length(t2)<2
%                 disp('err');
%                 break;
%             end
%             vj=vertex_m(neighbor_idx(j),:);
%             v1=vertex_m(t2(1),:);
%             v2=vertex_m(t2(2),:);
%             alphaij=vec3theta(vj-v1,vi-v1);
%             betaij=vec3theta(vj-v2,vi-v2);
%             dfvi=0.5*(cot(alphaij)+cot(betaij))*(vi(coord)-vj(coord));
%             vjid=neighbor_idx(j);%find(vertex_id_ref==neighbor_idx(j));
%             Ax(i,vjid)=0.5*(cot(alphaij)+cot(betaij));
%         end
%     end
    SAx=sparse(Ax);
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