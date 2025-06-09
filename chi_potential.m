function [chi Uchi Vchi]=chi_potential(longitude, latitude, u, v)
    % chi: Velocity Potential                       �ٶ���
    % Uchi, Vchi: Divergence Wind component         ��ɢ�����
    % Equ: Laplance chi = -divh, hard boundary      ���̣�����= -D���̶��߽��������߽�Ϊ 0 ��
    % Lieberman Method                              ������������
    MAX=100000;                                  % maximum iteration (corresponding eps: 1e-7) ������
    epsilon=1e-5;                                % precision ����/����׼ֵ��
    sor_index=0.2;                               % ���ų�ϵ����0.2��0.5��
    [M N]=size(longitude); 
    chi=zeros([M N]);                            % initialization   ��ʼ��
    Res=ones([M N]).*-9999;                      % �в�
    divh=divh_atmos(longitude, latitude, u, v);  % ˮƽɢ��
    dx2=dx_atmos(longitude, latitude).^2;        % γ���ݶȶ��η�
    dy2=dy_atmos(latitude).^2;                   % �����ݶȶ��η�
    for k=1:MAX
        for i=2:M-1
            for j=2:N-1
                % �в�
                Res(i, j)=(chi(i+1, j)+chi(i-1, j)-2*chi(i, j))./dx2(i, j)+...
                          (chi(i, j+1)+chi(i, j-1)-2*chi(i, j))./dy2(i, j)+...
                          divh(i, j);
                % ����
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
