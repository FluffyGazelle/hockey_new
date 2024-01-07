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

    reg [3:0] cstate; //current state
    reg [3:0] nstate; //next state
    reg [2:0] X_COORD;
	reg [2:0] Y_COORD;


    parameter [7:0] s0 = 8'b00000000;
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

    
    parameter [6:0] DIGIT_0 = 7'b0000001; // Example pattern for digit 0
    parameter [6:0] DIGIT_1 = 7'b1001111; // Example pattern for digit 1
    parameter [6:0] DIGIT_2 = 7'b0010010; // Example pattern for digit 2
    parameter [6:0] DIGIT_3 = 7'b0000110; // Example pattern for digit 3

   task hide_ssd;
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
   endtask

    task show_ssd;
    input [6:0] ssd4_value;
    input [6:0] ssd1_value;
    begin
        SSD4 = ssd4_value;
        SSD0 = ssd1_value;        
        SSD7 = 7'b0000001;
        SSD6 = 7'b0000001;
        SSD5 = 7'b0000001;
        SSD3 = 7'b0000001;
        SSD2 = 7'b0000001;
        SSD1 = 7'b0000001; 
    end
    endtask
    
    parameter LD_NONE = 5'b00000;
    parameter LD_ALL = 5'b11111;
    parameter LD_0 = 5'b00001;
    parameter LD_1 = 5'b00010;
    parameter LD_2 = 5'b00100;
    parameter LD_3 = 5'b01000;
    parameter LD_4 = 5'b10000;
    //else yaz
    //ID: 29015 / 27968;

    reg btn_A;
    reg btn_B;

    reg x1;
    reg [3:0] y1;

    reg [2:0] guess_y_A;
    reg [2:0] guess_y_B;
    reg [1:0] turn; // 0 = A , 1 = B, 2 = standby
    reg [1:0] score_A;
    reg [1:0] score_B;
    reg [1:0] win;
    reg [7:0] timer;
    reg[1:0] correct_guess_B;
    reg[1:0] correct_guess_A;




    always @(posedge clk or posedge rst)
        begin
            
        
            if(rst == 1)begin
                cstate <= s0;
            end
            else begin
                cstate <= nstate;
            
           

            if(cstate == s1 && BTNA == 1)begin
                Y_COORD <= YA;
                //y1 <= DIRA;
                btn_A <= 1;
                X_COORD <= 0;
                
            end
            else if(cstate == s2)begin
                if(BTNB == 1) begin
                Y_COORD <= YB;
                //y1 <= DIRB;
                btn_B <= 1;
                X_COORD <= 4;
                end
                
            end
            
            else if(cstate == s3)begin
                
                //win state check code from here
                /*if( score_B >= 3)begin
                    win <= win + 1;
                end
                if( score_A >= 3)begin
                    win <= win + 1;
                end*/
                //to here


                if(X_COORD < 3'b100)begin
                    X_COORD <= X_COORD + 1;
                    guess_y_B <= YB;
                    if(BTNB == 1)begin
                        btn_B <= 1;
                    end
                    
                end
                /*if(X_COORD == 3'b100)begin
                    guess_y_B <= YB;
                    turn <= 1;
                    if(BTNB == 1)begin
                        btn_B <= 1;
                    end
                    if(BTNB == 0)begin
                        btn_B <= 0;
                    end
                    
                    if((guess_y_B != Y_COORD) | (btn_B == 0))begin
                        score_A <= score_A + 1;
                    end
                    if((guess_y_B == Y_COORD) | (btn_B == 0))begin
                        Y_COORD <= Y_COORD;
                    end
    
                end*/

                if ( y1 == 2'd1)begin 
                    if (Y_COORD < 3'b100)begin
                        Y_COORD[0] <= 1 ^ Y_COORD[0];
                        Y_COORD[1] <= Y_COORD[0] ^ Y_COORD[1];
                        Y_COORD[2] <= ((Y_COORD[0] & Y_COORD[1]) ^ Y_COORD[2]);
                        y1 <= 2'd1; 
                        end
                    else if(Y_COORD == 3'b100)begin
                        y1 <= 2'd2;
                        Y_COORD <= 3'b100;
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
                            Y_COORD <= 3'b000;
                        end
                end
                if (y1 == 2'd0)begin
                    Y_COORD <= Y_COORD;
                end
            end

            else if(cstate == s4)begin
                
                //win state check code from here
               /* if( score_B >= 3)begin
                    win <= win + 1;
                end
                if( score_A >= 3)begin
                    win <= win + 1;
                end*/
                //to here

                correct_guess_B <= 0;

                if(X_COORD > 3'b000)begin
                    X_COORD <= (X_COORD - 1);
                    guess_y_A <= YA;
                    if(BTNA == 1)begin
                        btn_A <= 1;
                    end
                    if(BTNA == 0)begin
                        btn_A <= 0;
                    end
                end

                if(X_COORD == 3'b000)begin
                    guess_y_A <= YA;
                    turn <= 0;
                    if(BTNA == 1)begin
                        btn_A <= 1;
                    end
                    if(BTNA == 0)begin
                        btn_A <= 0;
                    end
                    /*if((guess_y_A != Y_COORD) | (btn_A == 0))begin
                        score_B <= score_B + 1;
                    end
                    if((guess_y_A == Y_COORD) | (btn_A == 0))begin
                        Y_COORD <= Y_COORD;
                    end*/
                    
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
                        Y_COORD <= 3'b100;
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
                            Y_COORD <= 3'b000;
                        end
                end
                
                if (y1 == 2'd0)begin
                    Y_COORD <= Y_COORD;
                end



            end

            else if( cstate == s6)begin
                timer <= timer + 1;
            end

            else if( cstate == s7)begin
                if(timer <= 50 )begin
                    
            
                    if(BTNA == 1)begin
                        guess_y_B <= YB;
                    end

                    timer <= timer + 1;

                    if((guess_y_B != Y_COORD) | (BTNB == 1))begin
                        correct_guess_B <= 0;
                        score_A <= score_A + 1;
                        timer <= 0; 
                    end

                    else if((guess_y_B == Y_COORD) | (BTNB == 1))begin
                        correct_guess_B <= 1;
                        timer <= 0;
                    end
                end

                else begin
                    correct_guess_B <= 0;
                    score_A <= score_A + 1;
                    timer <= 0;
                end
                    

                
                    
                
            end

            else if( cstate == s9)begin
                timer <= timer + 1;
            end

            else if( cstate == s8)begin
                if(timer <= 50 )begin
                    
            
                    if(BTNB == 1)begin
                        guess_y_A <= YA;
                    end

                    timer <= timer + 1;

                    if((guess_y_A != Y_COORD) | (BTNA == 1))begin
                        correct_guess_A <= 0;
                        score_B <= score_B + 1;
                        timer <= 0; 
                    end

                    else if((guess_y_A == Y_COORD) | (BTNA == 1))begin
                        correct_guess_A <= 1;
                        timer <= 0;
                    end
                end

                else begin
                    correct_guess_A <= 0;
                    score_B <= score_B + 1;
                    timer <= 0;
                end
            end
                    
            else
                ;

            end
        
    
           
        end


        always@(*)
        begin

            if(cstate == s0)begin
                if(BTNA == 1 && BTNB == 0)begin
                    turn <= 0;
                end

                else if(BTNB == 1 && BTNA == 0)begin
                    turn <= 1;
                end
                else if(BTNB == 0 && BTNA == 0) begin
                    turn <= 2;
                end
                else if(BTNB == 1 && BTNA == 1) begin
                    turn <= 2;
                end
                else begin
                    turn <= 2;
                end
            end
        end
       



        always @ (*)
        begin
            case (cstate)
            s0:
            begin
            hide_ssd();  
            end
            
            s1:
            begin
            hide_ssd();
            end

            s2:
            begin
            hide_ssd();
            end
            
            s3:
            begin
            hide_ssd();
            end

            s4:
            begin
            hide_ssd();
            end

            s5:
            begin
                if( score_A == 0 && score_B == 3)begin
                    show_ssd(DIGIT_0, DIGIT_3);
                end
                else if( score_A == 1 && score_B == 3)begin
                    show_ssd(DIGIT_1, DIGIT_3);
                end
                else if( score_A == 2 && score_B == 3)begin
                    show_ssd(DIGIT_2,DIGIT_3);
                end

                else if( score_A == 3 && score_B == 0)begin
                    show_ssd(DIGIT_3, DIGIT_0);
                end
                else if( score_A == 3 && score_B == 1)begin
                    show_ssd(DIGIT_3, DIGIT_1);
                end
                else if( score_A == 3 && score_B == 2)begin
                    show_ssd(DIGIT_3, DIGIT_2);
                end

                else:begin
                    show_ssd(7'b0000000,7'b0000000);
                end
            end
            

            s6:
            begin
            show_ssd(7'b0000001,7'b0000001);
            end

            s7:
            begin
            hide_ssd();
            end

            s8:
            begin
            hide_ssd();
            end


            s9:
            begin
            case ({score_A, score_B}) 
                4'b0000: show_ssd(DIGIT_0, DIGIT_0);
                4'b0001: show_ssd(DIGIT_0, DIGIT_1);
                4'b0010: show_ssd(DIGIT_0, DIGIT_2);
                4'b0100: show_ssd(DIGIT_1, DIGIT_0);
                4'b0101: show_ssd(DIGIT_1, DIGIT_1);
                4'b0110: show_ssd(DIGIT_1, DIGIT_2);
                4'b1000: show_ssd(DIGIT_2, DIGIT_0);
                4'b1001: show_ssd(DIGIT_2, DIGIT_1);
                4'b1010: show_ssd(DIGIT_2, DIGIT_2);
            endcase
            end
            
            s10:
            begin
            case ({score_A, score_B}) 
                4'b0000: show_ssd(DIGIT_0, DIGIT_0);
                4'b0001: show_ssd(DIGIT_0, DIGIT_1);
                4'b0010: show_ssd(DIGIT_0, DIGIT_2);
                4'b0100: show_ssd(DIGIT_1, DIGIT_0);
                4'b0101: show_ssd(DIGIT_1, DIGIT_1);
                4'b0110: show_ssd(DIGIT_1, DIGIT_2);
                4'b1000: show_ssd(DIGIT_2, DIGIT_0);
                4'b1001: show_ssd(DIGIT_2, DIGIT_1);
                4'b1010: show_ssd(DIGIT_2, DIGIT_2);
            endcase  
            end
            endcase
        end
      
//for LEDs
        always @ (*)
        begin
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
      
            HIT_A:
            begin
              LEDA = 1;
              LEDB = 0;
              LEDX = LD_NONE;
            end
      
            HIT_B:
            begin
              LEDA = 0;
              LEDB = 1;
              LEDX = LD_NONE;
            end
      
            SEND_A:
            begin
              LEDA = 0;
              LEDB = 0;
              if(X_COORD == 0)
              begin
                LEDX = LD_0;
              end
              else if(X_COORD == 1)
              begin
                LEDX = LD_1;
              end
              else if(X_COORD == 2)
              begin
                LEDX = LD_2;
              end
              else if(X_COORD == 3)
              begin
                LEDX = LD_3;
              end
              else if(X_COORD == 4)
              begin
                LEDX = LD_4;
              end
            end
      
            SEND_B:
            begin
              LEDA = 0;
              LEDB = 0;
              if(X_COORD == 0)
              begin
                LEDX = LD_0;
              end
              else if(X_COORD == 1)
              begin
                LEDX = LD_1;
              end
              else if(X_COORD == 2)
              begin
                LEDX = LD_2;
              end
              else if(X_COORD == 3)
              begin
                LEDX = LD_3;
              end
              else if(X_COORD == 4)
              begin
                LEDX = LD_4;
              end
            end
      
            RESP_A:
            begin
              LEDA = 1;
              LEDB = 0;
              LEDX = LD_1;
            end
      
            RESP_B:
            begin
              LEDA = 0;
              LEDB = 1;
              LEDX = LD_4;
            end
      
            GOAL_A:
            begin
              LEDX = LD_ALL;
              LEDA = 0;
              LEDB = 0;
            end
      
            GOAL_B:
            begin
              LEDX = LD_ALL;
              LEDA = 0;
              LEDB = 0;
            end
      
           s5:
            begin
              if(1)
              begin
                LEDX = 5'b10101;
                LEDA = 0;
                LEDB = 0;
              end
              else
              begin
                LEDX = 5'b01010;
                LEDA = 0;
                LEDB = 0;
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

        always @(*)
        begin

            case(cstate)

                s0:
                begin
                    if(rst == 1)begin
                        X_COORD = 3'b000;
                        Y_COORD = 3'b000;
                        score_A = 2'b00;
                        score_B = 2'b00;
                        btn_A = 1'b0;
                        btn_B = 1'b0;
                        turn  = 2;
                        win = 0;
                        timer = 0;
                        correct_guess_B = 0;
                        correct_guess_A = 0;
                    end
                    
                    //x1 <= 1'b0;
                    //btn_A <= BTNA;
                    //btn_B <= BTNB;

                    if(turn == 0)begin
                        nstate = s6;
                        //turn = 0;
                    end

                    else if(turn == 1)begin
                        nstate = s6;
                        //turn = 1;
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
                        timer = 0;
                        if((YA < 3'b101 ) && (BTNA == 1'b1))begin
                            nstate = s3;
                            y1 = DIRA;
                        end
                        else begin
                            nstate = s1;
                        end

                        
                end

                s2:
                begin
                        timer = 0;
                        if( (YB < 5 ) && (BTNB == 1'b1))begin
                            nstate = s4;
                            y1 = DIRB;
                            
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
                            nstate = s1;
                        end
                        else begin
                            nstate = s0;
                        end
                        
                        if(win >= 1)begin
                            nstate = s5;
                        end
                end

                s5:
                begin
                    // win state stays here forever until rst = 1;
                    nstate = s5;
                end

                s6:
                begin
                
                    if(turn == 0)begin
                        if (timer >= 2) begin
                        nstate = s1;
                        //turn = 0;
                        end

                        else begin
                            nstate = s6;
                        end

                        
                    end

                    else begin
                        if (timer >= 2)begin
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
                    
                    if(correct_guess_B == 1 ) begin
                        nstate = s4;
                    end

                    else begin
                        nstate = s9;
                    end
 
                end

                s9:
                begin
                    if(timer <= 50)begin
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
                    
                    if(correct_guess_A == 1 ) begin
                        nstate = s3;
                    end

                    else begin
                        nstate = s10;
                    end
 
                end

                s10:
                begin
                    if(timer <= 2)begin
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

                
                

            endcase
        
        end

 




endmodule