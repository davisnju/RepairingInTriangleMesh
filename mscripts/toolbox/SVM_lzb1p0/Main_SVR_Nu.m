% 支持向量机Matlab工具箱1.0 - Nu-SVR, Nu回归算法
% 使用平台 - Matlab6.5 
% 版权所有：陆振波，海军工程大学
% 电子邮件：luzhenbo@yahoo.com.cn
% 个人主页：http://luzhenbo.88uu.com.cn
% 参数文献：Chih-Chung Chang, Chih-Jen Lin. "LIBSVM: a Library for Support Vector Machines"
%
% Support Vector Machine Matlab Toolbox 1.0 - Nu Support Vector Regression
% Platform : Matlab6.5 / Matlab7.0
% Copyright : LU Zhen-bo, Navy Engineering University, WuHan, HuBei, P.R.China, 430033  
% E-mail : luzhenbo@yahoo.com.cn        
% Homepage : http://luzhenbo.88uu.com.cn     
% Reference : Chih-Chung Chang, Chih-Jen Lin. "LIBSVM: a Library for Support Vector Machines"
%
% Solve the quadratic programming problem - "quadprog.m"

clc
clear
%close all

% ------------------------------------------------------------%
% 定义核函数及相关参数

C = 100;                % 拉格朗日乘子上界
nu = 0.05;              % nu -> (0,1] 在支持向量数与拟合精度之间进行折衷

%ker = struct('type','linear');
%ker = struct('type','ploy','degree',3,'offset',1);
ker = struct('type','gauss','width',0.6);
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
rand('state',42);
X  = linspace(-4,4,n);                            % 训练样本,d×n的矩阵,n为样本个数,d为样本维数,这里d=1
Ys = (1-X+2*X.^2).*exp(-.5*X.^2);
f = 0.2;                                          % 相对误差
Y  = Ys+f*max(abs(Ys))*(2*rand(size(Ys))-1)/2;    % 训练目标,1×n的矩阵,n为样本个数,值为期望输出

figure;
plot(X,Ys,'b-',X,Y,'b*');
title('\nu-SVR');
hold on;

% ------------------------------------------------------------%
% 训练支持向量机

tic
svm = svmTrain('svr_nu',X,Y,ker,C,nu);
t_train = toc

% svm  支持向量机(结构体变量)
% the following fields:
%   type - 支持向量机类型  {'svc_c','svc_nu','svm_one_class','svr_epsilon','svr_nu'}
%   ker - 核参数
%   x - 训练样本,d×n的矩阵,n为样本个数,d为样本维数
%   y - 训练目标,1×n的矩阵,n为样本个数
%   a - 拉格朗日乘子,1×n的矩阵

% ------------------------------------------------------------%
% 寻找支持向量

a = svm.a;
epsilon = 1e-8;                     % 如果"绝对值"小于此值则认为是0
i_sv = find(abs(a)>epsilon);        % 支持向量下标,这里对abs(a)进行判定
plot(X(i_sv),Y(i_sv),'ro');

% ------------------------------------------------------------%
% 测试输出

tic
Yd = svmSim(svm,X);           % 测试输出
t_sim = toc

plot(X,Yd,'r--');
hold off;
