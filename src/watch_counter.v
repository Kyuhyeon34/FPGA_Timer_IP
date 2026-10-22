`timescale 1ns / 1ps

// [신규]

// 분초시계 카운터 : 00.00 ~ 59.59 (분.초), 리셋 후 항상 동작
module watch_counter(
    input clk,
    input reset,
    input tick_10ms,
    output reg [5:0] min,   // 분 0~59
    output reg [5:0] sec,   // 초 0~59
    output dot              // 0.5초 ON / 0.5초 OFF -> 1초에 1번 깜박
    );

    reg [6:0] r_cs;   // 10ms 카운트 0~99 (= 1초)

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_cs <= 0;
            sec  <= 0;
            min  <= 0;
        end else if (tick_10ms) begin
            if (r_cs == 99) begin
                r_cs <= 0;
                if (sec == 59) begin
                    sec <= 0;
                    if (min == 59) min <= 0;
                    else           min <= min + 1;
                end else begin
                    sec <= sec + 1;
                end
            end else begin
                r_cs <= r_cs + 1;
            end
        end
    end

    assign dot = (r_cs < 50);

endmodule
