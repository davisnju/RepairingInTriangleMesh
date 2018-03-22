function [rn]=create_ball_unit(N,R)
%     N=12; % num of vertex
%     R=radus
    a=rand(N,1)*2*pi;  % init
    b=asin(rand(N,1)*2-1);
    r0=[R*cos(a).*cos(b),R*sin(a).*cos(b),R*sin(b)];
    v0=zeros(size(r0));
    G=1e-2;%
 
   for ii=1:200%iteration num
         [rn,vn]=countnext(r0,v0,G);%update
          r0=rn;v0=vn;
    end

%     plot3(rn(:,1),rn(:,2),rn(:,3),'.');hold on;%
%     [xx,yy,zz]=sphere(50); 
%     h2=surf(xx,yy,zz); %
%     set(h2,'edgecolor','none','facecolor','b','facealpha',0.7);
%     axis equal;
%     axis([-1 1 -1 1 -1 1]);
%     hold off;

 end

function [rn vn]=countnext(r,v,G) %update
%r is coord
%v is speed
    num=size(r,1);
    dd=zeros(3,num,num); %vec
    
    for m=1:num-1
          for n=m+1:num
              dd(:,m,n)=(r(m,:)-r(n,:))';
              dd(:,n,m)=-dd(:,m,n);
          end
     end 

      L=sqrt(sum(dd.^2,1));%dis
      L(L<1e-2)=1e-2; %
      F=sum(dd./repmat(L.^3,[3 1 1]),3)';%calc g

      Fr=r.*repmat(dot(F,r,2),[1 3]); %radial
      Fv=F-Fr; %tangential

       rn=r+v;  %update coord
       rn=rn./repmat(sqrt(sum(rn.^2,2)),[1 3]);
       vn=v+G*Fv;%update speed
end