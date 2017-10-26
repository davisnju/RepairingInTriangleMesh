% Given a set of classification outputs and binary labels for a set of
% examples, finds the threshold that maximizes some function of the
% classification errors (as determined by user-provided function)
%
% [error,thresh] = rocBreakeven(outputs,labels,func)
% outputs - real-valued classification outputs [n,1]
% labels - binary labels (-1/+1) [n,1]
% func - user-provided function, must take four arguments: (np,nn,fp,fn)
% where
% maxthresh - threshold point that maximizes 'func' [1,1]
%
% Written by Jason Rennie <jrennie@csail.mit.edu>
% Last modified: Thu Feb 19 13:19:32 2004
%
% Modified by Vikas Sindhwani (included Precision-recall breakeven point)
% 05/31/04
%
%

function [maxthresh,maxobj] = breakeven(outputs,labels,func)
  n = length(outputs);
  if n ~= length(labels)
    error('length of outputs and labels must match')
  end
  np = sum(labels>0);
  nn = sum(labels<0);
  fp = nn;
  fn = 0;
  maxobj = feval(func,np,nn,fp,fn);
  [tmp,idx] = sort(outputs);
  so = outputs(idx);
  sl = labels(idx);
  maxthresh = so(1)-1;
  for i=1:length(so)-1
    if sl(i) < 0
      fp = fp - 1;
    else
      fn = fn + 1;
    end
    if so(i) == so(i+1)
      continue
    end
    obj = feval(func,np,nn,fp,fn);
    if obj > maxobj
      maxobj = obj;
      maxthresh = (so(i)+so(i+1))/2;
    end
  end
  if sl(n) < 0
    fp = fp - 1;
  else
    fn = fn + 1;
  end
  obj = feval(func,np,nn,fp,fn);
  if obj > maxobj
    maxobj = obj;
    maxthresh = so(n)+1;
  end
