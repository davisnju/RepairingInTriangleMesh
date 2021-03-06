% Author:
% - Mehrtash Harandi (mehrtash.harandi at gmail dot com)
%
% This file is provided without any warranty of
% fitness for any purpose. You can redistribute
% this file and/or modify it under the terms of
% the GNU General Public License (GPL) as published
% by the Free Software Foundation, either version 3
% of the License or (at your option) any later version.

clear;
clc;

addpath('local_manopt')
load('toy_data');

Metric_Flag = 2; %1:AIRM, 2:Stein
graph_kw = 15;
graph_kb = 10;
newDim = 10;

%initializing training structure
trnStruct.X = covD_Struct.trn_X;
trnStruct.y = covD_Struct.trn_y;
trnStruct.n = size(covD_Struct.trn_X,1);
trnStruct.nClasses = max(covD_Struct.trn_y);
trnStruct.r = newDim;
trnStruct.Metric_Flag = Metric_Flag;

%Generating graph
nPoints = length(trnStruct.y);
trnStruct.G = generate_Graphs(trnStruct.X,trnStruct.y,graph_kw,graph_kb,Metric_Flag);



%- different ways of initializing, the first 10 features are genuine so
%- the first initialization is the lucky guess, the second one is a random
%- attempt and the last one is the worst possible initialization.

% U = orth(rand(trnStruct.n,trnStruct.r));
U = eye(trnStruct.n,trnStruct.r);
% U = [zeros(trnStruct.n-trnStruct.r,trnStruct.r);eye(trnStruct.r)];

% Create the problem structure.
manifold = grassmannfactory(covD_Struct.n,covD_Struct.r);
problem.M = manifold;

% conjugate gradient on Grassmann
problem.costgrad = @(U) supervised_WB_CostGrad(U,trnStruct);
U  = conjugategradient(problem,U,struct('maxiter',50));


TL_trnX = zeros(newDim,newDim,length(covD_Struct.trn_y));
for tmpC1 = 1:nPoints
    TL_trnX(:,:,tmpC1) = U'*covD_Struct.trn_X(:,:,tmpC1)*U;
end
TL_tstX = zeros(newDim,newDim,length(covD_Struct.tst_y));
for tmpC1 = 1:length(covD_Struct.tst_y)
    TL_tstX(:,:,tmpC1) = U'*covD_Struct.tst_X(:,:,tmpC1)*U;
end

if (Metric_Flag == 1)
    %AIRM
    pair_dist = Compute_AIRM_Metric(covD_Struct.tst_X,covD_Struct.trn_X);
    pair_dist_U = Compute_AIRM_Metric(TL_tstX,TL_trnX);
elseif (Metric_Flag == 2)
    %Stein
    pair_dist = Compute_Stein_Metric(covD_Struct.tst_X,covD_Struct.trn_X);
    pair_dist_U = Compute_Stein_Metric(TL_tstX,TL_trnX);
else
    error('the metric is not defined');
end

[~,minIDX] = min(pair_dist);
y_hat = covD_Struct.trn_y(minIDX);
CRR(1) = sum(covD_Struct.tst_y == y_hat)/length(covD_Struct.tst_y);

[~,minIDX] = min(pair_dist_U);
y_hat = covD_Struct.trn_y(minIDX);
CRR(2) = sum(covD_Struct.tst_y == y_hat)/length(covD_Struct.tst_y);

if (Metric_Flag == 1)
    %AIRM
    fprintf('\n-----------------------------------------\n')
    fprintf('Metric : AIRM, dim(M1) = %d, dim(M2) = %d. \n',0.5*covD_Struct.n*(covD_Struct.n+1),0.5*newDim*(newDim+1));
    fprintf('Recognition accuracy for the high-dimensional manifold (M1)-> %.1f%%.\n',100*CRR(1));
    fprintf('Recognition accuracy after learning the low-dimensional manifold (M2)-> %.1f%%.\n',100*CRR(2));
    fprintf('-----------------------------------------\n')
else
    %Stein
    fprintf('\n-----------------------------------------\n')
    fprintf('Metric : Stein, dim(M1) = %d, dim(M2) = %d. \n',0.5*covD_Struct.n*(covD_Struct.n+1),0.5*newDim*(newDim+1));
    fprintf('Recognition accuracy for the high-dimensional manifold (M1)-> %.1f%%.\n',100*CRR(1));
    fprintf('Recognition accuracy after learning the low-dimensional manifold (M2)-> %.1f%%.\n',100*CRR(2));
    fprintf('-----------------------------------------\n')
end