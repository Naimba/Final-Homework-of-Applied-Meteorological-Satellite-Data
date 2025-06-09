function autoscale=Get_Autoscale(x, y, u, v)
    autoscale=1;
    [m n]=size(x);
    delx=diff([min(x(:)) max(x(:))])/n;
    dely=diff([min(y(:)) max(y(:))])/m;
    del=delx.^2 + dely.^2;
    len=sqrt((u.^2 + v.^2)/del);
    maxlen=max(len(:));
    autoscale=autoscale*0.9/maxlen;
end