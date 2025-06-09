clc;clear;close all

%% 读取数据
% 读取2024梅雨期数据
fn = 'preci_MeiYu2024.nc';
t = ncread(fn,'time');
t = seconds(t)+datetime(1900,1,1);
preci = ncread(fn,'preci');
lon = ncread(fn,'lon');lat = ncread(fn,'lat');
preci = mean(preci,3)*24*60/30;

% 读取ltm数据
fn_preci_ltm = 'F:\Data\CPC Global Unified Gauge-Based Analysis of Daily Precipitation\precip.day.1991-2020.ltm.nc';
start_time = datetime(0001,6,10);end_time = datetime(0001,7,21);
range = [85 150 5 60];
[preci_ltm,lon_ltm,lat_ltm,t_ltm] = readncfile(fn_preci_ltm,'precip',start_time,end_time,range);
preci_ltm(abs(preci_ltm)>1e5) = nan;
preci_ltm = mean(preci_ltm,3);
% fn_preci_ltm = 'F:\Data\NCEP1\Daily\precip\precip.mon.ltm.1991-2020.nc';
% [preci_ltm,lon_ltm,lat_ltm] = readncfile(fn_preci_ltm);

% 读取再分析数据
fn_preci = 'F:\Data\CPC Global Unified Gauge-Based Analysis of Daily Precipitation\precip.2024.nc';
start_time = datetime(2024,6,10);end_time = datetime(2024,7,21);
range = [85 150 5 60];
[preci_CPC,~,~,~] = readncfile(fn_preci,'precip',start_time,end_time,range);
preci_CPC(abs(preci_CPC)>1e5) = nan;
preci_CPC = mean(preci_CPC,3);
%% 辅助函数：读取nc文件
function [hgt,lon,lat,t] = readncfile(fn,varname,start_time,end_time,range)

lon = ncread(fn,'lon');lat = ncread(fn,'lat');
lon = double(lon);lat = double(lat);

lat_range = lat>=range(3) & lat<=range(4);lon_range = lon>=range(1) & lon<=range(2);
lat_index = find(lat_range);lon_index = find(lon_range);
lon = lon(lon_range);lat = lat(lat_range);

it = days(start_time-datetime(year(end_time),1,1)+days(1));
n = days(end_time-start_time+days(1));

t = ncread(fn,'time',it,n);
t = days(t)+datetime(1800,1,1);

hgt = ncread(fn,varname,[lon_index(1) lat_index(1) it],[numel(lon_index) numel(lat_index) n]);
hgt = double(hgt);
end
%% 计算梅雨区降水量距平百分率分布
[Xq,Yq] = meshgrid(lon,lat);
[X,Y] = meshgrid(lon_ltm,lat_ltm);
preci_interp = interp2(X,Y,preci_ltm',Xq,Yq,"linear");
preci_interp = preci_interp';
preci_anomaly_percentage = (preci - preci_interp)./preci_interp*100;
preci_anomaly_percentage2 = (preci_CPC - preci_ltm)./preci_ltm*100;
clear X Y Xq Yq
%% 绘制梅雨区降水量距平百分率分布
clc;close all;
fig = figure('Position',[50,50,1400,500]);
[ha,~] = tight_subplot(1,2,[.08 .04],[.05 .05],[.04 .07]);
cm = [237 42 41;238 104 107;245 145 109;238 239 156;194 223 192;88 184 80;100 200 210;50 142 204;39 86 165]/255;
levels = [-100 -80 -50 -20 0 20 50 100 200 250];

ax = ha(1);
titlename = '(a) Preci. anom. percentage 0610—0721 (GPM)';
plot_anomaly_percentage(lon,lat,preci_anomaly_percentage,levels,cm,ax,titlename)

ax = ha(2);
titlename = '(b) Preci. anom. percentage 0610—0721 (CPC)';
plot_anomaly_percentage(lon_ltm,lat_ltm,preci_anomaly_percentage2,levels,cm,ax,titlename)

cax = mycolorbar(levels,cm,'v','=>',[ax.Position(3)+ax.Position(1)+0.02 ax.Position(2) ...
    0.015 ax.Position(4)]);
cax.FontSize = 12;
cax.Title.String = '%';

exportgraphics(fig,'图/Precipitation_anomaly_percentage.png','Resolution',700)
%% 辅助函数：绘制梅雨区降水量距平百分率分布
function plot_anomaly_percentage(lon,lat,preci_anomaly_percentage,levels,cm,ax,titlename)
[X,Y] = meshgrid(lon,lat);
axes(ax);
m_proj('Equidistant Cylindrical','lon',[88.75 126.25],'lat',[20 45]);hold on
m_grid('box','on','tickdir','out','xtick',90:10:125,'ytick',20:5:45, ...
    'linestyle','none','Fontsize',12);
mycontourf(X,Y,preci_anomaly_percentage',levels,cm,'m');
% m_contourf(X,Y,z_anom',levels,'Linestyle','none');
% m_pcolor(X,Y,z_anom');
colormap(cm)
% m_coast('line','color',[0.6 0.6 0.6],'linewidth',1,'linestyle','-');

plot_boundary('r')

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
m_coast('line','linewidth',1,'linestyle','-','color','k');% 海岸线
% m_gshhs_i('line','linewidth',1,'linestyle','-','color','k');% 海岸线

% 画梅雨区域
m_plot([110,122.5],[28 28],'color',MeiyuColor,'linewidth',1.2);
m_plot([122.5,122.5],[28 34],'color',MeiyuColor,'linewidth',1.2);
m_plot([122.5,110],[34 34],'color',MeiyuColor,'linewidth',1.2);
m_plot([110,110],[34 28],'color',MeiyuColor,'linewidth',1.2);
m_plot([110,122.5],[30,30],'color',MeiyuColor,'linewidth',1.2,'Linestyle',':')
m_plot([110,122.5],[32,32],'color',MeiyuColor,'linewidth',1.2,'Linestyle',':')
end