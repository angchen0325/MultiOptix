function out = pylist2double(pyList)
    c = cell(pyList);
    out = zeros(1, length(c));
    for i = 1:length(c)
        out(i) = double(c{i});
    end
end
