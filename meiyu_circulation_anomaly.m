clc;clear;close all

%% 读取数据
% 读取2024梅雨期大气环流数据
fn = 'F:\Data\NCEP1\Daily\hgt\hgt.2024.nc';
[hgt,lon,lat,p,t] = readncfiles(fn,'hgt');
fn = 'F:\Data\NCEP1\Daily\u\uwnd.2024.nc';
[u,~,~,~,~] = readncfiles(fn,'uwnd');
fn = 'F:\Data\NCEP1\Daily\v\vwnd.2024.nc';
[v,~,~,~,~] = readncfiles(fn,'vwnd');
fn = 'F:\Data\NCEP1\Daily\shum\shum.2024.nc';
[shum,~,~,p_shum,~] = readncfiles(fn,'shum');

% 读取ltm大气环流数据
fn = 'F:\Data\NCEP1\Daily\hgt\hgt.day.ltm.1991-2020.nc';
[hgt_ltm,~,~,~,~] = readncfile(fn,'hgt');
fn = 'F:\Data\NCEP1\Daily\u\uwnd.day.ltm.1991-2020.nc';
[u_ltm,~,~,~,~] = readncfile(fn,'uwnd');
fn = 'F:\Data\NCEP1\Daily\v\vwnd.day.ltm.1991-2020.nc';
[v_ltm,~,~,~,~] = readncfile(fn,'vwnd');
% fn = 'F:\Data\NCEP1\Daily\shum\shum.day.ltm.1991-2020.nc';
% [shum_ltm,~,~,~,~] = readncfiles(fn,'shum');

% 大气环流距平数据
hgt_a = hgt - hgt_ltm;
u_a = u - u_ltm;
v_a = v - v_ltm;

fig = figure('Position',[50 50 1530 900]);
[ha,~] = tight_subplot(2,2,[.08 .04],[.05 .05],[.04 .07]);
%% 辅助函数：读取nc文件 daily
function [hgt,lon,lat,p,t] = readncfiles(fn,varname)

p = ncread(fn,'level');p = double(p);

lon = ncread(fn,'lon');lat = ncread(fn,'lat');
lon = double(lon);lat = double(lat);

lat_range = lat>=-2.5 & lat<=90;lon_range = lon>=30-2.5 & lon<=180+2.5;
lat_index = find(lat_range);lon_index = find(lon_range);
lon = lon(lon_range);lat = lat(lat_range);

n = days(datetime(2024,7,21)-datetime(2024,6,10)+days(1));
it = days(datetime(2024,6,10)-datetime(2024,1,1)+days(1));

t = ncread(fn,'time',it,n);
t = hours(t)+datetime(1800,1,1);

hgt = ncread(fn,varname,[lon_index(1) lat_index(1) 1 it],[numel(lon_index) numel(lat_index) inf n]);
hgt = double(hgt);
end
%% 辅助函数：读取nc文件 ltm
function [hgt,lon,lat,p,t] = readncfile(fn,varname)

p = ncread(fn,'level');p = double(p);

lon = ncread(fn,'lon');lat = ncread(fn,'lat');
lon = double(lon);lat = double(lat);

lat_range = lat>=-2.5 & lat<=90;lon_range = lon>=30-2.5 & lon<=180+2.5;
lat_index = find(lat_range);lon_index = find(lon_range);
lon = lon(lon_range);lat = lat(lat_range);

it = days(datetime(0001,6,10)+days(1)-datetime(0000,12,30));
n = days(datetime(0001,7,21)-datetime(0001,6,10)+days(1));

t = ncread(fn,'time',it,n);
t = hours(t)+datetime(1900,1,1);

hgt = ncread(fn,varname,[lon_index(1) lat_index(1) 1 it],[numel(lon_index) numel(lat_index) inf n]);
hgt = double(hgt);
end
%% (a) 100 hPa hgt
hgt_a_100 = hgt_a(:,:,p==100,:);
hgt_a_100 = squeeze(hgt_a_100);
hgt_a_100 = mean(hgt_a_100,3);

% 绘图
clc;
% fig = figure('Position',[50,50,700,500]);
ax = ha(1);
cm = othercolor('RdYlBu10',14);cm = flip(cm,1);
levels = [-90 -80 -60 -40 -25 -10 -5 0 5 10 25 40 60 80 90];
% cax = mycolorbar(levels,cm,'h','<>',[ax.Position(1) ax.Position(2)-0.04 ...
%     ax.Position(3) 0.02]);
% cax.FontSize = 12;
plot_anomaly_circulation(lon,lat,hgt_a_100,levels,cm,ax);
hgt100 = hgt(:,:,p==100,:);hgt100 = squeeze(hgt100);hgt100 = mean(hgt100,3);
hgt100_ltm = hgt_ltm(:,:,p==100,:);hgt100_ltm = squeeze(hgt100_ltm);hgt100_ltm = mean(hgt100_ltm,3);
plot_anomaly_circulation_gpm(lon,lat,hgt100,hgt100_ltm,16780)
title('(a) HGTa 100 hPa','FontSize',15,'Position',[ax.XLim(1) ax.YLim(2) 1],'HorizontalAlignment','left','FontWeight','bold')
%% (b) 500 hPa hgt
hgt_a_500 = hgt_a(:,:,p==500,:);
hgt_a_500 = squeeze(hgt_a_500);
hgt_a_500 = mean(hgt_a_500,3);

% 绘图
clc;
% fig = figure('Position',[50,50,700,500]);
ax = ha(2);
cm = othercolor('RdYlBu10',14);cm = flip(cm,1);
levels = [-90 -80 -60 -40 -25 -10 -5 0 5 10 25 40 60 80 90];
cax = mycolorbar(levels,cm,'v','<>',[ax.Position(1)+ax.Position(3)+0.02 ax.Position(2) ...
    0.015 ax.Position(4)]);
cax.FontSize = 12;cax.Title.String = 'gpm';
plot_anomaly_circulation(lon,lat,hgt_a_500,levels,cm,ax);
hgt500 = hgt(:,:,p==500,:);hgt500 = squeeze(hgt500);hgt500 = mean(hgt500,3);
hgt500_ltm = hgt_ltm(:,:,p==500,:);hgt500_ltm = squeeze(hgt500_ltm);hgt500_ltm = mean(hgt500_ltm,3);
plot_anomaly_circulation_gpm(lon,lat,hgt500,hgt500_ltm,5880)
title('(b) HGTa 500 hPa','FontSize',15,'Position',[ax.XLim(1) ax.YLim(2) 1],'HorizontalAlignment','left','FontWeight','bold')
%% 辅助函数：绘制梅雨区位势高度异常分布
function plot_anomaly_circulation(lon,lat,hgt,levels,cm,ax)
[X,Y] = meshgrid(lon,lat);
axes(ax);
m_proj('Equidistant Cylindrical','lon',[30 180],'lat',[0 70]);hold on
% m_proj('Stereographic','lon',60,'lat',90);hold on
m_grid('box','on','tickdir','out','xtick',30:30:180,'ytick',0:10:70, ...
    'linestyle','none','Fontsize',12);
mycontourf(X,Y,hgt',levels,cm,'m');
% m_contourf(X,Y,z_anom',levels,'Linestyle','none');
colormap(cm)

plot_boundary('white');

end
%% 辅助函数：绘制梅雨区位势高度等值线分布
function plot_anomaly_circulation_gpm(lon,lat,hgt_p,hgt_p_ltm,hgt_plot)
[X,Y] = meshgrid(lon,lat);
m_contour(X,Y,hgt_p',[hgt_plot hgt_plot],'color','b','LineWidth',1.5,'ShowText','on')
m_contour(X,Y,hgt_p_ltm',[hgt_plot hgt_plot],'color','g','LineWidth',1.5,'ShowText','on')
end
%% (c) 850 hPa风场分布
clc;
u_a_850 = squeeze(u_a(:,:,p==850,:));v_a_850 = squeeze(v_a(:,:,p==850,:));
u_a_850 = mean(u_a_850,3);v_a_850 = mean(v_a_850,3);
% 绘图
% fig = figure('Position',[50,50,700,500]);
ax = ha(3);
plot_anomaly_wind(lon,lat,u_a_850,v_a_850,ax)
title('(c) Wind ano. 850 hPa','FontSize',15,'Position',[ax.XLim(1) ax.YLim(2) 1],'HorizontalAlignment','left','FontWeight','bold')
%% 辅助函数：绘制风场分布
function plot_anomaly_wind(lon,lat,u_a,v_a,ax)
axes(ax);
m_proj('Equidistant Cylindrical','lon',[30 182],'lat',[0 70]);hold on
% m_proj('Stereographic','lon',60,'lat',90);hold on
m_grid('box','on','tickdir','out','xtick',30:30:180,'ytick',0:10:70, ...
    'linestyle','none','Fontsize',12);
% mycontourf(X,Y,hgt',levels,cm,'m');
dx = 2;dy = 1;
u_a = u_a(1:dx:end,1:dy:end-1);v_a = v_a(1:dx:end,1:dy:end-1);
u_a(:,lat>=70) = nan;
lon1 = lon(1:dx:end);lat1 = lat(1:dy:end-1);
[X,Y] = meshgrid(lon1,lat1);

m_vec(20,X,Y,u_a',v_a', [.8 .1 0.8]);
plot_boundary('k');

end
%% (d) 水汽通量及其散度
clc;
levels = [-6:1:-1,-0.5,0.5,1:6];
cm = othercolor('RdYlGn10',12);cm = flip(cm,1);
cm = cat(1,cm(1:6,:),[1 1 1],cm(7:end,:));
% fig = figure('Position',[50,50,700,500]);
ax = ha(4);
cax = mycolorbar(levels,cm,'v','<>',[ax.Position(1)+ax.Position(3)+0.02 ax.Position(2) ...
    0.015 ax.Position(4)]);
cax.FontSize = 12;cax.Title.String = '10^{-5} kg/(m^2 s)';
plot_vapor_flux_d(lon,lat,u,v,shum,p_shum,ax,levels,cm)
title('(d) Water vapor flux & div.','FontSize',15,'Position',[ax.XLim(1) ax.YLim(2) 1],'HorizontalAlignment','left','FontWeight','bold')
%% 保存文件
exportgraphics(fig,'图\Circu_anom.png','Resolution',700)
%% 辅助函数：计算水汽通量及其散度并绘图
function plot_vapor_flux_d(lon,lat,u,v,shum,p,ax,levels,cm)
u = u(:,:,p>=300,:);v = v(:,:,p>=300,:);shum = shum(:,:,p>=300,:);
% u_meiyu = mean(u,4);v_meiyu = mean(v,4);shum_meiyu = mean(shum,4);
% [qu, qv] = cal_vapor_flux(u_meiyu, v_meiyu, shum_meiyu, p);
% div_q = cal_div(qu, qv, lat, lon);
% div_q_d([1 end],:) = nan;
% 气候
qu = zeros(size(u,[1 2 4]));qv = qu;div_q = qu;
for it = 1:size(u,4)
    [qu(:,:,it), qv(:,:,it)] = cal_vapor_flux(u(:,:,:,it), v(:,:,:,it), shum(:,:,:,it), p);
    div_q(:,:,it) = cal_div(qu(:,:,it), qv(:,:,it), lat, lon);   
    div_q([1 end],:,:) = nan;
end
qu = mean(qu,3);qv = mean(qv,3);div_q = mean(div_q,3);
div_q = div_q*1e5;

axes(ax)
m_proj('Equidistant Cylindrical','lon',[30 180],'lat',[0 70]);hold on
m_grid('box','on','tickdir','out','xtick',30:30:180,'ytick',0:10:70, ...
    'linestyle','none','Fontsize',12);

[X,Y] = meshgrid(lon,lat);
mycontourf(X,Y,div_q',levels,cm,'m');

dx = 2;dy = 1;
lon1 = lon(1:dx:end);lat1 = lat(1:dy:end);
qu = qu(1:dx:end,1:dy:end);qv = qv(1:dx:end,1:dy:end);
qu(:,lat>=70) = nan;qv(:,lat>=70) = nan;
[X,Y] = meshgrid(lon1,lat1);
m_vec(800,X,Y,qu',qv',[0.9 0.1 0.9]);


plot_boundary('white');

end
%% 辅助函数：绘制国界海岸线等
function plot_boundary(MeiyuColor)
%中国省界线文件（含九段线）
ChinaL=shaperead('bou2_4l.shp');
bou2_4lx=[ChinaL(:).X];
bou2_4ly=[ChinaL(:).Y];

clear ChinaP ChinaL
m_plot(bou2_4lx,bou2_4ly,'color',[.2 .2 .2],'linewidth',1.2,'linestyle','-.');%绘制中国省界
m_gshhs('lb1','line','color','k','linewidth',1.2,'linestyle','-'); % 国界线
m_coast('line','linewidth',1,'linestyle','-','color','k');% 海岸线

% 画梅雨区域
m_plot([110,122.5],[28 28],'color',MeiyuColor,'linewidth',1.2);
m_plot([122.5,122.5],[28 34],'color',MeiyuColor,'linewidth',1.2);
m_plot([122.5,110],[34 34],'color',MeiyuColor,'linewidth',1.2);
m_plot([110,110],[34 28],'color',MeiyuColor,'linewidth',1.2);
m_plot([110,122.5],[30,30],'color',MeiyuColor,'linewidth',1,'Linestyle',':')
m_plot([110,122.5],[32,32],'color',MeiyuColor,'linewidth',1,'Linestyle',':')
end