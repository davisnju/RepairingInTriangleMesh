function [alpha,b]=laprlsc(K,Y,L,lambda1,lambda2)

    n=size(K,1); % total examples
    l=sum(abs(Y)); % labeled examples
    
    u=n - l; % unlabeled examples
    I=eye(n);   
    J=diag(abs(Y));
      
      
    if ~isempty(L) & lambda2~=0
        alpha = (J*K + lambda1*I + lambda2*L*K)\Y;
    else
        alpha = (J*K + lambda1*I)\Y;  
    end
         b=0;
