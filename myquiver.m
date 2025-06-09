function myquiver(ax,n,X,Y,u,v)

% 获取 Axes 位置
posAxes = get(ax,'Position');
posX = posAxes(1);
posY = posAxes(2);
width = posAxes(3);
height = posAxes(4);

% 获取 Axes 范围
limX = get(gca,'Xlim');
limY = get(gca,'Ylim');
minX = limX(1);
maxX = limX(2);
minY = limY(1);
maxY = limY(2);

% 转换坐标
xNew = posX + (X - minX) / (maxX - minX) * width;
yNew = posY + (Y - minY) / (maxY - minY) * height;

% 画风场
[~,lon1] = find(X(1,:)==limX(1));
[~,lon2] = find(X(1,:)==limX(2));

for i=2:size(X,1)-1 % 不画最底层和最高层
    for j=lon1:1:lon2
        if xNew(i,j)+u(i,j).*n<=xNew(1,lon1)      % 避免让箭头超出左边界
            annotation('arrow',[xNew(i,j),xNew(1,lon1)],[yNew(i,j),yNew(i,j)+v(i,j).*n], ...
                'Color','k','Headwidth',5,'Headstyle','none','Headlength',5);
        elseif xNew(i,j)+u(i,j).*n>=xNew(1,lon2)  % 避免让箭头超出右边界
            annotation('arrow',[xNew(i,j),xNew(1,lon2)],[yNew(i,j),yNew(i,j)+v(i,j).*n], ...
                'Color','k','Headwidth',5,'Headstyle','none','Headlength',5);
        else
            annotation('arrow',[xNew(i,j),xNew(i,j)+u(i,j).*n],[yNew(i,j),yNew(i,j)+v(i,j).*n], ...
                'Color','k','Headwidth',5,'Headstyle','vback3','Headlength',5);
        end
    end
end

end