clc;clear;close all

%% SSTA 秋冬
clear;clc;close all
range = [0 360 -40 70];

cm = othercolor('RdYlBu10',14);cm = flip(cm,1);
% cm = [cm(1:6,:);[1 1 1];cm(end-5:end,:)];
fig = figure('Position',[50 50 1350 1200]);
[ha,~] = tight_subplot(3,1,[.05 .04],[.05 .05],[.04 .07]);

% ax = axes('Position',[0.05 0.08 0.85 0.8]);
levels = -2.1:0.3:2.1;


% 读取SST数据
fn = 'F:\Data\NOAA OI SST V2 High Resolution Dataset\sst.mon.mean.nc';
start_time = datetime(2023,9,1);end_time = datetime(2024,5,1);
[sst,lon,lat,t] = readncfile_SST_mon(fn,'sst',start_time,end_time,range);
sst(abs(sst)>1e5) = nan;

fn = 'F:\Data\NCEP1\hgt.mon.mean.nc';
[hgt,lon_uv,lat_uv,p,t_uv] = readncfile_Wind_mon(fn,'hgt',start_time,end_time,range);


% 读取ltm SST数据
fn = 'F:\Data\NOAA OI SST V2 High Resolution Dataset\sst.mon.ltm.1991-2020.nc';
start_time = datetime(0000,12,30);end_time = datetime(0001,11,29);
[sst_ltm,~,~,~] = readncfile_SST_mon(fn,'sst',start_time,end_time,range);
sst_ltm(abs(sst_ltm)>1e5) = nan;
% sst_ltm = sst_ltm(:,:,[12,1,2]);

fn = 'F:\Data\NCEP1\hgt.mon.ltm.1991-2020.nc';
[hgt_ltm,~,~,~,~] = readncfile_Wind_mon(fn,'hgt',start_time,end_time,range);
% hgt_ltm = hgt_ltm(:,:,:,[12,1,2]);


ltm_range = [9,10,11;12,1,2];
% titlename = {'(a) SSTa & HGTa 200 hPa SON 2023','(b) SSTa & HGTa 200 hPa D^0J^1F^1 2023'};
titlename = {'',''};
for i = 1:1
    ax = ha(i);
    sst_i = sst(:,:,3*i-2:3*i);
    sst_ltm_i = sst_ltm(:,:,ltm_range(i,:));
    hgt_i = hgt(:,:,:,3*i-2:3*i);
    hgt_ltm_i = hgt_ltm(:,:,:,ltm_range(i,:));
    if i == 1
        hgt_i(~isnan(hgt_i)) = nan;
    end
    plot_sst_ano1(lon,lat,hgt_i,hgt_ltm_i,p,300,lon_uv,lat_uv,sst_i,sst_ltm_i,ax,levels,cm,titlename{i})
    % cax = mycolorbar(levels,cm,'v','<>',[ax.Position(1)+ax.Position(3)+0.01 ax.Position(2) ...
        % 0.015 ax.Position(4)]);
    % cax.FontSize = 14;cax.Title.String = '°C';
end

for i = 2:2
    ax = ha(i);
    sst_i = sst(:,:,3*i-2:3*i);
    sst_ltm_i = sst_ltm(:,:,ltm_range(i,:));
    hgt_i = hgt(:,:,:,3*i-2:3*i);
    hgt_ltm_i = hgt_ltm(:,:,:,ltm_range(i,:));
    if i == 1
        hgt_i(~isnan(hgt_i)) = nan;
    end
    plot_sst_ano2(lon,lat,hgt_i,hgt_ltm_i,p,300,lon_uv,lat_uv,sst_i,sst_ltm_i,ax,levels,cm,titlename{i})
    % cax = mycolorbar(levels,cm,'v','<>',[ax.Position(1)+ax.Position(3)+0.01 ax.Position(2) ...
        % 0.015 ax.Position(4)]);
    % cax.FontSize = 14;cax.Title.String = '°C';
end
%% SST梅雨期
range = [0 360 -40 70];
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
ax = ha(3);
levels = [-2.1:0.3:-0.3,0.3:0.3:2.1];
% titlename = '(a) SSTa 0610—0721';
titlename = '';
plot_sst_ano_daliy(lon,lat,sst_a,ax,levels,cm,titlename)
% cax = mycolorbar(levels,cm,'v','<>',[ax.Position(1)+ax.Position(3)+0.01 ax.Position(2) ...
%     0.015 ax.Position(4)]);
% cax.FontSize = 12;cax.Title.String = '°C';
exportgraphics(ha(1),'图/Meiyu_SSTa_23SON.png','Resolution',700)
cla(ha(1))
exportgraphics(ha(2),'图/Meiyu_SSTa_23DJF.png','Resolution',700)
exportgraphics(ha(3),'图/Meiyu_SSTa_meiyu.png','Resolution',700)
exportgraphics(fig,'图/Meiyu_SSTa_23DJF_meiyu.png','Resolution',700)

%% 辅助函数：绘制SST梅雨期异常
function plot_sst_ano_daliy(lon,lat,sst_a,ax,levels,cm,titlename)
sst_a = mean(sst_a,3);
[X,Y] = meshgrid(lon,lat);
axes(ax);
m_proj('Equidistant Cylindrical','lon',[0 360],'lat',[-35 60]);hold on
m_grid('box','on','tickdir','out','xtick',0:30:360,'ytick',-30:15:60, ...
    'linestyle','none','Fontsize',12);
mycontourf(X,Y,sst_a',levels,cm,'m');
% m_contourf(X,Y,z_anom',levels,'Linestyle','none');
% m_pcolor(X,Y,z_anom');
colormap(ax,cm)


m_coast('line','linewidth',1,'linestyle','-','color','k');

title(titlename,'FontSize',15,'Position',[ax.XLim(1) ax.YLim(2) 1],'HorizontalAlignment','left','FontWeight','bold')
end
% exportgraphics(fig,'图\SSTa_HGTa2023_2024.png','Resolution',700)
% exportgraphics(ha(2),'图\SSTa_HGTa2023DJF.png','Resolution',700)


%% 辅助函数：绘制SST 月异常1 2
function plot_sst_ano1(lon,lat,hgt,hgt_ltm,p,p_level,lon_uv,lat_uv,sst,sst_ltm,ax,levels,cm,titlename)
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

function plot_sst_ano2(lon,lat,hgt,hgt_ltm,p,p_level,lon_uv,lat_uv,sst,sst_ltm,ax,levels,cm,titlename)
sst_a = sst - sst_ltm;
sst_a = mean(sst_a,3);
sst_a1 = cat(1,sst_a,sst_a);

hgt_a = hgt - hgt_ltm;
hgt_a = hgt_a(:,:,p==p_level,:);
hgt_a = squeeze(mean(hgt_a,4));
hgt_a1 = cat(1,hgt_a,hgt_a);
lon = cat(1,lon,lon+360);
[X,Y] = meshgrid(lon,lat);
axes(ax);
m_proj('Equidistant Cylindrical','lon',[0 510],'lat',[-35 60]);hold on
m_grid('box','on','tickdir','out','xtick',0:30:540,'ytick',-30:15:60, ...
    'linestyle','none','Fontsize',12);
mycontourf(X,Y,sst_a1',levels,cm,'m');
% m_contourf(X,Y,z_anom',levels,'Linestyle','none');
% m_pcolor(X,Y,z_anom');
colormap(ax,cm)

lon_uv = cat(1,lon_uv,lon_uv+360);
[X,Y] = meshgrid(lon_uv,lat_uv);
m_contour(X,Y,hgt_a1',10:10:120,'color','k','Linestyle','-','Linewidth',1.2)
m_contour(X,Y,hgt_a1',-120:10:-10,'color','k','Linestyle','--','Linewidth',1.2)
m_contour(X,Y,hgt_a1',[0 0],'color','k','Linestyle','-','Linewidth',2)

m_coast('line','linewidth',1,'linestyle','-','color','k');

title(titlename,'FontSize',15,'Position',[ax.XLim(1) ax.YLim(2) 1],'HorizontalAlignment','left','FontWeight','bold')
end
%% 辅助函数：读取nc文件 SST

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