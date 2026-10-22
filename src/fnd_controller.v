`timescale 1ns / 1ps

// [원본] 09.up_down_counter/fnd_controller.v
// [수정] 가운데 dot, circle 애니메이션 표시 추가
//        fnd_digit_select, bin2bcd4digit 는 원본 그대로

module fnd_controller(
    input clk,
    input reset,
    input tick,              // 1ms : 자리 전환
    input [13:0] in_data,    // 0~9999
    input dot,               // [추가] 가운데 dot (digit 2)
    input anim,              // [추가] circle 애니메이션 표시
    input [3:0] anim_step,   // [추가] 애니메이션 위치 0~11
    output [3:0] an,
    output [7:0] seg
    );

    wire [1:0] w_sel;
    wire [3:0] w_d1, w_d10, w_d100, w_d1000;
    wire [3:0] w_bcd_data;

    fnd_digit_select u_fnd_digit_select(
        .clk(clk),
        .reset(reset),
        .tick(tick),
        .sel(w_sel)
    );

    bin2bcd4digit u_bin2bcd4digit(
        .in_data(in_data),
        .d1(w_d1),
        .d10(w_d10),
        .d100(w_d100),
        .d1000(w_d1000)
    );

    fnd_digit_display u_fnd_digit_display(
        .sel(w_sel),
        .d1(w_d1),
        .d10(w_d10),
        .d100(w_d100),
        .d1000(w_d1000),
        .dot(dot),               // [추가]
        .anim(anim),             // [추가]
        .anim_step(anim_step),   // [추가]
        .an(an),
        .bcd_data(w_bcd_data),
        .seg(seg)
    );
endmodule

// tick(1ms)마다 표시할 자리를 0 → 1 → 2 → 3 순서로 바꾼다
module fnd_digit_select(
    input clk,
    input reset,
    input tick,
    output reg [1:0] sel
);
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            sel <= 0;
        end else begin
            if (tick)
                sel <= sel + 1;
        end
    end
endmodule

// 14bit 2진수(0~9999)를 자리별 숫자(BCD)로 분리
module bin2bcd4digit(
    input [13:0] in_data,
    output [3:0] d1,
    output [3:0] d10,
    output [3:0] d100,
    output [3:0] d1000
);
    assign d1 = (in_data) % 10;
    assign d10 = (in_data / 10) % 10;
    assign d100 = (in_data / 100) % 10;
    assign d1000 = (in_data / 1000) % 10;

endmodule

// sel에 해당하는 자리를 켜고(an), 그 자리의 숫자를 내보낸다
module fnd_digit_display(
    input [1:0] sel,
    input [3:0] d1,
    input [3:0] d10,
    input [3:0] d100,
    input [3:0] d1000,
    input dot,               // [추가]
    input anim,              // [추가]
    input [3:0] anim_step,   // [추가]
    output reg [3:0] an,
    output reg [3:0] bcd_data,
    output reg [7:0] seg
);
    // [추가] 숫자 / 애니메이션 패턴을 따로 만든 뒤 마지막에 선택
    reg [7:0] r_num_seg;     // 숫자 패턴
    reg [1:0] r_anim_digit;  // 애니메이션이 켜질 자리
    reg [7:0] r_anim_seg;    // 애니메이션이 켜질 세그먼트

    always @(*) begin
        case (sel)
            2'b00: begin
                bcd_data=d1;
                an = 4'b1110;
            end
            2'b01: begin
                bcd_data=d10;
                an = 4'b1101;
            end
            2'b10: begin
                bcd_data=d100;
                an = 4'b1011;
            end
            2'b11: begin
                bcd_data=d1000;
                an = 4'b0111;
            end
            default: begin
                bcd_data=4'b0000;
                an = 4'b1111;
            end
        endcase
    end

    // [수정] 원본 : always @(bcd_data) 에서 seg에 바로 출력
    //        변경 : r_num_seg에 저장 → 아래 최종 출력에서 dot / 애니메이션과 합침
    always @(*) begin
        case(bcd_data)
            4'd0: r_num_seg = 8'b11000000;   // 0
            4'd1: r_num_seg = 8'b11111001;   // 1
            4'd2: r_num_seg = 8'b10100100;   // 2
            4'd3: r_num_seg = 8'b10110000;   // 3
            4'd4: r_num_seg = 8'b10011001;   // 4
            4'd5: r_num_seg = 8'b10010010;   // 5
            4'd6: r_num_seg = 8'b10000010;   // 6
            4'd7: r_num_seg = 8'b11111000;   // 7
            4'd8: r_num_seg = 8'b10000000;   // 8
            4'd9: r_num_seg = 8'b10010000;   // 9
            default: r_num_seg = 8'b11111111;  // all off
        endcase
    end

    // [추가] circle 애니메이션 : 4자리 바깥 테두리 12칸을 시계 방향으로 회전
    //   seg 비트 : [0]a [1]b [2]c [3]d [4]e [5]f [6]g [7]dp  (0 = 켜짐)
    always @(*) begin
        case(anim_step)
            4'd0:  begin r_anim_digit = 2'd3; r_anim_seg = 8'b11111110; end  // a
            4'd1:  begin r_anim_digit = 2'd2; r_anim_seg = 8'b11111110; end  // a
            4'd2:  begin r_anim_digit = 2'd1; r_anim_seg = 8'b11111110; end  // a
            4'd3:  begin r_anim_digit = 2'd0; r_anim_seg = 8'b11111110; end  // a
            4'd4:  begin r_anim_digit = 2'd0; r_anim_seg = 8'b11111101; end  // b
            4'd5:  begin r_anim_digit = 2'd0; r_anim_seg = 8'b11111011; end  // c
            4'd6:  begin r_anim_digit = 2'd0; r_anim_seg = 8'b11110111; end  // d
            4'd7:  begin r_anim_digit = 2'd1; r_anim_seg = 8'b11110111; end  // d
            4'd8:  begin r_anim_digit = 2'd2; r_anim_seg = 8'b11110111; end  // d
            4'd9:  begin r_anim_digit = 2'd3; r_anim_seg = 8'b11110111; end  // d
            4'd10: begin r_anim_digit = 2'd3; r_anim_seg = 8'b11101111; end  // e
            4'd11: begin r_anim_digit = 2'd3; r_anim_seg = 8'b11011111; end  // f
            default: begin r_anim_digit = 2'd0; r_anim_seg = 8'b11111111; end
        endcase
    end

    // [추가] 최종 출력 : 애니메이션 / 숫자 + dot
    always @(*) begin
        if (anim)
            seg = (sel == r_anim_digit) ? r_anim_seg : 8'b11111111;
        else if (sel == 2'b10 && dot)
            seg = r_num_seg & 8'b01111111;   // digit 2의 dp 켜기 (MM.SS / SS.cc)
        else
            seg = r_num_seg;
    end
endmodule
