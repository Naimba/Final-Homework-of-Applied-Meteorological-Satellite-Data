function [chi Uchi Vchi]=chi_potential(longitude, latitude, u, v)
    % chi: Velocity Potential                       速度势
    % Uchi, Vchi: Divergence Wind component         辐散风分量
    % Equ: Laplance chi = -divh, hard boundary      方程：▽φ= -D，固定边界条件（边界为 0 ）
    % Lieberman Method                              加速利布曼法
    MAX=100000;                                  % maximum iteration (corresponding eps: 1e-7) 最大迭代
    epsilon=1e-5;                                % precision 精度/误差标准值ε
    sor_index=0.2;                               % 超张弛系数（0.2～0.5）
    [M N]=size(longitude); 
    chi=zeros([M N]);                            % initialization   初始化
    Res=ones([M N]).*-9999;                      % 残差
    divh=divh_atmos(longitude, latitude, u, v);  % 水平散度
    dx2=dx_atmos(longitude, latitude).^2;        % 纬向梯度二次方
    dy2=dy_atmos(latitude).^2;                   % 经向梯度二次方
    for k=1:MAX
        for i=2:M-1
            for j=2:N-1
                % 残差
                Res(i, j)=(chi(i+1, j)+chi(i-1, j)-2*chi(i, j))./dx2(i, j)+...
                          (chi(i, j+1)+chi(i, j-1)-2*chi(i, j))./dy2(i, j)+...
                          divh(i, j);
                % 迭代
                chi(i, j)=chi(i, j)+(1+sor_index)*Res(i, j)/(2/dx2(i, j)+2/dy2(i, j));
            end
        end
        if(max(max(Res))<epsilon)
            break % <----- Terminate the loop
        end
    end
    % divergence wind
    [DchiDx DchiDy]=grad_atmos(longitude, latitude, chi);
    Uchi=-DchiDx;
    Vchi=-DchiDy;
    % make boundary NaN
    chi(1, :)=NaN; Uchi(1, :)=NaN; Vchi(1, :)=NaN;
    chi(M, :)=NaN; Uchi(M, :)=NaN; Vchi(M, :)=NaN;
    chi(:, 1)=NaN; Uchi(:, 1)=NaN; Vchi(:, 1)=NaN;
    chi(:, N)=NaN; Uchi(:, N)=NaN; Vchi(:, N)=NaN;
end
