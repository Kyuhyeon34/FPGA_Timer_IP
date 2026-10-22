`timescale 1ns / 1ps

// [원본] 09.up_down_counter/tick_generator.v  -  수정 없음 (top에서 TICK_Hz 1000 / 100 으로 2번 사용)

module tick_generator(
    input clk,
    input reset,
    output reg tick
    );

    parameter INPUT_FREQ = 100_000_000;
    parameter TICK_Hz = 1000;
    parameter TICK_COUNT = INPUT_FREQ /TICK_Hz;

    reg [$clog2(TICK_COUNT)-1:0] r_tick_counter=0;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            tick <= 0;
            r_tick_counter <= 0;
        end else begin
            if (r_tick_counter ==TICK_COUNT-1) begin
                r_tick_counter <= 0;
                tick <= 1'b1;
            end else begin
                r_tick_counter <= r_tick_counter + 1;
                tick <= 0;
            end
        end        
    end
endmodule
