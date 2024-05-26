-------------------------------------------------------
-- Auto-generated module template: DE10_LITE_Default
--
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;


entity DE10_LITE_Default is
	port (
	-- CLOCK
		ADC_CLK_10 			: in std_logic;
		MAX10_CLK1_50 		: in std_logic;
		MAX10_CLK2_50 		: in std_logic;
	-- SDRAM
		DRAM_ADDR 			: out std_logic_vector(12 downto 0);
		DRAM_BA 			: out std_logic_vector(1 downto 0);
		DRAM_CAS_N 			: out std_logic;
		DRAM_CKE 			: out std_logic;
		DRAM_CLK 			: out std_logic;
		DRAM_CS_N 			: out std_logic;
		DRAM_DQ 			: inout std_logic_vector(15 downto 0);
		DRAM_LDQM 			: out std_logic;
		DRAM_RAS_N 			: out std_logic;
		DRAM_UDQM 			: out std_logic;
		DRAM_WE_N 			: out std_logic;
	-- SEG7
		HEX0 				: out std_logic_vector(7 downto 0);
		HEX1 				: out std_logic_vector(7 downto 0);
		HEX2 				: out std_logic_vector(7 downto 0);
		HEX3				: out std_logic_vector(7 downto 0);
		HEX4				: out std_logic_vector(7 downto 0);
		HEX5 				: out std_logic_vector(7 downto 0);
	-- KEY
		KEY 				: in std_logic_vector(1 downto 0);
	-- LED
		LEDR 				: out std_logic_vector(9 downto 0);
	-- SW
		SW 					: in std_logic_vector(9 downto 0);
	-- VGA
		VGA_B 				: out std_logic_vector(3 downto 0);
		VGA_G 				: out std_logic_vector(3 downto 0);
		VGA_HS 				: out std_logic;
		VGA_R 				: out std_logic_vector(3 downto 0);
		VGA_VS 				: out std_logic;
	-- Accelerometer
		GSENSOR_INT 		: in std_logic_vector(2 downto 1);
		GSENSOR_CS_N 		: out std_logic;	
		GSENSOR_SCLK 		: out std_logic;
		GSENSOR_SDI 		: inout std_logic;
		GSENSOR_SDO 		: inout std_logic;
	-- Arduino
		ARDUINO_IO 			: inout std_logic_vector(15 downto 0);
		ARDUINO_RESET_N 	: inout std_logic;
	-- GPIO, GPIO connect to GPIO Default
		GPIO 				: inout std_logic_vector(35 downto 0)
    );
end DE10_LITE_Default;
 
architecture RTL of DE10_LITE_Default is

component Reset_Delay is
	port (
		iCLK		: in std_logic;
		oRESET	: out std_logic
	);
end component;

component ClkGen is
   generic (N : integer);
   port (
	   	CLK, RESET : in std_logic;
		CLKout : out std_logic
	);
end component;

component Chattering is
    port (
        clk : in std_logic;
        sw_in : in std_logic;
        sw_out : out std_logic
    );
end component;

component UpDownCounter is
	port (
		clk	: in std_logic;
		reset	: in std_logic;
		EN		: in std_logic;
		UD		: in std_logic;
		SET	: in std_logic;
		chatterdKey1  : in std_logic;
		Cin	: in std_logic_vector(3 downto 0);
		Cout	: out std_logic_vector(3 downto 0);
		CB		: out std_logic
	);
end component;

component UpDownCounter6 is
	port (
		clk	: in std_logic;
		reset	: in std_logic;
		EN		: in std_logic;
		UD		: in std_logic;
		SET	: in std_logic;
		chatterdKey1    : in std_logic;
        Cin	: in std_logic_vector(3 downto 0);
		Cout	: out std_logic_vector(3 downto 0);
		CB		: out std_logic
	);
end component;

component SegmentDecoder is
	port (
		Din  : in std_logic_vector(3 downto 0);
		Dout : out std_logic_vector(7 downto 0)	
	);
end component;

signal clk, clk1, clk10, clk100, clk1000, reset : std_logic;
signal EN, SET, UD, CB : std_logic;  -- Enable, Set, Up/Down, Carry/Borrow
signal Cin, Cout : std_logic_vector(3 downto 0);  -- Counter In/Out
signal SD : std_logic_vector(7 downto 0);  -- Decoder

signal CB1, CB2, CB3, CB4, CB5 : std_logic;
signal EN1, EN2, EN3, EN4, EN5 : std_logic;
signal Cin4, Cin5 : std_logic_vector(3 downto 0);
signal Cout1, Cout2, Cout3, Cout4, Cout5 : std_logic_vector(3 downto 0);
signal SD1, SD2, SD3, SD4, SD5 : std_logic_vector(7 downto 0);
signal DLY_RST : std_logic;
signal Key1 : std_logic;
signal chatterdKey1 : std_logic;

begin

RD0: Reset_Delay port map (MAX10_CLK1_50, DLY_RST); 

-- IO test
	LEDR(8 downto 0) <= SW(8 downto 0);
	reset <= key(0);

-- Clock Generater at 1s(25000000)
CG1: ClkGen generic map (25000000) port map (MAX10_CLK1_50, reset, clk1);
CG10: ClkGen generic map (2500000) port map (MAX10_CLK1_50, reset, clk10);	
CG100: ClkGen generic map (250000) port map (MAX10_CLK1_50, reset, clk100);
clk <= clk100;  -- 10ms
	
-- Signal of Up/Down Counter	
	EN <= '1';  -- Enable=1(Up/Down)
	UD <= SW(9);  -- Up/Down=0/1
	SET <= SW(8) ;  -- Set Initial Value=1
	Cin <= "0000";  -- Counter In 0000
	Cin4 <= SW(3 downto 0);  -- Counter In Lower
	Cin5 <= SW(7 downto 4);  -- Counter In Upper
	LEDR(9) <= CB;  -- LED Display Carry/Borrow
	Key1 <= Key(1); -- Start/Stop

-- Enable of Carry/Borrow
-- Enable of Carry/Borrow
EN1 <= CB;
EN2 <= CB and CB1;
EN3 <= CB and CB1 and CB2;
EN4 <= CB and CB1 and CB2 and CB3;
EN5 <= CB and CB1 and CB2 and CB3 and CB4;

-- Up/Down Counter	
UDC0: UpDownCounter port map (clk, reset, EN, UD, SET, chatterdKey1, Cin, Cout, CB);
UDC1: UpDownCounter port map (clk, reset, EN1, UD, SET, chatterdKey1, Cin, Cout1, CB1);
UDC2: UpDownCounter port map (clk, reset, EN2, UD, SET, chatterdKey1, Cin4, Cout2, CB2);
UDC3: UpDownCounter6 port map (clk, reset, EN3, UD, SET, chatterdKey1, Cin5, Cout3, CB3);
UDC4: UpDownCounter port map (clk, reset, EN4, UD, SET, chatterdKey1, Cin, Cout4, CB4);
UDC5: UpDownCounter6 port map (clk, reset, EN5, UD, SET, chatterdKey1, Cin, Cout5, CB5);

-- Hex Segment Decoder
HSD0: SegmentDecoder port map (Cout, SD);
HSD1: SegmentDecoder port map (Cout1, SD1);
HSD2: SegmentDecoder port map (Cout2, SD2);
HSD3: SegmentDecoder port map (Cout3, SD3);
HSD4: SegmentDecoder port map (Cout4, SD4);
HSD5: SegmentDecoder port map (Cout5, SD5);

-- Display Segment
	HEX0 <= SD;
	HEX1 <= SD1;
	HEX2 <= SD2;
	HEX3 <= SD3;
	HEX4 <= SD4;
	HEX5 <= SD5;

end RTL;

-- Component

-- Clock Generater

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity ClkGen is
   generic (N : integer := 25000000);  -- 1s
   port (
	   CLK, RESET : in std_logic;
		CLKout : out std_logic
	);
end ClkGen;

architecture RTL of ClkGen is
signal c : std_logic;
begin
	process(CLK, RESET)
	variable i : integer;
	begin
		if (RESET = '0') then
			i := 0;
			c <= '0';
		elsif (CLK'event and CLK = '1') then
			if (i < N) then
				i := i + 1;
			else
				i := 0;
				c <= not c;
			end if;
		end if;
	end process;
	CLKout <= c;
end RTL;

-- Chattering
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity Chattering is
    port (
        clk : in std_logic;
        sw_in : in std_logic;
        sw_out : out std_logic
    );
end Chattering;

architecture RTL of Chattering is
    signal cnt : std_logic_vector(3 downto 0); -- 4bit counter
    signal swreg : std_logic; -- Switch Latch
    signal iclk : std_logic; -- 1/16 clock
begin
    sw_out <= swreg;

    -- 4bit Counter
    process(clk)
    begin
        if clk'event and clk = '1' then
            cnt <= cnt + "1";
        end if;
    end process;

    iclk <= cnt(3); -- clock for chattering inhibit

    -- switch latch 
    process(iclk)
    begin
        if iclk'event and iclk = '1' then
            swreg <= sw_in;
        end if;
    end process;
end RTL;

-- UpDownCounter

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity UpDownCounter is
   port (
      CLK, RESET : in std_logic;
      EN, UD, SET, chatterdKey1	: in std_logic;
      Cin : in std_logic_vector(3 downto 0);
      Cout : out std_logic_vector(3 downto 0);
      CB : out std_logic
   );
end UpDownCounter;

architecture RTL of UpDownCounter is
signal c : std_logic_vector(3 downto 0);
signal enable : std_logic := '1';
begin
-- Up/Down Counter with Carry/Borrow and Enable
	process(CLK, RESET, chatterdKey1)
	begin
		if (chatterdKey1'event and chatterdKey1 = '1') then
			enable <= not enable;
		end if;
		if (RESET = '0') then
			c <= "0000";
		elsif (CLK'event and CLK = '1') then
			if (SET = '1') then
				if (Cin <= "1001") then
                    c <= Cin;
                else
                    c <= "0000";
                end if;
			elsif (EN = '1' and enable = '1') then
				if (UD = '0') then  -- Up
					if (c = "1001") then
						c <= "0000";
					else
						c <= c + 1;
					end if;
				else  -- Down
					if (c = "0000") then
						c <= "1001";
					else
						c <= c - 1;
					end if;
				end if;
            end if;
		end if;
	end process;
	Cout <= c;
	-- Carry/Borrow
	CB <= '1' when (UD = '0') and (c = "1001") else  -- Up Carry
         '1' when (UD = '1') and (c = "0000") else  -- Down Borrow
         '0';
end RTL;

-- UpDownCounter6

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity UpDownCounter6 is
   port (
      CLK, RESET : in std_logic;
      EN, UD, SET, chatterdKey1	: in std_logic;
      Cin : in std_logic_vector(3 downto 0);
      Cout : out std_logic_vector(3 downto 0);
      CB : out std_logic
   );
end UpDownCounter6;

architecture RTL of UpDownCounter6 is
signal c : std_logic_vector(3 downto 0);
signal enable : std_logic := '1';
begin
-- Up/Down Counter with Carry/Borrow and Enable
	process(CLK, RESET, chatterdKey1)
	begin
		if (chatterdKey1'event and chatterdKey1 = '1') then
			enable <= not enable;
		end if;
		
		if (RESET = '0') then
			c <= "0000";
		elsif (CLK'event and CLK = '1') then
			if (SET = '1') then
				if (Cin <= "0101") then
                    c <= Cin;
                else
                    c <= "0000";
                end if;
			elsif (EN = '1' and enable = '1') then
				if (UD = '0') then  -- Up
					if (c = "0101") then
						c <= "0000";
					else
						c <= c + 1;
					end if;
				else  -- Down
					if (c = "0000") then
						c <= "0101";
					else
						c <= c - 1;
					end if;
				end if;
            end if;
		end if;
	end process;
	Cout <= c;
	-- Carry/Borrow
	CB <= '1' when (UD = '0') and (c = "0101") else  -- Up Carry
         '1' when (UD = '1') and (c = "0000") else  -- Down Borrow
         '0';
end RTL;

-- Segment Decoder

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
 
entity SegmentDecoder is
	port (
		Din : in std_logic_vector(3 downto 0);
		Dout : out std_logic_vector(7 downto 0)
    );
end SegmentDecoder;
 
architecture RTL of SegmentDecoder is
begin	
	process(Din)
	begin
		case Din is
			when "0000" => Dout <= "11000000";  -- 0
			when "0001" => Dout <= "11111001";  -- 1
			when "0010" => Dout <= "10100100";  -- 2
			when "0011" => Dout <= "10110000";  -- 3
			when "0100" => Dout <= "10011001";  -- 4
			when "0101" => Dout <= "10010010";  -- 5
			when "0110" => Dout <= "10000010";  -- 6
			when "0111" => Dout <= "11111000";  -- 7
			when "1000" => Dout <= "10000000";  -- 8
			when "1001" => Dout <= "10010000";  -- 9
			when "1010" => Dout <= "00001000";  -- A.
			when "1011" => Dout <= "00000011";  -- b.
			when "1100" => Dout <= "01000110";  -- C.
			when "1101" => Dout <= "00100001";  -- d.
			when "1110" => Dout <= "00000110";  -- E.
			when "1111" => Dout <= "00001110";  -- F.
			when others => Dout <= "11111111";  -- No Disp
		end case;
	end process;
end RTL;