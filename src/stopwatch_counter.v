`timescale 1ns / 1ps

// [신규]

// 스톱워치 카운터 : 00.00 ~ 59.99 (초.1/100초)
module stopwatch_counter(
    input clk,
    input reset,
    input tick_10ms,
    input run,
    input clear,
    output reg [6:0] cs,    // 1/100초 0~99
    output reg [5:0] sec    // 초 0~59
    );

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            cs  <= 0;
            sec <= 0;
        end else if (clear) begin
            cs  <= 0;
            sec <= 0;
        end else if (run && tick_10ms) begin
            if (cs == 99) begin
                cs <= 0;
                if (sec == 59) sec <= 0;
                else           sec <= sec + 1;
            end else begin
                cs <= cs + 1;
            end
        end
    end

endmodule
