`timescale 1ns/1ns

module Reg #(
    parameter WIDTH = 12
)(
    input  logic                    clk,
    input  logic                    rst,
    input  logic                    load,
    input  logic signed [WIDTH-1:0] din,
    output logic signed [WIDTH-1:0] dout
);
    always @(posedge clk) begin
        if (rst)       dout <= '0;
        else if (load) dout <= din;
        else           dout <= dout;
    end
endmodule

module Shift_Reg_Unsigned #(
    parameter WIDTH = 8
)(
    input  logic              clk,
    input  logic              rst,
    input  logic              enable,
    input  logic              load,
    input  logic [WIDTH-1:0]  input_spike,
    input  logic              serial_in,
    output logic              serial_out
);

    logic [WIDTH-1:0] data;

    always @(posedge clk) begin
        if (rst)         data <= '0;
        else if (load)   data <= input_spike;
        else if (enable) data <= {serial_in, data[WIDTH-1:1]};
    end

    assign serial_out = data[0];
endmodule

module counter_3bit (
    input  logic clk,
    input  logic rst,
    input  logic enable,
    output logic [2:0] count
);
    always @(posedge clk) begin
        if (rst)         count <= 3'd0;
        else if (enable) count <= count + 3'd1;
    end
endmodule

module Shift_Reg_Signed #(
    parameter WIDTH = 12
)(
    input  logic                    clk,
    input  logic                    rst,
    input  logic                    enable,
    input  logic                    load,
    input  logic signed [WIDTH-1:0] data_in,
    output logic signed [WIDTH-1:0] data_out
);
    always @(posedge clk) begin
        if (rst)         data_out <= '0;
        else if (load)   data_out <= data_in;
        else if (enable) data_out <= {data_out[WIDTH-1], data_out[WIDTH-1:1]}; // >>>1
    end
endmodule

module ALU (
    input  logic signed [11:0] A,
    input  logic signed [11:0] B,
    input  logic        [1:0]  mode,
    output logic signed [11:0] result,
    output logic               gt,
    output logic               eq
);
    always @(*) begin
        gt = 1'b0;
        eq = 1'b0;
        case (mode)
            2'b00: result = A + B;        
            2'b01: result = A - B;        
            2'b10: begin                  
                result = 12'sd0;
                gt = (A > B);
                eq = (A == B);
            end
            default: result = 12'sd0;
        endcase
    end
endmodule

module Weights_Rom (
    input  logic [2:0]            addr,
    output logic signed [11:0]    data_out
);
    logic signed [11:0] mem [0:7];
    initial begin
        $readmemb("Weights.mif", mem);
    end
    assign data_out = mem[addr];
endmodule

module DFF (
    input  wire clk,
    input  wire rst_spk,
    input  wire dff_enable,
    input  wire bit_in,
    output reg  bit_out
);
    always @(posedge clk or posedge rst_spk) begin
        if (rst_spk)       bit_out <= 1'b1;
        else if (dff_enable) bit_out <= bit_in;
    end
endmodule

module Data_Path (
    input  logic [7:0]  input_spikes,
    input  logic [11:0] Vrest, Vth,
    input  logic        clk,
    input  logic        count_ROM,
    input  logic        init_DP_counter,
    input  logic        shift_spike,
    input  logic        ld_spike,
    input  logic        ld_Vrest,
    input  logic        shift_Vr,
    input  logic        ld_VrReg,
    input  logic        ld_In,
    input  logic        init_In,
    input  logic        ld_Vn,
    input  logic        shift_Vn,
    input  logic        ld_Vnew,
    input  logic        ld_Vth,
    input  logic        sel_Vnew,
    input  logic        sel_In,
    input  logic        sel_Vn,
    input  logic        sel_Vrest,
    input  logic        sel_ROM,
    input  logic        sel_Vth,
    input  logic        dff_enable,
    input  logic        rst_spk,
    input  logic [1:0]  alu_sel,
    input  logic        Vnew_rst,
    output logic        spike,
    output logic        spk,
    output logic signed [11:0] Vnew_out
);

    logic signed [11:0] AA, BB, alu_out;
    logic gt, eq;

    wire        serout;
    wire [2:0]  address;

    wire signed [11:0] In;
    wire signed [11:0] VrReg_out;
    wire signed [11:0] VnewReg_out;
    wire signed [11:0] VthReg_out;

    wire signed [11:0] VrShiftReg_out;
    wire signed [11:0] Vn_in, Vn_out;

    wire signed [11:0] weight_value;
    wire signed [11:0] spikeTimesWeight;

    ALU lif_alu (
        .A(AA),
        .B(BB),
        .mode(alu_sel),
        .result(alu_out),
        .gt(gt),
        .eq(eq)
    );

    DFF my_dff (
        .clk(clk),
        .rst_spk(rst_spk),
        .dff_enable(dff_enable),
        .bit_in(spk),
        .bit_out(spike)
    );

    Reg #(12) InReg (
        .clk(clk),
        .rst(init_In),
        .load(ld_In),
        .din(alu_out),
        .dout(In)
    );

    Reg #(12) VrReg (
        .clk(clk),
        .rst(1'b0),
        .load(ld_VrReg),
        .din(Vrest),
        .dout(VrReg_out)
    );

    Reg #(12) VnewReg  (
        .clk(clk),
        .rst(Vnew_rst),
        .load(ld_Vnew),
        .din(alu_out),
        .dout(VnewReg_out)
    );

    Reg #(12) VthReg (
        .clk(clk),
        .rst(1'b0),
        .load(ld_Vth),
        .din(Vth),
        .dout(VthReg_out)
    );

    Shift_Reg_Unsigned #(8) spike_shift_reg (
        .clk(clk),
        .rst(1'b0),
        .enable(shift_spike),
        .load(ld_spike),
        .input_spike(input_spikes),
        .serial_in(1'b0),
        .serial_out(serout)
    );

    Shift_Reg_Signed #(12) Vrshifreg (
        .clk(clk),
        .rst(1'b0),
        .enable(shift_Vr),
        .load(ld_Vrest),
        .data_in(Vrest),
        .data_out(VrShiftReg_out)
    );

    Shift_Reg_Signed #(12) Vnshiftreg (
        .clk(clk),
        .rst(1'b0),
        .enable(shift_Vn),
        .load(ld_Vn),
        .data_in(Vn_in),
        .data_out(Vn_out)
    );

    counter_3bit u_counter (
        .clk(clk),
        .rst(init_DP_counter),
        .enable(count_ROM),
        .count(address)
    );

    Weights_Rom ROM_inst (
        .addr(address),
        .data_out(weight_value)
    );

    assign spikeTimesWeight = serout ? weight_value : 12'sd0;

    assign Vn_in = spike ? Vrest : VnewReg_out;

    assign AA = sel_Vnew ? VnewReg_out :
                sel_In   ? In :
                12'sd0;

    assign BB = sel_Vn     ? Vn_out :
                sel_Vrest  ? VrShiftReg_out :
                sel_ROM    ? spikeTimesWeight :
                sel_Vth    ? VthReg_out :
                12'sd0;

    assign spk = gt | eq;

    assign Vnew_out = Vn_out;
endmodule
