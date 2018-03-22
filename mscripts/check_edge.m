function [rc,listE,listHole]=check_edge(listE,listHole)
rc=0;
if(listE(end,2)==listE(1,1))
    listHole{size(listH,1)+1}=listE;
    listE=[];
else
    rc=-1;
end

end