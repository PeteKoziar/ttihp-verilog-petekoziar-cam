/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_petekoziar_cam (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0.
CamBlock
    #(.PATTERN_WIDTH(8), .ROWS(8), .COLUMNS(8))
    memory
    (
    .nReset(rst_n),
    .lookup_strobe(clk),    // Kicks it off.
    .pattern(ui_in),
    .notPattern(!ui_in),
    .store(uio_in[0]),
    .nStore(!uio_in[0]),
    .location(uo_out[5:0]),
    .found(uo_out[6]),
    .full(uo_out[7])
    );

  // Assign the direction and the unused outputs:
  assign uio_oe = 0;
  assign uio_out = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, uio_in[7:1], 1'b0};

endmodule
