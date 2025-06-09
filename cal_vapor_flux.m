function [qu, qv] = cal_vapor_flux(u, v, q, p_levels)
% 计算地表到300 hPa的水汽通量垂直积分
% 输入:
%   u: 纬向风速 (m/s), 三维数组 [lon, lat, level]
%   v: 经向风速 (m/s), 三维数组 [lon, lat, level]
%   q: 比湿 (kg/kg), 三维数组 [lon, lat, level]
%   p_levels: 各层气压 (hPa), 一维数组 [地表, 1000, 925, ..., 300]
% 输出:
%   qu: 纬向水汽通量积分 (kg/(m·s))
%   qv: 经向水汽通量积分 (kg/(m·s))

u = permute(u, [2,1,3:ndims(u)]); % 交换lon/lat位置
v = permute(v, [2,1,3:ndims(v)]);
q = permute(q, [2,1,3:ndims(q)]);

% 确保气压层按降序排列
[p_levels, sort_idx] = sort(p_levels, 'descend');
u = u(:, :, sort_idx);
v = v(:, :, sort_idx);
q = q(:, :, sort_idx);

% 转换气压单位到Pa
p_levels = p_levels * 100;

% 重力加速度 (m/s²)
g = 9.80665;

% 初始化水汽通量
qu = zeros(size(u, 1), size(u, 2));
qv = zeros(size(v, 1), size(v, 2));

% 遍历每个气压层对进行积分
for i = 1:(length(p_levels) - 1)
    % 计算相邻层的平均uq和vq
    uq_avg = (u(:,:,i) .* q(:,:,i) + u(:,:,i+1) .* q(:,:,i+1)) / 2;
    vq_avg = (v(:,:,i) .* q(:,:,i) + v(:,:,i+1) .* q(:,:,i+1)) / 2;
    
    % 计算气压差并转换为Pa
    dp = p_levels(i) - p_levels(i+1);
    
    % 累加当前层的贡献
    qu = qu + uq_avg * dp / g;
    qv = qv + vq_avg * dp / g;
end
qu = permute(qu, [2,1,3:ndims(qu)]); % 恢复lon×lat顺序
qv = permute(qv, [2,1,3:ndims(qv)]); % 恢复lon×lat顺序

end