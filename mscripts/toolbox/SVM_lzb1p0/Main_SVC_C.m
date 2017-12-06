% 支持向量机Matlab工具箱1.0 - C-SVC, C二类分类算法
% 使用平台 - Matlab6.5
% 版权所有：陆振波，海军工程大学
% 电子邮件：luzhenbo@yahoo.com.cn
% 个人主页：http://luzhenbo.88uu.com.cn
% 参数文献：Chih-Chung Chang, Chih-Jen Lin. "LIBSVM: a Library for Support Vector Machines"
%
% Support Vector Machine Matlab Toolbox 1.0 - C Support Vector Classification
% Platform : Matlab6.5 / Matlab7.0
% Copyright : LU Zhen-bo, Navy Engineering University, WuHan, HuBei, P.R.China, 430033  
% E-mail : luzhenbo@yahoo.com.cn        
% Homepage : http://luzhenbo.88uu.com.cn     
% Reference : Chih-Chung Chang, Chih-Jen Lin. "LIBSVM: a Library for Support Vector Machines"
%
% Solve the quadratic programming problem - "quadprog.m"

%clc
clear
%close all

% ------------------------------------------------------------%
% 定义核函数及相关参数

C = 200;                % 拉格朗日乘子上界

ker = struct('type','linear');
%ker = struct('type','ploy','degree',3,'offset',1);
%ker = struct('type','gauss','width',1);
%ker = struct('type','tanh','gamma',1,'offset',0);

% ker - 核参数(结构体变量)
% the following fields:
%   type   - linear :  k(x,y) = x'*y
%            poly   :  k(x,y) = (x'*y+c)^d
%            gauss  :  k(x,y) = exp(-0.5*(norm(x-y)/s)^2)
%            tanh   :  k(x,y) = tanh(g*x'*y+c)
%   degree - Degree d of polynomial kernel (positive scalar).
%   offset - Offset c of polynomial and tanh kernel (scalar, negative for tanh).
%   width  - Width s of Gauss kernel (positive scalar).
%   gamma  - Slope g of the tanh kernel (positive scalar).

% ------------------------------------------------------------%
% 构造两类训练样本

n = 50;
randn('state',6);
x1 = randn(2,n);
y1 = ones(1,n);
x2 = 5+randn(2,n);
y2 = -ones(1,n);

figure(1);
plot(x1(1,:),x1(2,:),'bx',x2(1,:),x2(2,:),'k.');
axis([-3 8 -3 8]);
title('C-SVC')
hold on;

X = [x1,x2];        % 训练样本,d×n的矩阵,n为样本个数,d为样本维数
Y = [y1,y2];        % 训练目标,1×n的矩阵,n为样本个数,值为+1或-1

% ------------------------------------------------------------%
% 训练支持向量机

tic
svm = svmTrain('svc_c',X,Y,ker,C);
t_train = toc

% svm  支持向量机(结构体变量)
% the following fields:
%   type - 支持向量机类型  {'svc_c','svc_nu','svm_one_class','svr_epsilon','svr_nu'}
%   ker - 核参数
%   x - 训练样本,d×n的矩阵,n为样本个数,d为样本维数
%   y - 训练目标,1×n的矩阵,n为样本个数,值为+1或-1
%   a - 拉格朗日乘子,1×n的矩阵

% ------------------------------------------------------------%
% 寻找支持向量

a = svm.a;
epsilon = 1e-8;                     % 如果小于此值则认为是0
i_sv = find(abs(a)>epsilon);        % 支持向量下标
plot(X(1,i_sv),X(2,i_sv),'ro');

% ------------------------------------------------------------%
% 测试输出

[x1,x2] = meshgrid(-2:0.1:7,-2:0.1:7);
[rows,cols] = size(x1);
nt = rows*cols;                  % 测试样本数
Xt = [reshape(x1,1,nt);reshape(x2,1,nt)];

tic
Yd = svmSim(svm,Xt);           % 测试输出
t_sim = toc

Yd = reshape(Yd,rows,cols);
contour(x1,x2,Yd,[0 0],'m');    % 分类面
hold off;



