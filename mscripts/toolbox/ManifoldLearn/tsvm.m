function classifier=tsvm(X,Y,Kernel,KernelParam,lambda)

% TSVM Implements Transductive SVMs
% [alpha,b]=tsvm(X,Y,Kernel,KernelParam,C)
% C = 1/(2*l*lambda)
% 
% Inputs: 
% X : (num x dim) examples are rows
% Y : column vector of labels [-1,0,+1] 0:unlabeled points
% YU: Labels of unlabeled data if known
% options: structure with fields 
%           options.lambda1 (1/(2*l*C))
%           options.Kernel = 'rbf' | 'poly' | 'linear'
%           options.KernelParam = sigma | degree | 0                    
%
% Outputs:
% alpha : column vector containing coefficients of expansion
% b     : bias
% svs   : support vectors
% labels    : structure labels.train labels.unlab - labels on training/unlabeled data
% error     : structure error.train error.unlab
% 
% Requires: SVMLight
%           Set SVMLightPath to the path to SVMLight binaries
%
%
% Notes   : This code has been tested for correctness:
%           /home/vikas/research/data/text/joachims-examples/example2
%
% Author:  Vikas Sindhwani vikass@cs.uchicago.edu
%          ManifoldLearn : Machine Learning Toolbox
%          May 2004
%------------------------------------------------------------------------------%

% Set path here
       SVMLightPath='/home/vikas/software/svm_light/';

% for RBF kernel change sigma to gamma

       switch Kernel
       case 'rbf'
           kerparam=1/(2*KernelParam*KernelParam);  
       case 'poly'
          kerparam=[KernelParam 1 0];    
       otherwise
           kerparam=KernelParam;
       end

%   SVMLight will train and write a model file to 'junk'
%   and then read alphas , b svs, from it
    C=1/(2*lambda);
    optsvml = ...
    svmlopt('C',C,'Kernel',KERNELS(Kernel),'KernelParam',kerparam);
    optsvml.Verbosity=0;
    optsvml.ExecPath=SVMLightPath;
    net=svml('junk',optsvml);
    net=svmltrain(net,X,Y);
    [alpha,svs]=svmlread('junk');
    delete('junk');
    delete('junk.transduction');
    b=alpha(9);
    alpha=alpha(10:end);
    svs=svs(10:end,:);
    disp('tsvm: b set to 0');
%    
 classifier=saveclassifier('tsvm',Kernel,KernelParam,alpha,svs,b,lambda);
    
    
%----------------------------------------------------------------------------------%

% switch to numerical parameter for kernel
function k=KERNELS(kerneltype)
    switch kerneltype
    
    case 'linear'
        k=0;
    case 'poly'
        k=1;
    case 'rbf'
        k=2
    otherwise
        error('Unknown Kernel Type');
 end
 
 %----------------------------------------------------------------------------------%
