function divh=divh_atmos(longitude, latitude, u, v)
    R=6378137.0;             % ����뾶
    dx=dx_atmos(longitude, latitude);
    dy=dy_atmos(latitude);
    [du, ~]=gradient(u);
    [~, dv]=gradient(v);
    divh=du./dx+dv./dy-v.*tan(latitude.*pi./180)./R;  % ���ź���Ϊ γȦ�ܳ���γ�ȱ仯����Ա仯��
    divh(abs(latitude)==90)=NaN;
end