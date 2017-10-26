function [alpha,b]=rlsc(K,Y,lambda)
          l=length(Y);
          I=eye(l);
          alpha=(K+lambda*I)\Y;
          b=0;