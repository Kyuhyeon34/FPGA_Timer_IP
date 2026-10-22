`timescale 1ns / 1ps

module top(
    input clk,
    input reset,
    input [2:0] btn,
    input [7:0] sw,
    output [7:0] seg,
    output [3:0] an,
    output [15:0] led
    );

    wire [2:0]  w_clean_btn;
    wire [13:0] w_seg_data;
    wire        w_tick;

    btn_debouncer u_btn_debouncer(
        .clk(clk),
        .reset(reset),
        .noisy_btn(btn),
        .clean_btn(w_clean_btn)
    );

    main_controller u_main_controller(
        .clk(clk),
        .reset(reset),
        .btn(w_clean_btn),
        .sw(sw),
        .seg_data(w_seg_data),
        .led(led)
    );

    tick_generator u_tick_controller(
        .clk(clk),
        .reset(reset),
        .tick(w_tick)
    );

    fnd_controller u_fnd_controller(
        .clk(clk),
        .reset(reset),
        .tick(w_tick),
        .in_data(w_seg_data),
        .an(an),
        .seg(seg)
    );
    
endmodule

