`include "CLOG2.v"

module Cache #(parameter LINE_SIZE = 16,
               parameter WORD_BIT_SIZE = 32,
               parameter NUM_SETS = 16,
               parameter NUM_WAYS = 1) (
    input reset,
    input clk,

    input is_input_valid,
    input [31:0] addr,
    input mem_read,
    input mem_write,
    input [31:0] din,

    output is_ready,
    output is_output_valid,
    output [31:0] dout,
    output is_hit);
  
    integer i;
  // Wire declarations
  //cache indexing
  wire is_dirty;
  wire [3:0] index;
  wire [1:0] block_offset;
  wire [23:0] tag;
  wire [7:0] bit_offset;
  //dmem signals
  wire is_data_mem_ready;
  wire dmem_out_valid;
  wire dmem_read;
  wire dmem_write;
  //dmem data I/O
  wire [127:0]dmem_input;
  wire [127:0] dmem_out;
  wire [31:0] dmem_addr;
  
  
  // Reg declarations
  reg [127:0] data_bank [15:0];
  reg [23:0] tag_bank [15:0];
  reg valid_bit_table [15:0];
  reg dirty_bit_table [15:0];
  reg waiting_for_evict; //when evict dirty cache block
  reg waiting_for_allocate; //waiting for allocate
  reg waiting_for_modify;//when write miss, after bring cache blcok, should write value to the cache
  
  // You might need registers to keep the status.
  
  //Cache wire declerations
  assign is_ready = !waiting_for_evict && !waiting_for_modify;
  assign is_output_valid = valid_bit_table[index];
  assign is_hit = tag_bank[index] == tag;
  assign is_dirty = dirty_bit_table[index];
  
  assign tag = addr[31:8];
  assign index = addr[7:4];
  assign block_offset = addr[3:2];
  
  assign bit_offset = block_offset*WORD_BIT_SIZE;
  assign dout = data_bank[index][bit_offset+:31];
  
  always @(posedge clk) begin
    // Invalidate All Cache lines on reset
    if (reset) begin
       valid_bit_table[0] = 0; valid_bit_table[1] = 0; valid_bit_table[2] = 0;
       valid_bit_table[3] = 0; valid_bit_table[4] = 0; valid_bit_table[5] = 0;
       valid_bit_table[6] = 0; valid_bit_table[7] = 0; valid_bit_table[8] = 0;
       valid_bit_table[9] = 0; valid_bit_table[10] = 0; valid_bit_table[11] = 0;
       valid_bit_table[12] = 0; valid_bit_table[13] = 0; valid_bit_table[14] = 0;
       valid_bit_table[15] = 0;
       
       waiting_for_evict <= 0;//waiting for evict
       waiting_for_allocate <= 0;//waiting for allocate
       waiting_for_modify <= 0;//waiting for store
    end
    
    if(is_input_valid&&(!is_hit)&&is_output_valid&&is_dirty&&!waiting_for_evict) begin //Cache miss, Conflict with dirty bit - start write back
      waiting_for_evict<=1;
      end
    else if (is_input_valid&&(!is_hit)&&is_output_valid&&is_dirty&&is_data_mem_ready) begin //Cache miss, Conflict with dirty bit- finish write back
      dirty_bit_table[index] <= 0;
      waiting_for_evict<=0; 
      end

    else if (is_input_valid&&is_hit&&is_output_valid && mem_write) begin //Cache hit on Store - edit cache
      data_bank[index][bit_offset+:31] <= din;
      valid_bit_table[index] <= 1;
      dirty_bit_table[index] <= 1; 
      waiting_for_allocate <= 0;
      waiting_for_modify <= 0;
    end
    else if (is_input_valid&&is_hit&&is_output_valid && !mem_write) begin //Cache hit on Load 
      valid_bit_table[index] <= 1;
      dirty_bit_table[index] <= 0; 
      waiting_for_allocate <= 0;
      waiting_for_modify <= 0;
    end
    // bring cache block from memory when read
    else if (is_input_valid && mem_read && (!is_hit || !is_output_valid) && dmem_out_valid) begin //Cache miss on Load - wait till dmem ready and start allocate data
      data_bank[index] <= dmem_out;
      tag_bank[index] <= tag; 
      valid_bit_table[index] <= 1;
      dirty_bit_table[index] <= 0;
      waiting_for_allocate <= 1;
      waiting_for_modify <= 0;
    end
    // bring cache block from memory when write
    else if (is_input_valid && mem_write && (!is_hit || !is_output_valid) && dmem_out_valid) begin //Cache miss on Store - wait till dmem ready start allocate data
      data_bank[index] <= dmem_out;
      tag_bank[index] <= tag; 
      valid_bit_table[index] <= 1;
      dirty_bit_table[index] <= 0; 
      waiting_for_allocate <= 1;
      waiting_for_modify <= 1;
    end
  end
  
  //I/O for data memory
  assign dmem_read = (!is_hit || !is_output_valid) && !dmem_out_valid; //Cache miss -> bring from dmem
  assign dmem_write = (!is_hit) && is_output_valid && is_dirty; //Conflict occur && dirty -> dmem write
  assign dmem_input = data_bank[index];
  //If write to dmem, get addr from cache tag, If read from dmem use addr
  assign dmem_addr = dmem_write ? {tag_bank[index],index,4'b0000} : addr ; 
  
  // Instantiate data memory
  DataMemory #(.BLOCK_SIZE(LINE_SIZE)) data_mem(
    .reset(reset),
    .clk(clk),
    .is_input_valid(is_input_valid),
    .addr(dmem_addr>>>(`CLOG2(LINE_SIZE))), // NOTE: address must be shifted by CLOG2(LINE_SIZE)
    .mem_read(dmem_read),
    .mem_write(dmem_write),
    .din(dmem_input),
    .is_output_valid(dmem_out_valid), //Load output valid
    .dout(dmem_out),
    .mem_ready(is_data_mem_ready) //mem ready for knew inst
  );
endmodule
