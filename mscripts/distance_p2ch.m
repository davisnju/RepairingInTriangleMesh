function [d]=distance_p2ch(p,ch_tp_n)
global CONVHULL_X;
global CONVHULL_K;
di=zeros(ch_tp_n,1);
for j=1:ch_tp_n
    dj=distance2tp(p,...
        [CONVHULL_X(CONVHULL_K(j,1),:);...
        CONVHULL_X(CONVHULL_K(j,2),:);...
        CONVHULL_X(CONVHULL_K(j,3),:)]);
    di(j)=dj;
end

d_min=min(di);
if d_min<0
    d=max(di(di<0));
else
    d=d_min;
end
end