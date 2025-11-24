module LIF_Controller (
    input  logic clk,
    input  logic rst,
    input  logic start,             

    output logic count_ROM, init_DP_counter,
    output logic shift_spike, ld_spike,
    output logic ld_Vrest, shift_Vr, ld_VrReg, Vnew_rst,
    output logic ld_In, init_In,
    output logic ld_Vn, shift_Vn,
    output logic ld_Vnew, ld_Vth,
    output logic sel_Vnew, sel_In,
    output logic sel_Vn, sel_Vrest, sel_ROM, sel_Vth,
    output logic [1:0] alu_sel,
    output logic valid, rst_spk, dff_enable
);

    logic [2:0] z_count;
    logic Co;
    logic init_z, count;

    always @(posedge clk) begin
        if (init_z)
            z_count <= 3'd0;
        else if (count)
            z_count <= z_count + 3'd1;
    end

    assign Co = (z_count == 3'd7);

    typedef enum logic [3:0] { 
        S_ONE_TIME  = 4'd0,
        S_IDLE      = 4'd1,
        S_INIT_LOAD = 4'd2,
        S_ADD_In    = 4'd3,
        S_LOAD      = 4'd4,
        S_ADD1      = 4'd5,
		S_LOAD0		= 4'd6,
        S_SHIFT1    = 4'd7,
        S_SHIFT2    = 4'd8,
        S_SUB       = 4'd9,
        S_LOAD1     = 4'd10,
        S_ADD3      = 4'd11,
        S_LOAD2     = 4'd12,
        S_COMPARE   = 4'd13,
        S_END       = 4'd14
    } state_t;

    state_t ps, ns;

    always @(posedge clk or posedge rst) begin
        if (rst)
            ps <= S_ONE_TIME;
        else
            ps <= ns;
    end

 
    always_comb begin

        ns                 = ps;
        {count_ROM, init_DP_counter, shift_spike, ld_spike}                   = 4'd0;
        {ld_Vrest, shift_Vr, ld_VrReg, ld_In, init_In, dff_enable, rst_spk,Vnew_rst}   = 8'd0;
        {ld_Vn, shift_Vn, ld_Vnew, ld_Vth}                                    = 4'd0;
        {sel_Vnew, sel_In, sel_Vn, sel_Vrest, sel_ROM, sel_Vth}               = 6'd0;
        alu_sel           = 2'b00;
        valid             = 1'b0;
        {init_z, count}   = 2'd0;

        case (ps)

            S_ONE_TIME: begin
                rst_spk = 1'b1;
                ns = S_IDLE;
            end
           
            S_IDLE: begin
                if (start) ns = S_INIT_LOAD;
                valid = 1'b1;
            end

            S_INIT_LOAD: begin
                {ld_Vrest, ld_Vth, ld_spike, init_In, init_DP_counter, ld_VrReg, init_z, ld_Vn} = 8'b11111111;
                if (~start) ns = S_ADD_In;
            end

            S_ADD_In: begin
                {sel_ROM, sel_In} = 2'b11;
                alu_sel = 2'b00;  
                ns = S_LOAD;
            end

            S_LOAD: begin
				{sel_ROM, sel_In} = 2'b11;
                {ld_In, count_ROM, shift_spike, count} = 4'b1111;
                ns = Co ? S_ADD1 : S_ADD_In;
            end

            S_ADD1: begin
                {sel_In, sel_Vn} = 2'b11;
                alu_sel = 2'b00;
                ns = S_LOAD0;
            end
			S_LOAD0: begin
                {sel_In, sel_Vn,ld_Vnew} = 3'b111;
                alu_sel = 2'b00;
                ns = S_SHIFT1;
            end

            S_SHIFT1: begin
				{sel_In, sel_Vn} = 2'b11;
                {shift_Vn, shift_Vr} = 2'b11;
                ns = S_SHIFT2;
            end

            S_SHIFT2: begin
                {shift_Vn, shift_Vr} = 2'b11;
                ns = S_SUB;
            end

            S_SUB: begin
                {sel_Vnew, sel_Vn} = 2'b11;
                alu_sel = 2'b01;
                ns = S_LOAD1;
            end

            S_LOAD1: begin
				{sel_Vnew, sel_Vn} = 2'b11;
				alu_sel  = 2'b01;
                ld_Vnew = 1'b1;
                ns = S_ADD3;
            end

            S_ADD3: begin
                {sel_Vnew, sel_Vrest} = 2'b11;
                alu_sel = 2'b00;
                ns = S_LOAD2;
            end

            S_LOAD2: begin
				{sel_Vnew, sel_Vrest} = 2'b11;
                alu_sel = 2'b00;
                ld_Vnew = 1'b1;
                ns = S_COMPARE;
            end

            S_COMPARE: begin
                {sel_Vnew, sel_Vth} = 2'b11;
                alu_sel = 2'b10; 
				dff_enable = 1'b1;
                ns = S_END;
            end

            S_END: begin
                valid = 1'b1;
                
                ns = S_IDLE;
            end

            default: ns = S_ONE_TIME;
        endcase
    end
endmodule
