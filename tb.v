module tb();
  
  //Input declaration
  reg [7:0] Paddr;
  reg [7:0] Pwdata;
  reg Pwrite;
  reg Psel;
  reg Penable;
  reg Pclk;
  reg Preset;
  
  //output declaration
  wire [7:0] Prdata;
  wire Pslverr;
  wire Pready;
  
  reg [7:0] mem [255:0];
  reg [1:0] state,next_state;
   
  APB_slave dut(Paddr,Pwdata,Pwrite,Psel,Penable,Pclk,Preset,Prdata,Pslverr,Pready);
  
 initial begin  
   Pclk = 0;
   //Preset = 0;
   
   repeat (50) begin
       
    Paddr= $random;
    Pwdata = $random; 
     
     @(posedge Pclk);
      Preset = 0;

     @(posedge Pclk);
      Psel = 0;
      Penable = 0;

     @(posedge Pclk);
      Psel = 1;

     @(posedge Pclk);      	     
      Penable = 1;

     @(posedge Pclk);
      Pwrite = 1;

     @(posedge Pclk);
     	Psel = 0;
     	Penable = 0;

     @(posedge Pclk);
      Psel = 1;
   
     @(posedge Pclk);           
      Penable = 1;

     @(posedge Pclk);
 	    Pwrite = 0;

     @(posedge Pclk);
      #2 Preset = 1;
    end
   
   #200 $finish;
  end
  
  
  initial begin
    forever begin
      @(Prdata);
      $display ("change in datao observed %d and %d",Prdata,Paddr);
    end
  end
    
  
  
  always #5 Pclk=~Pclk;
  
  initial $dumpvars();
  
endmodule
