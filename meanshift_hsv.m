 %清除命令
close all;  
clear; 

%图像信息加载
imgfile=dir(strcat(pwd,'\image_test\*.jpg'));

%读取图像并进行目标选定
image_rgb = imread(imgfile(1).name);
image_hsv = rgb_to_hsv(image_rgb);
image_h = image_hsv(:,:,1);           %提取色调
image_s = image_hsv(:,:,2);           %提取饱和度
image_v = image_hsv(:,:,3);           %提取明度
%imshow(uint8(image_v));            %展示明度
crop_size = [170,320,119,79];       %目标定位窗
[img_crop] = imcrop(image_hsv, crop_size);
[img_height, img_width, img_z_index]=size(img_crop);

%定位目标中心
target_center(1) = img_height/2;
target_center(2) = img_width/2;

img_weight = zeros(img_height,img_height);               %初始化目标区域的权值矩阵
h = target_center(1)^2 + target_center(2)^2 ;            %带宽

%计算权值矩阵
for i=1:img_height
    for j=1:img_width
        dist=(i-target_center(1))^2+(j-target_center(2))^2;
        img_weight(i,j)=1-dist/h;              %epanechnikov profile
    end
end
C=1/sum(sum(img_weight));           %对系数进行归一化

%进行直方图统计
%rgb颜色空间量化为16*16*16 bins
hist = zeros(1,4096);
for i=1:img_height
    for j=1:img_width   
        img_h = fix(double(img_crop(i,j,1))/16);
        img_s = fix(double(img_crop(i,j,2))/16);
        img_v = fix(double(img_crop(i,j,3))/16);
        index = img_h*256 + img_s*16 + img_v;
        hist(index+1)= hist(index+1) + img_weight(i,j);
    end
end
hist = hist * C;

%对裁剪区域大小进行向上取整
crop_size(3)=ceil(crop_size(3));
crop_size(4)=ceil(crop_size(4));

%读取图像序列
lengthfile=length(imgfile);  

for img_index=1:lengthfile  
    img_temp = imread(imgfile(img_index).name);  
    img_cache = rgb_to_hsv(img_temp);
    iterator = 0;  
    center_move=[2,2];  
      
    % mean shift迭代  
    while((center_move(1)^2 + center_move(2)^2>0.5) && iterator<20)   %迭代条件  
        iterator = iterator + 1;  
        iter_cache = imcrop(img_cache,crop_size);
        img_move_temp = zeros(img_height,img_height); 
        
        %计算侯选区域直方图  
        hist_temp = zeros(1,4096);  
        for i=1:img_height
            for j=1:img_width   
                img_h = fix(double(iter_cache(i,j,1))/16);
                img_s = fix(double(iter_cache(i,j,2))/16);
                img_v = fix(double(iter_cache(i,j,3))/16);
                index = img_h*256 + img_s*16 + img_v;
                hist_temp(index+1)= hist_temp(index+1) + img_weight(i,j);
                img_move_temp(i,j) = index;
            end
        end
        hist_temp = hist_temp * C;
        
        %figure(2);  
        %subplot(1,2,1);  
        %plot(hist_temp);  
        %hold on;  
        
        %与选中的指定区域匹配,进行偏移权重计算
        weight = zeros(1,4096);  
        for i=1:4096  
            if(hist_temp(i)~=0)
                weight(i) = sqrt(hist(i)/hist_temp(i));  
            else  
                weight(i)=0;  
            end  
        end  
          
        %偏移量计算  
        count = 0;  
        img_move = [0,0];  
        for i=1:img_height  
            for j=1:img_width
                count = count + weight(uint32(img_move_temp(i,j))+1);  
                img_move = img_move + weight(uint32(img_move_temp(i,j))+1) * [i-target_center(1)-0.5, j-target_center(2)-0.5];  
            end  
        end  
        center_move = img_move/count;  
        %中心点位置更新  
        crop_size(1) = crop_size(1) + center_move(2);  
        crop_size(2) = crop_size(2) + center_move(1);  
    end  
      
    %%%跟踪轨迹矩阵%%%  
    %tic_x=[tic_x;rect(1)+rect(3)/2];  
    %tic_y=[tic_y;rect(2)+rect(4)/2];  
      
    v1=crop_size(1);  
    v2=crop_size(2);  
    v3=crop_size(3);  
    v4=crop_size(4);
    
    %%%显示跟踪结果%%%  
    %subplot(1,2,2);
    pause(0.2)
    clf
    imshow(uint8(img_cache(:,:,3)));  
    %title('目标跟踪结果及其运动轨迹');  
    hold on;  
    plot([v1,v1+v3],[v2,v2],[v1,v1],[v2,v2+v4],[v1,v1+v3],[v2+v4,v2+v4],[v1+v3,v1+v3],[v2,v2+v4],'LineWidth',2,'Color','r');  
    %plot(tic_x,tic_y,'LineWidth',2,'Color','b'); 
end 