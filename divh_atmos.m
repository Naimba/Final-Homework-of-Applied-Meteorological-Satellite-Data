function divh=divh_atmos(longitude, latitude, u, v)
    R=6378137.0;             % 赤道半径
    dx=dx_atmos(longitude, latitude);
    dy=dy_atmos(latitude);
    [du, ~]=gradient(u);
    [~, dv]=gradient(v);
    divh=du./dx+dv./dy-v.*tan(latitude.*pi./180)./R;  % 减号后面为 纬圈周长随纬度变化的相对变化率
    divh(abs(latitude)==90)=NaN;
end