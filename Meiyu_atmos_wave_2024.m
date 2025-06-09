clc;clear;close all
%% 读取数据
% 读取2024梅雨期大气环流数据
range = [0 360 -90 90];
start_time = datetime(2024,6,10);end_time = datetime(2024,7,21);
fn = 'F:\Data\NCEP1\Daily\hgt\hgt.2024.nc';
[hgt,lon,lat,p,t] = readncfiles(fn,'hgt',start_time,end_time,range);
fn = 'F:\Data\NCEP1\Daily\u\uwnd.2024.nc';
[u,~,~,~,~] = readncfiles(fn,'uwnd',start_time,end_time,range);
fn = 'F:\Data\NCEP1\Daily\v\vwnd.2024.nc';
[v,~,~,~,~] = readncfiles(fn,'vwnd',start_time,end_time,range);


% 读取ltm大气环流数据
fn = 'F:\Data\NCEP1\Daily\hgt\hgt.day.ltm.1991-2020.nc';
[hgt_ltm,~,~,~,~] = readncfile(fn,'hgt',start_time,end_time,range);
fn = 'F:\Data\NCEP1\Daily\u\uwnd.day.ltm.1991-2020.nc';
[u_ltm,~,~,~,~] = readncfile(fn,'uwnd',start_time,end_time,range);
fn = 'F:\Data\NCEP1\Daily\v\vwnd.day.ltm.1991-2020.nc';
[v_ltm,~,~,~,~] = readncfile(fn,'vwnd',start_time,end_time,range);
% fn = 'F:\Data\NCEP1\Daily\shum\shum.day.ltm.1991-2020.nc';
% [shum_ltm,~,~,~,~] = readncfiles(fn,'shum');

% fig = figure('Position',[50 50 1530 900]);
% [ha,~] = tight_subplot(2,2,[.08 .04],[.05 .05],[.04 .07]);
%% 辅助函数：读取nc文件 daily
function [hgt,lon,lat,p,t] = readncfiles(fn,varname,start_time,end_time,range)

p = ncread(fn,'level');p = double(p);

lon = ncread(fn,'lon');lat = ncread(fn,'lat');
lon = double(lon);lat = double(lat);

lat_range = lat>=range(3) & lat<=range(4);lon_range = lon>=range(1) & lon<=range(2);
lat_index = find(lat_range);lon_index = find(lon_range);
lon = lon(lon_range);lat = lat(lat_range);

it = days(start_time-datetime(year(end_time),1,1)+days(1));
n = days(end_time-start_time+days(1));

t = ncread(fn,'time',it,n);
t = hours(t)+datetime(1800,1,1);

hgt = ncread(fn,varname,[lon_index(1) lat_index(1) 1 it],[numel(lon_index) numel(lat_index) inf n]);
hgt = double(hgt);
end
%% 辅助函数：读取nc文件 ltm
function [hgt,lon,lat,p,t] = readncfile(fn,varname,start_time,end_time,range)

p = ncread(fn,'level');p = double(p);

lon = ncread(fn,'lon');lat = ncread(fn,'lat');
lon = double(lon);lat = double(lat);

lat_range = lat>=range(3) & lat<=range(4);lon_range = lon>=range(1) & lon<=range(2);
lat_index = find(lat_range);lon_index = find(lon_range);
lon = lon(lon_range);lat = lat(lat_range);

it = days(datetime(0001,6,10)+days(1)-datetime(0000,12,30));
n = days(datetime(0001,7,21)-datetime(0001,6,10)+days(1));

t = ncread(fn,'time',it,n);
t = hours(t)+datetime(1900,1,1);

hgt = ncread(fn,varname,[lon_index(1) lat_index(1) 1 it],[numel(lon_index) numel(lat_index) inf n]);
hgt = double(hgt);
end
%% RWS
close all
p_level = p==500;
S = RWS_cal(squeeze(mean(u_ltm(:,:,p_level,:),4)),squeeze(mean(v_ltm(:,:,p_level,:),4)),...
    squeeze(mean(u(:,:,p_level,:),4)),squeeze(mean(v(:,:,p_level,:),4)),lon,lat);

fig = figure('Position',[50 50 1400 700]);
% [ha,~] = tight_subplot(3,1,[.05 .03],[.05 .05],[.08 .1]);
ax = axes;

levels = [-6:1:-2,2:1:6];
cm = othercolor('RdBu10',8);cm = flip(cm,1);
cm = [cm(1:4,:);1 1 1;cm(end-3:end,:)];
cax = mycolorbar(levels,cm,'v','<>',[ax.Position(1)+ax.Position(3)+0.01 ax.Position(2)...
     0.015 ax.Position(4)]);
cax.FontSize = 12;

titlename = '(a) RWS 0610—0721';
plot_RWS(lon,lat,S,ax,cm,levels,titlename)
%% 辅助函数：绘制RWS
function plot_RWS(lon,lat,S,ax,cm,levels,titlename)
S = S*1e11;
[X,Y] = meshgrid(lon,lat);
axes(ax)
m_proj('Equidistant Cylindrical','lon',[0 360],'lat',[0 80]);hold on
m_grid('box','on','tickdir','out','xtick',30:15:135,'ytick',0:10:50, ...
    'linestyle','none','Fontsize',12);
mycontourf(X,Y,S',levels,cm,'m');
colormap(ax,cm)
m_coast('line','color',[0.5 0.5 0.5],'linewidth',1,'linestyle','-');
title(titlename,'FontSize',15,'Position',[ax.XLim(1) ax.YLim(2) 1],'HorizontalAlignment','left','FontWeight','bold')
end
%% TN WAF
close all
p_level = p==500;
[Wx,Wy,~] = TN_WAF(squeeze(u_ltm(:,:,p_level,:)),squeeze(v_ltm(:,:,p_level,:)),squeeze(hgt_ltm(:,:,p_level,:)),...
    500,lon,lat,squeeze(mean(hgt(:,:,p_level,:),4)));

fig = figure('Position',[50 50 1400 700]);
% [ha,~] = tight_subplot(3,1,[.05 .03],[.05 .05],[.08 .1]);
ax = axes;
titlename = '(b) TN WAF 0610—0721';
plot_Tn_WAF(lon,lat,Wx,Wy,ax,titlename)
%% 辅助函数：绘制TN WAF
function plot_Tn_WAF(lon,lat,WAF_x,WAF_y,ax,titlename)
axes(ax);
m_proj('Equidistant Cylindrical','lon',[0 360],'lat',[0 60]);hold on
m_grid('box','on','tickdir','out','xtick',0:30:180,'ytick',0:10:60, ...
    'linestyle','none','Fontsize',12);

WAF_x(:,abs(lat)<10) = nan;WAF_y(:,abs(lat)<10) = nan;
WAF_x(lon>=360,:) = nan;WAF_y(lon>=360,:) = nan;
WAF_x(:,lat>=60) = nan;WAF_y(:,lat>=60) = nan;

dx = 2;dy = 1;
lon = lon(1:dx:end);lat = lat(1:dy:end);
WAF_x = WAF_x(1:dx:end,1:dy:end);
WAF_y = WAF_y(1:dx:end,1:dy:end);

[X,Y] = meshgrid(lon,lat);
m_vec(20,X,Y,WAF_x',WAF_y','magenta')
plot_boundary('white');

title(titlename,'FontSize',15,'Position',[ax.XLim(1) ax.YLim(2) 1],'HorizontalAlignment','left','FontWeight','bold')
end
%% SST Atalantic
clear;clc;close all
range = [0 360 -40 70];
% 读取2024梅雨期SST数据
fn = 'F:\Data\NOAA OI SST V2 High Resolution Dataset\sst.mon.mean.nc';
start_time = datetime(2023,12,1);end_time = datetime(2024,2,1);
[sst,lon,lat,t] = readncfile_SST_mon(fn,'sst',start_time,end_time,range);
sst(abs(sst)>1e5) = nan;

fn = 'F:\Data\NCEP1\hgt.mon.mean.nc';
[hgt,lon_uv,lat_uv,p,t_uv] = readncfile_Wind_mon(fn,'hgt',start_time,end_time,range);


% 读取ltm SST数据
fn = 'F:\Data\NOAA OI SST V2 High Resolution Dataset\sst.mon.ltm.1991-2020.nc';
start_time = datetime(0000,12,30);end_time = datetime(0001,11,29);
[sst_ltm,~,~,~] = readncfile_SST_mon(fn,'sst',start_time,end_time,range);
sst_ltm(abs(sst_ltm)>1e5) = nan;
sst_ltm = sst_ltm(:,:,[12,1,2]);

fn = 'F:\Data\NCEP1\hgt.mon.ltm.1991-2020.nc';
[hgt_ltm,~,~,~,~] = readncfile_Wind_mon(fn,'hgt',start_time,end_time,range);
hgt_ltm = hgt_ltm(:,:,:,[12,1,2]);

cm = othercolor('RdYlBu10',14);cm = flip(cm,1);
% cm = [cm(1:6,:);[1 1 1];cm(end-5:end,:)];
fig = figure('Position',[50 50 1400 400]);
ax = axes('Position',[0.05 0.08 0.85 0.8]);
levels = -2.1:0.3:2.1;
titlename = '(a) SSTa & HGTa 200 hPa D^0J^1F^1 2023';

plot_sst_ano(lon,lat,hgt,hgt_ltm,p,300,lon_uv,lat_uv,sst,sst_ltm,ax,levels,cm,titlename)
cax = mycolorbar(levels,cm,'v','<>',[ax.Position(1)+ax.Position(3)+0.01 ax.Position(2) ...
    0.015 ax.Position(4)]);
cax.FontSize = 12;cax.Title.String = '°C';
exportgraphics(fig,'图\SSTa_HGTa2023DJF.png','Resolution',700)
%% 辅助函数：绘制SST Atalantic异常
function plot_sst_ano(lon,lat,hgt,hgt_ltm,p,p_level,lon_uv,lat_uv,sst,sst_ltm,ax,levels,cm,titlename)
sst_a = sst - sst_ltm;
sst_a = mean(sst_a,3);

hgt_a = hgt - hgt_ltm;
hgt_a = hgt_a(:,:,p==p_level,:);
hgt_a = squeeze(mean(hgt_a,4));
[X,Y] = meshgrid(lon,lat);
axes(ax);
m_proj('Equidistant Cylindrical','lon',[0 360],'lat',[-35 60]);hold on
m_grid('box','on','tickdir','out','xtick',0:30:360,'ytick',-30:15:60, ...
    'linestyle','none','Fontsize',12);
mycontourf(X,Y,sst_a',levels,cm,'m');
% m_contourf(X,Y,z_anom',levels,'Linestyle','none');
% m_pcolor(X,Y,z_anom');
colormap(ax,cm)

[X,Y] = meshgrid(lon_uv,lat_uv);
m_contour(X,Y,hgt_a',10:10:120,'color','k','Linestyle','-','Linewidth',1.2)
m_contour(X,Y,hgt_a',-120:10:-10,'color','k','Linestyle','--','Linewidth',1.2)
m_contour(X,Y,hgt_a',[0 0],'color','k','Linestyle','-','Linewidth',2)

m_coast('line','linewidth',1,'linestyle','-','color','k');

title(titlename,'FontSize',15,'Position',[ax.XLim(1) ax.YLim(2) 1],'HorizontalAlignment','left','FontWeight','bold')
end
%% 辅助函数：读取nc文件 SST
function [hgt,lon,lat,t] = readncfile_SST(fn,varname,start_time,end_time,range)

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

function [hgt,lon,lat,t] = readncfile_SST_ltm(fn,varname,start_time,end_time,range)

lon = ncread(fn,'lon');lat = ncread(fn,'lat');
lon = double(lon);lat = double(lat);

lat_range = lat>=range(3) & lat<=range(4);lon_range = lon>=range(1) & lon<=range(2);
lat_index = find(lat_range);lon_index = find(lon_range);
lon = lon(lon_range);lat = lat(lat_range);

it = days(start_time+days(1)-datetime(0000,12,30));
n = days(end_time-start_time+days(1));

t = ncread(fn,'time',it,n);
t = days(t)+datetime(1800,1,1);

hgt = ncread(fn,varname,[lon_index(1) lat_index(1) it],[numel(lon_index) numel(lat_index) n]);
hgt = double(hgt);
end

function [hgt,lon,lat,t] = readncfile_SST_mon(fn,varname,start_time,end_time,range)

lon = ncread(fn,'lon');lat = ncread(fn,'lat');
lon = double(lon);lat = double(lat);

lat_range = lat>=range(3) & lat<=range(4);lon_range = lon>=range(1) & lon<=range(2);
lat_index = find(lat_range);lon_index = find(lon_range);
lon = lon(lon_range);lat = lat(lat_range);

t = ncread(fn,'time');
t = days(t)+datetime(1800,1,1);

t1 = find(t == start_time);
t2 = find(t == end_time);
n = t2 - t1 + 1;

hgt = ncread(fn,varname,[lon_index(1) lat_index(1) t1],[numel(lon_index) numel(lat_index) n]);
hgt = double(hgt);

t = t(t1:t2);
end

function [hgt,lon,lat,p,t] = readncfile_Wind_mon(fn,varname,start_time,end_time,range)
p = ncread(fn,'level');p = double(p);

lon = ncread(fn,'lon');lat = ncread(fn,'lat');
lon = double(lon);lat = double(lat);

lat_range = lat>=range(3) & lat<=range(4);lon_range = lon>=range(1) & lon<=range(2);
lat_index = find(lat_range);lon_index = find(lon_range);
lon = lon(lon_range);lat = lat(lat_range);

t = ncread(fn,'time');
t = hours(t)+datetime(1800,1,1);

t1 = find(t == start_time);
t2 = find(t == end_time);
n = t2 - t1 + 1;

hgt = ncread(fn,varname,[lon_index(1) lat_index(1) 1 t1],[numel(lon_index) numel(lat_index) inf n]);
hgt = double(hgt);

t = t(t1:t2);
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
