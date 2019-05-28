%%
classdef ExtremaContainer < matlab.mixin.Copyable
    %%
    properties
        Records
        NumberOfPoints
    end
    
    %%
    methods
        %%
        function obj = ExtremaContainer(arg)
            if nargin==0
                arg = 0;
            end
            obj.Records = table('Size', [arg,5], ...
                'VariableNames', {'XCoordinates', 'YCoordinates','ScaleLevel', 'Polarity', 'ImageRowHeight'}, ...
                'VariableTypes', {'double', 'double', 'double', 'double', 'double'});
            obj.NumberOfPoints = 0;
        end
        
        %%
        function insertPoint(obj, MyCoord, MyScale, MyPolarity, MyImageRowHeight)
            obj.NumberOfPoints = obj.NumberOfPoints + 1;
            
            new_cell = {MyCoord(1), MyCoord(2), MyScale, MyPolarity, MyImageRowHeight};
            obj.Records(obj.NumberOfPoints,:)=new_cell;
           
            % Validity check
            if min(MyCoord) <= 0
                warning("Coordinate value is not positive, re-check!")
            end
            
            if (MyPolarity~=1 && MyPolarity~=-1)
                warning("Polarity should be either 1 or -1; re-check!")
            end
            
            if MyScale < 0
                warning("Scale should be positive, re-check!")
            end
            
        end
        
        %%
        function deletePoint(obj, index)
            if index > obj.NumberOfPoints || index < 1
                error("Cannot delete points out of valid range")
                return
            end
            
            obj.Records(index,:)=[];
            obj.NumberOfPoints = obj.NumberOfPoints - 1;
        end
        
        %%
        function mergeTables(obj, foreigner)
            assert(isa(foreigner, 'ExtremaContainer'), "Wrong data type!");
            obj.concatTables(foreigner);
            obj.getUniqueTable();
        end
        
        %%
        function concatTables(obj, foreigner)
            assert(isa(foreigner, 'ExtremaContainer'), "Wrong data type!");
            obj.Records = [obj.Records(1:obj.NumberOfPoints,:); foreigner.Records(1:foreigner.NumberOfPoints,:)];
            obj.NumberOfPoints = obj.NumberOfPoints + foreigner.NumberOfPoints;
        end
        
        %%
        function getUniqueTable(obj)
            obj.Records = unique(obj.Records);
            obj.NumberOfPoints = height(obj.Records);
        end
        
        %%
        function sortRows(obj, varName)
            if nargin>1 && isa(varName, 'char')
                obj.Records = sortrows(obj.Records, varName);
            else
                obj.Records = sortrows(obj.Records);
            end
        end
    end
end