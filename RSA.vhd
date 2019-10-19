----------------------------------------------
-- Donanim Tanimlama Dilleri Dersi Proje Ödevi
-- 19/10/2019
--
--
-- Mirza ATLI
-- Yücel TOPRAK
-- Halil Ibrahim BASKAYA
--
--
----------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

ENTITY RSA_Processor IS
	PORT(	prime_1,prime_2 : IN std_logic_vector(7 downto 0) := "10101010";
		calculate_priv_pub_key, prime_set, enc_dec_select : IN std_logic;
		public_key, n : BUFFER std_logic_vector(15 downto 0);
		message : OUT std_logic_vector(7 downto 0)
	);
END RSA_Processor;

ARCHITECTURE Behv OF RSA_Processor IS
SIGNAL z : STD_LOGIC_VECTOR(15 downto 0);
SIGNAL e : STD_LOGIC_VECTOR(15 downto 0);
SIGNAL e_1, n_1, z_1: integer;
SIGNAL prime1, prime2 : STD_LOGIC_VECTOR(7 downto 0);
BEGIN

	prime1 <= prime_1 when rising_edge(prime_set); 
	prime2 <= prime_2 when rising_edge(prime_set); 

	n <= std_logic_vector(unsigned(prime1) * unsigned(prime2));
	z <= std_logic_vector(((unsigned(prime1) - 1) * ((unsigned(prime2) - 1))));
	n_1 <= to_integer(unsigned(prime1) * unsigned(prime_2));
	z_1 <= to_integer((unsigned(prime1) - 1) * ((unsigned(prime2) - 1)));
	
	-- Algoritmadaki N ve Z de?i?kenlerini bulan k?s?m.

	Calculate: PROCESS (calculate_priv_pub_key) -- Key'leri tekrar hesaplayan k?s?m.

		variable i : integer;
		variable coprime_temp : integer := i;
		variable z_temp : integer := to_integer(unsigned(z));
		

		-- Seçilen E say?s?n?n Z ile coprime olup olmad???n? döndüren fonksiyon.
		function coprime_check(z_temp, i: integer) return BOOLEAN is
			variable result : BOOLEAN := false;
			variable z_temp_n : integer := z_temp;
			variable i_n : integer := 3;
			begin
			WHILE (z_temp_n /= 0) AND (i_n /= 0) LOOP
				if (z_temp_n > i_n ) THEN
					z_temp_n := z_temp_n mod i_n;
				else
					i_n := i_n mod z_temp_n;	
				end if;
				if (z_temp_n = 1) OR (i_n = 1) then
					result := true;
					return result;
				end if;
			END LOOP;
			return result;
		end function coprime_check;


		BEGIN 
		i := n_1 / 2;
		WHILE (i < n_1) LOOP -- Z'nin yar?s?ndan büyük bir E bulan loop.
			if coprime_check(z_1, i) then
				e <=  std_logic_vector(to_unsigned(i, e'length));
				exit;
			END IF;
			i := i + 1;
		END LOOP;
	END PROCESS Calculate;
END Behv;