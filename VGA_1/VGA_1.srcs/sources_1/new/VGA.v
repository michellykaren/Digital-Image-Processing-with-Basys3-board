`timescale 1ns / 1ps

module vga_syncIndex(
clock,reset,sel_module,val,         //entradas - sel_module(seleciona função), reset(ligar e desligar), val(valor do nível de brilho)
hsync,vsync,                        // hsync e vsync para o monitor vga
red, green, blue,LED_out,Anode_Activate                    
);

    input clock;
    input reset;
    input [7:0] val = 0;            // inicializa o valor com zero
    input[3:0] sel_module;          // seleciona uma das 10 funções
    reg [7:0] gray, left, right, up, down, leftup, leftdown, rightup, rightdown;       //valores diferentes na matriz
    reg[7:0] red_o, blue_o, green_o;            
    reg [15:0] r, b, g;                         
    
    
   reg clk;
   initial begin
   clk =0;
   end
   always@(posedge clock)
   begin
    clk<=~clk;
   end
 
   output reg hsync;
   output reg vsync;
   reg [7:0] tred,tgreen,tblue;
	output reg [3:0] red,green;
	output reg [3:0] blue;
    output reg [6:0] LED_out;
    output reg [3:0] Anode_Activate;
	reg read = 0;
	reg [14:0] addra = 0;
	reg [95:0] in1 = 0;
	wire [95:0] out2;
	
	
image  inst1(
  .clka(clk), // input clka
  .wea(read), // input [0 : 0] wea
  .addra(addra), // input [14 : 0] addra
  .dina(in1), // input [95 : 0] dina
  .douta(out2) // output [95 : 0] douta
);

   wire pixel_clk;
   reg 		pcount = 0;
   wire 	ec = (pcount == 0);
   reg pass = 0'b0;
   always @ (posedge clk) pcount <= ~pcount;
   assign 	pixel_clk = ec;
   
   reg 		hblank=0,vblank=0;
   initial begin
   hsync =0;
   vsync=0;
   end
   reg [9:0] 	hc=0;      
   reg [9:0] 	vc=0;	 
	
   wire 	hsyncon,hsyncoff,hreset,hblankon;
   assign 	hblankon = ec & (hc == 639);    
   assign 	hsyncon = ec & (hc == 655);
   assign 	hsyncoff = ec & (hc == 751);
   assign 	hreset = ec & (hc == 799);
   
   wire 	blank =  (vblank | (hblank & ~hreset));    
   
   wire 	vsyncon,vsyncoff,vreset,vblankon;
   assign 	vblankon = hreset & (vc == 479);    
   assign 	vsyncon = hreset & (vc == 490);
   assign 	vsyncoff = hreset & (vc == 492);
   assign 	vreset = hreset & (vc == 523);

   always @(posedge clk) begin
   hc <= ec ? (hreset ? 0 : hc + 1) : hc;
   hblank <= hreset ? 0 : hblankon ? 1 : hblank;
   hsync <= hsyncon ? 0 : hsyncoff ? 1 : hsync; 
   
   vc <= hreset ? (vreset ? 0 : vc + 1) : vc;
   vblank <= vreset ? 0 : vblankon ? 1 : vblank;
   vsync <= vsyncon ? 0 : vsyncoff ? 1 : vsync;
end

always @(posedge pixel_clk)
    begin
        case(sel_module)
            4'b0000: begin
                Anode_Activate = 4'b1110;
                LED_out = 7'b0000001;
                end
            4'b0001: begin
                Anode_Activate = 4'b1110;
                LED_out = 7'b1001111;
                end
            4'b0010: begin
                Anode_Activate = 4'b1110;
                LED_out = 7'b0010010;
                end
            4'b0011: begin
                Anode_Activate = 4'b1110;
                LED_out = 7'b0000110;
                end
            4'b0100: begin
                Anode_Activate = 4'b1110;
                LED_out = 7'b1001100;
                end
            4'b0101: begin
                Anode_Activate = 4'b1110;
                LED_out = 7'b0100100;
                end
            4'b0110: begin
                Anode_Activate = 4'b1110;
                LED_out = 7'b0100000;
                end
            4'b0111: begin
                Anode_Activate = 4'b1110;
                LED_out = 7'b0001111;
                end
            4'b1000: begin
                Anode_Activate = 4'b1110;
                LED_out = 7'b0000000;
                end
            4'b1001: begin
                Anode_Activate = 4'b1110;
                LED_out = 7'b0000100;
                end
            
            default: begin
               Anode_Activate = 4'b0000;
               LED_out = 7'b1001111;
               end
            endcase
    end

always @(posedge pixel_clk)
	begin		
            if(blank == 0 && hc >= 100 && hc < 260 && vc >= 100 && vc < 215)
            begin
                
                gray =  {out2[95], out2[94], out2[93], out2[92], out2[91], out2[90], out2[89], out2[88]};
                left = {out2[87], out2[86], out2[85], out2[84], out2[83], out2[82], out2[81], out2[80]};
                right = {out2[79], out2[78], out2[77], out2[76], out2[75], out2[74], out2[73], out2[72]};                
                            
                up =  {out2[71], out2[70], out2[69], out2[68], out2[67], out2[66], out2[65], out2[64]};
                down = {out2[63], out2[62], out2[61], out2[60], out2[59], out2[58], out2[57], out2[56]};
                leftup = {out2[55], out2[54], out2[53], out2[52], out2[51], out2[50], out2[49], out2[48]};
                leftdown =  {out2[47], out2[46], out2[45], out2[44], out2[43], out2[42], out2[41], out2[40]};
                rightup = {out2[39], out2[38], out2[37], out2[36], out2[35], out2[34], out2[33], out2[32]};
                rightdown = {out2[31], out2[30], out2[29], out2[28], out2[27], out2[26], out2[25], out2[24]};
                tblue =  {out2[23], out2[22], out2[21], out2[20], out2[19], out2[18], out2[17], out2[16]};
                tgreen = {out2[15], out2[14], out2[13], out2[12], out2[11], out2[10], out2[9], out2[8]};
                tred = {out2[7], out2[6], out2[5], out2[4], out2[3], out2[2], out2[1], out2[0]};
                
                

//                 Imagem original
              if(sel_module == 4'b0000)begin
              
                    if(reset) begin
                        red = 0;
                        green = 0;
                        blue = 0;
                    end else begin
                        
                        
                        red_o = tred/16;
                        blue_o = tblue/16;
                        green_o = tgreen/16;
                        red = {red_o[3],red_o[2], red_o[1], red_o[0]};
                        green = {green_o[3],green_o[2], green_o[1], green_o[0]};
                        blue = {blue_o[3],blue_o[2], blue_o[1], blue_o[0]};
                        
                         end
                
                    // Aumentar brilho
                end else if(sel_module == 4'b0001)begin
                
                    if(reset) begin
                        red = 0;
                        green = 0;
                        blue = 0;
                    end else begin
                        r = tred + val;
                        g = tgreen + val;
                        b = tblue + val;
                        
                        if(r > 255)begin
                            red_o = 255;
                        end else begin
                            red_o = r;
                        end
                        if(g > 255)begin
                            green_o = 255;
                        end else begin
                            green_o = g;
                        end
                        if(b > 255)begin
                            blue_o = 255;
                        end else begin
                            blue_o = b;
                        end
                        
                        red_o = red_o/16;
                        blue_o = blue_o/16;
                        green_o = green_o/16;
                        red = {red_o[3],red_o[2], red_o[1], red_o[0]};
                        green = {green_o[3],green_o[2], green_o[1], green_o[0]};
                        blue = {blue_o[3],blue_o[2], blue_o[1], blue_o[0]};
                    end
                    
                    // Diminuir brilho
                end else if(sel_module == 4'b0010)begin
                    if(reset) begin
                        red = 0;
                        green = 0;
                        blue = 0;
                    end else begin
                        r = tred - val;
                        g = tgreen - val;
                        b = tblue - val;
                        if(r > 256)begin
                            red_o = 0;
                        end else begin
                            red_o = r;
                        end
                        if(g > 256)begin
                            green_o = 0;
                        end else begin
                            green_o = g;
                        end
                        if(b > 256)begin
                            blue_o = 0;
                        end else begin
                            blue_o = b;
                        end
                        
                        red_o = red_o/16;
                        blue_o = blue_o/16;
                        green_o = green_o/16;
                        red = {red_o[3],red_o[2], red_o[1], red_o[0]};
                        green = {green_o[3],green_o[2], green_o[1], green_o[0]};
                        blue = {blue_o[3],blue_o[2], blue_o[1], blue_o[0]};
                    end
                    
                    //Escala de cinza
                end else if(sel_module == 4'b0011)begin
                    if(reset) begin
                        red = 0;
                        green = 0;
                        blue = 0;
                    end
                    else begin
                        red_o = (tred >> 2) + (tred >> 5) + (tgreen >> 1) + (tgreen >> 4)+ (tblue >> 4) + (tblue >> 5);
                        green_o = (tred >> 2) + (tred >> 5) + (tgreen >> 1) + (tgreen >> 4)+ (tblue >> 4) + (tblue >> 5);
                        blue_o = (tred >> 2) + (tred >> 5) + (tgreen >> 1) + (tgreen >> 4)+ (tblue >> 4) + (tblue >> 5);
                                            
                        red_o = red_o/16;
                        blue_o = blue_o/16;
                        green_o = green_o/16;
                    
                        red = {red_o[3],red_o[2], red_o[1], red_o[0]};
                        green = {green_o[3],green_o[2], green_o[1], green_o[0]};
                        blue = {blue_o[3],blue_o[2], blue_o[1], blue_o[0]};                        
                                            
                    end                   
                
                
                //   Desfoque médio    
                end else if(sel_module == 4'b0100)begin
                    if(reset) begin
                       red = 0;
                       green = 0;
                       blue = 0;                    
                   end else begin
                       
                       r = (gray + left + right + up +down +leftup +leftdown +rightup +rightdown);
                       r = r/9;
                       
                       red_o = r;
                       blue_o = r;
                       green_o = r;
                       
                       red_o = red_o/16;
                       blue_o = blue_o/16;
                       green_o = green_o/16;
                       
                       red = {red_o[3],red_o[2], red_o[1], red_o[0]};
                       green = {green_o[3],green_o[2], green_o[1], green_o[0]};
                       blue = {blue_o[3],blue_o[2], blue_o[1], blue_o[0]};
                   end
                   
                   //// Detecção de borda de sobel
               end else if(sel_module == 4'b0101)begin
                    if(reset) begin
                       red = 0;
                       green = 0;
                       blue = 0;
                   end else begin
                       
                       r = ((rightup)- leftup + (2*right) - (2*left) + rightdown - leftdown);
                       g = ((rightup) + (2*up) + leftup - rightdown - (2*down) - leftdown);
                       
                       if(r > 1024 & g > 1024)begin
                           b = -(r + g)/2;
                       end else if(r > 1024 & g < 1024)begin
                           b = (-r  + g)/2;
                       end else if(r < 1024 & g < 1024)begin
                           b = (r + g)/2;
                       end else begin
                           b = (r - g)/2;
                       end
                       red_o = b;
                       blue_o = b;
                       green_o = b;
                          red_o = red_o/16;
                          blue_o = blue_o/16;
                          green_o = green_o/16;
                          red = {red_o[3],red_o[2], red_o[1], red_o[0]};
                          green = {green_o[3],green_o[2], green_o[1], green_o[0]};
                          blue = {blue_o[3],blue_o[2], blue_o[1], blue_o[0]};
                       
                end
                
                
                
                    ////  Detecção de borda
               end else if(sel_module == 4'b0110)begin
                    if(reset) begin
                            red = 0;
                            green = 0;
                            blue = 0;                          
                        end else begin
                            
                            r = ((8*gray) - left - right - up - down - leftup - leftdown - rightup - rightdown);
                            if(r > 2048)begin
                               red_o = 0;
                               blue_o = 0;
                               green_o = 0;
                            end else if(r > 255) begin
                                  red_o = 255;
                                  blue_o = 255;
                                  green_o = 255;
                            end else begin
                               red_o = r;
                               blue_o = r;
                               green_o = r;
                            end
                            
                            red_o = red_o/16;
                           blue_o = blue_o/16;
                           green_o = green_o/16;
                           red = {red_o[3],red_o[2], red_o[1], red_o[0]};
                           green = {green_o[3],green_o[2], green_o[1], green_o[0]};
                           blue = {blue_o[3],blue_o[2], blue_o[1], blue_o[0]};
                         end
                         
                    /////  Desfoque em x     
               end else if(sel_module == 4'b0111)begin
                   if(reset) begin
                        red = 0;
                        green = 0;
                        blue = 0;                          
                   end else begin
                        r = (up + leftup + rightup);
                        r = r/3;
                        red_o = r;
                        blue_o = r;
                        green_o = r;
                                          
                        red_o = red_o/16;
                        blue_o = blue_o/16;
                        green_o = green_o/16;
                        red = {red_o[3],red_o[2], red_o[1], red_o[0]};
                        green = {green_o[3],green_o[2], green_o[1], green_o[0]};
                        blue = {blue_o[3],blue_o[2], blue_o[1], blue_o[0]};
                     end            
                     
                    ////   Relevo
               end else if(sel_module == 4'b1000)begin
                   if(reset) begin
                       red = 0;
                       green = 0;
                       blue = 0;
                   end else begin
                   r = (gray + left - right - up + down + (2*leftdown) -(2*rightup));
                       if(r > 1280)begin
                           red_o = 0;
                           blue_o = 0;
                           green_o = 0;
                       end else if(r > 255) begin
                           red_o = 255;
                           blue_o = 255;
                           green_o = 255;
                       end else begin
                           red_o = r;
                           blue_o = r;
                           green_o = r;
                       end
                       
                       red_o = red_o/16;
                      blue_o = blue_o/16;
                      green_o = green_o/16;
                      red = {red_o[3],red_o[2], red_o[1], red_o[0]};
                      green = {green_o[3],green_o[2], green_o[1], green_o[0]};
                      blue = {blue_o[3],blue_o[2], blue_o[1], blue_o[0]};
               end
               
                   ///// Afinamento
               end else if(sel_module == 4'b1001)begin
                    if(reset) begin
                          red = 0;
                          green = 0;
                          blue = 0;
                      end else begin
                      
                      r = ((5*gray) - left - right - up - down);
                          if(r > 1280)begin
                              red_o = 0;
                              blue_o = 0;
                              green_o = 0;
                          end else if(r > 255) begin
                              red_o = 256;
                              blue_o = 256;
                              green_o = 256;
                          end else begin
                              red_o = r;
                              blue_o = r;
                              green_o = r;
                          end
                          
                          
                          red_o = red_o/16;
                         blue_o  = blue_o/16;
                         green_o = green_o/16;
                         red = {red_o[3],red_o[2], red_o[1], red_o[0]};
                         green = {green_o[3],green_o[2], green_o[1], green_o[0]};
                         blue = {blue_o[3],blue_o[2], blue_o[1], blue_o[0]};
                  end
                  
                  
               
               end else if(sel_module == 4'b1111)begin
                    if(reset) begin
                          red = 0;
                          green = 0;
                          blue = 0;                          
                    end else begin
                          r = (rightup  + (2*up) + leftup + (2*right) + (4*gray) + (2*left) + rightdown + (2*down) + (2*leftdown));
                          r = r/16;
                          red_o = r;
                          blue_o = r;
                          green_o = r;
                          
                          red_o = red_o/16;
                         blue_o = blue_o/16;
                         green_o = green_o/16;
                         red = {red_o[3],red_o[2], red_o[1], red_o[0]};
                         green = {green_o[3],green_o[2], green_o[1], green_o[0]};
                         blue = {blue_o[3],blue_o[2], blue_o[1], blue_o[0]};
                    end 
               end            

                
                if(addra <18399)
                    addra = addra + 1;
                else
                    addra = 0;
            end
            
            else
            begin
            
                red = 0;
                green = 0;
                blue = 0;
                
            end
        end    
       
    endmodule

