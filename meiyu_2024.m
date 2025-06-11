clc;clear;close all

%% 读取数据
% 读取2024梅雨期数据
fn = 'preci_MeiYu2024.nc';
t = ncread(fn,'time');
t = seconds(t)+datetime(1900,1,1);
preci_2024 = ncread(fn,'preci');
lon = ncread(fn,'lon');lat = ncread(fn,'lat');

% 读取ltm数据
fn_preci_ltm = 'F:\Data\CPC Global Unified Gauge-Based Analysis of Daily Precipitation\precip.day.1991-2020.ltm.nc';
[preci_ltm,lon_ltm,lat_ltm,t_ltm] = readncfile(fn_preci_ltm);
% preci_ltm = mean(preci_ltm,3);
%% 图片信息
clc;close all
fig = figure('Position',[50 50 1250 900]);
[ha,~] = tight_subplot(2,2,[.08 .04],[.05 .05],[.04 .07]);
%% 辅助函数：读取nc文件
function [preci_ltm,lon_ltm,lat_ltm,t_ltm] = readncfile(fn)

lon_ltm = ncread(fn,'lon');lat_ltm = ncread(fn,'lat');
lon_ltm = double(lon_ltm);lat_ltm = double(lat_ltm);


lat_range = lat_ltm>=5 & lat_ltm<=60;lon_range = lon_ltm>=85 & lon_ltm<=150;
lat_index = find(lat_range);lon_index = find(lon_range);
lon_ltm = lon_ltm(lon_range);lat_ltm = lat_ltm(lat_range);
it = days(datetime(0001,6,10)+days(1)-datetime(0000,12,30));
n = days(datetime(0001,7,21)-datetime(0001,6,10)+days(1));
preci_ltm = ncread(fn,'precip',[lon_index(1) lat_index(1) it],[numel(lon_index) numel(lat_index) n]);
preci_ltm = double(preci_ltm);
preci_ltm(abs(preci_ltm)>1e5) = nan;

t_ltm = ncread(fn,'time',it,n);
t_ltm = hours(t_ltm) + datetime(1900,1,1);

end
%% 计算、绘制梅雨区降水量实况分布
cm = [192 225 135;71 167 62;144 208 229;63 85 168;197 93 174;234 44 61;162 43 54]/255;
levels = [0 25 50 100 200 300 500 600];

ax = ha(1);
start_time = datetime(2024,6,17);end_time = datetime(2024,7,2);
mask = cal_preci_anomaly_percentage(lon,lat,t,preci_2024,lon_ltm,lat_ltm,preci_ltm,start_time,end_time);
mask(~isnan(mask)) = 0;
preci_2024 = preci_2024 - mask;
titlename = ['(a) Total precipitation ',num2str(month(start_time),'%.2d'),num2str(day(start_time),'%.2d')...
    ,'—',num2str(month(end_time),'%.2d'),num2str(day(end_time),'%.2d')];
plot_precipitation(lon,lat,t,preci_2024,start_time,end_time,levels,cm,ax,titlename)

ax = ha(2);
start_time = datetime(2024,7,8);end_time = datetime(2024,7,20);
titlename = ['(b) Total precipitation ',num2str(month(start_time),'%.2d'),num2str(day(start_time),'%.2d')...
    ,'—',num2str(month(end_time),'%.2d'),num2str(day(end_time),'%.2d')];
plot_precipitation(lon,lat,t,preci_2024,start_time,end_time,levels,cm,ax,titlename)

cax = mycolorbar(levels,cm,'v','=>',[ax.Position(1)+ax.Position(3)+0.01 ax.Position(2)...
     0.015 ax.Position(4)]);
cax.FontSize = 12;
cax.Title.String = 'mm';cax.Title.FontSize = 12;
%% 辅助函数：计算并绘制梅雨区降水实况
function plot_precipitation(lon,lat,t,preci,start_time,end_time,levels,cm,ax,titlename)
preci = sum(preci(:,:,t>=start_time & t<=end_time),3);

[X,Y] = meshgrid(lon,lat);
axes(ax);
m_proj('Equidistant Cylindrical','lon',[105-2.5 125+2.5],'lat',[20 36]);hold on
m_grid('box','on','tickdir','out','xtick',105:5:135,'ytick',20:2:36, ...
    'linestyle','none','Fontsize',12);
mycontourf(X,Y,preci',levels,cm,'m');
colormap(ax,cm)
plot_boundary('k')
title(titlename,'FontSize',15,'Position',[ax.XLim(1) ax.YLim(2) 1],'HorizontalAlignment','left','FontWeight','bold')

end
%% 计算、绘制梅雨区降水量距平百分率分布
cm = [237 42 41;238 104 107;245 145 109;238 239 156;194 223 192;88 184 80;100 200 210;50 142 204;39 86 165]/255;
levels = [-100 -80 -50 -20 0 20 50 100 200 250];

ax = ha(3);
start_time = datetime(2024,6,17);end_time = datetime(2024,7,2);
preci_anomaly_percentage = cal_preci_anomaly_percentage(lon,lat,t,preci_2024,lon_ltm,lat_ltm,preci_ltm,start_time,end_time);
titlename = ['(c) Precipitation anomaly percentage ',num2str(month(start_time),'%.2d'),num2str(day(start_time),'%.2d')...
    ,'—',num2str(month(end_time),'%.2d'),num2str(day(end_time),'%.2d')];
plot_anomaly_percentage(lon,lat,preci_anomaly_percentage,levels,cm,ax,titlename)

ax = ha(4);
start_time = datetime(2024,7,8);end_time = datetime(2024,7,20);
preci_anomaly_percentage = cal_preci_anomaly_percentage(lon,lat,t,preci_2024,lon_ltm,lat_ltm,preci_ltm,start_time,end_time);
titlename = ['(d) Precipitation anomaly percentage ',num2str(month(start_time),'%.2d'),num2str(day(start_time),'%.2d')...
    ,'—',num2str(month(end_time),'%.2d'),num2str(day(end_time),'%.2d')];
plot_anomaly_percentage(lon,lat,preci_anomaly_percentage,levels,cm,ax,titlename)

cax = mycolorbar(levels,cm,'v','=>',[ax.Position(1)+ax.Position(3)+0.01 ax.Position(2)...
     0.015 ax.Position(4)]);
cax.FontSize = 12;
cax.Title.String = '%';cax.Title.FontSize = 12;
%% 保存文件
exportgraphics(fig,'图\Meiyu2024.png','Resolution',700)
%% 辅助函数：计算梅雨区降水量距平百分率分布
function preci_anomaly_percentage = cal_preci_anomaly_percentage(lon,lat,t,preci,lon_ltm,lat_ltm,preci_ltm,start_time,end_time)

preci = mean(preci(:,:,t>=start_time & t<=end_time),3)*2*24;
preci_ltm = mean(preci_ltm,3);
[Xq,Yq] = meshgrid(lon,lat);
[X,Y] = meshgrid(lon_ltm,lat_ltm);
preci_interp = interp2(X,Y,preci_ltm',Xq,Yq,"linear");
preci_interp = preci_interp';
preci_anomaly_percentage = (preci - preci_interp)./preci_interp*100;
clear X Y Xq Yq
end
%% 辅助函数：绘制梅雨区降水量距平百分率分布
function plot_anomaly_percentage(lon,lat,preci_anomaly_percentage,levels,cm,ax,titlename)
[X,Y] = meshgrid(lon,lat);
axes(ax);
m_proj('Equidistant Cylindrical','lon',[105-2.5 125+2.5],'lat',[20 36]);hold on
m_grid('box','on','tickdir','out','xtick',105:5:135,'ytick',20:2:36, ...
    'linestyle','none','Fontsize',12);
mycontourf(X,Y,preci_anomaly_percentage',levels,cm,'m');
% m_pcolor(X,Y,z_anom');
colormap(ax,cm)
% m_coast('line','color',[0.6 0.6 0.6],'linewidth',1,'linestyle','-');

plot_boundary('k')
title(titlename,'FontSize',15,'Position',[ax.XLim(1) ax.YLim(2) 1],'HorizontalAlignment','left','FontWeight','bold')

end
%% 辅助函数：绘制国界海岸线等
function plot_boundary(MeiyuColor)
%中国省界线文件（含九段线）
% ChinaL=shaperead('bou2_4l.shp');
% bou2_4lx=[ChinaL(:).X];
% bou2_4ly=[ChinaL(:).Y];
ChinaL = shaperead('中国各级行政区边界（shp格式）\行政边界_省级.shp');
bou2_4lx = [ChinaL(:).X];
bou2_4ly = [ChinaL(:).Y];
% clear ChinaP ChinaL
m_plot(bou2_4lx,bou2_4ly,'color',[.2 .2 .2],'linewidth',1.2,'linestyle','-');%绘制中国省界


nineLines = shaperead('中国地理要素shp完整版\SouthSea\九段线.shp');
nineLinesx = [nineLines(:).X];
nineLinesy = [nineLines(:).Y];
m_plot(nineLinesx,nineLinesy,'color',[.2 .2 .2],'linewidth',1.2,'linestyle','-');%绘制南海九段线


% m_gshhs('lb5','line','color','k','linewidth',1.2,'linestyle','-'); % 国界线
% m_coast('line','linewidth',1,'linestyle','-','color','k');% 海岸线
% m_gshhs_i('line','linewidth',1,'linestyle','-','color','k');% 海岸线

% 画梅雨区域
m_plot([110,122.5],[28 28],'color',MeiyuColor,'linewidth',1.2);
m_plot([122.5,122.5],[28 34],'color',MeiyuColor,'linewidth',1.2);
m_plot([122.5,110],[34 34],'color',MeiyuColor,'linewidth',1.2);
m_plot([110,110],[34 28],'color',MeiyuColor,'linewidth',1.2);
m_plot([110,122.5],[30,30],'color',MeiyuColor,'linewidth',1.2,'Linestyle',':')
m_plot([110,122.5],[32,32],'color',MeiyuColor,'linewidth',1.2,'Linestyle',':')
end