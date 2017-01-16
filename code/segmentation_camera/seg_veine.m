clearvars
close all;

img = imread('uEyeImg00225.bmp');
binaire = uint8(img>30);
imshow(img);


I = img.*binaire;
[Gx, Gy] = imgradientxy(I);
    [Gmag, Gdir] = imgradient(Gx, Gy);
  
    figure, imshow(Gmag, []), title('Gradient magnitude')
    figure, imshow(Gdir, []), title('Gradient direction')
    figure, imshow(Gx, []), title('Directional gradient: X axis')
    figure, imshow(Gy, []), title('Directional gradient: Y axis')
    
I2 = I(11:101,500:787);
    
figure();
imshow(I2); 
    
    