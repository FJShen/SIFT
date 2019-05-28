UpHeight = size(I_up,1);
I2 = I_up;
T = E.Records; % [T] is a table
idx = 1;
GainOfRadius = 1;
%step 1: categorize entries in the table

rowInd = (T.Polarity==1);
T_pos = T(rowInd,:); %table with only positive polarity entries
T(rowInd,:)=[];
T_neg = T; %table with only negative polarity entries
clear T

while height(T_pos)~=0
    min_value = min(T_pos.ImageRowHeight)%this is the smallest height value in the table
    rowInd = (T_pos.ImageRowHeight==min_value);
    
    %now we separate the table into two exclusive parts
    SubTable = T_pos(rowInd,:);
    T_pos(rowInd,:)=[];
    
    multiplier = UpHeight/min_value;
    
    I2 = insertShape(I2, 'circle', [SubTable{:,2}.*multiplier, SubTable{:,1}.*multiplier, GainOfRadius*SubTable{:,3}],...
            'Color','red','LineWidth', 2);    
end

while height(T_neg)~=0
    min_value = min(T_neg.ImageRowHeight)%this is the smallest height value in the table
    rowInd = (T_neg.ImageRowHeight==min_value);
    
    %now we separate the table into two exclusive parts
    SubTable = T_neg(rowInd,:);
    T_neg(rowInd,:)=[];
    
    multiplier = UpHeight/min_value;
    
    I2 = insertShape(I2, 'circle', [SubTable{:,2}.*multiplier, SubTable{:,1}.*multiplier, GainOfRadius*SubTable{:,3}],...
            'Color','blue','LineWidth', 2);    
end

figure
imshow(I2)