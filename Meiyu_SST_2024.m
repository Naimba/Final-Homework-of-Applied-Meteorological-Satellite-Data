clear;clc;close all;
%% 绘图
clear;clc;close all;
fig = figure('Position',[50,50,1145,825]);
[ha,~] = tight_subplot(2,2,[.06 .1],[.08 .03],[.06 .07]);
ha1(1) = axes('Position',[ha(1).Position(1) ha(1).Position(2) ha(2).Position(1)+ha(2).Position(3)-ha(1).Position(1) ha(1).Position(3)]);
ha1(2) = ha(3);ha1(3) = ha(4);
ha(1).Visible = "off";ha(2).Visible = "off";
% cla ha(2);cla ha(3);cla ha(4)
%% SST梅雨期
% clear;clc;close all
range = [40 355 -40 70];
% 读取2024梅雨期SST数据
fn = 'F:\Data\NOAA OI SST V2 High Resolution Dataset\sst.day.mean.2024.nc';
start_time = datetime(2024,6,10);end_time = datetime(2024,7,21);
[sst,lon,lat,~] = readncfile_SST(fn,'sst',start_time,end_time,range);
sst(abs(sst)>1e5) = nan;
% 读取ltm SST数据
fn = 'F:\Data\NOAA OI SST V2 High Resolution Dataset\sst.day.mean.ltm.1991-2020.nc';
start_time = datetime(0001,6,10);end_time = datetime(0001,7,21);
[sst_ltm,~,~,~] = readncfile_SST_ltm(fn,'sst',start_time,end_time,range);
sst_ltm(abs(sst_ltm)>1e5) = nan;

sst_a = sst - sst_ltm;

cm = othercolor('RdYlBu10',12);cm = flip(cm,1);
cm = [cm(1:6,:);[1 1 1];cm(end-5:end,:)];
ax = ha1(1);
levels = [-2.1:0.3:-0.3,0.3:0.3:2.1];
titlename = '(a) SSTa 0610—0721';
plot_sst_ano(lon,lat,sst_a,ax,levels,cm,titlename)
cax = mycolorbar(levels,cm,'v','<>',[ax.Position(1)+ax.Position(3)+0.01 ax.Position(2) ...
    0.015 ax.Position(4)]);
cax.FontSize = 12;cax.Title.String = '°C';
%% 辅助函数：绘制SST异常
function plot_sst_ano(lon,lat,sst_a,ax,levels,cm,titlename)
sst_a = mean(sst_a,3);
[X,Y] = meshgrid(lon,lat);
axes(ax);
m_proj('Equidistant Cylindrical','lon',[45 350],'lat',[-35 60]);hold on
m_grid('box','on','tickdir','out','xtick',60:30:360,'ytick',-35:15:60, ...
    'linestyle','none','Fontsize',12);
mycontourf(X,Y,sst_a',levels,cm,'m');
% m_contourf(X,Y,z_anom',levels,'Linestyle','none');
% m_pcolor(X,Y,z_anom');
colormap(ax,cm)


m_coast('line','linewidth',1,'linestyle','-','color','k');

title(titlename,'FontSize',15,'Position',[ax.XLim(1) ax.YLim(2) 1],'HorizontalAlignment','left','FontWeight','bold')
end
%% SST Hov 读取数据
range = [40 100 -12 -8];
% 读取2023~2024梅雨期SST数据
fn = 'F:\Data\NOAA OI SST V2 High Resolution Dataset\sst.day.mean.2023.nc';
start_time = datetime(2023,7,1);end_time = datetime(2023,12,31);
[sst1,lon,~,t1] = readncfile_SST(fn,'sst',start_time,end_time,range);
sst1(abs(sst1)>1e5) = nan;
fn = 'F:\Data\NOAA OI SST V2 High Resolution Dataset\sst.day.mean.2024.nc';
start_time = datetime(2024,1,1);end_time = datetime(2024,8,1);
[sst2,~,~,t2] = readncfile_SST(fn,'sst',start_time,end_time,range);
sst2(abs(sst2)>1e5) = nan;
sst = cat(3,sst1,sst2);clear sst1 sst2
t = cat(1,t1,t2);clear t1 t2
sst = sst(:,:,t~=datetime(2024,2,29));t = t(t~=datetime(2024,2,29));

% 读取ltm SST数据
fn = 'F:\Data\NOAA OI SST V2 High Resolution Dataset\sst.day.mean.ltm.1991-2020.nc';
start_time = datetime(0000,12,30);end_time = datetime(0001,12,29);
[sst_ltm,~,~,t_ltm] = readncfile_SST_ltm(fn,'sst',start_time,end_time,range);
sst_ltm(abs(sst_ltm)>1e5) = nan;
sst_ltm = sst_ltm(:,:,[find(t_ltm>=datetime(0001,7,1));find(t_ltm<=datetime(0001,8,1))]);
%% SST Hov 计算绘图
% close;clc
% fig = figure('Position',[50,50,600,500]);

cm = othercolor('RdYlBu10',12);cm = flip(cm,1);
% cm = [cm(1:5,:);[1 1 1];cm(end-4:end,:)];
ax = ha1(2);
levels = -1.8:0.3:1.8;

titlename = '(b) SSTa 8—12°S Hovmöller';
plot_sst_hov(lon,t,sst_ltm,sst,ax,cm,levels,titlename)
cax = mycolorbar(levels,cm,'v','<>',[ax.Position(3)+ax.Position(1)+0.01 ax.Position(2) ...
    0.015 ax.Position(4)]);
cax.FontSize = 12;cax.Title.String = '°C';
%% 辅助函数：SST Hov绘图
function plot_sst_hov(lon,t,sst_ltm,sst,ax,cm,levels,titlename)
sst_a = sst - sst_ltm;
sst_a = mean(sst_a,2);sst_a = squeeze(sst_a);
tn = 1:numel(t);
[X,T] = meshgrid(lon,tn);

axes(ax);
mycontourf(X,T,sst_a',levels,cm,'M');
colormap(ax,cm)
xlim([lon(3) lon(end)]);
xtick = 50:10:100;
xticks(xtick);
xtl = cell(numel(xtick),1);
for i = 1:numel(xtick)
    xtl{i} = [num2str(xtick(i),'%d'),'°E'];
end
xticklabels(xtl);
yticks(tn(day(t)==1));
yticklabels({'July^0','Aug.^0','Sept.^0','Oct.^0','Nov.^0','Dec.^0','Jan.^1','Feb.^1','Mar.^1','Apr.^0','May^1','June^1','July^1'});

ax.FontSize = 12;ax.FontWeight = "bold";

title(titlename,'FontSize',15,'Position',[ax.XLim(1) ax.YLim(2) 1],'HorizontalAlignment','left','FontWeight','bold')
ax.TickDir = "out";
grid on
box on
end
%% SST Wind Hov
% clear;clc;close all
range = [50 100 -30 30];
% 读取2023~2024梅雨期SST数据
fn = 'F:\Data\NOAA OI SST V2 High Resolution Dataset\sst.mon.mean.nc';
start_time = datetime(2023,7,1);end_time = datetime(2024,8,1);
[sst,~,lat,t] = readncfile_SST_mon(fn,'sst',start_time,end_time,range);
sst(abs(sst)>1e5) = nan;

fn = 'F:\Data\NCEP1\uwnd.mon.mean.nc';
[u,lon_uv,lat_uv,p,t_uv] = readncfile_Wind_mon(fn,'uwnd',start_time,end_time,range);
fn = 'F:\Data\NCEP1\vwnd.mon.mean.nc';
[v,~,~,~] = readncfile_Wind_mon(fn,'vwnd',start_time,end_time,range);

% 读取ltm SST数据
fn = 'F:\Data\NOAA OI SST V2 High Resolution Dataset\sst.mon.ltm.1991-2020.nc';
start_time = datetime(0000,12,30);end_time = datetime(0001,11,29);
[sst_ltm,~,~,~] = readncfile_SST_mon(fn,'sst',start_time,end_time,range);
sst_ltm(abs(sst_ltm)>1e5) = nan;
sst_ltm = sst_ltm(:,:,[7:12,1:8]);

fn = 'F:\Data\NCEP1\uwnd.mon.ltm.1991-2020.nc';
[u_ltm,~,~,~,~] = readncfile_Wind_mon(fn,'uwnd',start_time,end_time,range);
u_ltm = u_ltm(:,:,:,[7:12,1:8]);
fn = 'F:\Data\NCEP1\vwnd.mon.ltm.1991-2020.nc';
[v_ltm,~,~,~,~] = readncfile_Wind_mon(fn,'vwnd',start_time,end_time,range);
v_ltm = v_ltm(:,:,:,[7:12,1:8]);
%% SST Wind Hov 计算绘图
% close;clc

% fig = figure('Position',[50,50,600,500]);
cm = othercolor('RdYlBu10',10);cm = flip(cm,1);
cm = [cm(1:5,:);[1 1 1];cm(end-4:end,:)];
ax = ha1(3);
levels = [-1.2:0.2:-0.2,0.2:0.2:1.2];
plevel = 850;

titlename = '(c) SSTa & 850Wind 50—100°E Hovmöller';
plot_sst_wind_hov(lat,t,sst_ltm,u,v,u_ltm,v_ltm,p,plevel,lat_uv,sst,ax,cm,levels,titlename)
cax = mycolorbar(levels,cm,'v','<>',[ax.Position(3)+ax.Position(1)+0.01 ax.Position(2) ...
    0.015 ax.Position(4)]);
cax.FontSize = 12;cax.Title.String = '°C';
%% 保存图片
exportgraphics(fig,'图/Meiyu_SSTa.png','Resolution',700)
%% 辅助函数：SST Wind Hov绘图
function plot_sst_wind_hov(lat,t,sst_ltm,u,v,u_ltm,v_ltm,p,plevel,lat_uv,sst,ax,cm,levels,titlename)
sst_a = sst - sst_ltm*1.01;
% dy = 2;
sst_a = mean(sst_a,1,'omitmissing');sst_a = squeeze(sst_a);
u_a = u - u_ltm*1.01;u_a = mean(u_a,1,'omitmissing');u_a = u_a(:,:,p==plevel,:);u_a = squeeze(u_a);
% u_a = u_a(1:dy:end,:);
v_a = v - v_ltm*1.01;v_a = mean(v_a,1,'omitmissing');v_a = v_a(:,:,p==plevel,:);v_a = squeeze(v_a);
% v_a = v_a(1:dy:end,:);
% lat_uv = lat_uv(1:dy:end);
tn = 1:numel(t);
[T,Y] = meshgrid(tn,lat);

axes(ax);
mycontourf(T,Y,sst_a,levels,cm,'M');
colormap(ax,cm)
box on

[T,Y] = meshgrid(tn,lat_uv);
% quiver(T,Y,u_a,v_a,1,"filled")
myquiver(ax,0.01,T,Y,u_a,v_a)

ylim([-25 25]);
ytick = [-25,-20:10:20,25];
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

xlim([1 numel(t)])
xticks(tn);
xticklabels({'July^0','Aug.^0','Sept.^0','Oct.^0','Nov.^0','Dec.^0','Jan.^1','Feb.^1','Mar.^1','Apr.^0','May^1','June^1','July^1','Aug.^1'});

ax.FontSize = 12;ax.FontWeight = "bold";

title(titlename,'FontSize',15,'Position',[ax.XLim(1) ax.YLim(2) 1],'HorizontalAlignment','left','FontWeight','bold')
ax.TickDir = "out";
grid on
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