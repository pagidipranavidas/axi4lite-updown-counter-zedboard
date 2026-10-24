`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.07.2025 21:05:51
// Design Name: 
// Module Name: tb_axi4lite_updown_counter
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


module tb_axi4lite_updown_counter;
  // Clock and reset
  reg clk;
  reg rstn;

  // AXI Write Address Channel
  reg [3:0] s_axi_awaddr;
  reg s_axi_awvalid;
  wire s_axi_awready;

  // AXI Write Data Channel
  reg [31:0] s_axi_wdata;
  reg [3:0]  s_axi_wstrb;
  reg s_axi_wvalid;
  wire s_axi_wready;

  // AXI Write Response Channel
  wire [1:0] s_axi_bresp;
  wire s_axi_bvalid;
  reg s_axi_bready;

  // AXI Read Address Channel
  reg [3:0] s_axi_araddr;
  reg s_axi_arvalid;
  wire s_axi_arready;

  // AXI Read Data Channel
  wire [31:0] s_axi_rdata;
  wire [1:0]  s_axi_rresp;
  wire s_axi_rvalid;
  reg s_axi_rready;

  // Instantiate the DUT
  axi4lite_updown_counter dut (
    .S_AXI_ACLK(clk),
    .S_AXI_ARESETN(rstn),
    .S_AXI_AWADDR(s_axi_awaddr),
    .S_AXI_AWVALID(s_axi_awvalid),
    .S_AXI_AWREADY(s_axi_awready),
    .S_AXI_WDATA(s_axi_wdata),
    .S_AXI_WSTRB(s_axi_wstrb),
    .S_AXI_WVALID(s_axi_wvalid),
    .S_AXI_WREADY(s_axi_wready),
    .S_AXI_BRESP(s_axi_bresp),
    .S_AXI_BVALID(s_axi_bvalid),
    .S_AXI_BREADY(s_axi_bready),
    .S_AXI_ARADDR(s_axi_araddr),
    .S_AXI_ARVALID(s_axi_arvalid),
    .S_AXI_ARREADY(s_axi_arready),
    .S_AXI_RDATA(s_axi_rdata),
    .S_AXI_RRESP(s_axi_rresp),
    .S_AXI_RVALID(s_axi_rvalid),
    .S_AXI_RREADY(s_axi_rready)
  );

  // Clock generation
  initial 
  begin
  clk = 0;
  forever #5 clk = ~clk;
  end
  // Test sequence
  initial begin
    // Initialize
    rstn = 0;
    s_axi_awaddr = 0;
    s_axi_awvalid = 0;
    s_axi_wdata = 0;
    s_axi_wstrb = 4'b1111;
    s_axi_wvalid = 0;
    s_axi_bready = 0;
    s_axi_araddr = 0;
    s_axi_arvalid = 0;
    s_axi_rready = 0;

    // Reset
    #20;
    rstn = 1;

    // Write slv_reg0 = 0x3 => Enable = 1, Direction = 1 (Down)
   // axi_write(4'h0, 32'h3);

    // Wait some cycles
    //#100;

    // Write slv_reg0 = 0x1 => Enable = 1, Direction = 0 (Up)
    axi_write(4'h0, 32'h1);

    // Wait some cycles
   // #100;
    #500;
    // Read slv_reg1 (counter value)
    axi_read(4'h4);

    #5000 $finish;
  end

  task axi_write(input [3:0] addr, input [31:0] data);
  begin
    @(posedge clk);
    s_axi_awaddr <= addr;
    s_axi_awvalid <= 1;
    s_axi_wdata <= data;
    s_axi_wvalid <= 1;
    s_axi_bready <= 1;

    wait (s_axi_awready && s_axi_wready);
    @(posedge clk);
    s_axi_awvalid <= 0;
    s_axi_wvalid <= 0;

    wait (s_axi_bvalid);
    @(posedge clk);
    s_axi_bready <= 0;
  end
  endtask

  task axi_read(input [3:0] araddr);
  begin
    @(posedge clk);
    s_axi_araddr <= araddr;
    s_axi_arvalid <= 1;
    s_axi_rready <= 1;

    wait (s_axi_arready);
    @(posedge clk);
    s_axi_arvalid <= 0;

    wait (s_axi_rvalid);
    @(posedge clk);
    $display("Read Data from address %h = %h", araddr, s_axi_rdata);
    s_axi_rready <= 0;
  end
  endtask

endmodule
