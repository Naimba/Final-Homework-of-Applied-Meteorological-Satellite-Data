function [phi, Uphi, Vphi]=phi_velocity_potential(longitude, latitude, u, v)
    % phi: Velocity Potential                       �ٶ���
    % Uphi, Vphi: Divergence Wind component         ��ɢ�����
    % Equ: Laplance chi = -divh, hard boundary      ���̣�����= -D���̶��߽��������߽�Ϊ 0 ��
    % Richardson Method                             ���ѷ��
    % �ο����ף��������������������ٶ��Ƶ�3����ⷽ���ڷ���̨��Bilis���������еıȽ��о�(�γ�ƽ��,2013)��
    MAX=1e10;                                    % ��������
    epsilon=1e-10;                               % ���ֵ��
    [M, N]=size(longitude); 
    phi=zeros([M N]);                            % ��ʼ��
    Res=ones([M N]).*-9999;                      % �в�
    divh=-divh_atmos(longitude, latitude, u, v);  % ˮƽɢ��
    dx2=dx_atmos(longitude, latitude).^2;        % γ���ݶȶ��η�
    dy2=dy_atmos(latitude).^2;                   % �����ݶȶ��η�
    for k=1:MAX
        for i=2:M-1
            for j=2:N-1
                % �в�
                Res(i, j)=(phi(i+1, j)+phi(i-1, j)-2*phi(i, j))./dx2(i, j)+...
                          (phi(i, j+1)+phi(i, j-1)-2*phi(i, j))./dy2(i, j)+...
                          divh(i, j);
                % ����
                phi(i, j)=phi(i, j)+Res(i, j)/(2/dx2(i, j)+2/dy2(i, j));
            end
        end
        if(max(max(Res))<epsilon)   % �ж��Ƿ�����
            break                   % ���������˳�ѭ��
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
    % ת��
    phi = phi';
    Uphi = Uphi';
    Vphi = Vphi';
end
