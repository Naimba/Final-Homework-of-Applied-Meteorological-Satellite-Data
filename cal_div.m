function div = cal_div(u, v, lat, lon)
% 计算球坐标系中的水平速度散度（输入维度为lon×lat）
% 输入:
%   u: 纬向风速 (m/s), 维度 [lon, lat] 或 [lon, lat, level]
%   v: 经向风速 (m/s), 维度与u相同
%   lat: 纬度向量 (degrees_north)
%   lon: 经度向量 (degrees_east)
% 输出:
%   div: 水平散度 (1/s), 维度与输入一致

% ================== 维度处理 ==================
% 将输入数据维度转换为 [lat, lon] 处理
u = permute(u, [2,1,3:ndims(u)]); % 交换lon/lat位置
v = permute(v, [2,1,3:ndims(v)]);

% ================== 核心计算 ==================
% 转换为弧度制
lat_rad = deg2rad(lat(:)); % 纬度列向量
lon_rad = deg2rad(lon(:));


% 计算网格间距（假设均匀网格）
dphi = mean(diff(lat_rad));    % 纬度间隔 (rad)
dlambda = mean(diff(lon_rad)); % 经度间隔 (rad)

% 维度检查
if ndims(u) == 3
    [nlat, nlon, nlev] = size(u);
    div = zeros(nlat, nlon, nlev);
    for k = 1:nlev
        div(:,:,k) = compute_single_level(u(:,:,k), v(:,:,k),lat_rad,lon_rad,dlambda,dphi);
    end
else
    div = compute_single_level(u, v,lat_rad,lon_rad,dlambda,dphi);
end

% ================ 维度还原 ================
div = permute(div, [2,1,3:ndims(div)]); % 恢复lon×lat顺序

end
%% 辅助函数
function level_div = compute_single_level(u_level, v_level,lat_rad,lon_rad,dlambda,dphi)
        a = 6371e3; 
        [du_dlambda, dvcosphi_dphi] = deal(zeros(size(u_level)));
        [~,Lat] = meshgrid(lon_rad,lat_rad);
        
        % 经度方向导数 (周期性边界)
        for j = 1:size(u_level,1) % 纬度循环
            du_dlambda(j,:) = gradient_periodic(u_level(j,:), dlambda);
        end
        
        % 纬度方向导数 (非周期性)

        vcosphi = v_level .* cos(Lat); % 注意纬度方向转置
        for i = 1:size(vcosphi,2) % 经度循环
            dvcosphi_dphi(:,i) = gradient_nonperiodic(vcosphi(:,i), dphi);
        end
        
        % 组合散度项
        term1 = du_dlambda ./ (a * cos(lat_rad)); % 经度项
        term2 = dvcosphi_dphi / a;                % 纬度项
        level_div = term1 + term2;
end

%% 处理经度方向的周期性梯度
function grad = gradient_periodic(field, dx)
    n = length(field);
    grad = zeros(size(field));
    for i = 1:n
        ip = mod(i, n) + 1;
        im = mod(i-2, n) + 1;
        grad(i) = (field(ip) - field(im)) / (2*dx);
    end
end
%% 处理纬度方向的非周期梯度
function grad = gradient_nonperiodic(field, dx)
    % n = length(field);
    grad = zeros(size(field));
    % 内部点使用中心差分
    grad(2:end-1) = (field(3:end) - field(1:end-2)) / (2*dx);
    % 边界使用单边差分
    grad(1) = (field(2) - field(1)) / dx;
    grad(end) = (field(end) - field(end-1)) / dx;
end