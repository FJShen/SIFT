%%
classdef ScaleLayer  < matlab.mixin.Copyable %< handle %
    %%
    properties
        Size % an array [m n] containing the dimensions of the image
        NumberOfImages
        Images % a cell array containing all images
        Sigmas % an array containing all sigma values
    end
    
    
    %%
    methods
        %% constructor function
        function obj = ScaleLayer(~)
            obj.Size = zeros(0); %the size is an array [m n]
            obj.NumberOfImages = 0;
            obj.Sigmas = zeros(0);
            obj.Images = cell(0);
        end
        %%
        function obj=setImageSize(obj, size)
            obj.Size = size; %the size is an array [m n]
        end
        %%
        function obj=insertImage(obj, sigma, I)
            assert(isequal(size(I), obj.Size), "Wrong size of inserted image");
            obj.NumberOfImages = obj.NumberOfImages + 1;
            obj.Sigmas(end+1) = sigma;
            obj.Images{end+1} = I;
        end
        
        %%
        function displayImage(obj, m)
            assert(m <= obj.NumberOfImages, "index cannot be larger than NumberOfImages");
            assert(m >=1, "index cannot be smaller than 1");
            imagesc(obj.Images{m})
        end
        
        %%
        function [I, sigma, size] = getImage(obj, number)
            assert(number <= obj.NumberOfImages && number >= 0, "number out of valid range");
            I = obj.Images{number};
            sigma = obj.Sigmas(number);
            size = obj.Size;
        end
        
        %%
        % returns [ExtremaContainer] containing all extremi found in this
        % LAYER
        function T = getExtrema(obj)
            T = ExtremaContainer();
            
            %create a 3_D pixel matrix
            Pixel = [];
            for idx = 1:obj.NumberOfImages
                Pixel = cat(3, Pixel, obj.Images{idx});
            end
            
            %create an auxilary matrix marking validity of every pixel, 0
            %stands for not-inspected, 1 stands for inspected
            Inspected = zeros(obj.Size(1), obj.Size(2));
            
            %for each pixel in the middle image, check if it is a
            %maxima/minima
            for row = 2:obj.Size(1)-1
                for col = 2:obj.Size(2)-1
                    if Inspected(row, col)
                        continue
                    end
                    
                    Inspected(row, col)=1;
                    value = Pixel(row, col, 2);
                    checksum = 0;
                    
                    UpNeighbor = Pixel(row-1:row+1, col-1:col+1, 1);
                    DownNeighbor = Pixel(row-1:row+1, col-1:col+1, 3);
                    SameLevelNeighbor = Pixel(row-1, col-1:col+1, 2);
                    SameLevelNeighbor = [SameLevelNeighbor Pixel(row, col-1, 2)];
                    SameLevelNeighbor = [SameLevelNeighbor Pixel(row, col+1, 2)];
                    SameLevelNeighbor = [SameLevelNeighbor Pixel(row+1, col-1:col+1, 2)];
                    
                    % check upper level neighbors
                    if max(UpNeighbor(:)) < value
                        checksum = checksum+1;
                        Inspected(row-1:row+1, col-1:col+1, 1)=ones(3,3,1);
                    else
                        if min(UpNeighbor(:)) > value
                            checksum = checksum-1;
                            Inspected(row-1:row+1, col-1:col+1, 1)=ones(3,3,1);
                        else
                            continue
                        end
                    end
                    
                    % check lower level neighbors
                    if max(DownNeighbor(:)) < value
                        checksum = checksum+1;
                        Inspected(row-1:row+1, col-1:col+1, 3)=ones(3,3,1);
                    else
                        if min(DownNeighbor(:)) > value
                            checksum = checksum-1;
                            Inspected(row-1:row+1, col-1:col+1, 3)=ones(3,3,1);
                        else
                            continue
                        end
                    end
                    
                    % check same-level neighbors
                    if max(SameLevelNeighbor(:)) < value
                        checksum = checksum+1;
                        Inspected(row-1, col-1:col+1, 1)=ones(1,3,1);
                        Inspected(row+1, col-1:col+1, 1)=ones(1,3,1);
                        Inspected(row, col-1, 1)=ones(1,1,1);
                        Inspected(row, col+1, 1)=ones(1,1,1);
                    else
                        if min(SameLevelNeighbor(:)) > value
                            checksum = checksum-1;
                            Inspected(row-1, col-1:col+1, 1)=ones(1,3,1);
                            Inspected(row+1, col-1:col+1, 1)=ones(1,3,1);
                            Inspected(row, col-1, 1)=ones(1,1,1);
                            Inspected(row, col+1, 1)=ones(1,1,1);
                        else
                            continue
                        end
                    end
                    
                    % final trial
                    if checksum ~= 3 && checksum ~=-3
                        continue
                    end
                    
                 
                    if checksum == 3
                        T.insertPoint([row, col], obj.Sigmas(2), 1, obj.Size(1)); 
                    else
                        T.insertPoint([row, col], obj.Sigmas(2), -1, obj.Size(1));
                    end
                    
                end %for col
            end %for row
        end %function getExtrema
        
    end
    
end