function [X,Y]=generate_toydata(n,method)

% [X,Y]=generate_toydata(n,method)
%       Generates toy binary classification problem
%       n points in class +1 and n points in class -1
%       method:
%
%       'moons'          : 2 moons 
%       'swiss'            : 2d swiss roll 

[X,Y]=feval(method,n);



function [X,Y]=moons(n)

space=2;
noise=0.1;
r=randn(n,1)*noise+1;
theta=randn(n,1)*pi;
r1=1.1*r; r2=r;
X1=([r1.*cos(theta) abs(r2.*sin(theta))]);
Y1=ones(n,1);

r=randn(n,1)*noise+1;
theta=randn(n,1)*pi+2*pi;
r1=1.1*r; r2=r;
X2=([r1.*cos(theta)+space*rand -abs(r2.*sin(theta)) + 0.5 ]);
Y2=-ones(n,1);

X=[X1;X2];
Y=[Y1;Y2];

v=randperm(2*n);
X=X(v,:);
Y=Y(v);

function [X,Y]=swiss(n);

%GENERATE SAMPLED DATA 1
  tt = (3*pi/2)*(1+2*rand(1,n));  %height = 21*randn(1,N);
  X1 = [tt.*cos(tt); tt.*sin(tt)]';

  % GENERATE SAMPLED DATA 2
  tt = (3*pi/2)*(1+2*rand(1,n));  %height = 21*randn(1,N);
  X2 = [tt.*cos(tt);  tt.*sin(tt)]'; X2=1.6*X2;
  X=[X1;X2]/25+randn(2*n,2)*0.03;
  Y=[ones(n,1); -1*ones(n,1)];


function [X,Y]=lines(n);

var=1;
x=1;
y=0.5;
X1=[randn(n,1)*0.3+x randn(n,1)*0.05+y];
Y1=ones(n,1);
X2=[randn(n,1)*0.3-x randn(n,1)*0.05-y];
Y2=-1*ones(n,1);
X=[X1;X2];
Y=[Y1;Y2];
