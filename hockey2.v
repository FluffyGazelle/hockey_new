module hockey(

    input clk,
    input rst,
    
    input BTNA,
    input BTNB,
    
    input [1:0] DIRA,
    input [1:0] DIRB,
    
    input [2:0] YA,
    input [2:0] YB,
   
    output reg LEDA,
    output reg LEDB,
    output reg [4:0] LEDX,
    
    output reg [6:0] SSD7,
    output reg [6:0] SSD6,
    output reg [6:0] SSD5,
    output reg [6:0] SSD4, 
    output reg [6:0] SSD3,
    output reg [6:0] SSD2,
    output reg [6:0] SSD1,
    output reg [6:0] SSD0   
	
    );
    reg [2:0] X_COORD;
	reg [2:0] Y_COORD;
    reg [3:0] cstate; //current state
    reg [3:0] nstate = 8'b00000000; //next state

    parameter [7:0] s0 = 8'b00000000; //IDLE
    parameter [7:0] s1 = 8'b00000001; //BTNA == 1
    parameter [7:0] s2 = 8'b00000010; //BTNB == 1
    parameter [7:0] s3 = 8'b00000011; //send to B from A //no timer
    parameter [7:0] s4 = 8'b00000100; //send to A from B //no timer
    parameter [7:0] s5 = 8'b00000101; // win state stays here forever until rst = 1
    parameter [7:0] s6 = 8'b00000110; // Display
    parameter [7:0] s7 = 8'b00000111; // respond B
    parameter [7:0] s8 = 8'b00001000; // respond A
    parameter [7:0] s9 = 8'b00001001; // goal_B
    parameter [7:0] s10 = 8'b00001010; // goal_A

   
    
    parameter [6:0] DIGIT_0 = 7'b0000001;
    parameter [6:0] DIGIT_1 = 7'b1001111;
    parameter [6:0] DIGIT_2 = 7'b0010010;
    parameter [6:0] DIGIT_3 = 7'b0000110;
    parameter [6:0] DIGIT_4 = 7'b1001100;
    parameter [6:0] DIGIT_line = 7'b1111110;
    parameter [6:0] PRINT_A = 7'b0001000;
    parameter [6:0] PRINT_B = 7'b1100000;


    parameter LD_NONE = 5'b00000;
    parameter LD_ALL = 5'b11111;
    parameter LD_0 = 5'b00001;
    parameter LD_1 = 5'b00010;
    parameter LD_2 = 5'b00100;
    parameter LD_3 = 5'b01000;
    parameter LD_4 = 5'b10000;


    
    //ID: 29015 / 27968;


    reg x1;
    reg [3:0] y1;

    reg [2:0] guess_y_A;
    reg [2:0] guess_y_B;
    reg [1:0] turn = 2; // 0 = A , 1 = B, 2 = standby
    reg [1:0] score_A;
    reg [1:0] score_B;
    //reg [1:0] win;
    reg [7:0] timer;
    reg [7:0] waittime = 8'd100;

    reg[1:0] correct_guess_B;
    reg[1:0] correct_guess_A;






    always @(posedge clk or posedge rst)
    begin
        
    
        if(rst == 1)begin
            cstate <= s0;
            X_COORD <= 3'b000;
            Y_COORD <= 3'b000;
            score_A <= 2'b00;
            score_B <= 2'b00;

            timer <= 0;
            correct_guess_B <= 0;
            correct_guess_A <= 0;
            turn <= 2;
        end
        else begin
            cstate <= nstate;
       

        if(cstate == s0)begin
            if(BTNA == 1 && BTNB == 0)begin
                turn <= 0;
            end

            else if(BTNB == 1 && BTNA == 0)begin
                turn <= 1;
            end

        end

        else if(cstate == s1)begin
            timer <= 0;
            if(BTNA == 1)begin
            Y_COORD <= YA;
            y1 <= DIRA;
            X_COORD <= 0;
            end
            
            

        
            
        end
        else if(cstate == s2)begin
            timer <= 0;

            
            if(BTNB == 1) begin
            Y_COORD <= YB;
            y1 <= DIRB;
            X_COORD <= 4;
            end
           
            
        end
        
        else if(cstate == s3)begin
            

            correct_guess_A <= 0;

            if(timer < waittime)begin
                
                timer <= timer + 1;
            end
            else begin

                timer <= 0;
                if(X_COORD < 3'b100)begin
                    X_COORD <= X_COORD + 1;
                    guess_y_B <= YB;

                end
                
            end
            if(X_COORD == 3'b100)begin
                guess_y_B <= YB;
                turn <= 1;

            end

                if ( y1 == 2'd1)begin 
                    if (Y_COORD < 3'b100)begin
                        Y_COORD[0] <= 1 ^ Y_COORD[0];
                        Y_COORD[1] <= Y_COORD[0] ^ Y_COORD[1];
                        Y_COORD[2] <= ((Y_COORD[0] & Y_COORD[1]) ^ Y_COORD[2]);
                        y1 <= 2'd1; 
                        end
                    else if(Y_COORD == 3'b100)begin
                        y1 <= 2'd2;
                        Y_COORD <= 3'b011;
                        end
                end
                if (y1 == 2'd2)begin
                    if ( Y_COORD > 3'b000)begin

                                Y_COORD[0] <= (1 ^ Y_COORD[0]);
                                Y_COORD[1] <= ((~Y_COORD[0]) ^ Y_COORD[1] );
                                Y_COORD[2] <= Y_COORD[2] ^ Y_COORD[2];
                                y1 <= 2'd2;
                            end
                    else if (Y_COORD == 3'b000 )begin
                            y1 <= 2'd1;
                            Y_COORD <= 3'b001;
                        end
                end
                if (y1 == 2'd0)begin
                    Y_COORD <= Y_COORD;
                end
            end


        else if(cstate == s4)begin
            
            correct_guess_B <= 0;


            if(timer < waittime)begin
                timer <= timer + 1;
            end
            
            else begin
                timer <= 0;
                if(X_COORD > 3'b000)begin
                    X_COORD <= (X_COORD - 1);
                    guess_y_A <= YA;

                end

                if(X_COORD == 3'b000)begin
                    guess_y_A <= YA;
                    turn <= 0;
                
                end
            
                if ( y1 == 2'd1)begin 
                    if (Y_COORD < 3'b100)begin
                        Y_COORD[0] <= 1 ^ Y_COORD[0];
                        Y_COORD[1] <= Y_COORD[0] ^ Y_COORD[1];
                        Y_COORD[2] <= ((Y_COORD[0] & Y_COORD[1]) ^ Y_COORD[2]);
                        y1 <= 2'd1; 
                        end
                    else if(Y_COORD == 3'b100)begin
                        y1 <= 2'd2;
                        Y_COORD <= 3'b011;
                        end
                end
           
                if (y1 == 2'd2)begin
                    if ( Y_COORD > 3'b000)begin                
                            Y_COORD[0] <= (1 ^ Y_COORD[0]);
                            Y_COORD[1] <= ((~Y_COORD[0]) ^ Y_COORD[1] );
                            Y_COORD[2] <= Y_COORD[2] ^ Y_COORD[2];
                            y1 <= 2'd2;
                        end
                else if (Y_COORD == 3'b000 )begin
                        y1 <= 2'd1;
                        Y_COORD <= 3'b001;
                    end
            end
            
                if (y1 == 2'd0)begin
                    Y_COORD <= Y_COORD;
                end
            end
        end

        else if (cstate == s5) begin
            if (timer < waittime) begin
                timer <= timer + 1;

            end
            else begin
                timer <= 0;
            end

        end

        else if( cstate == s6)begin
            timer <= timer + 1;
        end

        
        else if( cstate == s7)begin
            if (timer == 0) begin
                correct_guess_B <= 0;
            end
            if(timer < waittime )begin
        

                guess_y_B <= YB;

                if (BTNB == 1 && guess_y_B == Y_COORD)begin
                    
                    correct_guess_B <= 1;
                    X_COORD <= 3;
                end

                timer <= timer + 1;
            end

            else begin
                if (correct_guess_B == 0) begin
                    score_A <= score_A + 1;
                end
                timer <= 0;
            end
                
        end

        else if( cstate == s9)begin
            timer <= timer + 1;
        end
        else if( cstate == s10)begin
            timer <= timer + 1;
        end
        
        else if( cstate == s8)begin
            if (timer == 0) begin
                correct_guess_A <= 0;
            end
            if(timer < waittime )begin
                
                guess_y_A <= YA;
                
                if (BTNA == 1 && guess_y_A == Y_COORD)begin
                    correct_guess_A <= 1;
                    X_COORD <= 1;
                end

                timer <= timer + 1;

            end

            else begin
                if (correct_guess_A == 0) begin
                    score_B <= score_B + 1;
                end
                
                timer <= 0;
            end
        end
                
        
    end

    
    

       
    end




    always @(*)
    begin

        case(cstate)

            s0:
            begin


                if(turn == 0)begin
                    nstate = s6;
                end

                else if(turn == 1)begin
                    nstate = s6;
                end
                else if(turn == 2) begin
                    nstate = s0;
                end
                else if(turn == 2) begin
                    nstate = s0;
                end

                else begin
                    nstate = s0;
                end
                
            end


            
            s1:
            begin
                    if((YA < 3'b101 ) && (BTNA == 1'b1))begin
                        nstate = s3;
                        //y1 = DIRA;
                    end
                    else begin
                        nstate = s1;
                    end

                    
            end

            s2:
            begin
                    if( (YB < 5 ) && (BTNB == 1'b1))begin
                        nstate = s4;
                        //y1 = DIRB;
                        
                    end
                    else begin
                        nstate = s2;
                    end
            end

            s3:
            begin    

                    if (X_COORD < 3'b100)begin
                        nstate = s3;
                        //#5; //speed of the puck
                    end
                    else if(X_COORD == 3'b100)begin
                        nstate = s7;
                    end
                    else begin
                        nstate = s0;
                    end
                    
                    /*if(win >= 1)begin
                        nstate = s5;
                    end*/
            end

            s4:
            begin
                
                    if (X_COORD > 3'b000)begin
                        nstate = s4;
                        //#5; //speed of the puck
                    end
                    else if(X_COORD == 3'b000)begin
                        nstate = s8; //s1
                    end
                    else begin
                        nstate = s0;
                    end
                    
                    /*if(win >= 1)begin
                        nstate = s5;
                    end*/
            end

            s5:
            begin
                // win state stays here forever until rst = 1;
                nstate = s5;
            end

            s6: // DISP
            begin
            
                if(turn == 0)begin
                    if (timer >= waittime) begin
                    nstate = s1;
                    //turn = 0;
                    end

                    else begin
                        nstate = s6;
                    end

                    
                end

                else begin
                    if (timer >= waittime)begin
                    nstate = s2;
                    //turn = 1;
                    end

                    else begin
                        nstate = s6;
                    end


                end
            end
            s7:
            begin
                
                if(timer >= waittime)begin
                    if(correct_guess_B == 1 ) begin
                        nstate = s4;
                    end

                    else begin
                        nstate = s9;
                    end
                end
                else begin
                    nstate <= s7;
                end

            end

            s9:
            begin
                if(timer <= waittime)begin
                    nstate = s9;
                end
                else begin
                    if(score_A == 3)begin
                    nstate = s5;
                    end
                    else begin
                        nstate = s2;
                    end
                end
            end

            s8:
            begin

                if(timer >= waittime)begin
                    if(correct_guess_A == 1 ) begin
                        nstate = s3;
                    end

                    else begin
                        nstate = s10;
                    end
                end
                else begin
                    nstate = s8;
                end

            end

            s10:
            begin
                if(timer < waittime)begin
                    nstate = s10;
                end
                else begin
                    if(score_B == 3)begin
                    nstate = s5;
                    end
                    else begin
                        nstate = s1;
                    end
                end
            end

            default: nstate = s0;
            

        endcase
    
    end


//for LEDs
        always @ (*)
        begin
            LEDA = 0;
            LEDB = 0;
            LEDX = LD_NONE;
          case (cstate)
            s0:
            begin
              LEDA = 1;
              LEDB = 1;
              LEDX = LD_NONE;
            end
      
            s6:
            begin
              LEDA = 0;
              LEDB = 0;
              LEDX = LD_ALL;
            end
      
            s1:
            begin
              LEDA = 1;
              LEDB = 0;
              LEDX = LD_NONE;
            end
      
            s2:
            begin
              LEDA = 0;
              LEDB = 1;
              LEDX = LD_NONE;
            end
      
            s3:
            begin
              LEDA = 0;
              LEDB = 0;
              if(X_COORD == 0)
              begin
                LEDX = LD_4;
              end
              else if(X_COORD == 1)
              begin
                LEDX = LD_3;
              end
              else if(X_COORD == 2)
              begin
                LEDX = LD_2;
              end
              else if(X_COORD == 3)
              begin
                LEDX = LD_1;
              end
              else if(X_COORD == 4)
              begin
                LEDX = LD_0;
              end
            end
      
            s4:
            begin
              LEDA = 0;
              LEDB = 0;
              if(X_COORD == 0)
              begin
                LEDX = LD_4;
              end
              else if(X_COORD == 1)
              begin
                LEDX = LD_3;
              end
              else if(X_COORD == 2)
              begin
                LEDX = LD_2;
              end
              else if(X_COORD == 3)
              begin
                LEDX = LD_1;
              end
              else if(X_COORD == 4)
              begin
                LEDX = LD_0;
              end
            end
      
            s8:
            begin
              LEDA = 1;
              LEDB = 0;
              LEDX = LD_4;
            end
      
            s7:
            begin
              LEDA = 0;
              LEDB = 1;
              LEDX = LD_0;
            end
      
            s10:
            begin
              LEDX = LD_ALL;
              LEDA = 0;
              LEDB = 0;
            end
      
            s9:
            begin
              LEDX = LD_ALL;
              LEDA = 0;
              LEDB = 0;
            end
      
           s5:
            begin
                LEDA = 0;
                LEDB = 0;
                if (timer < (waittime/2)) begin
                LEDX = 5'b10101;
                end 
                else begin
                LEDX = 5'b01010;
                end
            end
      
            default:
            begin
              LEDA = 0;
              LEDB = 0;
              LEDX = LD_NONE;
            end
            endcase
      
        end


//FOR SSDs
        always @ (*)
        begin

            SSD7 = 7'b1111111;
            SSD6 = 7'b1111111;
            SSD5 = 7'b1111111;
            SSD4 = 7'b1111111;
            SSD3 = 7'b1111111;
            SSD2 = 7'b1111111;
            SSD1 = 7'b1111111;
            SSD0 = 7'b1111111;

            case (cstate)
            s0:
            begin
                SSD7 = 7'b1111111;
                SSD6 = 7'b1111111;
                SSD5 = 7'b1111111;
                SSD4 = 7'b1111111;
                SSD3 = 7'b1111111;
                SSD2 = PRINT_A;
                SSD1 = DIGIT_line;
                SSD0 = PRINT_B;
            end
            
            s1: 
            begin
                if (YA == 0) begin
                    SSD4 = DIGIT_0;
                end
                else if (YA == 1)
                begin
                    SSD4 = DIGIT_1;
                end
                else if (YA == 2)
                begin
                    SSD4 = DIGIT_2;
                end
                else if (YA == 3)
                begin
                    SSD4 = DIGIT_3;
                end
                else if (YA == 4)
                begin
                    SSD4 = DIGIT_4;
                end
                else begin
                    SSD4 = 7'b0000000;
                end

                SSD5 = 7'b1111111;
                SSD3 = 7'b1111111;
                SSD2 = 7'b1111111;
                SSD1 = 7'b1111111;
                SSD0 = 7'b1111111;
            end

            s2:
            begin
                if (YB == 0) begin
                    SSD4 = DIGIT_0;
                end
                else if (YB == 1)
                begin
                    SSD4 = DIGIT_1;
                end
                else if (YB == 2)
                begin
                    SSD4 = DIGIT_2;
                end
                else if (YB == 3)
                begin
                    SSD4 = DIGIT_3;
                end
                else if (YB == 4)
                begin
                    SSD4 = DIGIT_4;
                end
                else begin
                    SSD4 = 7'b0000000;
                end

                SSD5 = 7'b1111111;
                SSD3 = 7'b1111111;
                SSD2 = 7'b1111111;
                SSD1 = 7'b1111111;
                SSD0 = 7'b1111111;
            end
            
            s3:
            begin
                if (Y_COORD == 0) begin
                    SSD4 = DIGIT_0;
                end
                else if (Y_COORD == 1)
                begin
                    SSD4 = DIGIT_1;
                end
                else if (Y_COORD == 2)
                begin
                    SSD4 = DIGIT_2;
                end
                else if (Y_COORD == 3)
                begin
                    SSD4 = DIGIT_3;
                end
                else if (Y_COORD == 4)
                begin
                    SSD4 = DIGIT_4;
                end
                else begin
                    SSD4 = 7'b0000000;
                end

                SSD5 = 7'b1111111;
                SSD3 = 7'b1111111;
                SSD2 = 7'b1111111;
                SSD1 = 7'b1111111;
                SSD0 = 7'b1111111;
            end

            s4:
            begin
                if (Y_COORD == 0) begin
                    SSD4 = DIGIT_0;
                end
                else if (Y_COORD == 1)
                begin
                    SSD4 = DIGIT_1;
                end
                else if (Y_COORD == 2)
                begin
                    SSD4 = DIGIT_2;
                end
                else if (Y_COORD == 3)
                begin
                    SSD4 = DIGIT_3;
                end
                else if (Y_COORD == 4)
                begin
                    SSD4 = DIGIT_4;
                end
                else begin
                    SSD4 = 7'b0000000;
                end

                SSD5 = 7'b1111111;
                SSD3 = 7'b1111111;
                SSD2 = 7'b1111111;
                SSD1 = 7'b1111111;
                SSD0 = 7'b1111111;
            end

            s5:
            begin
                SSD3 = 7'b1111111;
                SSD5 = 7'b1111111;
                SSD6 = 7'b1111111;
                SSD7 = 7'b1111111;
                SSD1 = DIGIT_line; 
                
                if( score_A == 0 && score_B == 3)begin
                    SSD4 = PRINT_B;
                    SSD2 = DIGIT_0;
                    SSD0 = DIGIT_3;    
                end
                else if( score_A == 1 && score_B == 3)begin
                    SSD4 = PRINT_B;
                    SSD2 = DIGIT_1;
                    SSD0 = DIGIT_3;                    
                end
                else if( score_A == 2 && score_B == 3)begin
                    SSD4 = PRINT_B;
                    SSD2 = DIGIT_2;
                    SSD0 = DIGIT_3;                    
                end

                else if( score_A == 3 && score_B == 0)begin
                    SSD4 = PRINT_A;
                    SSD2 = DIGIT_3;
                    SSD0 = DIGIT_0;                    
                end
                else if( score_A == 3 && score_B == 1)begin
                    SSD4 = PRINT_A;
                    SSD2 = DIGIT_3;
                    SSD0 = DIGIT_1;                    
                end
                else if( score_A == 3 && score_B == 2)begin
                    SSD4 = PRINT_A;
                    SSD2 = DIGIT_3;
                    SSD0 = DIGIT_2;    
                    end

                else begin
                    SSD2 = 7'b0000000;
                    SSD0 = 7'b0000000;    
                end
            end
            

            s6:
            begin
            SSD7 = 7'b1111111;
            SSD6 = 7'b1111111;
            SSD5 = 7'b1111111;
            SSD3 = 7'b1111111;
            SSD4 = 7'b1111111;
            
            SSD2 = DIGIT_0;
            SSD1 = DIGIT_line;
            SSD0 = DIGIT_0;    
            end

            s7:
            begin
                if (Y_COORD == 0) begin
                    SSD4 = DIGIT_0;
                end
                else if (Y_COORD == 1)
                begin
                    SSD4 = DIGIT_1;
                end
                else if (Y_COORD == 2)
                begin
                    SSD4 = DIGIT_2;
                end
                else if (Y_COORD == 3)
                begin
                    SSD4 = DIGIT_3;
                end
                else if (Y_COORD == 4)
                begin
                    SSD4 = DIGIT_4;
                end
                else begin
                    SSD4 = 7'b0000000;
                end
    

                SSD5 = 7'b1111111;
                SSD3 = 7'b1111111;
                SSD2 = 7'b1111111;
                SSD1 = 7'b1111111;
                SSD0 = 7'b1111111;
            end

            s8:
            begin
                if (Y_COORD == 0) begin
                    SSD4 = DIGIT_0;
                end
                else if (Y_COORD == 1)
                begin
                    SSD4 = DIGIT_1;
                end
                else if (Y_COORD == 2)
                begin
                    SSD4 = DIGIT_2;
                end
                else if (Y_COORD == 3)
                begin
                    SSD4 = DIGIT_3;
                end
                else if (Y_COORD == 4)
                begin
                    SSD4 = DIGIT_4;
                end
                else begin
                    SSD4 = 7'b0000000;
                end
    

                SSD5 = 7'b1111111;
                SSD3 = 7'b1111111;
                SSD2 = 7'b1111111;
                SSD1 = 7'b1111111;
                SSD0 = 7'b1111111;
            end


            s9:
            begin
                SSD7 = 7'b1111111;
                SSD6 = 7'b1111111;
                SSD5 = 7'b1111111;
                SSD3 = 7'b1111111;
                SSD4 = 7'b1111111;
                SSD1 = DIGIT_line; 
            case ({score_A, score_B}) 
                4'b0000: begin
                    SSD2 = DIGIT_0;
                    SSD0 = DIGIT_0;
                end
                4'b0001: begin
                    SSD2 = DIGIT_0;
                    SSD0 = DIGIT_1;
                end
                4'b0010: begin
                    SSD2 = DIGIT_0;
                    SSD0 = DIGIT_2;
                end
                4'b0011: begin
                    SSD2 = DIGIT_0;
                    SSD0 = DIGIT_3;
                end
                4'b0100: begin
                    SSD2 = DIGIT_1;
                    SSD0 = DIGIT_0;
                end
                4'b0101: begin
                    SSD2 = DIGIT_1;
                    SSD0 = DIGIT_1;
                end
                4'b0110: begin
                    SSD2 = DIGIT_1;
                    SSD0 = DIGIT_2;
                end
                4'b0111: begin
                    SSD2 = DIGIT_1;
                    SSD0 = DIGIT_3;
                end
                4'b1000: begin
                    SSD2 = DIGIT_2;
                    SSD0 = DIGIT_0;
                end
                4'b1001: begin
                    SSD2 = DIGIT_2;
                    SSD0 = DIGIT_1;
                end
                4'b1010: begin
                    SSD2 = DIGIT_2;
                    SSD0 = DIGIT_2;
                end
                4'b1011: begin
                    SSD2 = DIGIT_2;
                    SSD0 = DIGIT_3;
                end
                4'b1100: begin
                    SSD2 = DIGIT_3;
                    SSD0 = DIGIT_0;
                end
                4'b1101: begin
                    SSD2 = DIGIT_3;
                    SSD0 = DIGIT_1;
                end
                4'b1110: begin
                    SSD2 = DIGIT_3;
                    SSD0 = DIGIT_2;
                end
                
            endcase
            end
            
            s10:
            begin
                SSD7 = 7'b1111111;
                SSD6 = 7'b1111111;
                SSD3 = 7'b1111111;
                SSD2 = 7'b0000001;
                SSD1 = DIGIT_line; 
            case ({score_A, score_B}) 
            4'b0000: begin
                SSD2 = DIGIT_0;
                SSD0 = DIGIT_0;
            end
            4'b0001: begin
                SSD2 = DIGIT_0;
                SSD0 = DIGIT_1;
            end
            4'b0010: begin
                SSD2 = DIGIT_0;
                SSD0 = DIGIT_2;
            end
            4'b0011: begin
                SSD2 = DIGIT_0;
                SSD0 = DIGIT_3;
            end
            4'b0100: begin
                SSD2 = DIGIT_1;
                SSD0 = DIGIT_0;
            end
            4'b0101: begin
                SSD2 = DIGIT_1;
                SSD0 = DIGIT_1;
            end
            4'b0110: begin
                SSD2 = DIGIT_1;
                SSD0 = DIGIT_2;
            end
            4'b0111: begin
                SSD2 = DIGIT_1;
                SSD0 = DIGIT_3;
            end
            4'b1000: begin
                SSD2 = DIGIT_2;
                SSD0 = DIGIT_0;
            end
            4'b1001: begin
                SSD2 = DIGIT_2;
                SSD0 = DIGIT_1;
            end
            4'b1010: begin
                SSD2 = DIGIT_2;
                SSD0 = DIGIT_2;
            end
            4'b1011: begin
                SSD2 = DIGIT_2;
                SSD0 = DIGIT_3;
            end
            4'b1100: begin
                SSD2 = DIGIT_3;
                SSD0 = DIGIT_0;
            end
            4'b1101: begin
                SSD2 = DIGIT_3;
                SSD0 = DIGIT_1;
            end
            4'b1110: begin
                SSD2 = DIGIT_3;
                SSD0 = DIGIT_2;
            end
                
            endcase
            end

            default:
            begin
                SSD7 = 7'b1111111;
                SSD6 = 7'b1111111;
                SSD5 = 7'b1111111;
                SSD4 = 7'b1111111;
                SSD3 = 7'b1111111;
                SSD2 = 7'b1111111;
                SSD1 = 7'b1111111;
                SSD0 = 7'b1111111;
            end
            endcase
        end
            

 




endmodule