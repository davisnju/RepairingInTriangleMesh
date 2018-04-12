% advancing front mesh generation loop
disp(['loop ' num2str(loop_i) ':']);
min_edge_length_th=0.00001;
%% get min theta and vid
border_num=length(border_l);
i=0;
for i=1:1:length(border_l)
    border_num=length(border_l);
    if  i>border_num 
        break;
    end
    min_theta=ones(border_num,1)*2*pi;% min theta for each border
    min_theta_vi=zeros(border_num,1);% vertex idx with min theta for each border
    bli=border_l(i);
    v_bli=border_vid{i};%vertex on border Label=lli
    
    vn_bli=size(v_bli,1);
    %  test31c
    if max(vertex_m(v_bli,2))>0.9 ...
        || vn_bli<5 && border_num>2 && max(vertex_m(border_vid{1},2))<0.9
        continue;
    end
    
    if vn_bli<3
        border_l(border_l==bli)=[];
        border_vid_num=size(border_vid,1);
        for j=i:border_vid_num-1
            border_vid{j}=border_vid{j+1};
        end
        continue;
    end
    
    %find v1_3 v2_3
    s=floor(vn_bli/3); % >=1
    v1_3=v_bli( 1+s );
    v2_3=v_bli( 1+s*2 );
    v0=v_bli(1);
    normal_border=normal4plane(vertex_m(v0,:),...
        vertex_m(v1_3,:),vertex_m(v2_3,:));
    normal_border=normal_border/norm(normal_border);
    %     adj_edge_vertex=find_nonborder_neighbor(v_bli(vi),adj_list_m,isborder);
    %     v0nnb=adj_edge_vertex(1);
    %     if (vertex_m(v0nnb,:)-vertex_m(v0,:))*normal_border'>0
    if check_hole_normal(vertex_m,v_bli,adj_list_m,isborder,normal_border)
        disp(' ');
%         normal_border=-normal_border;
    end
    %     normal_border=[0 0 1];
    %     disp('search min theta for border i:')
    for vi=1:vn_bli
        v1idx=v_bli(vi);
        v1=vertex_m(v1idx,:);
        vec12=vertex_m(v_bli(calc_next_idx(vi,vn_bli)),:)-v1;
        vec13=vertex_m(v_bli(calc_prev_idx(vi,vn_bli)),:)-v1;
        theta_i=vec3ang_with_dir(vec12, vec13,normal_border);
        
        if theta_i<min_theta(i)
            min_theta(i)=theta_i;
            %             disp([num2str(theta_i)]);
            min_theta_vi(i)=vi;
        end
    end
    %% generate vertex on min_theta plane
    v1idx_ob=min_theta_vi(i);% no. on border, [1,bvn]
    v1idx=v_bli(v1idx_ob);
    %     disp(['border ' num2str(i) ': v1 idx:' num2str(v1idx)])
    %     disp(['min theta:' num2str(min_theta(i)) ])
    %     normalv1=normalv(:,v1idx)';
    v2idx=v_bli(calc_next_idx(v1idx_ob,vn_bli));
    v3idx=v_bli(calc_prev_idx(v1idx_ob,vn_bli));
    v1=vertex_m(v1idx,:);
    vec12=vertex_m(v2idx,:)-v1;
    vec13=vertex_m(v3idx,:)-v1;
    
%     quiver3(v1(1),v1(2),v1(3),...
%         vec12(1),vec12(2),vec12(3),'g','LineWidth',2);
%     
%     quiver3(v1(1),v1(2),v1(3),...
%         vec13(1),vec13(2),vec13(3),'g','LineWidth',1);
%     
%     quiver3(0,0,0,...
%         normal_border(1),normal_border(2),normal_border(3),'g','LineWidth',1);
%     T=[vertex_m(v0,:);...
%         vertex_m(v1_3,:);...
%         vertex_m(v2_3,:)];
%     scatter3(T(:,1),T(:,2),T(:,3),'m','filled');
    
    
    % ============ di ==========
    connected_border_idx=[];%compute_conn_border_idx(bli,border_l,border_vid,hv_u_matrix,adj_list_m);
    bid=1:border_num;
    bid([i;connected_border_idx])=[];
    if border_num>1 && isempty(bid) || vn_bli<=4 ...
            || rotate_face_default==0
        rotate_face=0;
    else
        rotate_face=1;
        ma=ones(border_num,1);
        for l=1:border_num
            ma(l)=length(border_vid{l});
        end
        dir1=compute_growdir(v1idx,vertex_m,bid,border_vid,ma);
        dir2=compute_growdir(v2idx,vertex_m,bid,border_vid,ma);
        dir3=compute_growdir(v3idx,vertex_m,bid,border_vid,ma);
    end
    
    if cross(vec12,vec13)*normal_border'<0
        [vec12, vec13]=exchange(vec12,vec13);
        %         [v2idx, v3idx]=exchange(v2idx,v3idx);
    end
    v2=vertex_m(v2idx,:);
    v3=vertex_m(v3idx,:);
    vec12=vertex_m(v2idx,:)-v1;
    vec13=vertex_m(v3idx,:)-v1;
    
    % ===== connect two neighbor =====
    if min_theta(i)<theta_thred1
        disp(['border ' num2str(i) ': add no vertex,just connect']);
        %         [vp_idx,dis]=check_merge(vp_rot,vertex_m,find(isborder==1),edge_len_mean*point_merge_th_factor);
        if 0 && vp_idx>0
            merge_point;
        else
            connect2vertex;
        end
        % ===== add one vertex,edge length=avg(vec1len,vec2len) =====
    elseif min_theta(i)<theta_thred2
        disp(['border ' num2str(i) ': add one vertex'])
        % get bisector
        vec1n=norm(vec12);
        vec2n=norm(vec13);
        vec12=vec12/vec1n;
        vec13=vec13/vec2n;
        edge_length=max([mean([vec1n vec2n]),min_edge_length_th]);
        bisector=vec12+vec13;
        bisector=bisector/norm(bisector);
        
        
        rotate_angle=0;
        
        if rotate_face
            n=cross(vec12,vec13);
            n=n/norm(n);
            % ============ rotate vertex,  ref liu yong mei ===========
            %             neighbor_idx0=adj_list_m{v2idx};
            %             v20idx=intersect(neighbor_idx0,neighbor_idx);
            %             v20neighbor=v20idx(ol(v20idx)==1);
            %             v20neighbor_t=v20neighbor(hv_u_matrix(v20neighbor,1)==bli);
            %             v20=vertex_m(v20neighbor_t,:);
            %             neighbor_idx1=adj_list_m{v3idx};
            %             v31idx=intersect(neighbor_idx1,neighbor_idx);
            %             v31neighbor=v31idx(ol(v31idx)==1);
            %             v31neighbor_t=v31neighbor(hv_u_matrix(v31neighbor,1)==bli);
            %             v31=vertex_m(v31neighbor_t,:);
            %             n0=normal4plane(v1,v2,v20(1,:));
            %             n1=normal4plane(v1,v3,v31(1,:));
            %             beta0=angplane(n0,n);
            %             beta1=angplane(n1,n);
            %             beta=angplane(n0,n1);
            %             if min_theta(i)>pi/2
            %                 beta=pi-beta;   %[0,pi]
            %             end
            %             rotate_angle=(beta0+beta1)/4*(1+alpha*beta/pi);
            
            % =================== ours ===========================
            dir=dir3*vec2n+dir2*vec1n+dir1;
            d=norm(dir);d=max(d,eps);
            dir=dir/d;
            n_v=cross(bisector,n);
            d=norm(n_v);d=max(d,eps);
            n_v=n_v/d;
            dir_s=dir-n_v*(dir*n_v');
            rotate_angle=vec3ang_with_dir(bisector,dir_s,n_v);
        end
        
        rotate_axis=cross(bisector,n);
        rotate_axis=rotate_axis/norm(rotate_axis);
        h = makehgtform('axisrotate',rotate_axis,rotate_angle);
        n2 = h(1:3,1:3)*bisector(:);
        vp_rot=v1+edge_length*n2(:)';
        
        % ===== normal
        nf1=normal4plane(v1,v2,vp_rot)';
        nf2=normal4plane(v3,v1,vp_rot)';
        if vec3theta(nf1,nf2)>0.7
            vp_rot2=v1+edge_length*bisector;
        end
        % quiver3(v1(1),v1(2),v1(3), vp_rot(1)-v1(1),vp_rot(2)-v1(2),vp_rot(3)-v1(3),'g','LineWidth',2);
        
        % check vertex merge
        [vp0_idx,dis]=check_merge(vp_rot,vertex_m,find(isborder==1),edge_len_mean*point_merge_th_factor);
        if vp0_idx>0
            % get idx
            disp('merge');
            merge_point;
        else
            vmn=size(vertex_m,1);
            
            disp(['v new (' num2str(vp_rot(1)),',',...
                num2str(vp_rot(2)),',',...
                num2str(vp_rot(3)),')']);
            
            vertex_m=[vertex_m;vp_rot];
            vp_idx=vmn+1;
            
            % update normalv
            normalv=[normalv  normal4plane(v1,v2,vp_rot)'];
            
            % ======= update border ======
            % border_vid
            border_vid{i}(border_vid{i}==v1idx)=vp_idx;
            %   ol
            ol=[ol;1];
            %   isborder
            isborder=[isborder;1;];
            isborder(v1idx)=0;
            
            %   hv_u_matrix
            v1p=hv_u_matrix(v1idx,1);
            hv_u_matrix=[hv_u_matrix;v1p 0 1;];
            if v1p==v1idx
                % v1 is root !!!!!!
                this_border_vid=hv_u_matrix(:,1)==v1p;
                v1p=vp_idx;
                hv_u_matrix(this_border_vid,1)=v1p;
                hv_u_matrix(v1p,2)=hv_u_matrix(v1idx,2);
                hv_u_matrix(v1p,3)=hv_u_matrix(v1idx,3);
                
                border_l(border_l==v1idx)=v1p;
            end
            hv_u_matrix(v1idx,1)=v1idx;  % v1 no longer on border
            hv_u_matrix(v1idx,2)=0;
            hv_u_matrix(v1idx,3)=1;
            
            %   adj_list_m
            adj_list_m{v1idx}=[adj_list_m{v1idx}, vp_idx];
            adj_list_m{v2idx}=[adj_list_m{v2idx}, vp_idx];
            adj_list_m{v3idx}=[adj_list_m{v3idx}, vp_idx];
            adj_list_m{vp_idx}=[v1idx v2idx v3idx];
            
            
            new_patch=[[v1idx v2idx vp_idx];
                [v1idx vp_idx v3idx];];
            %             disp(['new patch:' '('...
            %                 num2str(new_patch(1,1)),','...
            %                 num2str(new_patch(1,2)),','...
            %                 num2str(new_patch(1,3)) ...
            %                 ') ('...
            %                 num2str(new_patch(2,1)),','...
            %                 num2str(new_patch(2,2)),','...
            %                 num2str(new_patch(2,3)) ')']);
            
            face_patch=[face_patch;new_patch];
            face_m=[face_m;new_patch];
            fmn=size(face_m,1);
            vertex_adj_face{v2idx}=[vertex_adj_face{v2idx};fmn-1];
            vertex_adj_face{v3idx}=[vertex_adj_face{v3idx};fmn];
            vertex_adj_face{vp_idx}=[fmn-1;fmn];
        end
        
        % ===== add two vertex,edge length=avg(vec1len,vec2len) =====
    else
        % get trisector
        disp(['border ' num2str(i) ': add two vertex'])
        vec1n=norm(vec12);
        vec2n=norm(vec13);
        edge_length=max([mean([vec1n vec2n]),min_edge_length_th]);
        theta_3=min_theta(i)/3;
        vec12=vec12/vec1n;
        vec13=vec13/vec2n;
        
        %             (vp-v1)*vec1=cos(theta_3);
        %             (vp-v1)*vec2=cos(theta_3*2);
        syms x y z
        eqns=[([x y z]-v1)*vec12'==cos(theta_3), ...
            ([x y z]-v1)*vec13'==cos(theta_3*2),...
            sum(([x y z]-v1).^2)==1];
        [solx, soly, solz] = solve(eqns, [x y z]);
        trisector1=[real(double(solx(1))) real(double(soly(1))) real(double(solz(1)))]-v1;
        trisector1=trisector1/norm(trisector1);
        eqns=[([x y z]-v1)*vec12'==cos(theta_3*2), ...
            ([x y z]-v1)*vec13'==cos(theta_3),...
            sum(([x y z]-v1).^2)==1];
        [solx, soly, solz] = solve(eqns, [x y z]);
        trisector2=[real(double(solx(1))) real(double(soly(1))) real(double(solz(1)))]-v1;
        trisector2=trisector2/norm(trisector2);
        rotate_angle=0;
        rotate_angle1=0;
        rotate_angle2=0;
        if rotate_face
            
            n=cross(vec12,vec13);
            n=n/norm(n);
            
            % ============ rotate vertex,  ref liu yong mei ===========
            %             neighbor_idx=adj_list_m{v1idx};
            %             neighbor_idx0=adj_list_m{v2idx};
            %             v20idx=intersect(neighbor_idx0,neighbor_idx);
            %             v20neighbor=v20idx;%(ol(v20idx)==1);
            %             v20=vertex_m(v20neighbor,:);
            %             neighbor_idx1=adj_list_t{v3idx};
            %             v31idx=intersect(neighbor_idx1,neighbor_idx);
            %             v31neighbor=v31idx;%(ol(v31idx)==1);
            %             v31=vertex_m(v31neighbor,:);
            %             n0=normal4plane(v1,v2,v20(1,:));
            %             n1=normal4plane(v1,v3,v31(1,:));
            %             beta0=angplane(n0,n);
            %             beta1=angplane(n1,n);
            %             beta=angplane(n0,n1);
            %
            %             if min_theta(i)>pi/2
            %                 beta=pi-beta;   %[0,pi]
            %             end
            %             rotate_angle=(beta0+beta1)/4*(1+alpha*beta/pi);
            
            
            % ====================== ours =============================
            
            %angle1
            dir=dir1+dir2;
            d=norm(dir);d=max(d,eps);
            dir=dir/d;
            n_v=cross(trisector1,n);
            d=norm(n_v);d=max(d,eps);
            n_v=n_v/d;
            dir_s=dir-n_v*(dir*n_v');
            rotate_angle1=vec3ang_with_dir(trisector1,dir_s,n_v);
            %angle2
            dir=dir1+dir3;
            d=norm(dir);d=max(d,eps);
            dir=dir/d;
            n_v=cross(trisector2,n);
            d=norm(n_v);d=max(d,eps);
            n_v=n_v/d;
            dir_s=dir-n_v*(dir*n_v');
            rotate_angle2=vec3ang_with_dir(trisector2,dir_s,n_v);
        end
        
        rotate_axis=vec12;%cross(trisector1,n);
        rotate_axis=rotate_axis/norm(rotate_axis);
        h = makehgtform('axisrotate',rotate_axis,rotate_angle1);
        n12 = h(1:3,1:3)*trisector1(:);
        vp1_rot=v1+edge_length*n12(:)';
        
        rotate_axis=-vec13;%cross(trisector2,n);
        rotate_axis=rotate_axis/norm(rotate_axis);
        h = makehgtform('axisrotate',rotate_axis,rotate_angle2);
        n22 = h(1:3,1:3)*trisector2(:);
        vp2_rot=v1+edge_length*n22(:)';
        
        ang2p1=vec3ang_with_dir(vec12,vp1_rot-v1,n);
        if ang2p1>pi
            ang2p1=pi-ang2p1;
        end
        ang2p2=vec3ang_with_dir(vec12,vp2_rot-v1,n);
        if ang2p2>pi
            ang2p2=pi-ang2p2;
        end
        if ang2p1 > ang2p2
            figure(25);
            quiver3(v1(1),v1(2),v1(3),...
                vec12(1),vec12(2),vec12(3),'b','LineWidth',2);
            
            quiver3(v1(1),v1(2),v1(3),...
                vec13(1),vec13(2),vec13(3),'b','LineWidth',1);
            [vp1_rot,vp2_rot]=exchange(vp1_rot,vp2_rot);
        end
        % check vertex merge
        [vp10_idx,d1]=check_merge(vp1_rot,vertex_m,find(isborder==1),point_merge_th_factor*edge_len_mean);
        [vp20_idx,d2]=check_merge(vp2_rot,vertex_m,find(isborder==1),point_merge_th_factor*edge_len_mean);
        if ( vp10_idx>0 || vp20_idx>0 )
            disp('merge two point');
            % get idx
            merge_point2;
            
            % check border merge
            
        else
            vmn=size(vertex_m,1);
            % update vertex_m
            vertex_m=[vertex_m;vp1_rot;vp2_rot];
            vp1_idx=vmn+1;
            vp2_idx=vmn+2;
            
            % update normalv
            normalv=[normalv normal4plane(v1,v2,vp1_rot)' normal4plane(v1,vp1_rot,v3)'];
            
            % ======= update border ======
            % border_vid
            v_bli=[v_bli([1:(v1idx_ob-1)]);...
                vp2_idx;vp1_idx;...
                v_bli([v1idx_ob+1:end])];
            border_vid{i}=v_bli;
            %   ol
            ol=[ol;1; 1;];
            %   isborder
            isborder=[isborder;1;1;];
            isborder(v1idx)=0;
            
            %   hv_u_matrix
            
            v1p=hv_u_matrix(v1idx,1);
            hv_u_matrix=[hv_u_matrix;v1p 0 1;v1p 0 1;];
            hv_u_matrix(v1p,3)=hv_u_matrix(v1p,3)+2;
            if v1p==v1idx
                % v1 is root !!!!!!
                this_border_vid=hv_u_matrix(:,1)==v1p;
                v1p=vp_idx;
                hv_u_matrix(this_border_vid,1)=v1p;
                hv_u_matrix(v1p,2)=1;
                hv_u_matrix(v1p,3)=hv_u_matrix(v1idx,3);
                
                border_l(border_l==v1idx)=v1p;
            end
            hv_u_matrix(v1idx,1)=v1idx;  % v1 no longer on border
            hv_u_matrix(v1idx,2)=0;
            hv_u_matrix(v1idx,3)=1;
            
            %   adj_list_m
            adj_list_m{v1idx}=[adj_list_m{v1idx}, vp1_idx, vp2_idx];
            adj_list_m{v2idx}=[adj_list_m{v2idx}, vp1_idx];
            adj_list_m{v3idx}=[adj_list_m{v3idx}, vp2_idx];
            adj_list_m{vp1_idx}=[v1idx v2idx vp2_idx];
            adj_list_m{vp2_idx}=[vp1_idx v1idx v3idx];
            
            new_patch=[[v1idx v2idx vp1_idx];
                [v1idx vp1_idx vp2_idx];
                [v1idx vp2_idx v3idx];];
            
            face_patch=[face_patch;new_patch];
            face_m=[face_m;new_patch];
            
            fmn=size(face_m,1);
            vertex_adj_face{v2idx}=[vertex_adj_face{v2idx};fmn-2];
            vertex_adj_face{v3idx}=[vertex_adj_face{v3idx};fmn];
            vertex_adj_face{vp1_idx}=[fmn-2;fmn-1];
            vertex_adj_face{vp2_idx}=[fmn-1;fmn];
        end
    end
    
    
end %for each border

%% show patch
% subplot(2,1,2)
% show_patch

