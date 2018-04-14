function [D] = geodesics_in_heat(V, F, src)   
    % choose time step
    c = 5;
    t = c * mean(doublearea(V, F))/2;

    %% Step 1: Integrate the heat flow for some fixed time t
    L = cotmatrix(V, F);
    M = massmatrix(V, F, 'barycentric');
 
    nV = size(V, 1);
    u0 = zeros(nV, 1);
    u0(src) = 1;
    
    A = M - t*L;
    B = M*u0;

    nsrc = length(src);
    % 1.1 dirichlet condition
    hole = Cal_Boundary(F);
    if isempty(hole)
        boundary = [];
    else
        boundary = hole.boundary.edge(:,1)';
    end

    b = setdiff(boundary, src);
    nb = [b, src];
    Acons = sparse([1:length(nb)], nb, ones(1,length(nb)), length(nb), nV);
    Bcons = [zeros(length(b), 1); ones(nsrc, 1)];

    % 硬约束        
    r = setdiff([1:nV], nb);
    uD = [A(r,:);Acons]\[B(r,:);Bcons];

    % 1.2 neumann condition
    Acons = sparse([1:nsrc], src, ones(1,nsrc), nsrc, nV);
    Bcons = ones(nsrc, 1);

    % 硬约束  
    r = setdiff([1:nV], src);
    uN = [A(r,:);Acons]\[B(r,:);Bcons];
    
    % averaged boundary condition
    u = 0.5*(uN + uD);
    
    %% Step 2: Evaluate the vector field X
    G = grad(V, F); % nF*3 by nV matrix(梯度算子 - 所有三角片顶点基函数)
    grad_u = reshape(G*u, size(F,1), 3); % nF by nV matrix(所有三角片中u的梯度)
    grad_u_norm = sqrt(sum(grad_u.^2, 2));
    normalized_grad_u = bsxfun(@rdivide, grad_u, grad_u_norm+eps);
    X = -normalized_grad_u;
    
    %% Step 3: Solve the Poisson equation
    Div = div(V, F); % 散度算子
    div_X = Div*X(:); % #nV by #nF*3

    Lcons = sparse([1:nsrc], src, ones(1,nsrc), nsrc, nV);
    div_Xcons = zeros(nsrc, 1);

    % 硬约束
    r = setdiff([1:nV], src);
    D = [L(r,:);Lcons]\[div_X(r,:);div_Xcons];
    
    D = D - min(D);
end