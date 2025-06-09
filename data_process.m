clear;clc;close all

% fn = 'F:\Data\NCEP1\Daily\precip\precip.mon.ltm.1991-2020.nc';
% preci = ncread(fn,'precip',[1 1 6],[inf inf 2]);
%% 读取遥感降水数据
% 2024
start_time = datetime(2024,06,10);end_time = datetime(2024,07,21);
[preci,lon,lat,time] = readHDF5file(start_time,end_time);
write2nc(preci,lon,lat,time,'preci_MeiYu2024.nc','preci');
doc h5read
% 2020
start_time = datetime(2020,06,1);end_time = datetime(2020,08,2);
[preci,lon,lat,time] = readHDF5file(start_time,end_time);
write2nc(preci,lon,lat,time,'preci_MeiYu2020.nc','preci');
%% 辅助函数：读取HDF5文件
function [preci,lon,lat,time] = readHDF5file(start_time,end_time)
fn1 = 'F:\Data\GPM\3B-HHR.MS.MRG.3IMERG\GPM_3IMERGHH.07ː3B-HHR.MS.MRG.3IMERG.';
fn2 = '.V07B.HDF5';
t1 = start_time;
t2 = t1 + minutes(30) - seconds(1);
fn = [fn1,num2str(year(t1),'%.4d'),num2str(month(t1),'%.2d'),num2str(day(t1),'%.2d'),'-S',...
    num2str(hour(t1),'%.2d'),num2str(minute(t1),'%.2d'),num2str(second(t1),'%.2d'),'-E',...
    num2str(hour(t2),'%.2d'),num2str(minute(t2),'%.2d'),num2str(second(t2),'%.2d'),'.',...
    num2str(minutes(t1-datetime(year(t1),month(t1),day(t1))),'%.4d'),fn2];
lon = h5read(fn,'/Grid/lon');lat = h5read(fn,'/Grid/lat');
lat_range = lat>=5 & lat<=60;lon_range = lon>=85 & lon<=150;
lat_index = find(lat_range);lon_index = find(lon_range);
time_array = start_time:minutes(30):end_time+days(1);
preci = zeros(numel(lon_index),numel(lat_index),numel(time_array)-1);
for i = 1:numel(time_array)-1
    t1 = time_array(i);
    t2 = t1 + minutes(30) - seconds(1);
    fn = [fn1,num2str(year(t1),'%.4d'),num2str(month(t1),'%.2d'),num2str(day(t1),'%.2d'),'-S',...
        num2str(hour(t1),'%.2d'),num2str(minute(t1),'%.2d'),num2str(second(t1),'%.2d'),'-E',...
        num2str(hour(t2),'%.2d'),num2str(minute(t2),'%.2d'),num2str(second(t2),'%.2d'),'.',...
        num2str(minutes(t1-datetime(year(t1),month(t1),day(t1))),'%.4d'),fn2];
    preci_i = h5read(fn,'/Grid/precipitation',[lat_index(1) lon_index(1) 1],[numel(lat_index) numel(lon_index) 1]);
    preci_i = preci_i'*0.5;preci_i = double(preci_i);
    preci(:,:,i) = preci_i;
    disp(t1)
end
lon = lon(lon_range);lat = lat(lat_range);
lon = double(lon);lat = double(lat);
time = seconds(time_array(1:end-1) - datetime(1900,1,1));
end
%% 辅助函数：写为nc文件from 1900-01-01
function write2nc(x,lon,lat,time,fn,varname)

if isfile(fn)
    delete(fn);
    disp(['由于文件 ',fn,' 已存在，遂删除'])
end

[mx,my,n] = size(x);
nccreate(fn,varname,"Dimensions",{"lon",mx,"lat",my,'time',n}...
    ,"FillValue","disable","Datatype","double");
nccreate(fn,"lon","Dimensions",{"lon",mx}...
    ,"FillValue","disable","Datatype","double");
nccreate(fn,"lat","Dimensions",{"lat",my}...
    ,"FillValue","disable","Datatype","double");
nccreate(fn,"time","Dimensions",{"time",n}...
    ,"FillValue","disable","Datatype","double");

ncwrite(fn,varname,x);
ncwrite(fn,"lon",lon);
ncwrite(fn,"lat",lat);
ncwrite(fn,"time",time);

disp(['文件 ',fn,' 写入完成'])

end