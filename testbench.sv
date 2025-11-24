`timescale 1ns/1ns

module tb_LIF_Top;

    logic clk;
    logic rst;
    logic start;
    logic [7:0] input_spikes;
    logic [11:0] Vth;
    logic [11:0] Vrest;

    wire valid;
    wire spike;

    LIF_Top DUT (
        .clk(clk),
        .rst(rst),
        .start(start),
        .input_spikes(input_spikes),
        .Vrest(Vrest),
        .Vth(Vth),
        .spike(spike),
        .valid(valid)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1;
        start = 0;
        input_spikes = 8'b0;
        Vrest = 12'b111111100110; 
        Vth   = 12'b000100000000; 
        #20 rst = 0;
        apply_spike(8'b11111011);
        apply_spike(8'b00011010);
        apply_spike(8'b00010001);
        apply_spike(8'b00000010);
        apply_spike(8'b01010111);
        apply_spike(8'b00111101);
        apply_spike(8'b10011100);
        apply_spike(8'b01011110);
        apply_spike(8'b01110000);
        apply_spike(8'b10101010);
        apply_spike(8'b10101110);
        apply_spike(8'b00000101);
        apply_spike(8'b11110111);
        apply_spike(8'b10100111);
        apply_spike(8'b11110000);
        apply_spike(8'b10100010);
        apply_spike(8'b10101010);
        apply_spike(8'b10110110);
        apply_spike(8'b00010000);
        apply_spike(8'b00001100);
        #200 $stop;
    end

  
    task apply_spike(input [7:0] spike_pattern);
        begin
            #10 start = 1;
            input_spikes = spike_pattern;
            #10 start = 0;
            $display("Time %0t | Input spikes = %b", $time, spike_pattern);
            #500; 
        end
    endtask
endmodule
