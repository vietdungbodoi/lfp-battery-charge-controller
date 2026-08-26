`timescale 1ns / 1ps

module tb_charge_controller();

    reg clk;
    reg rst;
    reg [7:0] v_batt;
    reg temp_high;
    reg charger_plugged;

    wire charge_en;
    wire alert_led;

    charge_controller uut (
        .clk(clk),
        .rst(rst),
        .v_batt(v_batt),
        .temp_high(temp_high),
        .charger_plugged(charger_plugged),
        .charge_en(charge_en),
        .alert_led(alert_led)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("simulation.vcd");
        $dumpvars(0, tb_charge_controller);

      
        $display("--- BAT DAU KIEM CHUNG ---");
        clk = 0; rst = 1; v_batt = 8'd0; temp_high = 0; charger_plugged = 0;
        #15 rst = 0; 
        $display("[%0t] Khoi dong xong. Trang thai IDLE.", $time);

        #10 charger_plugged = 1; v_batt = 8'd100; 
        $display("[%0t] Cam sac (v_batt=100) -> Chuyen CC_MODE", $time);

        #30 v_batt = 8'd210; 
        $display("[%0t] Pin vuot nguong 200 (v_batt=210) -> Chuyen CV_MODE", $time);

        #30 v_batt = 8'd255; 
        $display("[%0t] Pin day (v_batt=255) -> Chuyen FULL", $time);

        #20 charger_plugged = 0; 
        $display("[%0t] Rut sac -> Ve lai IDLE", $time);

       
        #30 charger_plugged = 1; v_batt = 8'd150; 
        $display("[%0t] Cam sac lai. Dang CC_MODE...", $time);

        #20 temp_high = 1; 
        $display("[%0t] CANH BAO! Qua nhiet! -> Nhay sang FAULT, Ngat sac, Bat LED", $time);

        #30 charger_plugged = 0; 
        $display("[%0t] Da rut sac nhung van nong -> Van giu FAULT", $time);

        #30 temp_high = 0; 
        $display("[%0t] Nhiet do on dinh tro lai -> Ve IDLE", $time);

     
        #50 $display("--- KET THUC KIEM CHUNG ---");
        $finish;
    end

endmodule