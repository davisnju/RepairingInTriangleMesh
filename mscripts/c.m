
ch_idx=[];
dis_tpch_thred=quantile(abs(dis_tpch),0.9);
figure;
hold on;
for i=1:tn2    
    
    if abs(dis_tpch(i))<dis_tpch_thred
        ch_idx=[ch_idx;i];

        v=[vertex_set(tpis(i,1),:);
           vertex_set(tpis(i,2),:);
           vertex_set(tpis(i,3),:)];
        plot3(v([1:end,1],1),v([1:end,1],2),v([1:end,1],3),'.-',...
            'Color',color_RGB(vertex_ds_label==find_in_universe(ds_u,tpis(i,1)),:)); 
    end
end
grid on;