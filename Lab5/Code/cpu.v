// Submit this file with other files you created.
// Do not touch port declarations of the module 'CPU'.

// Guidelines
// 1. It is highly recommened to `define opcodes and something useful.
// 2. You can modify modules (except InstMemory, DataMemory, and RegisterFile)
// (e.g., port declarations, remove modules, define new modules, ...)
// 3. You might need to describe combinational logics to drive them into the module (e.g., mux, and, or, ...)
// 4. `include files if required

module CPU(input reset,       // positive reset signal
           input clk,         // clock signal
           output is_halted); // Whehther to finish simulation
  /***** Wire declarations *****/
  
  //IF
  wire kill; 

  wire [31:0] next_pc;
  wire [31:0] curr_pc;
  wire [31:0] imem_to_IR;
  wire [31:0] btb_next_pc;
  wire predict_branch_taken;
 
  // stall signals
  
  wire PC_stall;
  wire IF_ID_stall;
  wire control_unit_stall;

  //ID
  wire [4:0] ecall_rs_1;
  wire [4:0] ecall_x_17;
  assign ecall_x_17 = 5'b10001;
  wire [31:0] rs1_data;
  wire [31:0] rs2_data;
  
  wire mem_read_con;
  wire mem_to_reg_con;
  wire mem_write_con;
  wire alu_src_con;
  wire write_enable_con;
  wire [1:0] alu_op_con;
  wire is_jump_con;
  wire is_jal_con;
  wire is_jalr_con;
  wire is_branch_con;
  wire pc_to_reg_con;
  wire is_ecall_con;
  
  wire [31:0] imm_gen_out;
  
  wire id_ex_halt_signal;
 
  //EX
  wire [3:0] alu_op;
  wire alu_bcond;

  wire [1:0] forwarding_unit_to_mux_A;
  wire [1:0] forwarding_unit_to_mux_B;

  wire [31:0] mux_A_to_ALU;
  wire [31:0] mux_B_to_alu_src_mux;
  
  wire [31:0] srcmux_to_alu;
  wire [31:0] alu_result;

  wire [31:0] branch_target;
  wire actual_branch_taken;
  wire hash_colision;

  //MEM
  wire [31:0] mem_read_data;

  //cache control signals
  wire cache_stall;
  wire cache_access;

  // wire is_input_valid; cache_access
  //wire [31:0] addr; EX_MEM_alu_out
  //wire mem_read; EX_MEM_mem_read
  //wire mem_write; EX_MEM_mem_write
  //wire [31:0] din; EX_MEM_dmem_data
  wire cache_ready;
  wire chace_out_valid;
  // wire [31:0] dout; mem_read_data
  wire cache_hit;

  //WB
  wire [31:0] WB_data;
  wire [31:0] pc_to_reg_mux_to_rd_din; 
  wire [31:0] MEM_WB_pc_plus_4;


  /***** Register declarations *****/
  // You need to modify the width of registers
  // In addition, 
  // 1. You might need other pipeline registers that are not described below
  // 2. You might not need registers described below
  
  /***** IF/ID pipeline registers *****/
  reg [31:0] IF_ID_IR;     // will be used in ID stage
  reg [31:0] IF_ID_pc;
  reg IF_ID_predict_branch_taken;
  reg [31:0] IF_ID_branch_predict_target;
  
  /***** ID/EX pipeline registers *****/
  // From the control unit
  reg [1:0] ID_EX_alu_op;         // will be used in EX stage
  reg ID_EX_alu_src;        // will be used in EX stage
  reg ID_EX_mem_write;      // will be used in MEM stage
  reg ID_EX_mem_read;       // will be used in MEM stage
  reg ID_EX_mem_to_reg;     // will be used in WB stage
  reg ID_EX_reg_write;      // will be used in WB stage

  reg ID_EX_pc_to_reg; // will be used in WB stage
  reg ID_EX_is_jump;
  reg ID_EX_is_jal;
  reg ID_EX_is_jalr;
  reg ID_EX_is_branch;
  reg ID_EX_predict_branch_taken;
  reg [31:0] ID_EX_branch_predict_target;

  // From others
  reg [31:0] ID_EX_rs1_data;
  reg [31:0] ID_EX_rs2_data;
  
  reg [31:0] ID_EX_imm;
  reg [3:0] ID_EX_ALU_ctrl_unit_input;

  reg [4:0] ID_EX_rs1_field;
  reg [4:0] ID_EX_rs2_field;
  reg [4:0] ID_EX_rd;

  reg [31:0] ID_EX_pc;
  
  reg ID_EX_halted;

  /***** EX/MEM pipeline registers *****/
  // From the control unit
  reg EX_MEM_mem_write;     // will be used in MEM stage
  reg EX_MEM_mem_read;      // will be used in MEM stage
  reg EX_MEM_mem_to_reg;    // will be used in WB stage
  reg EX_MEM_reg_write;     // will be used in WB stage

  reg EX_MEM_pc_to_reg; // will be used in WB stage 
  // From others
  reg [31:0] EX_MEM_alu_out;
  reg [31:0] EX_MEM_dmem_data;
  reg [4:0] EX_MEM_rd;

  reg [31:0] EX_MEM_pc;
  
  reg EX_MEM_halted;

  /***** MEM/WB pipeline registers *****/
  // From the control unit
  reg MEM_WB_mem_to_reg;    // will be used in WB stage
  reg MEM_WB_reg_write;     // will be used in WB stage

  reg MEM_WB_pc_to_reg; // will be used in WB stage
  // From others
  reg [31:0] MEM_WB_alu_out;
  reg [31:0] MEM_WB_read_data;
  reg [4:0] MEM_WB_rd;

  reg [31:0] MEM_WB_pc;
  
  reg MEM_WB_halted;


  NextPCLogic next_pc_logic(
    .kill(kill), 
    .hash_colision(hash_colision),
    .ID_EX_predict_branch_taken(ID_EX_predict_branch_taken), 
    .ID_EX_is_jalr(ID_EX_is_jalr), 
    .ID_EX_pc(ID_EX_pc), 
    .ID_EX_imm(ID_EX_imm), 
    .btb_next_pc(btb_next_pc), 
    .jalr_next_pc(alu_result), 
    .next_pc(next_pc)
  );
  
  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  PC pc(
    .reset(reset),       // input (Use reset to initialize PC. Initial value must be 0)
    .clk(clk),         // input
    .next_pc(next_pc),     // input
    .PC_stall(PC_stall||cache_stall), 
    .current_pc(curr_pc)   // output
  );
  
  //---------- BranchPredictorBTB----------
  BranchPredictorBTB branch_predictor_btb(
    .reset(reset),
    .clk(clk),
    .current_pc(curr_pc),
    .ID_EX_pc(ID_EX_pc),
    .ID_EX_branch_target(branch_target),
    .ID_EX_is_jal(ID_EX_is_jal),
    .ID_EX_is_branch(ID_EX_is_branch),
    .ID_EX_actual_branch_taken(actual_branch_taken),
    .btb_next_pc(btb_next_pc),
    .predict_branch_taken(predict_branch_taken)
  );
  
  // ---------- Instruction Memory ----------
  InstMemory imem(
    .reset(reset),   // input
    .clk(clk),     // input
    .addr(curr_pc),    // input
    .dout(imem_to_IR)     // output
  );

  // Update IF/ID pipeline registers here

  always @(posedge clk) begin 
    if (reset || kill) begin 
        IF_ID_IR <= 0;
        IF_ID_pc <= 0;
        IF_ID_predict_branch_taken <= 0;
        IF_ID_branch_predict_target <= 0;
    end
    else if (!IF_ID_stall && !cache_stall) begin 
        IF_ID_IR <= imem_to_IR;
        IF_ID_pc <= curr_pc;
        IF_ID_predict_branch_taken <= predict_branch_taken;
        IF_ID_branch_predict_target <= btb_next_pc;
    end 

  end 

  // Hazard Detection Unit 
  HazardDetectionUnit hazrard_detection_unit(
    .ID_EX_mem_read(ID_EX_mem_read),
    .ID_EX_rd_field(ID_EX_rd),
    .IF_ID_rs1_field(ecall_rs_1),
    .IF_ID_rs2_field(IF_ID_IR[24:20]),
    .EX_MEM_rd_field(EX_MEM_rd),
    .MEM_WB_rd_field(MEM_WB_rd),
    .is_ecall(is_ecall_con),
    .PC_stall(PC_stall),
    .IF_ID__stall(IF_ID_stall),
    .control_unit_stall(control_unit_stall)
  );

  // ---------- Register File ----------
  MUX_ECALL ecall_mux(
    .mux_in1(IF_ID_IR[19:15]),
    .mux_in2(ecall_x_17),
    .select_signal(is_ecall_con),
    .mux_out(ecall_rs_1)
  );

  RegisterFile reg_file (
    .reset (reset),    // input
    .clk (clk),          // input
    .rs1 (ecall_rs_1),          // input
    .rs2 (IF_ID_IR[24:20]),          // input
    .rd (MEM_WB_rd),           // input
    .rd_din (pc_to_reg_mux_to_rd_din),       // input
    .write_enable (MEM_WB_reg_write),    // input
    .rs1_dout (rs1_data),     // output
    .rs2_dout (rs2_data)      // output
  );
 
  // ---------- Control Unit ----------
  ControlUnit ctrl_unit (
    .part_of_inst(IF_ID_IR[6:0]),      // input
    .mem_read(mem_read_con),      // output
    .mem_to_reg(mem_to_reg_con),    // output
    .mem_write(mem_write_con),     // output
    .alu_src(alu_src_con),       // output
    .write_enable(write_enable_con),  // output
    .pc_to_reg(pc_to_reg_con),     // output 
    .alu_op(alu_op_con),        // output 2bit
    .is_jump(is_jump_con),
    .is_jal(is_jal_con),
    .is_jalr(is_jalr_con),
    .is_branch(is_branch_con),
    .is_ecall(is_ecall_con)       // output (ecall inst)
  );

  // ---------- Immediate Generator ----------
  ImmediateGenerator imm_gen(
    .part_of_inst(IF_ID_IR),            // input
    .imm_gen_out(imm_gen_out)    // output
  );
  
  assign id_ex_halt_signal = (is_ecall_con && (rs1_data == 'd10));  
  
  // Update ID/EX pipeline registers here
  always @(posedge clk) begin
    if (reset || kill) begin
      ID_EX_rs1_data <= 0;
      ID_EX_rs2_data <= 0;
      
      ID_EX_mem_read <= 0;
      ID_EX_mem_to_reg <= 0;
      ID_EX_mem_write <= 0;
      ID_EX_pc_to_reg <= 0;
      ID_EX_is_jump <= 0;
      ID_EX_is_jal <= 0;
      ID_EX_is_jalr <= 0;
      ID_EX_is_branch <= 0;

      ID_EX_alu_src <= 0;
      ID_EX_reg_write <= 0;
      ID_EX_alu_op <= 0;
      
      ID_EX_imm <= 0;
      ID_EX_ALU_ctrl_unit_input <= 0; // fun7,func3

      ID_EX_rs1_field <= 0;
      ID_EX_rs2_field <= 0;
      ID_EX_rd <= 0;

      ID_EX_pc <= 0;
      ID_EX_predict_branch_taken <= 0;
      ID_EX_branch_predict_target <= 0;
      
      ID_EX_halted <= 0;
    end
    else if(!cache_stall)begin      
      ID_EX_mem_read <= mem_read_con;
      ID_EX_mem_to_reg <= mem_to_reg_con;
      ID_EX_pc_to_reg <= pc_to_reg_con;
      ID_EX_is_jump <= is_jump_con;
      ID_EX_is_jal <= is_jal_con;
      ID_EX_is_jalr <= is_jalr_con;
      ID_EX_is_branch <= is_branch_con;
      
      ID_EX_rs1_data <= rs1_data;
      ID_EX_rs2_data <= rs2_data;

      if (control_unit_stall == 1) begin
        ID_EX_mem_write <= 0;
        ID_EX_reg_write <= 0;
      end 
      else begin
        ID_EX_mem_write <= mem_write_con;
        ID_EX_reg_write <= write_enable_con;
      end
      
      ID_EX_alu_src <= alu_src_con;
      ID_EX_alu_op <= alu_op_con;
      ID_EX_alu_op <= alu_op_con;
      
      ID_EX_imm <= imm_gen_out;
      ID_EX_ALU_ctrl_unit_input <= {IF_ID_IR[30], IF_ID_IR[14:12]}; // fun7,func3

      ID_EX_rs1_field <= IF_ID_IR[19:15];
      ID_EX_rs2_field <= IF_ID_IR[24:20];
      ID_EX_rd <= IF_ID_IR[11:7];

      ID_EX_pc <= IF_ID_pc;
      ID_EX_predict_branch_taken <= IF_ID_predict_branch_taken;
      ID_EX_branch_predict_target <= IF_ID_branch_predict_target;

      ID_EX_halted <= id_ex_halt_signal;
    end
  end

  // ---------- ALU Control Unit ----------
  ALUControlUnit alu_ctrl_unit (
    .alu_ctrl_op(ID_EX_alu_op), // input
    .part_of_inst(ID_EX_ALU_ctrl_unit_input),  // input
    .alu_op(alu_op)         // output
  );

  ForwardingUnit forwarding_unit(
    .ID_EX_rs1_field(ID_EX_rs1_field),
    .ID_EX_rs2_field(ID_EX_rs2_field),
    .EX_MEM_rd_field(EX_MEM_rd),
    .MEM_WB_rd_field(MEM_WB_rd),
    .EX_MEM_reg_write(EX_MEM_reg_write),
    .MEM_WB_reg_write(MEM_WB_reg_write),
    .forwarding_unit_to_mux_A(forwarding_unit_to_mux_A),
    .forwarding_unit_to_mux_B(forwarding_unit_to_mux_B)
  );

  Mux4_1 alu_forward_mux_A(
    .mux_in1(ID_EX_rs1_data),
    .mux_in2(EX_MEM_alu_out),
    .mux_in3(pc_to_reg_mux_to_rd_din),
    .mux_in4(),
    .select_signal(forwarding_unit_to_mux_A),
    .mux_out(mux_A_to_ALU)
  );

  Mux4_1 alu_forward_mux_B(
    .mux_in1(ID_EX_rs2_data),
    .mux_in2(EX_MEM_alu_out),
    .mux_in3(pc_to_reg_mux_to_rd_din),
    .mux_in4(),
    .select_signal(forwarding_unit_to_mux_B),
    .mux_out(mux_B_to_alu_src_mux)
  );
  
  //ALU source MUX 
  MUX_2_1 ALU_src(
  .mux_in1(mux_B_to_alu_src_mux),
  .mux_in2(ID_EX_imm),
  .select_signal(ID_EX_alu_src),
  .mux_out(srcmux_to_alu)
  );

  ControlHazardDetectionUnit control_hazard_detection_unit(
    .ID_EX_is_jal(ID_EX_is_jal),
    .ID_EX_is_jalr(ID_EX_is_jalr),
    .ID_EX_is_branch(ID_EX_is_branch),
    .ID_EX_predict_branch_taken(ID_EX_predict_branch_taken), // 1:0 taken/not taken
    .ID_EX_actual_branch_taken(actual_branch_taken), // 1:0 taken/not taken
    .ID_EX_branch_target(branch_target),
    .ID_EX_branch_predict_target(ID_EX_branch_predict_target),
    .kill(kill), //stop IF,ID
    .hash_colision(hash_colision)
  );

  BranchTargetAdder branch_target_adder(
    .in1(ID_EX_pc),
    .in2(ID_EX_imm),
    .out(branch_target)
  );

  // ---------- ALU ----------
  ALU alu (
    .alu_op(alu_op),      // input
    .alu_in_1(mux_A_to_ALU),    // input  
    .alu_in_2(srcmux_to_alu),    // input
    .alu_result(alu_result),  // output
    .alu_bcond(alu_bcond)     // output don't need w/o con flow
  );

  assign actual_branch_taken = (ID_EX_is_jal || (ID_EX_is_branch && alu_bcond)) ? 1 : 0;
  


  // Update EX/MEM pipeline registers here
  always @(posedge clk) begin
    if (reset) begin
      EX_MEM_mem_write <= 0;
      EX_MEM_mem_read <= 0;
      //EX_MEM_is_branch; 
      EX_MEM_mem_to_reg <= 0;
      EX_MEM_reg_write <= 0;
      EX_MEM_pc_to_reg <= 0;
      
      EX_MEM_alu_out <= 0;
      EX_MEM_dmem_data <= 0;
      EX_MEM_rd <= 0;

      EX_MEM_pc <= 0;
      
      EX_MEM_halted <= 0;
    end
    else if(!cache_stall)begin
      EX_MEM_mem_write <= ID_EX_mem_write;
      EX_MEM_mem_read <= ID_EX_mem_read;
      EX_MEM_mem_to_reg <= ID_EX_mem_to_reg;
      EX_MEM_reg_write <= ID_EX_reg_write;
      EX_MEM_pc_to_reg <= ID_EX_pc_to_reg;
      
      EX_MEM_alu_out <= alu_result;
      EX_MEM_dmem_data <= mux_B_to_alu_src_mux; // LW->SW forwarding? 
      EX_MEM_rd <= ID_EX_rd;

      EX_MEM_pc <= ID_EX_pc;
      
      EX_MEM_halted <= ID_EX_halted;
    end
  end

  //-----------chace control---------
  Cache_controller cache_control_unit(
    .mem_read(EX_MEM_mem_read),
    .mem_write(EX_MEM_mem_write),
    .cache_ready(cache_ready),
    .chace_out_valid(chace_out_valid),
    .cache_hit(cache_hit),
    .cache_access(cache_access),
    .cache_stall(cache_stall)
  );
  
 Cache cache(
    .reset(reset),
    .clk(clk),
    .is_input_valid(cache_access),
    .addr(EX_MEM_alu_out),
    .mem_read(EX_MEM_mem_read),
    .mem_write(EX_MEM_mem_write),
    .din(EX_MEM_dmem_data),
    .is_ready(cache_ready), //dmem ready
    .is_output_valid(chace_out_valid), //valid bit of chace block
    .dout(mem_read_data),
    .is_hit(cache_hit) //is tag same cache block
 );

/*
  // ---------- Data Memory ----------
  DataMemory dmem(
    .reset (reset),      // input
    .clk (clk),        // input
    .addr (EX_MEM_alu_out),       // input
    .din (EX_MEM_dmem_data),        // input
    .mem_read (EX_MEM_mem_read),   // input
    .mem_write (EX_MEM_mem_write),  // input
    .dout (mem_read_data)        // output
  );*/

  // Update MEM/WB pipeline registers here
  always @(posedge clk) begin
    if (reset) begin
        MEM_WB_mem_to_reg <= 0;
        MEM_WB_reg_write <= 0;
        MEM_WB_pc_to_reg <= 0;
        
        MEM_WB_alu_out <= 0;
        MEM_WB_read_data <= 0;
        MEM_WB_rd <= 0;

        MEM_WB_pc <= 0;
        
        MEM_WB_halted <= 0;
    end
    else if(!cache_stall)begin
        MEM_WB_mem_to_reg <= EX_MEM_mem_to_reg;
        MEM_WB_reg_write <= EX_MEM_reg_write;
        MEM_WB_pc_to_reg <= EX_MEM_pc_to_reg;
        
        MEM_WB_alu_out <= EX_MEM_alu_out;
        MEM_WB_read_data <= mem_read_data;
        MEM_WB_rd <= EX_MEM_rd;

        MEM_WB_pc <= EX_MEM_pc;
        
        MEM_WB_halted <= EX_MEM_halted;
    end
  end

  MUX_2_1 WB_mux(
  .mux_in1(MEM_WB_alu_out),
  .mux_in2(MEM_WB_read_data),
  .select_signal(MEM_WB_mem_to_reg),
  .mux_out(WB_data)
  );

  PC_4_Adder pc_4_adder_WB(
    .current_pc(MEM_WB_pc),
    .next_pc(MEM_WB_pc_plus_4)
  );

  MUX_2_1 pc_to_reg_mux(
    .mux_in1(WB_data),
    .mux_in2(MEM_WB_pc_plus_4),
    .select_signal(MEM_WB_pc_to_reg),
    .mux_out(pc_to_reg_mux_to_rd_din)
  );
  
  assign is_halted = MEM_WB_halted;
  
endmodule
