%%
classdef Helper
    
    %%
    methods (Static)
        
        %%
        %compute Hessian at [row] row [col] column
        %Attention: [row] corresponds to the Y axis and [col] corresponds to
        %the X axis when computing derivatives
        %
        function t = HessianXX(I, row, col, RowLength, ColLength)
            if nargin <=3
                ColLength = size(I,2);
            end
            if col+2 <= ColLength
                t = I(row, col+2) -2*I(row, col+1) +I(row, col);
            else
                if col+1 <= ColLength
                    t =  I(row, col)-I(row, col+1);
                else
                    t = 0;
                end
            end
        end
        
        %%
        function t = HessianYY(I, row, col, RowLength, ColLength)
            if nargin <=3
                RowLength = size(I,1);
            end
            if row+2 <= RowLength
                t = I(row+2, col) -2*I(row+1, col) +I(row, col);
            else
                if row+1 <= RowLength
                    t =  I(row, col)-I(row+1, col);
                else
                    t = 0;
                end
            end
        end
        
        %%
        function t = HessianXY(I, row, col, RowLength, ColLength)
            if nargin <=3
                RowLength = size(I,1);
                ColLength = size(I,2);
            end
            
            if row+1 <= RowLength && col+1 <= ColLength
                t = I(row, col) - I(row+1, col) - I(row, col+1) + I(row+1, col+1);
            else
                t = 0;
            end
            
        end
        
        %%
        function t = HessianYX(I, row, col, RowLength, ColLength)
            if nargin <=3
                RowLength = size(I,1);
                ColLength = size(I,2);
            end
            
            if row+1 <= RowLength && col+1 <= ColLength
                t = I(row, col) - I(row+1, col) - I(row, col+1) + I(row+1, col+1);
            else
                t = 0;
            end
        end
        
        %%
        %This function takes in the pixel-level extremum location [row,
        %col], and use the Talor Expansion:
        % D(X) = D_0 + {\diff{D}{X}}^T X + 0.5 * X^T *
        % \diff{\diff{D}{X}}{X} * X
        % to find the "real" location of the extremum on a sub-pixel level
        function x = subPixelLocalize(I, row, col, RowLength, ColLength, recursionDepth)
            
            if nargin <=5
                recursionDepth = 1;
                if nargin <=3
                    RowLength = size(I,1);
                    ColLength = size(I,2);
                end
            end
            
            Dxy = Helper.HessianXY(I, row, col, RowLength, ColLength);
            Dxx = Helper.HessianXX(I, row, col, RowLength, ColLength);
            Dyy = Helper.HessianYY(I, row, col, RowLength, ColLength);
            
            if row==RowLength
                Dy = 0;
            else
                Dy = I(row+1, col) - I(row,col);
            end
            
            if col==ColLength
                Dx = 0;
            else
                Dx = I(row, col+1) - I(row,col);
            end
            
            SecondDeriv = [Dxx Dxy; Dxy Dyy];
            FirstDeriv = [Dx; Dy];
            shift = -SecondDeriv * FirstDeriv;
            if recursionDepth>=5 || max(abs(shift))<=0.5
                x = [row; col] + shift;
                return;
            else
                shift = round(shift);
                x = Helper.subPixelLocalize(I, row+shift(1), col+shift(2), RowLength, ColLength, recursionDepth+1);
            end
            
        end
        
        %%
        function showImage(I_up, ExtremaContainer)
            UpHeight = size(I_up,1);
            I2 = I_up;
            T = ExtremaContainer.Records; % [T] is a table
            GainOfRadius = 2;
            %step 1: categorize entries in the table
            
            rowInd = (T.Polarity==1);
            T_pos = T(rowInd,:); %table with only positive polarity entries
            T(rowInd,:)=[];
            T_neg = T; %table with only negative polarity entries
            clear T
            
            while height(T_pos)~=0
                min_value = min(T_pos.ImageRowHeight) %this is the smallest height value in the table
                rowInd = (T_pos.ImageRowHeight==min_value);
                
                %now we separate the table into two exclusive parts
                SubTable = T_pos(rowInd,:);
                T_pos(rowInd,:)=[];
                
                multiplier = UpHeight/min_value;
                
                I2 = insertShape(I2, 'circle', [SubTable{:,2}.*multiplier, SubTable{:,1}.*multiplier, GainOfRadius*SubTable{:,3}],...
                    'Color','blue','LineWidth', 2);
            end
            
            while height(T_neg)~=0
                min_value = min(T_neg.ImageRowHeight)  %this is the smallest height value in the table
                rowInd = (T_neg.ImageRowHeight==min_value);
                
                %now we separate the table into two exclusive parts
                SubTable = T_neg(rowInd,:);
                T_neg(rowInd,:)=[];
                
                multiplier = UpHeight/min_value;
                
                I2 = insertShape(I2, 'circle', [SubTable{:,2}.*multiplier, SubTable{:,1}.*multiplier, GainOfRadius*SubTable{:,3}],...
                    'Color','red','LineWidth', 2);
            end
            
            figure
            imshow(I2)
        end
    end
    
end