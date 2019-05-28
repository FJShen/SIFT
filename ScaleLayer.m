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
        function T = getExtrema(obj, r)
            
            RowLength = obj.Size(1);
            ColLength = obj.Size(2);
            T = ExtremaContainer(round(RowLength*ColLength*obj.NumberOfImages/100));
            
            %create a 3_D pixel matrix
            Pixel = [];
            for idx = 1:obj.NumberOfImages
                Pixel = cat(3, Pixel, obj.Images{idx});
            end
            
            %for each pixel in the middle image, check if it is a
            %maxima/minima
            T_local = ExtremaContainer();
            for image_idx = 2:obj.NumberOfImages-1
                for row = 2:RowLength-1
                    for col = 2:ColLength-1
                        value = Pixel(row, col, image_idx);
                        if value<0.015 && value>-0.015
                            continue
                        end
                        
                        
                        %check extrema condition
                        % check upper level neighbors
                        UpNeighbor = Pixel(row-1:row+1, col-1:col+1, image_idx - 1);
                        if max(UpNeighbor(:)) < value
                            checksum = 1;
                        else
                            if min(UpNeighbor(:)) > value
                                checksum = -1;
                            else
                                continue
                            end
                        end
                        
                        
                        % check lower level neighbors
                        DownNeighbor = Pixel(row-1:row+1, col-1:col+1, image_idx + 1);
                        if abs(checksum)~=1
                            continue
                        end
                        if checksum==1 && max(DownNeighbor(:)) < value
                            checksum = checksum+1;
                        else
                            if checksum==-1 && min(DownNeighbor(:)) > value
                                checksum = checksum-1;
                            else
                                continue
                            end
                        end
                        
                        
                        % check same-level neighbors
                        SameLevelNeighbor = Pixel(row-1, col-1:col+1, image_idx);
                        SameLevelNeighbor = [SameLevelNeighbor Pixel(row, col-1, image_idx)];
                        SameLevelNeighbor = [SameLevelNeighbor Pixel(row, col+1, image_idx)];
                        SameLevelNeighbor = [SameLevelNeighbor Pixel(row+1, col-1:col+1, image_idx)];
                        if abs(checksum)~=2
                            continue
                        end
                        if  checksum==2 && max(SameLevelNeighbor(:)) < value
                            checksum = checksum+1;
                        else
                            if checksum==-2 && min(SameLevelNeighbor(:)) > value
                                checksum = checksum-1;
                            else
                                continue
                            end
                        end
                        
                        %check if the point satisfies the Hessian
                        %condition
                        Hxx = Helper.HessianXX(obj.Images{image_idx}, row, col);
                        Hyy = Helper.HessianYY(obj.Images{image_idx}, row, col);
                        Hxy = Helper.HessianXY(obj.Images{image_idx}, row, col);
                        if (Hxx*Hyy-Hxy^2)/((Hxx+Hyy)^2) < r/((r+1)^2)
                            continue;
                        end
                        
                        
                        TrueLoc = Helper.subPixelLocalize(obj.Images{image_idx}, row, col, RowLength, ColLength);
                        if checksum == 3
                            T_local.insertPoint([TrueLoc(1), TrueLoc(2)], obj.Sigmas(image_idx), 1, obj.Size(1));
                        else
                            if checksum == -3
                                T_local.insertPoint([TrueLoc(1), TrueLoc(2)], obj.Sigmas(image_idx), -1, obj.Size(1));
                            else
                                continue
                            end
                        end
                        
                    end %for col
                    T.concatTables(T_local);
                    T_local.NumberOfPoints = 0;
                end %for row
            end %for image_idx
        end %function getExtrema
        
    end
    
end