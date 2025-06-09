function dy=dy_atmos(latitude)
    R=6356752.3;               % ¾­È¦°ë¾¶
    [~, dy]=gradient(latitude);
    dy=dy.*(pi./180).*R;
end