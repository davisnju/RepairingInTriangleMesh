% Returns harmonic mean of precision and recall.  Intended to be used
% with breakeven.m
%
% Written by Jason Rennie <jrennie@csail.mit.edu>
% Last modified: Thu Feb 19 13:17:51 2004

function [obj] = f1(np,nn,fp,fn)
  recall = (np-fn)/np;
  if fp+np-fn > 0
    precision = (np-fn)/(fp+np-fn);
  else
    precision = 0;
  end
  if precision+recall > 0
    obj = 2*recall*precision/(recall+precision);
  else
    obj = 0;
  end

