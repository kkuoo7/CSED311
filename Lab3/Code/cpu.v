// Submit this file with other files you created.
// Do not touch port declarations of the module 'CPU'.

// Guidelines
// 1. It is highly recommened to `define opcodes and something useful.
// 2. You can modify the module.
// (e.g., port declarations, remove modules, define new modules, ...)
// 3. You might need to describe combinational logics to drive them into the module (e.g., mux, and, or, ...)
// 4. `include files if required

module CPU(input reset,       // positive reset signal
           input clk,         // clock signal
           output is_halted); // Whehther to finish simulation
  /***** Wire declarations *****/

  /***** Register declarations *****/
  reg [31:0] IR; // instruction register
  reg [31:0] MDR; // memory data register
  reg [31:0] A; // Read 1 data register
  reg [31:0] B; // Read 2 data register
  reg [31:0] ALUOut; // ALU output register
  // Do not modify and use registers declared above.
  
  reg [31:0] x17;


  wire [31:0] pc_src_mux_to_pc;
  
  wire [31:0] pc_to_mux;
  wire [31:0] i_or_d_mux_to_mem; // address 

  wire [31:0] mem_data; 

  wire [31:0] write_data_to_reg_file;

  wire [31:0] rs1_to_A; 
  wire [31:0] rs2_to_B;


  wire [31:0] always4;
  wire [31:0] always0;

  wire [31:0] imm_gen_to_alu_src_mux_b;

  wire [31:0] alu_src_mux_a_to_alu; 
  wire [31:0] alu_src_mux_b_to_alu;

  wire [3:0] alu_control_unit_to_alu;

  wire alu_bcond; 
  wire [31:0] alu_to_alu_out;
  
  wire [3:0] curr_state; 
  wire [1:0] addr_ctrl;

  // control input signal 
  wire pc_write;
  wire pc_write_not_cond;
  
  wire i_or_d;
  wire mem_read;
  wire mem_write;
  wire mem_to_reg;

  wire ir_write;
  wire pc_source;
  
  wire alu_src_a; 
  wire [1:0] alu_src_b;
  wire reg_write;
  wire alu_op;

  wire is_ecall;

  wire pc_write_enable;

  assign always4 = 4;
  assign always0 = 0;
  assign is_halted = is_ecall;

  assign pc_write_enable = pc_write || (pc_write_not_cond && !(alu_bcond));



  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  PC pc(
    .reset(reset),       // input (Use reset to initialize PC. Initial value must be 0)
    .clk(clk),         // input
    .next_pc(pc_src_mux_to_pc),     // input
    .pc_write_enable(pc_write_enable),    // control input
    .current_pc(pc_to_mux)   // output
  );

  Mux IorD_mux(
    .mux_in1(pc_to_mux),
    .mux_in2(ALUOut), 
    .select_signal(i_or_d),
    .mux_out(i_or_d_mux_to_mem)
  );

    // ---------- Memory ----------
  Memory memory(
    .reset(reset),        // input
    .clk(clk),          // input
    .addr(i_or_d_mux_to_mem),         // input
    .din(B),          // input
    .mem_read(mem_read),     // input
    .mem_write(mem_write),    // input
    .dout(mem_data)          // output
  );

  always @ (posedge clk) begin
    if (ir_write) begin
      IR <= mem_data;
    end
  end 

  always @ (posedge clk) begin 
    MDR <= mem_data;
  end 
  
  Mux mem_to_reg_mux(
    .mux_in1(ALUOut),
    .mux_in2(MDR), 
    .select_signal(mem_to_reg),
    .mux_out(write_data_to_reg_file)
  );

  // ---------- Register File ----------
  RegisterFile reg_file(
    .reset(reset),        // input
    .clk(clk),          // input
    .rs1(IR[19:15]),          // input
    .rs2(IR[24:20]),          // input
    .rd(IR[11:7]),           // input
    .rd_din(write_data_to_reg_file),       // input
    .write_enable(reg_write),    // input
    .rs1_dout(rs1_to_A),     // output
    .rs2_dout(rs2_to_B)                // output
  );

  // ---------- Control Unit ----------

  // control input signal 
  // wire pc_write;
  // wire i_or_d;
  // wire mem_read;
  // wire mem_write;
  // wire mem_to_reg;
  // wire ir_write;
  // wire pc_source;
  // wire alu_src_a; 
  // wire [2:0] alu_src_b;
  // wire reg_write;
  
  MicroCounter micro_counter(
   .reset(reset),
   .clk(clk),
   .part_of_inst(IR[6:0]),
   .addr_ctrl(addr_ctrl),
   .curr_state(curr_state)
  );
  
  
  MicroCode micro_code(
   .alu_bcond(alu_bcond),
   .x17(x17),
   .curr_state(curr_state),
   .pc_write_not_cond(pc_write_not_cond), //output
   .pc_write(pc_write),     //output
   .i_or_d(i_or_d), //output
   .mem_read(mem_read), //output
   .mem_write(mem_write), //output
   .mem_to_reg(mem_to_reg), //output
   .ir_write(ir_write), //output
   .pc_source(pc_source), //output
   .alu_src_a(alu_src_a), //output
   .alu_src_b(alu_src_b), //output
   .reg_write(reg_write), //output
   .ALUOp(alu_op), //output
   .halt(is_ecall), //output
   .addr_ctrl(addr_ctrl)
  );
  
//  ControlUnit ctrl_unit(
//    .reset(reset),
//    .clk(clk),
//    .part_of_inst(IR[6:0]),  
//    .alu_bcond(alu_bcond),
//    .x17(x17),  // input
//    .pc_write_not_cond(pc_write_not_cond),
//    .pc_write(pc_write),        // output
//    .i_or_d(i_or_d),       // output
//    .mem_read(mem_read),        // output
//    .mem_write(mem_write),      // output
//    .mem_to_reg(mem_to_reg),    // output
//    .ir_write(ir_write),       // output
//    .pc_source(pc_source),     // output
//    .alu_src_a(alu_src_a),     // output
//    .alu_src_b(alu_src_b),     // output
//    .reg_write(reg_write),     // output
//    .ALUOp(alu_op),
//    .Ecall(is_ecall)       // output (ecall inst)
//  );

  // ---------- Immediate Generator ----------
  ImmediateGenerator imm_gen(
    .part_of_inst(IR),  // input
    .imm_gen_out(imm_gen_to_alu_src_mux_b)    // output
  );


  always @ (posedge clk) begin 
    A <= rs1_to_A; 
    B <= rs2_to_B;
    
    if (IR[11:7] == 17 && reg_write == 1)
        x17 <= write_data_to_reg_file;
  end

  
  Mux alu_src_a_mux(
    .mux_in1(pc_to_mux),
    .mux_in2(A), 
    .select_signal(alu_src_a),
    .mux_out(alu_src_mux_a_to_alu)
  );

  Mux4_1 alu_src_b_mux(
    .mux_in1(B),
    .mux_in2(always4),
    .mux_in3(imm_gen_to_alu_src_mux_b),
    .mux_in4(always0), 
    .select_signal(alu_src_b),
    .mux_out(alu_src_mux_b_to_alu)
  );

  // ---------- ALU Control Unit ----------
  ALUControlUnit alu_ctrl_unit(
    .part_of_inst(IR),  // input
    .alu_op(alu_op),
    .alu_control_output(alu_control_unit_to_alu)
  );

  // ---------- ALU ----------
  ALU alu(
    .alu_op(alu_control_unit_to_alu),      // input
    .alu_in_1(alu_src_mux_a_to_alu),    // input  
    .alu_in_2(alu_src_mux_b_to_alu),    // input
    .alu_result(alu_to_alu_out),  // output
    .alu_bcond(alu_bcond)     // output
  );

  always @ (posedge clk) begin 
    ALUOut <= alu_to_alu_out;
  end 

  Mux pc_src_mux(
    .mux_in1(alu_to_alu_out),
    .mux_in2(ALUOut), 
    .select_signal(pc_source),
    .mux_out(pc_src_mux_to_pc)
  );

endmodule
