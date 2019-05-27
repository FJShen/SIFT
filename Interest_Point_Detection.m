%%
%1.1 Calculate the Scale Space pyramid and DoG pyramid
%1.1.1 Create a [ScaleSpace] instance - the Scale Space pyramid
S = ScaleSpace();

%1.1.2 Upsample the original image and make it the [PrimitiveImage]
I_up = imresize(I, 2);
S.insertPrimitiveLayer(I_up)

%1.1.3 Use for loop to create multiple instances of [ScaleLayer]
sigma = 1;
I_temp = I_up;
row_height = size(I_up,1);
while row_height > 4
    I_temp = downsample(I_temp, 2);
    I_temp = downsample(I_temp', 2);
    I_temp = I_temp';
    L = ScaleLayer;
    L.setImageSize(size(I_temp));
    row_height = size(I_temp,1);
    for idx = 0:3
        local_sigma = (2^(idx/2));
        L.insertImage(sigma*local_sigma, imgaussfilt(I_temp, local_sigma));
    end
    S.insertLayer(size(I_temp), L);
    I_temp = imgaussfilt(I_temp, 2);
    row_height = row_height/2;
    sigma = sigma*2;
end

%1.1.4 Create the DoG pyramid
D = DogSpace();
D.generateDOG(S);

%%
%1.2 Find local extrema from DoG Scale Space
E = D.generateExtremaContainer();
E.sortRows('ScaleLevel');
