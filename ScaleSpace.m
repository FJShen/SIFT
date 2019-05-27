%%
classdef ScaleSpace < matlab.mixin.Copyable %< handle
    %%
    properties (SetAccess = 'public')
        NumberOfLayers %length of the array [Sizes]
        Sizes %cell containing sizes of each layer, not including the size of the primitive one
        PrimitiveLayer %a single instance of [ScaleLayer]
        Layers %cell containing multiple [ScaleLayer]s
    end
    
    %%
    methods
        %%
        function obj = ScaleSpace(~)
            obj.NumberOfLayers = 0;
            obj.Sizes = cell(0);
            obj.Layers = cell(0);
        end
        
        %%
        function insertPrimitiveLayer(obj, I)
            L = ScaleLayer;
            L.setImageSize(size(I));
            L.insertImage(0, I);
            
            obj.PrimitiveLayer = L;
        end
        
        %%
        function insertLayer(obj, size, NewLayer)
            %make sure the NewLayer is copyable
            obj.Sizes{end+1} = [size(1) size(2)];
            obj.NumberOfLayers = obj.NumberOfLayers+1;
            obj.Layers{end+1} = NewLayer;
        end
        
        %%
%         function setPrimitiveImage(obj, I, size)
%             obj.PrimitiveImage = I;
%             obj.PrimitiveSize = size;
%         end
        
        %%
        function displayLayer(obj, layerNumber)
            assert(layerNumber<=obj.NumberOfLayers && layerNumber>=1, "layer number out of valid range");
            figure
            for idx = 1:obj.Layers{layerNumber}.NumberOfImages
                subplot(2, ceil(obj.Layers{layerNumber}.NumberOfImages / 2), idx)
                imagesc(obj.Layers{layerNumber}.Images{idx})
                title(['sigma=' num2str(obj.Layers{layerNumber}.Sigmas(idx))])
            end
        end
        
        %%
        function displayPyramid(obj)
            P = obj.Layers{1}.getImage(1);
            if(obj.NumberOfLayers<2)
                return
            end
            for idx=2:obj.NumberOfLayers
                size = obj.Sizes{idx};
                P(1:size(1),end+1:end+size(2)) = obj.Layers{idx}.getImage(1);
            end
            figure
            imagesc(P)
        end
        
        %%
%         % return [ScaleSpace] containing all LAYERS of the DoG pyramid
%         function DOG = generateDOG(obj)
%             DOG = ScaleSpace(true);
%             for idx = 1:obj.NumberOfLayers
%                 L = ScaleLayer();
%                 L_Gaussian = obj.Layers{idx};
%                 imagesize = size(L_Gaussian.getImage(1));
%                 L.setImageSize(imagesize);
%                 for jdx = 1:L_Gaussian.NumberOfImages-1
%                     [~, sigma] = L_Gaussian.getImage(jdx);
%                     L.insertImage(sigma, L_Gaussian.getImage(jdx+1) - L_Gaussian.getImage(jdx));
%                 end
%                 DOG.insertLayer(obj.Scales{idx}, L);
%             end
%         end
%         
%         %%
%         function T=generateExtremaContainer(obj)
%             T = ExtremaContainer();
%             for idx = 1:obj.NumberOfLayers
%                 fprintf('generateExtremaContainer: Layer%d\n', idx);
%                 new_T = obj.Layers{idx}.getExtrema();
%                 T.mergeTables(new_T);
%             end
%         end
    end
end