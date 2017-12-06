function [d]=distance2tp(X,tp)
%点到三角面片的距离
% X m-by-3
% tp 3-by-3,每一行表示一个顶点坐标

A=tp(1,:);
B=tp(2,:);
C=tp(3,:);

AB=B-A;
BC=C-B;
n=cross(AB,BC);
AX=X-A;
dn=AX*n'./norm(n);

%求点X在三角面片上的投影Xt
Xt=A+AX-dn*n/norm(n);

if dn(1)>=0
    sdn=1;
else
    sdn=-1;
end
dp=0;
%如果Xt不在三角面片内
[r,u,v]=point_in_triangle(Xt,A,B,C);
AXt=Xt-A;
BXt=Xt-B;
pi_2=pi/2;
if ~r
    if u>0 && v>0 && u+v>1
        angleBCXt=point3theta(B,C,Xt);
        angleCBXt=point3theta(C,B,Xt);
        if angleBCXt < pi_2 && angleCBXt < pi_2
            dp=norm(BXt)*sin(angleCBXt);
        elseif angleBCXt < pi_2 && angleCBXt > pi_2
            dp=norm(Xt-B);
        elseif angleBCXt > pi_2 && angleCBXt < pi_2
            dp=norm(Xt-C);      
        end
    elseif u>0 && v<0 && u+v<1            
        angleACXt=point3theta(A,C,Xt);
        angleCAXt=point3theta(C,A,Xt);
        if angleACXt < pi_2 && angleCAXt < pi_2
            dp=norm(AXt)*sin(angleCAXt);
        elseif angleACXt < pi_2 && angleCAXt > pi_2
            dp=norm(Xt-A);
        elseif angleACXt > pi_2 && angleCAXt < pi_2
            dp=norm(Xt-C);      
        end        
    elseif u<0 && v>0 && u+v<1         
        angleABXt=point3theta(A,B,Xt);
        angleBAXt=point3theta(B,A,Xt);
        if angleABXt < pi_2 && angleBAXt < pi_2
            dp=norm(AXt)*sin(angleBAXt);
        elseif angleABXt < pi_2 && angleBAXt > pi_2
            dp=norm(Xt-A);
        elseif angleABXt > pi_2 && angleBAXt < pi_2
            dp=norm(Xt-B);          
        end
    elseif u<0 && v<0 && u+v<1
        dp=norm(Xt-A);
    elseif u<0 && v>0 && u+v>1
        dp=norm(Xt-B);
    elseif u>0 && v<0 && u+v>1
        dp=norm(Xt-C);
    end
end
d=sdn*sqrt(dn^2+dp^2);
end