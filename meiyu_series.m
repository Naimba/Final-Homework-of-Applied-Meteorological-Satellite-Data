clc;clear;close all

%% 读取数据
% 读取2024梅雨期数据
fn = 'preci_MeiYu2024.nc';
t_2024 = ncread(fn,'time');
t_2024 = seconds(t_2024)+datetime(1900,1,1);
preci_2024 = ncread(fn,'preci');
lon = ncread(fn,'lon');lat = ncread(fn,'lat');

% 读取2020梅雨期数据
fn = 'preci_MeiYu2020.nc';
t_2020 = ncread(fn,'time');
t_2020 = seconds(t_2020)+datetime(1900,1,1);
preci_2020 = ncread(fn,'preci');
%% 绘制三个区域的梅雨降水
clc;
close;
fig = figure('Position',[50 50 1000 900]);
[ha,~] = tight_subplot(2,1,[.08 .04],[.05 .05],[.08 .04]);
% tiledlayout(2,1,"TileSpacing","tight");

ax = ha(1);
[preci_SY,preci_MLY,preci_YH,preci_all] = cal_meiyu_series(preci_2024,lon,lat);
titlename = '(a) Mean precipitation of Meiyu 2024 UTC+8';
starttime = [datetime(2024,6,17),datetime(2024,7,8)];
endtime = [datetime(2024,7,2),datetime(2024,7,20)];
plot_meiyu_series(preci_SY,preci_MLY,preci_YH,preci_all,t_2024,ax,titlename,starttime,endtime)

ax = ha(2);
starttime = [datetime(2020,6,12),datetime(2020,6,30)];
endtime = [datetime(2020,6,25),datetime(2020,7,13)];
[preci_SY,preci_MLY,preci_YH,preci_all] = cal_meiyu_series(preci_2020,lon,lat);
titlename = '(b) Mean precipitation of Meiyu 2020 UTC+8';
plot_meiyu_series(preci_SY,preci_MLY,preci_YH,preci_all,t_2020,ax,titlename,starttime,endtime)
exportgraphics(fig,'图\MeiyuSeries.png','Resolution',700)
exportgraphics(ha(1),'图\MeiyuSeries2024.png','Resolution',700)
%% 辅助函数：计算三个区域的梅雨降水
function [preci_SY,preci_MLY,preci_YH,preci_all] = cal_meiyu_series(preci,lon,lat)
lon_range = lon>=110 & lon<=122.5;
lat_SY_range = lat<=30 & lat>=28;
lat_MLY_range = lat<=32 & lat>30;
lat_YH_range = lat<=34 & lat>32;
lat_all_range = lat<=34 & lat>=28;

preci_SY = mean(preci(lon_range,lat_SY_range,:),[1 2]);preci_SY = squeeze(preci_SY)*2;
preci_MLY = mean(preci(lon_range,lat_MLY_range,:),[1 2]);preci_MLY = squeeze(preci_MLY)*2;
preci_YH = mean(preci(lon_range,lat_YH_range,:),[1 2]);preci_YH = squeeze(preci_YH)*2;
preci_all = mean(preci(lon_range,lat_all_range,:),[1 2]);preci_all = squeeze(preci_all)*2;
end
%% 辅助函数：绘制三个区域的梅雨降水
function [] = plot_meiyu_series(preci_SY,preci_MLY,preci_YH,preci_all,t,ax,titlename,starttime,endtime)
axes(ax);hold on
time = 1:numel(t);
h1 = plot(time,preci_SY,'Color','#FF8E00','LineStyle','-','LineWidth',1.2);
h2 = plot(time,preci_MLY,'Color',[0.2 0.1 0.8],'LineStyle','-','LineWidth',1.2);
h3 = plot(time,preci_YH,'Color',[0.2 0.8 0.2],'LineStyle','-','LineWidth',1.2);
h4 = plot(time,preci_all,'Color',[0.8 0.1 0.2],'LineStyle','-','LineWidth',1.2);


ylim([0 6]);
ylm = ylim();
for i = 1:numel(starttime)
    starttime_n = time(t==starttime(i)-hours(8));
    endtime_n = time(t==endtime(i)-hours(8));
    area([starttime_n,endtime_n],[ylm(2) ylm(2)],'LineStyle','none',...
        'FaceColor',[0.8 0.5 0.5],'FaceAlpha',0.2)
end

xlim([time(1) time(end)])
t8 = t + hours(8);
xtks = time([1+32:2*24*7:end,end]);
ax.XAxis.MinorTickValues = time([1+32:2*24:end,end]);

xticks(xtks);
n_xtl = numel(xtks);
xtl_name = cell(n_xtl,1);
for i = 1:n_xtl
    xtl_name{i} = [num2str(month(t8(xtks)),'%.2d'), num2str(day(t8(xtks)),'%.2d')];
end
xticklabels(xtl_name)
ax.YTickLabelMode = "auto";
ylabel('Precipitation/ (mm hr^{-1})')

box on;grid on;
ax.TickDir = "out";
ax.FontSize = 15;
ax.FontWeight = "bold";
ax.XMinorTick = "on";
ax.XMinorGrid = "on";

legend([h4 h3 h2 h1],{'Meiyu','YH','MLY','SY'})
legend('boxoff')

title(titlename,'FontSize',18,'Position',[ax.XLim(1) ax.YLim(2) 0],'HorizontalAlignment','left','FontWeight','bold')
end