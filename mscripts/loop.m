% advancing front mesh generation loop
disp(['loop ' num2str(loop_i) ':']);
%% get min theta and vid
min_theta=ones(border_num,1)*2*pi;% min theta for each border
min_theta_vi=zeros(border_num,1);% vertex idx with min theta for each border
for i=1:size(border_l,1)
    bli=border_l(i);
    v_bli=find(hv_u_matrix(:,1)==bli);%vertex on border Label=lli
    vn_bli=size(v_bli,1);
    front_size=vn_bli;
    if vn_bli<3
        border_l(border_l==bli)=[];
        continue;
    end
    normal_border=zeros(vn_bli,3);
    theta_border=zeros(vn_bli,1);
    for vi=1:vn_bli
        v1idx=v_bli(vi);
        v1=vertex_m(v1idx,:);
        %get adj edge to vi
        neighbor_idx=adj_list_t{v_bli(vi)};
        adj_edge_vertex=neighbor_idx(isborder(neighbor_idx)==1);
        v2idx=adj_edge_vertex(1);
        v2=vertex_m(v2idx,:);
        v3idx=adj_edge_vertex(2);
        v3=vertex_m(v3idx,:);
        vec12=v2-v1;
        vec13=v3-v1;
        %==== hole on left along border ==========
        % adj facet
        v1_adj_facet_idx=vertex_adj_face{v1idx};
        v1_adj_facet=face_m(v1_adj_facet_idx,:);
        v12face_idx=find(v1_adj_facet(:,1)==v2idx);
        v12face_idx=[v12face_idx;find(v1_adj_facet(:,2)==v2idx)];
        v12face_idx=[v12face_idx;find(v1_adj_facet(:,3)==v2idx)];
        v12face=v1_adj_facet(v12face_idx,:);
        vx=setdiff(v12face,[v1idx v2idx]);
        n=normal4plane(vertex_m(v12face(1,1),:),vertex_m(v12face(1,2),:),vertex_m(v12face(1,3),:));
        flip=n*normal4plane(v1,v2,vertex_m(vx,:))'>0;
        if flip
            [v2,v3]=exchange(v2,v3);
        end
        vec12=v2-v1;
        vec13=v3-v1;
        normal_border(vi,:)=cross(vec12,vec13);
        theta_border(vi)=vec3theta(vec12,vec13);
    end
    normal_border_a=mean(normal_border);
    
    for vi=1:vn_bli
        v1idx=v_bli(vi);
        v1=vertex_m(v1idx,:);
        %get adj edge to vi
        neighbor_idx=adj_list_t{v_bli(vi)};
        adj_edge_vertex=neighbor_idx(isborder(neighbor_idx)==1);
        v2idx=adj_edge_vertex(1);
        v2=vertex_m(v2idx,:);
        v3idx=adj_edge_vertex(2);
        v3=vertex_m(v3idx,:);
        vec12=v2-v1;
        vec13=v3-v1;
        %==== hole on left along border ==========
        % adj facet
        v1_adj_facet_idx=vertex_adj_face{v1idx};
        v1_adj_facet=face_m(v1_adj_facet_idx,:);
        v12face_idx=find(v1_adj_facet(:,1)==v2idx);
        v12face_idx=[v12face_idx;find(v1_adj_facet(:,2)==v2idx)];
        v12face_idx=[v12face_idx;find(v1_adj_facet(:,3)==v2idx)];
        v12face=v1_adj_facet(v12face_idx,:);
        vx=setdiff(v12face,[v1idx v2idx]);
        n=normal4plane(vertex_m(v12face(1,1),:),vertex_m(v12face(1,2),:),vertex_m(v12face(1,3),:));
        flip=n*normal4plane(v1,v2,vertex_m(vx,:))'>0;
        if flip
            [v2,v3]=exchange(v2,v3);
        end
        vec12=v2-v1;
        vec13=v3-v1;
        theta_i=vec3ang_with_dir(vec12, vec13,normal_border_a);
        
        if theta_i<min_theta(i)
            min_theta(i)=theta_i;
            min_theta_vi(i)=v1idx;
        end
    end
    
    
    %% generate vertex on min_theta plane
    v1idx=min_theta_vi(i);
    neighbor_idx=adj_list_t{v1idx};
    adj_edge_vertex=neighbor_idx(isborder(neighbor_idx)==1);
    v1=vertex_m(v1idx,:);
    v2idx=adj_edge_vertex(1);
    v3idx=adj_edge_vertex(2);
    v2=vertex_m(v2idx,:);
    v3=vertex_m(v3idx,:);
    
    normalv1=normalv(:,v1idx);
    vec12=v2-v1;
    vec13=v3-v1;
    
    if cross(vec12,vec13)*normalv1<0
        [vec12, vec13]=exchange(vec12,vec13);
        [v2, v3]=exchange(v2,v3);
        [v2idx, v3idx]=exchange(v2idx,v3idx);
    end
    
    % ===== connect two neighbor =====
    if min_theta(i)<theta_thred1
        disp(['border ' num2str(i) ': add no vertex,just connect']);
        if 0 % (check_merge(vp_rot,vertex_m,find(isborder==1),edge_len_mean*0.3))
            merge_point();
        else
            % ======= update border ======
            %   isborder
            isborder(v1idx)=0;
            %   hv_u_matrix
            v1p=hv_u_matrix(v1idx,1);
            hv_u_matrix(v1p,3)=hv_u_matrix(v1p,3)-1;
            if v1p==v1idx
                % v1 is root !!!!!!
                this_border_vid=hv_u_matrix(:,1)==v1p;
                v1p=max([v2idx v3idx]);
                hv_u_matrix(this_border_vid,1)=v1p;
                hv_u_matrix(v1p,2)=1;
                hv_u_matrix(v1p,3)=hv_u_matrix(v1idx,3);
                
                border_l(border_l==v1idx)=v1p;
            end
            hv_u_matrix(v1idx,1)=v1idx;  % v1 no longer on border
            hv_u_matrix(v1idx,2)=0;
            hv_u_matrix(v1idx,3)=1;
            
            %   adj_list_t
            adj_list_t{v2idx}=[adj_list_t{v2idx}, v3idx];
            adj_list_t{v3idx}=[adj_list_t{v3idx}, v2idx];
            
            new_patch=[v1idx v2idx v3idx];
            face_patch=[face_patch;new_patch];
            face_m=[face_m;new_patch];
            fmn=size(face_m,1);
            vertex_adj_face{v2idx}=[vertex_adj_face{v2idx};fmn];
            vertex_adj_face{v3idx}=[vertex_adj_face{v3idx};fmn];
        end
        % ===== add one vertex,edge length=avg(vec1len,vec2len) =====
    elseif min_theta(i)<theta_thred2
        disp(['border ' num2str(i) ': add one vertex'])
        % get bisector
        vec1n=norm(vec12);
        vec2n=norm(vec13);
        vec12=vec12/vec1n;
        vec13=vec13/vec2n;
        edge_length=mean([vec1n vec2n]);
        bisector=vec12+vec13;
        bisector=bisector/norm(bisector);
        
        % ============ rotate vertex,  ref liu yong mei ===========
        d=edge_length;
        n=cross(vec12,vec13);
        n=n/norm(n);
        
        % judge direction
        if n*normalv1<0
            n=-n;
        end
        
        %         vec12angle_dir=vec3ang_with_dir(vec1,vec2,n);
        %         if abs(vec12angle_dir-min_theta(i))>0.0001
        %             % excahnge vec1 vec2
        %             [vec1,vec2]=exchange(vec1,vec2);
        %         end
        
        neighbor_idx0=adj_list_t{v2idx};
        v20idx=intersect(neighbor_idx0,neighbor_idx);
        v20=vertex_m(v20idx(ol(v20idx)==1),:);
        neighbor_idx1=adj_list_t{v3idx};
        v31idx=intersect(neighbor_idx1,neighbor_idx);
        v31=vertex_m(v31idx(ol(v31idx)==1),:);
        n0=normal4plane(v1,v2,v20(1,:));
        n1=normal4plane(v1,v3,v31(1,:));
        beta0=angplane(n0,n);
        beta1=angplane(n1,n);
        beta=angplane(n0,n1);
        if min_theta(i)>pi/2
            beta=pi-beta;   %[0,pi]
        end
        rotate_angle=(beta0+beta1)/4*(1+alpha*beta/pi);
        
        if ~rotate_face
            rotate_angle=0;
        end
        rotate_axis=vec12;%cross(angular_bisector,n);
        rotate_axis=rotate_axis/norm(rotate_axis);
        h = makehgtform('axisrotate',rotate_axis,rotate_angle);
        n2 = h(1:3,1:3)*bisector(:);
        vp_rot=v1+d*n2(:)';
        
        % check vertex merge
        if(check_merge(vp_rot,vertex_m,isborder==1,edge_len_mean*point_merge_th_factor))
            % get idx
            merge_point();
        else
            vmn=size(vertex_m,1);
            vertex_m=[vertex_m;vp_rot];
            vp_idx=vmn+1;
            
            % update normalv
            normalv=[normalv  normal4plane(v1,v2,vp_rot)'];
            
            % ======= update border ======
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
                hv_u_matrix(v1p,2)=1;
                hv_u_matrix(v1p,3)=hv_u_matrix(v1idx,3);
                
                border_l(border_l==v1idx)=v1p;
            end
            hv_u_matrix(v1idx,1)=v1idx;  % v1 no longer on border
            hv_u_matrix(v1idx,2)=0;
            hv_u_matrix(v1idx,3)=1;
            
            %   adj_list_t
            adj_list_t{v1idx}=[adj_list_t{v1idx}, vp_idx];
            adj_list_t{v2idx}=[adj_list_t{v2idx}, vp_idx];
            adj_list_t{v3idx}=[adj_list_t{v3idx}, vp_idx];
            adj_list_t{vp_idx}=[v1idx v2idx v3idx];
            
        end
        new_patch=[[v1idx v2idx vp_idx];
            [v1idx vp_idx v3idx];];
        face_patch=[face_patch;new_patch];
        face_m=[face_m;new_patch];
        fmn=size(face_m,1);
        vertex_adj_face{v2idx}=[vertex_adj_face{v2idx};fmn-1];
        vertex_adj_face{v3idx}=[vertex_adj_face{v3idx};fmn];
        vertex_adj_face{vp_idx}=[fmn-1;fmn];
        
        % ===== add two vertex,edge length=avg(vec1len,vec2len) =====
    else
        % get trisector
        disp(['border ' num2str(i) ': add two vertex'])
        vec1n=norm(vec12);
        vec2n=norm(vec13);
        edge_length=mean([vec1n vec2n]);
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
        % ============ rotate vertex,  ref liu yong mei ===========
        d=edge_length;
        n=cross(vec12,vec13);
        n=n/norm(n);
        
        % judge direction
        if n*normalv1<0
            n=-n;
        end
        
        %         vec12angle_dir=vec3ang_with_dir(vec1,vec2,n);
        %         if abs(vec12angle_dir-min_theta(i))>0.0001
        %             % excahnge vec1 vec2
        %             [vec1,vec2]=exchange(vec1,vec2);
        %         end
        
        neighbor_idx0=adj_list_t{v2idx};
        v20idx=intersect(neighbor_idx0,neighbor_idx);
        v20=vertex_m(v20idx(ol(v20idx)==1),:);
        neighbor_idx1=adj_list_t{v3idx};
        v31idx=intersect(neighbor_idx1,neighbor_idx);
        v31=vertex_m(v31idx(ol(v31idx)==1),:);
        n0=normal4plane(v1,v2,v20(1,:));
        n1=normal4plane(v1,v3,v31(1,:));
        beta0=angplane(n0,n);
        beta1=angplane(n1,n);
        beta=angplane(n0,n1);
        
        if min_theta(i)>pi/2
            beta=pi-beta;   %[0,pi]
        end
        rotate_angle=(beta0+beta1)/4*(1+alpha*beta/pi);
        
        if ~rotate_face
            rotate_angle=0;
        end
        
        rotate_axis=vec12;%cross(trisector1,n);
        rotate_axis=rotate_axis/norm(rotate_axis);
        h = makehgtform('axisrotate',rotate_axis,rotate_angle);
        n12 = h(1:3,1:3)*trisector1(:);
        vp1_rot=v1+d*n12(:)';
        
        rotate_axis=vec13;%cross(trisector2,n);
        rotate_axis=rotate_axis/norm(rotate_axis);
        h = makehgtform('axisrotate',rotate_axis,-rotate_angle);
        n22 = h(1:3,1:3)*trisector2(:);
        vp2_rot=v1+d*n22(:)';
        
        if vec3ang_with_dir(vec12,vp1_rot-v1,n)>...
                vec3ang_with_dir(vec12,vp2_rot-v1,n)
            [vp1_rot,vp2_rot]=exchange(vp1_rot,vp2_rot);
        end
        % check vertex merge
        if(check_merge(vp1_rot,vertex_m,isborder==1,point_merge_th*edge_len_mean))
            % get idx
            merge_point();
            
            
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
            
            %   adj_list_t
            adj_list_t{v1idx}=[adj_list_t{v1idx}, vp1_idx, vp2_idx];
            adj_list_t{v2idx}=[adj_list_t{v2idx}, vp1_idx];
            adj_list_t{v3idx}=[adj_list_t{v3idx}, vp2_idx];
            adj_list_t{vp1_idx}=[v1idx v2idx vp2_idx];
            adj_list_t{vp2_idx}=[vp1_idx v1idx v3idx];
        end
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
    
    
end %for each border

%% show patch
show_patch

