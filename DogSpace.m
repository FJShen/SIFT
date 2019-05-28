%%
classdef DogSpace < ScaleSpace
    %%
    properties
        value
    end
    
    %%
    methods
        %%
        function obj = DogSpace(arg)
            if nargin == 0
                arg = 666;
            end
            obj@ScaleSpace();
            obj.value = arg;
        end
        
        %%
        % return [ScaleSpace] containing all LAYERS of the DoG pyramid
        function generateDOG(obj, ScaleSpaceObj)
            for idx = 1:ScaleSpaceObj.NumberOfLayers
                fprintf("Generating DOG space on scale #%d\n", idx);
                L = ScaleLayer();
                L_Gaussian = ScaleSpaceObj.Layers{idx};
                imagesize = size(L_Gaussian.getImage(1));
                L.setImageSize(imagesize);
                for jdx = 1:L_Gaussian.NumberOfImages-1
                    [~, sigma] = L_Gaussian.getImage(jdx);
                    L.insertImage(sigma, L_Gaussian.getImage(jdx+1) - L_Gaussian.getImage(jdx));
                end
                obj.insertLayer(imagesize, L);
            end
        end
        
        %%
        function T=generateExtremaContainer(obj, S, r)
            if nargin < 3
                r = 10;
            end
            r
            T = ExtremaContainer();
            %             for idx = 1:obj.NumberOfLayers
            %                 fprintf('generateExtremaContainer: Layer%d\n', idx);
            %                 new_T = obj.Layers{idx}.getExtrema(r);
            %                 T.mergeTables(new_T);
            %             end
            new_T = cell(obj.NumberOfLayers,1);
            parfor idx = 1:obj.NumberOfLayers
                fprintf('generateExtremaContainer: Layer%d\n', idx);
                new_T{idx} = obj.Layers{idx}.getExtrema(r);
            end
            
            for idx = 1:obj.NumberOfLayers
                T.concatTables(new_T{idx});
            end
            
            T.getUniqueTable();
        end
    end
end