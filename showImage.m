UpHeight = size(I_up,1);
I2 = I_up;
T = E.Records;
for idx= 1:height(E.Records)

    multiplier = UpHeight / T{idx, 5};
    if T{idx,4}>0
        I2 = insertShape(I2, 'circle', [T{idx, 2}*multiplier, T{idx, 1}*multiplier, T{idx, 3}*2],...
            'Color','red','LineWidth', 2);
    else
        I2 = insertShape(I2, 'circle', [T{idx, 2}*multiplier, T{idx, 1}*multiplier, T{idx, 3}*2],...
            'Color','blue','LineWidth', 2);
    end
    if ~mod(idx,100)
        idx
    end
end