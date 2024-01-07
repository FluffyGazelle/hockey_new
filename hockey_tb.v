module hockey_tb();


parameter HP = 5;       // Half period of our clock signal
parameter FP = (2*HP);  // Full period of our clock signal

reg clk, rst, BTNA, BTNB;
reg [1:0] DIRA;
reg [1:0] DIRB;
reg [2:0] YA;
reg [2:0] YB;

wire [2:0] X_COORD, Y_COORD;

// Our design-under-test is the DigiHockey module
hockey dut(clk, rst, BTNA, BTNB, DIRA, DIRB, YA, YB, X_COORD,Y_COORD);

// This always statement automatically cycles between clock high and clock low in HP (Half Period) time. Makes writing test-benches easier.
always #HP clk = ~clk;

initial begin
    $dumpfile("hockey.vcd"); //  * Our waveform is saved under this file.
    $dumpvars(0,hockey_tb); // * Get the variables from the module.
    
    $display("Simulation started.");

    clk = 0; 
    rst = 0;
    BTNA = 0;
	BTNB = 0;
	DIRA = 0;
	DIRB = 0;
    YA = 0;
    YB = 0;
    
	#FP; //10
	rst=1;
	#FP; //20
	rst=0;
	// Here, you are asked to write your test scenario.
	
	//BTNB = 1;
	#FP; //30

	#FP; //40
	#FP; //50
	#FP; //60
	
	BTNB = 0;
	BTNA = 1;
	#FP; //70
	BTNA = 0;
	#FP; //80
	BTNA = 1;
	DIRA = 0;
	YA = 2;
	#FP; //90
	BTNA = 0;
	#FP; //100
	#FP; //110
	YB = 2;
	BTNB = 1;
	#FP; //120
	YB = 2;
	BTNB = 1;
	//BTNB = 1;
	#FP; //130
	BTNA = 0;
	
	//DIRB = 2;
	
	#FP; //140
	BTNA = 1;
	DIRA = 0;
	//BTNB = 0;
	#FP; //160
	BTNA = 0;
	#FP; //170
	#FP; //180
	#FP; //190
	#FP; //200
	#FP; //210
	#FP; //220
	#FP; //230
	#FP; //240
	YB = 2;
	#FP; //250
	YB = 2;
	#FP; //260
	BTNB = 1;
	#FP; //270
	BTNB = 1;
	#FP; //280
	BTNB = 1;
	#FP; //290
	BTNB = 1;
	#FP; //300
	BTNB = 0;
	#FP; //310
	#FP; //320
	DIRB = 0;
	YB = 3;
	BTNB = 1;

	#FP; //330
	BTNB = 0;
	#FP; //340
	#FP; //350
	#FP; //360
	#FP; //370
	#FP; //380
	#FP; //390
	#FP; //400
	#FP; //410
	#FP; //420
	#FP; //430
	#FP; //440
	#FP; //450
	#FP; //460
	#FP; //470




	
	
	
	
	
	
	
	$display("Simulation finished.");
    $finish(); // Finish simulation.
	
end



endmodule