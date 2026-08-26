module charge_controller (
    input wire clk,
    input wire rst,
    input wire [7:0] v_batt,
    input wire temp_high,
    input wire charger_plugged,

    output reg charge_en,
    output reg alert_led
);
    parameter IDLE    = 3'b000;
    parameter CC_MODE = 3'b001;
    parameter CV_MODE = 3'b010;
    parameter FULL    = 3'b011;
    parameter FAULT   = 3'b100;

    reg [2:0] current_state, next_state;

    always @(posedge clk or posedge rst) begin
        if(rst)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    always @(*) begin
        next_state = current_state;
        charge_en = 1'b0;
        alert_led = 1'b0;

        if(temp_high) begin
            next_state = FAULT;
        end else begin
            case(current_state)
                IDLE: begin
                    charge_en = 1'b0;
                    if(charger_plugged) begin
                        next_state = CC_MODE;
                    end
                end

                CC_MODE: begin
                    charge_en = 1'b1;
                    if(v_batt >= 8'd200) begin
                        next_state = CV_MODE;
                    end
                end

                CV_MODE: begin
                    charge_en = 1'b1;
                    if(v_batt >= 8'd255) begin
                        next_state = FULL;
                    end
                end

                FULL: begin 
                    charge_en = 1'b0;
                    if(charger_plugged == 1'b0) begin
                        next_state = IDLE;
                    end
                end

                FAULT: begin
                    charge_en = 1'b0;
                    alert_led = 1'b1;
                    if(charger_plugged == 1'b0 && temp_high == 1'b0) begin
                        next_state = IDLE;
                    end
                end

                default: next_state = IDLE;
            endcase
        end
    end
endmodule