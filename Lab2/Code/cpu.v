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

  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.

  wire [31:0] pc_to_imem;
  wire [31:0] instruction;

  wire [31:0] rs1_to_alu; 
  wire [31:0] rs2_to_alu_mux; 
  wire [31:0] imm_gen_to_alu_mux;
  wire [31:0] alu_mux_to_alu;
  wire [3:0] alu_control_to_alu;

  wire [31:0] alu_result;
  wire alu_bcond; 
  wire [31:0] dmem_to_dmem_mux;
  wire [31:0] alu_to_dmem_mux;

  wire [31:0] dmem_mux_to_rd_din_mux;
  wire [31:0] pc_adder1_result;
  wire [31:0] rd_din_mux_to_rd_din;

  wire [31:0] pc_adder2_to_pc_mux1;
  
  wire [31:0] pc_mux1_to_pc_mux2;
  wire [31:0] pc_mux2_to_next_pc;
  
  wire is_jal; 
  wire is_jalr; 
  wire branch;
  wire mem_read; 
  wire mem_to_reg; 
  wire mem_write;
  wire alu_src; 
  wire write_enable; 
  wire pc_to_reg; 
  wire is_ecall;

  wire PCsrc1;
  wire PCsrc2; 
  
  wire [31:0] always4;
  
  wire [31:0] x17;

  assign is_halted = (is_ecall && x17 == 10);
  assign always4 = 4;

  PC pc(
    .reset(reset),       // input (Use reset to initialize PC. Initial value must be 0)
    .clk(clk),         // input
    .next_pc(pc_mux2_to_next_pc),     // input
    .current_pc(pc_to_imem)   // output
  );

  Adder pc_adder1(
    .add_in1(pc_to_imem),
    .add_in2(always4),
    .add_out(pc_adder1_result)
  );
  
  // ---------- Instruction Memory ----------
  InstMemory imem(
    .reset(reset),   // input
    .clk(clk),     // input
    .addr(pc_to_imem),    // input
    .dout(instruction)     // output
  );

  // wire [6:0] imem_to_control;
  // wire [4:0] imem_to_rs1; 
  // wire [4:0] imem_to_rs2; 
  // wire [4:0] imem_to_rd;
  // wire [31:0] imem_to_imm_gen;
  // wire [31:0] imem_to_alu_control;

  Mux pc_reg_mux(
    .mux_in1(dmem_mux_to_rd_din_mux), 
    .mux_in2(pc_adder1_result), 
    .select_signal(pc_to_reg), 
    .mux_out(rd_din_mux_to_rd_din)
  );

  // ---------- Register File ----------
  RegisterFile reg_file (
    .reset (reset),        // input
    .clk (clk),          // input
    .rs1 (instruction[19:15]),          // input
    .rs2 (instruction[24:20]),          // input
    .rd (instruction[11:7]),           // input
    .rd_din (rd_din_mux_to_rd_din),       // input
    .write_enable (write_enable),    // input
    .rs1_dout (rs1_to_alu),     // output
    .rs2_dout (rs2_to_alu_mux),     // output
    .x17(x17)
  );


  // ---------- Control Unit ----------        
  ControlUnit ctrl_unit ( 
    .part_of_inst(instruction[6:0]),  // input
    .is_jal(is_jal),        // output
    .is_jalr(is_jalr),       // output
    .branch(branch),        // output
    .mem_read(mem_read),      // output
    .mem_to_reg(mem_to_reg),    // output
    .mem_write(mem_write),     // output
    .alu_src(alu_src),       // output
    .write_enable(write_enable),     // output
    .pc_to_reg(pc_to_reg),     // output
    .is_ecall(is_ecall)       // output (ecall inst)
  );

  // ---------- Immediate Generator ----------
  ImmediateGenerator imm_gen(
    .part_of_inst(instruction),  // input
    .imm_gen_out(imm_gen_to_alu_mux)    // output
  );

  Mux alu_mux(
    .mux_in1(rs2_to_alu_mux), 
    .mux_in2(imm_gen_to_alu_mux), 
    .select_signal(alu_src), 
    .mux_out(alu_mux_to_alu)
  );

  // ---------- ALU Control Unit ----------
  ALUControlUnit alu_ctrl_unit (
    .part_of_inst(instruction),  // input
    .alu_op(alu_control_to_alu)         // output
  );

  // ---------- ALU ----------
  ALU alu (
    .alu_op(alu_control_to_alu),      // input
    .alu_in_1(rs1_to_alu),    // input  
    .alu_in_2(alu_mux_to_alu),    // input
    .alu_result(alu_result),  // output
    .alu_bcond(alu_bcond)     // output
  );

  Adder pc_adder2(
    .add_in1(pc_to_imem),
    .add_in2(imm_gen_to_alu_mux),
    .add_out(pc_adder2_to_pc_mux1)
  );
  
  assign PCsrc1 = (branch && alu_bcond) || is_jal;

  Mux pc_mux1(
    .mux_in1(pc_adder1_result), 
    .mux_in2(pc_adder2_to_pc_mux1), 
    .select_signal(PCsrc1), 
    .mux_out(pc_mux1_to_pc_mux2)
  );

  assign PCsrc2 = is_jalr;

  Mux pc_mux2(
    .mux_in1(pc_mux1_to_pc_mux2), 
    .mux_in2(alu_result), 
    .select_signal(PCsrc2), 
    .mux_out(pc_mux2_to_next_pc)
  );
 

  // ---------- Data Memory ----------
  DataMemory dmem(
    .reset (reset),      // input
    .clk (clk),        // input
    .addr (alu_result),       // input
    .din (rs2_to_alu_mux),        // input
    .mem_read (mem_read),   // input
    .mem_write (mem_write),  // input
    .dout (dmem_to_dmem_mux)        // output
  );

 Mux Dmem_mux(
    .mux_in1(alu_result), 
    .mux_in2(dmem_to_dmem_mux), 
    .select_signal(mem_to_reg), 
    .mux_out(dmem_mux_to_rd_din_mux)
 );
endmodule
