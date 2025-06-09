function dx=dx_atmos(longitude, latitude)
    R=6378137.0;             % ����뾶
    [dx, ~]=gradient(longitude);
    dx=dx.*(pi./180).*R.*cos(latitude*pi./180);
end