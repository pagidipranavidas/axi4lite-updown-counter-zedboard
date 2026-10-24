`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.07.2025 21:03:22
// Design Name: 
// Module Name: axi4lite_updown_counter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module axi4lite_updown_counter #
(
    parameter integer C_S_AXI_DATA_WIDTH = 32,
    parameter integer C_S_AXI_ADDR_WIDTH = 4
)
(
    input  wire S_AXI_ACLK,
    input  wire S_AXI_ARESETN,
    input  wire [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR,
    input  wire S_AXI_AWVALID,
    output reg  S_AXI_AWREADY,
    input  wire [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA,
    input  wire [(C_S_AXI_DATA_WIDTH/8)-1:0] S_AXI_WSTRB,
    input  wire S_AXI_WVALID,
    output reg  S_AXI_WREADY,
    output reg [1:0] S_AXI_BRESP,
    output reg S_AXI_BVALID,
    input  wire S_AXI_BREADY,
    input  wire [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR,
    input  wire S_AXI_ARVALID,
    output reg  S_AXI_ARREADY,
    output reg [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA,
    output reg [1:0] S_AXI_RRESP,
    output reg S_AXI_RVALID,
    input  wire S_AXI_RREADY,
    output wire [31:0]reg1_out
);

// Registers
reg [31:0] slv_reg0; // Control Register: bit[0] = enable, bit[1] = direction
reg [31:0] slv_reg1; // Counter Output Register (Read-only)
reg [31:0] slv_reg1_shadow;

wire enable = slv_reg0[0];
// 0 = Up, 1 = Down

// AXI4Lite signals
reg aw_en;

// WRITE ADDRESS CHANNEL
always @(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN) begin
        S_AXI_AWREADY <= 0;
        aw_en <= 1;
    end else begin
        if (~S_AXI_AWREADY && S_AXI_AWVALID && S_AXI_WVALID && aw_en) begin
            S_AXI_AWREADY <= 1;
            aw_en <= 0;
        end else if (S_AXI_BREADY && S_AXI_BVALID) begin
            aw_en <= 1;
            S_AXI_AWREADY <= 0;
        end else begin
            S_AXI_AWREADY <= 0;
        end
    end
end

// WRITE DATA CHANNEL
always @(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN) begin
        S_AXI_WREADY <= 0;
    end else begin
        if (~S_AXI_WREADY && S_AXI_WVALID && S_AXI_AWVALID) begin
            S_AXI_WREADY <= 1;
        end else begin
            S_AXI_WREADY <= 0;
        end
    end
end

// WRITE RESPONSE CHANNEL
always @(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN) begin
        S_AXI_BVALID <= 0;
        S_AXI_BRESP <= 2'b0;
    end else begin
        if (S_AXI_AWREADY && S_AXI_AWVALID && ~S_AXI_BVALID && S_AXI_WREADY && S_AXI_WVALID) begin
            S_AXI_BVALID <= 1;
            S_AXI_BRESP <= 2'b00; // OKAY
        end else begin
            if (S_AXI_BREADY) begin
                S_AXI_BVALID <= 0;
            end
        end
    end
end

// READ ADDRESS CHANNEL
always @(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN) begin
        S_AXI_ARREADY <= 0;
    end else begin
        if (~S_AXI_ARREADY && S_AXI_ARVALID) begin
            S_AXI_ARREADY <= 1;
        end else begin
            S_AXI_ARREADY <= 0;
        end
    end
end

// READ DATA CHANNEL
always @(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN) begin
        S_AXI_RVALID <= 0;
        S_AXI_RRESP  <= 0;
    end else begin
        if (S_AXI_ARREADY && S_AXI_ARVALID && ~S_AXI_RVALID) begin
            S_AXI_RVALID <= 1;
            S_AXI_RRESP  <= 2'b00; // OKAY
            case (S_AXI_ARADDR[3:2])
                2'b00: S_AXI_RDATA <= slv_reg0;
                2'b01: S_AXI_RDATA <= slv_reg1;
                default: S_AXI_RDATA <= 32'hDEADBEEF;
            endcase
        end else if (S_AXI_RVALID && S_AXI_RREADY) begin
            S_AXI_RVALID <= 0;
        end
    end
end

// REGISTER WRITE LOGIC
always @(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN) begin
        slv_reg0 <= 0;
    end else begin
        if (S_AXI_WREADY && S_AXI_WVALID && S_AXI_AWREADY && S_AXI_AWVALID) begin
            case (S_AXI_AWADDR[3:2])
                2'b00: slv_reg0 <= S_AXI_WDATA;
                2'b01:slv_reg1_shadow<=S_AXI_WDATA;
            endcase
        end
    end
end

// COUNTER LOGIC with automatic direction flip
always @(posedge S_AXI_ACLK) begin
    if (!S_AXI_ARESETN) begin
        slv_reg1 <= 0;       // start from 0
        slv_reg0 <= 32'b01;  // enable=1, dir=down initially (change to 0 for up)
    end 
    else if (slv_reg0[0]) begin  // if enabled
        if (slv_reg0[1]) begin
            // counting down
            if (slv_reg1 == 0)
                slv_reg0[1] <= 0; // flip to up
            else
                slv_reg1 <= slv_reg1 - 1;
        end 
        else begin
            // counting up
            if (slv_reg1 == 8'hFF)
                slv_reg0[1] <= 1; // flip to down
            else
                slv_reg1 <= slv_reg1 + 1;
        end
    end
end
assign reg1_out=slv_reg1;
endmodule





