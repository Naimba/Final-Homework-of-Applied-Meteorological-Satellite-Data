clc;clear;close all

%% 读取数据
% 读取2024梅雨期数据
fn = 'preci_MeiYu2024.nc';
t = ncread(fn,'time');
t = seconds(t)+datetime(1900,1,1);
preci_2024 = ncread(fn,'preci');
lon = ncread(fn,'lon');lat = ncread(fn,'lat');
lon_range = lon>=110 & lon<=122.5;
preci_2024 = preci_2024(lon_range,:,:);lon = lon(lon_range);
% preci_ltm = mean(preci_ltm,1);
%%
clc;close all
fig = figure('Position',[50,50,900,500]);
ax = axes;
cm = [255 255 255;166 242 142; 61 185 61;97 184 255;0 0 254;250 0 250;129 0 64]/255;
levels = [0,2,10,25,50,100,250,300];
titlename = '(a) Precipitation Hovmöller 110—122.5°E';

plot_precip_hov(lat,t,preci_2024,ax,cm,levels,titlename)
cax = mycolorbar(levels,cm,'v','=>',[ax.Position(3)+ax.Position(1)+0.02 ax.Position(2) ...
    0.015 ax.Position(4)]);
cax.FontSize = 12;cax.Title.String = 'mm';
exportgraphics(fig,'图\Meiyu2024_hov.png','Resolution',700)
%% 辅助函数：绘制梅雨降水的Hovmöller
function plot_precip_hov(lat,t,preci_2024,ax,cm,levels,titlename)
preci_2024_hov = mean(preci_2024,1);
preci_2024_hov = squeeze(preci_2024_hov);

t1 = t(1:48:end);
preci_2024_daily_hov = zeros(size(preci_2024_hov,1),numel(t1));
for i = 1:numel(t1)
    preci_2024_daily_hov(:,i) = sum(preci_2024_hov(:,48*(i-1)+1:48*i),2);
end

tn = 1:numel(t1);
[T,Y] = meshgrid(tn,lat);

axes(ax);
hold on
mycontourf(T,Y,preci_2024_daily_hov,levels,cm,'M');
colormap(ax,cm)

xlim([tn(1) tn(end)]);
xtks = tn([1:7:end,end]);
xticks(xtks);
n_xtl = numel(xtks);
xtl_name = cell(n_xtl,1);
for i = 1:n_xtl
    xtl_name{i} = [num2str(month(t1(xtks)),'%.2d'), num2str(day(t1(xtks)),'%.2d')];
end
xticklabels(xtl_name)

ylim([lat(1)-0.1 lat(end)+0.1]);
ytick = 10:10:60;
yticks(ytick);
ytl = cell(numel(ytick),1);
for i = 1:numel(ytick)
    if ytick(i) > 0
        ytl{i} = [num2str(ytick(i),'%d'),'°N'];
    elseif ytick(i) < 0
        ytl{i} = [num2str(ytick(i),'%d'),'°S'];
    elseif ytick(i) == 0
        ytl{i} = [num2str(ytick(i),'%d'),'°'];
    end
end
yticklabels(ytl);
ax.YTickLabelMode = "auto";
ylabel('Precipitation/ (mm day^{-1})')

title(titlename,'FontSize',15,'Position',[ax.XLim(1) ax.YLim(2) 1],'HorizontalAlignment','left','FontWeight','bold')
box on
grid on

% 绘制梅雨参考线
MeiyuColor = 'r';
plot([tn(1) tn(end)],[28 28],'color',MeiyuColor,'linewidth',1.2);
plot([tn(1) tn(end)],[34 34],'color',MeiyuColor,'linewidth',1.2);
plot([tn(1) tn(1)],[28 34],'color',MeiyuColor,'linewidth',1.2);
plot([tn(end) tn(end)],[28 34],'color',MeiyuColor,'linewidth',1.2);
plot([tn(1) tn(end)],[30,30],'color',MeiyuColor,'linewidth',1.2,'Linestyle',':')
plot([tn(1) tn(end)],[32,32],'color',MeiyuColor,'linewidth',1.2,'Linestyle',':')

ax.Layer = 'top'; % 关键设置
ax.TickDir = "out";
ax.FontSize = 15;
ax.FontWeight = "bold";
ax.XMinorTick = "on";
ax.XAxis.MinorTickValues = tn;
ax.XMinorGrid = "on";
end
