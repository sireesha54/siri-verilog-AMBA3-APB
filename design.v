// Code your design here
module APB_slave(
 
  //Input declarations
  input [7:0] Paddr,
  input [7:0] Pwdata,
  input Pwrite,
  input Psel,
  input Penable,
  input Pclk,
  input Preset,
  
  
  //output declarations
  output [7:0] Prdata,
  output Pslverr,
  output Pready);
  
  reg Pslverr;
  reg Pready;
  reg [7:0] Prdata;
  wire [7:0] Pdatao;
  
  //error signal
  reg [7:0] addr_4_err=8'hca;
  parameter wait_delay = 4;
  
  //slave memory declaration
  reg [7:0] mem [255:0];  
  reg [1:0] state,next_state;
  
  //state declaration
  parameter IDLE=0;
  parameter SETUP=1;
  parameter ACCESS=2;
  
  //sequential
  always@(posedge Pclk)
    if(Preset)
          begin
            foreach(mem[i]) 
              begin
              	mem[i] <= 0;
              end
            	mem[Paddr] <= 0;
        		Prdata <= 0;
              	Pslverr <= 0;
          end
  		else 
    		state <= next_state;
  
  //combinational
  always @(*)     
    begin      
  		case(state)  	  
         IDLE:if(Psel == 1'b0 && Penable == 1'b0) //IDEAL PHASE    
      				begin
        				Pready <= 0;
        				Prdata <= 0;
              			Pslverr <= 0;
                      	next_state <= SETUP;
      				end
          
          SETUP: if(Psel == 1'b1 && Penable == 1'b0) //SETUP PHASE
      				begin                   
                      if(Pwrite)
                        begin
                          Pready <= 0;
                          mem[Paddr] <= Pwdata; 
                          $display("%t writw %d data %d",$time,Pwdata,mem[Paddr]);
                  		  Pslverr <= (Paddr == addr_4_err)?1:0;
                          next_state <= ACCESS;
                        end
      				end
          
          ACCESS:if(Psel == 1'b1 && Penable == 1'b1) //ACCESS PHASE
            		begin
                      if(!Pwrite)            				 
            			begin
                            Pslverr <= (Paddr == addr_4_err) ? 1: 0;
          					Prdata <= Pslverr? 8'bz : mem [Paddr];
                            $display("%t read %d data %d",$time,Prdata,mem[Paddr]);
                            Pready <= #(wait_delay) 1;
                            next_state <= SETUP;
        				end
                    end
          default: next_state <= IDLE;
        endcase
    end
  assign Pdatao = mem [Paddr];
  
  
endmodule
