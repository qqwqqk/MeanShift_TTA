function img_hsv = rgb_to_hsv(img_rgb)
[img_x, img_y, img_z]=size(img_rgb);
img_hsv = zeros(img_x, img_y, img_z); 

for i=1:img_x
    for j=1:img_y
        R = img_rgb(i,j,1);
        G = img_rgb(i,j,2);
        B = img_rgb(i,j,3);
        
        Max = max([R,G,B]);
        Min = min([R,G,B]);
        V = max([R,G,B]);
        S = (Max-Min)/Max;
        if (R == Max) 
            H = (G-B)/(Max-Min)* 60;
        elseif (G == Max) 
            H = 120 + (B-R)/(Max-Min)* 60;
        elseif (B == Max) 
            H = 240 + (R-G)/(Max-Min)* 60;
        end
            
        if (H < 0) 
            H = H + 360;
        end
 
        img_hsv(i,j,1) = H;
        img_hsv(i,j,2) = S;
        img_hsv(i,j,3) = V;
    end
end

return