module Cache_controller (
    input mem_read,
    input mem_write,
    input cache_ready,
    input chace_out_valid,
    input cache_hit,
    output wire cache_access,
    output wire cache_stall);

    assign cache_access = mem_read||mem_write;
    assign cache_stall = (cache_access && !(cache_ready && chace_out_valid && cache_hit)) ? 1 : 0;
    
endmodule