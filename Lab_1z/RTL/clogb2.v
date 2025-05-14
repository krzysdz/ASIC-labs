function automatic integer clogb2;
    input integer value;
    begin
        value = value - 1;
        for (clogb2 = 0; value > 0; clogb2 = clogb2 + 1) begin
        value = value >> 1;
        end
    end
endfunction
