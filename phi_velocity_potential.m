function [phi, Uphi, Vphi]=phi_velocity_potential(longitude, latitude, u, v)
    % phi: Velocity Potential                       速度势
    % Uphi, Vphi: Divergence Wind component         辐散风分量
    % Equ: Laplance chi = -divh, hard boundary      方程：▽φ= -D，固定边界条件（边界为 0 ）
    % Richardson Method                             理查逊法
    % 参考文献：《有限区域流函数和速度势的3种求解方法在分析台风Bilis暴雨增幅中的比较研究(任晨平等,2013)》
    MAX=1e10;                                    % 迭代次数
    epsilon=1e-10;                               % 误差值ε
    [M, N]=size(longitude); 
    phi=zeros([M N]);                            % 初始化
    Res=ones([M N]).*-9999;                      % 残差
    divh=-divh_atmos(longitude, latitude, u, v);  % 水平散度
    dx2=dx_atmos(longitude, latitude).^2;        % 纬向梯度二次方
    dy2=dy_atmos(latitude).^2;                   % 经向梯度二次方
    for k=1:MAX
        for i=2:M-1
            for j=2:N-1
                % 残差
                Res(i, j)=(phi(i+1, j)+phi(i-1, j)-2*phi(i, j))./dx2(i, j)+...
                          (phi(i, j+1)+phi(i, j-1)-2*phi(i, j))./dy2(i, j)+...
                          divh(i, j);
                % 迭代
                phi(i, j)=phi(i, j)+Res(i, j)/(2/dx2(i, j)+2/dy2(i, j));
            end
        end
        if(max(max(Res))<epsilon)   % 判断是否收敛
            break                   % 若收敛则退出循环
        end
    end
    % divergence wind
    [DphiDx, DphiDy]=grad_atmos(longitude, latitude, phi);
    Uphi=-DphiDx;
    Vphi=-DphiDy;
    % make boundary NaN
    phi(1, :)=NaN; Uphi(1, :)=NaN; Vphi(1, :)=NaN;
    phi(M, :)=NaN; Uphi(M, :)=NaN; Vphi(M, :)=NaN;
    phi(:, 1)=NaN; Uphi(:, 1)=NaN; Vphi(:, 1)=NaN;
    phi(:, N)=NaN; Uphi(:, N)=NaN; Vphi(:, N)=NaN;
    % 转置
    phi = phi';
    Uphi = Uphi';
    Vphi = Vphi';
end
