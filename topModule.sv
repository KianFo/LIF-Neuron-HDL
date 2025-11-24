module LIF_Top (
    input  logic        clk,
    input  logic        rst,
    input  logic        start,
    input  logic [7:0]  input_spikes,
    input  logic [11:0] Vrest,
    input  logic [11:0] Vth,
    output logic        spike,
    output logic        valid,
    output logic signed [11:0] Vnew_out
);

    logic count_ROM, init_DP_counter;
    logic shift_spike, ld_spike;
    logic ld_Vrest, shift_Vr, ld_VrReg;
    logic ld_In, init_In;
    logic ld_Vn, shift_Vn;
    logic ld_Vnew, ld_Vth;
    logic sel_Vnew, sel_In, sel_Vn, sel_Vrest, sel_ROM, sel_Vth;
    logic [1:0] alu_sel;
    logic rst_spk, dff_enable, Vnew_rst;
    logic spk_internal;

    LIF_Controller controller_inst (
        .clk(clk),
        .rst(rst),
        .start(start),
        .count_ROM(count_ROM),
        .init_DP_counter(init_DP_counter),
        .shift_spike(shift_spike),
        .ld_spike(ld_spike),
        .ld_Vrest(ld_Vrest),
        .shift_Vr(shift_Vr),
        .ld_VrReg(ld_VrReg),
        .Vnew_rst(Vnew_rst),
        .ld_In(ld_In),
        .init_In(init_In),
        .ld_Vn(ld_Vn),
        .shift_Vn(shift_Vn),
        .ld_Vnew(ld_Vnew),
        .ld_Vth(ld_Vth),
        .sel_Vnew(sel_Vnew),
        .sel_In(sel_In),
        .sel_Vn(sel_Vn),
        .sel_Vrest(sel_Vrest),
        .sel_ROM(sel_ROM),
        .sel_Vth(sel_Vth),
        .alu_sel(alu_sel),
        .valid(valid),
        .rst_spk(rst_spk),
        .dff_enable(dff_enable)
    );

    Data_Path datapath_inst (
        .input_spikes(input_spikes),
        .Vrest(Vrest),
        .Vth(Vth),
        .clk(clk),
        .count_ROM(count_ROM),
        .init_DP_counter(init_DP_counter),
        .shift_spike(shift_spike),
        .ld_spike(ld_spike),
        .ld_Vrest(ld_Vrest),
        .shift_Vr(shift_Vr),
        .ld_VrReg(ld_VrReg),
        .ld_In(ld_In),
        .init_In(init_In),
        .ld_Vn(ld_Vn),
        .shift_Vn(shift_Vn),
        .ld_Vnew(ld_Vnew),
        .ld_Vth(ld_Vth),
        .sel_Vnew(sel_Vnew),
        .sel_In(sel_In),
        .sel_Vn(sel_Vn),
        .sel_Vrest(sel_Vrest),
        .sel_ROM(sel_ROM),
        .sel_Vth(sel_Vth),
        .dff_enable(dff_enable),
        .rst_spk(rst_spk),
        .alu_sel(alu_sel),
        .Vnew_rst(Vnew_rst),
        .spike(spike),
        .spk(spk_internal),
        .Vnew_out(Vnew_out)
    );
endmodule
