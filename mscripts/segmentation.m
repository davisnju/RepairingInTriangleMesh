%% segmentation 
% input
vertex_seg=vertex_c;
face_seg=face_c;
REGION_MERGE_THRESH=0.01;
%
% [normalv,normalf]=compute_normal(vertex_seg,face_seg);
name='segmentation';
clear options;
options.name = name; % useful for displaying
% compute the curvature
options.curvature_smoothing = 2;
options.verb = 0;
[Umin,Umax,Cmin,Cmax,Cmean,Cgauss,Normal] = compute_curvature(vertex_seg,face_seg,options);
% adj matrix
A = triangulation2adjacency(face_seg,vertex_seg);
adj_list = adjmatrix2list(A);
% Cgauss,Cmean,Crms,Cabs
nv=size(vertex_seg,1);
% tic
Crms=sqrt((Cmin.^2+Cmax.^2)./2);
% toc
% tic
Cabs=abs(Cmin)+abs(Cmax);
% toc
% tic
Lgauss=fast_watershed(nv,Cgauss,adj_list);
% toc
% tic
Lmean=fast_watershed(nv,Cmean,adj_list);
% toc
% tic
Lrms=fast_watershed(nv,Crms,adj_list);
% toc
% tic
Labs=fast_watershed(nv,Cabs,adj_list);
% toc

%% region merge
L=Lrms;
C=Crms;

% region adj matrix
label_face=unique(L(face_seg(:,:)),'rows');

reg_A = triangulation2adjacency(label_face,vertex_seg);
% adjmatrix2list
reg_adj_list = adjmatrix2list(reg_A);

% min region height 
Labels=sort(unique(L));
Lnum=length(Labels);
h_min_reg=zeros(Lnum,1);
for i=1:Lnum
    h_min_reg(i)=min(C(L==Labels(i)));
end

for i=1:Lnum
    reg_adj_list{i}=setdiff(reg_adj_list{i},i);
end

% min relative height
Hr=Inf(Lnum,Lnum);
for i=1:Lnum
    Hr(i,i)=0;
end
nv=size(vertex_seg,1);
for i=1:nv
    lv=L(i);
    cv=C(i);
    idx_neighbors=adj_list{i};
    lv_neighbors=L(idx_neighbors);
    [l,lidx]=unique([lv_neighbors(:)]);
    llen=length(l);
    for j=1:llen
        if l(j)~=lv
            Hr(l(j),lv)=min([Hr(l(j),lv),cv]);
        end
    end
end
Hr=min(Hr,Hr');
% merge
th=REGION_MERGE_THRESH;
Lm=L;
num_merges=0;
while 1
    cblist=sort(unique(Lm));
    cblist2=cblist;
    cblnum=length(cblist);
    for i=1:cblnum
        l=cblist2(i);
        if isempty(find(cblist==l,1))
            continue;
        end
        cblist_l=intersect(cblist,reg_adj_list{l});
        if ~isempty(cblist_l)
            [wh,ki]=min(Hr(l,cblist_l));
            k=cblist_l(ki);
            if k==l
                continue;
            end
            hr_lk=Hr(l,k);
            if (hr_lk-h_min_reg(l)) < th ...
                    && (hr_lk - h_min_reg(k))<th
                % merge k to l
                display(['merge ' num2str(k) ' to ' num2str(l)])
                Lm(Lm==k)=l;
                % remove k from cblist
                cblist(cblist==k)=[];
                % l inherits N(k) except duplicates
                h_min_reg(l)=min([h_min_reg(l) h_min_reg(k)]);
                reg_adj_list{l}=unique([l reg_adj_list{l} reg_adj_list{k}]);
                radj_k_len=length(reg_adj_list{k});
                for j=1:radj_k_len
                    p=reg_adj_list{k}(j);
                    Hr(l,p)=min([Hr(l,p) Hr(k,p)]);
                end
                
                num_merges=num_merges+1;
            end
        end
    end
    if num_merges == 0
        break;
    else
        num_merges=0;
    end
end

%%
% figure;
% subplot(2,2,1);
% hold on;
% scatter3(vertex_seg(:,1),vertex_seg(:,2),vertex_seg(:,3),...
%     'filled',...
%     'cdata',Lgauss);
% axis([-15 15 -15 15 -5 15]);
% view(0,0);
% % view(2);
% title('Lgauss');
% subplot(2,2,2);
% hold on;
% scatter3(vertex_seg(:,1),vertex_seg(:,2),vertex_seg(:,3),...
%     'filled',...
%     'cdata',Lmean);
% axis([-15 15 -15 15 -5 15]);
% view(0,0);
% % view(2);
% title('Lmean');
% subplot(2,2,3);
% hold on;
% scatter3(vertex_seg(:,1),vertex_seg(:,2),vertex_seg(:,3),...
%     'filled',...
%     'cdata',Lrms);
% % axis([-15 15 -15 15 -5 15]);
% % view(0,0);view(2);
% title('Lrms');
% subplot(2,2,4);
% hold on;
% scatter3(vertex_seg(:,1),vertex_seg(:,2),vertex_seg(:,3),...
%     'filled',...
%     'cdata',Labs);
% axis([-15 15 -15 15 -5 15]);
% view(0,0);
% % view(2);
% title('Labs');

% %%
% nv=size(vertex,1);
% global ds_u;
% ds_u=table([1:nv]',zeros(nv,1),ones(nv,1));%[p,r,s]
% ds_u.Properties.VariableNames = {'p','r','s'};
% % global ds_u_size;
% ds_u_size=nv;
% for i=1:ne
%     edge_i=edge_set(i,:);
%     a=find_in_universe(ds_u,edge_i(1));
%     b=find_in_universe(ds_u,edge_i(2));
%     if a~=b
%         join_dsu(ds_u,a,b);
%         ds_u_size=ds_u_size-1;
%     end
% end
% 
% 
% %·Ö¸î
% vertex_ds_label= unique(ds_u.p);
% [max_size_u,large_u_label_idx]=max(ds_u.s(vertex_ds_label));
% large_u_label = vertex_ds_label(large_u_label_idx);
% 
% large_u=[];
% for i=1:nv
%     v=vertex_set(i,:);
%     tp_label = find_in_universe(ds_u,i);
%     if tp_label == large_u_label
%         large_u = [large_u;v];
%     end    
% end
