function [alpha,b]=lapsvm(K,Y,L,lambda1,lambda2)

parameters =  [4 1 1 0 1 40.00 0.001 0 0.5 0.1 1] ;
I=eye(size(K,1));
lab=find(Y);
l=length(lab);

    if isempty(L) | lambda2==0
        G=I/(2*lambda1);
    else 
        G=(2*lambda1*I + 2*lambda2*L*K)\I;
    end
    
    Gram=K*G;
    Gram=Gram(lab,lab);

    Ylab=Y(find(Y==-1 | Y==1));
    [betay, svs, b, nsv, nlab] = mexGramSVMTrain(Gram', Ylab', parameters);
    if nlab(1)==-1
    	betay=-betay;
    end
    Betay=zeros(l,1);
    Betay(svs+1)=betay';
    alpha=G(:,lab)*Betay;
    %alpha=G*K(:,lab)*Betay;
    %disp('lapsvm: b set to median K alpha (balanced datasets)');
    %b=median(K*alpha); % for the time being we assume balanced datasets
    b=0;
