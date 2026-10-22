`timescale 1ns / 1ps

// [신규]

// 시뮬레이션용으로 INPUT_FREQ를 1/1000로 줄임 -> 실제 1초 = 시뮬레이션 1ms
module tb_top();
    reg clk=0;
    reg reset=0;
    reg [2:0] btn=0;     // [0]:L [1]:C [2]:R
    wire [7:0] seg;
    wire [3:0] an;
    wire [15:0] led;

    wire mode = led[0];
    wire run  = led[1];
    wire anim = led[2];

    // 내부 신호 확인용
    wire [5:0] sw_sec = u_top.w_sw_sec;
    wire [6:0] sw_cs  = u_top.w_sw_cs;
    wire [5:0] w_sec  = u_top.w_sec;
    wire       w_dot  = u_top.w_dot;
    wire [1:0] state  = u_top.u_stopwatch_fsm.curr_state;
    wire [3:0] anim_step = u_top.w_anim_step;

    reg r_error=1'b0;

    localparam SEC = 1_000_000;   // 시뮬레이션 1초 (ns)

    top #(.INPUT_FREQ(100_000), .DEBOUNCE_LIMIT(20'd10)) u_top(
        .clk(clk),
        .reset(reset),
        .btn(btn),
        .seg(seg),
        .an(an),
        .led(led)
    );

    always #5 clk = ~clk;

    task press(input [1:0] idx);
    begin
        btn[idx]=1;
        repeat(30) @(posedge clk);
        btn[idx]=0;
        repeat(30) @(posedge clk);
    end
    endtask

    task check(input cond, input [8*40-1:0] msg);
    begin
        if (cond) $display("ok   t=%0t  %0s", $time, msg);
        else begin
            r_error=1'b1;
            $display("FAIL t=%0t  %0s  (mode=%b run=%b anim=%b sw=%0d.%0d)", $time, msg, mode, run, anim, sw_sec, sw_cs);
        end
    end
    endtask

    initial begin
        #100 reset=1;
        #100 reset=0;

        // 1) 분초시계 : 리셋 후 바로 동작, dot 깜박
        #(2*SEC+SEC/4);
        check(mode==0 && w_sec==2, "watch: 2 sec counted");
        check(w_dot==1, "watch: dot ON (first half)");
        #(SEC/2);
        check(w_dot==0, "watch: dot OFF (second half)");

        // 2) 스톱워치 모드 진입, RUN 1.5초 후 STOP
        press(0);
        check(mode==1 && run==0, "btnL -> stopwatch mode");
        press(1);
        check(run==1, "btnC -> RUN");
        #(SEC+SEC/2);
        press(1);
        check(run==0 && sw_sec==1 && sw_cs>=49 && sw_cs<=51, "btnC -> STOP at 1.50");

        // 3) 일시정지 5초 -> circle 애니메이션
        #(4*SEC);
        check(anim==0, "4 sec idle: no anim yet");
        #(SEC+SEC/10);
        check(anim==1, "5 sec idle -> ANIM");
        #(SEC/2);
        check(anim_step>=4, "anim_step rotating");

        // 4) ANIM 중 btnC -> 애니메이션 중지 + RUN
        press(1);
        check(anim==0 && run==1, "ANIM + btnC -> RUN");
        #(SEC/2);
        press(1);

        // 5) STOP 상태 btnR -> CLEAR
        press(2);
        check(sw_sec==0 && sw_cs==0, "btnR -> CLEAR 00.00");

        // 6) ANIM 중 btnR -> 애니메이션 중지 + CLEAR(STOP)
        press(1); #(SEC/3); press(1);
        #(5*SEC+SEC/10);
        check(anim==1, "idle -> ANIM again");
        press(2);
        check(anim==0 && run==0 && sw_sec==0 && sw_cs==0, "ANIM + btnR -> STOP & CLEAR");

        // 7) ANIM 중 btnL -> 애니메이션 중지 + 분초시계 모드
        #(5*SEC+SEC/10);
        check(anim==1, "idle -> ANIM again");
        press(0);
        check(anim==0 && mode==0, "ANIM + btnL -> watch mode");

        // 8) 분초시계 모드에서는 5초가 지나도 애니메이션 없음
        #(6*SEC);
        check(anim==0, "watch mode: no anim");

        if (r_error == 0) $display("PASS stopwatch");
        else $display("FAIL stopwatch");
        $finish;
    end

endmodule
