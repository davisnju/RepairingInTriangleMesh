function [Lm,Lgauss,Lmean,Lrms,Labs]=mesh_segmentation(face,vertex,smoothing,REGION_MERGE_THRESH)
%% mesh segmentation
% [Lm,Lgauss,Lmean,Lrms,Labs]=mesh_segmentation(face,vertex,smoothing,REGION_MERGE_THRESH)
% input
% face vertex
% smoothing for compute_curvature
% REGION_MERGE_THRESH=0.02;
%
% [normalv,normalf]=compute_normal(vertex_seg,face_seg);

name='segmentation';
clear options;
options.name = name; % useful for displaying
% compute the curvature
options.curvature_smoothing = smoothing;%2;
options.verb = 0;
[~,~,Cmin,Cmax,Cmean,Cgauss,~] = compute_curvature(vertex,face,options);
% adj matrix
A = triangulation2adjacency(face,vertex);
adj_list = adjmatrix2list(A);
% Cgauss,Cmean,Crms,Cabs
nv=size(vertex,1);
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
label_face=unique(L(face(:,:)),'rows');
reg_A = triangulation2adjacency(label_face,vertex);
% adjmatrix2list
reg_adj_list = adjmatrix2list(reg_A);

% min region height
Labels=sort(unique(L));
Lnum=length(Labels);
h_min_reg=zeros(Lnum,1);
for i=1:Lnum
    h_min_reg(i)=min(C(L==Labels(i)));
end

% min relative height
Hr=Inf(Lnum,Lnum);
for i=1:Lnum
    Hr(i,i)=0;
end
nv=size(vertex,1);
for i=1:nv
    lv=L(i);
    cv=C(i);
    idx_neighbors=adj_list{i};
    lv_neighbors=L(idx_neighbors);
    [l,~]=unique([lv_neighbors(:)]);
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
            [~,ki]=min(Hr(l,cblist_l));
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

end