----------------------------------------------
-- Donanim Tanimlama Dilleri Dersi Proje �devi
-- 19/10/2019
--
--
-- Mirza ATLI
-- Y�cel TOPRAK
-- Halil Ibrahim BASKAYA
--
--
----------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY RSA_Processor IS
	PORT(	prime_1,prime_2 : IN std_logic_vector(31 downto 0); 	--Kullanilacak asallar.
		calculate_priv_pub_key, prime_set, enc_dec_select : IN std_logic; 	--Reset RSA, set primes and enc/dec select
		public_key, n : BUFFER std_logic_vector(63 downto 0);               	-- (N,E) anahtar �ifti.
		message_out : OUT std_logic_vector(63 downto 0);
		message_in : IN std_logic_vector (63 downto 0)				-- Normal ya da sifreli mesaj.
	);
END RSA_Processor;

ARCHITECTURE Behv OF RSA_Processor IS
SIGNAL z : STD_LOGIC_VECTOR(63 downto 0);	-- Z = Prime1 * Prime2
SIGNAL e : STD_LOGIC_VECTOR(63 downto 0);	-- (E < N) & ebob(E,Z)
SIGNAL n_1 : unsigned(63 downto 0);
SIGNAL z_1 : unsigned(63 downto 0);			-- Z ve N'nin integer formmu. Vector formu laz?m olacak.
SIGNAL prime1 : STD_LOGIC_VECTOR(31 downto 0) := std_logic_vector(to_unsigned(1949, 32));
SIGNAL prime2 : STD_LOGIC_VECTOR(31 downto 0) := std_logic_vector(to_unsigned(1951, 32));
SIGNAL d_vector : STD_LOGIC_VECTOR(63 downto 0);
SIGNAL e_int : unsigned(63 downto 0);
SIGNAL d_int : unsigned(63 downto 0);
BEGIN
	-- assert clk='1' report "clock not up" severity WARNING; PR?MELARIN SETLEN?P SETLENMED???NE BAKMAK.
	--prime1 <= prime_1 when rising_edge(prime_set); 
	--prime2 <= prime_2 when rising_edge(prime_set); 

	n <= std_logic_vector(unsigned(prime1) * unsigned(prime2)); 			-- VECTOR
	z <= std_logic_vector(((unsigned(prime1) - 1) * ((unsigned(prime2) - 1))));
	n_1 <= unsigned(unsigned(prime1) * unsigned(prime2));			-- INTEGER
	z_1 <= (unsigned(prime1) - 1) * ((unsigned(prime2) - 1));
	
	-- Algoritmadaki N ve Z de?i?kenlerini bulan k?s?m.

	Calculate: PROCESS (calculate_priv_pub_key) -- Key'leri tekrar hesaplayan k?s?m.

		variable i : unsigned(63 downto 0);
		--variable z_temp : integer := to_integer(unsigned(z));
		variable temp : unsigned(127 downto 0);

		-- Se�ilen E say?s?n?n Z ile coprime olup olmad???n? d�nd�ren fonksiyon.
		function coprime_check(z_temp, i: unsigned(63 downto 0)) return BOOLEAN is
			variable z_temp1 : unsigned(63 downto 0) := z_temp; -- variable olarak atamazsam 58. sat?rda de?er atayam?yorum.
			variable i_n : unsigned(63 downto 0);
			begin
			i_n := i;
			WHILE (z_temp1 /= 0) AND (i_n /= 0) LOOP
				if (z_temp1 > i_n ) THEN
					z_temp1 := z_temp1 mod i_n;
				else
					i_n := i_n mod z_temp1;	
				end if;
				if (z_temp1 = 1) OR (i_n = 1) then
					return true;
				end if;
			END LOOP;
			return false;
		end function coprime_check;


		BEGIN
		if calculate_priv_pub_key'transaction'event then
		i := (n_1 - 1) / 1000;
		WHILE (i < n_1) LOOP -- Z'nin yar?s?ndan b�y�k bir E bulan loop.
			if coprime_check(z_1, i) then
				e_int <= i;
				wait for 10 ns;
				e <=  std_logic_vector(i);
				wait for 10 ns;
				exit;
			END IF;
			i := i + 1;
		END LOOP;
		
		i := to_unsigned(1, i'length);
		WHILE (i < 100)LOOP
			temp := (e_int * i) - 1;
			IF ( (z_1 rem temp) = 0 ) THEN -- z%(e*d - 1) = 0'a uyan D sayisini bulma.
				d_vector <= std_logic_vector(i);
				wait for 10 ns;
				d_int <= i;
				wait for 10 ns;
				exit;
			END IF;
			i := i + 1;
		END LOOP;
		public_key <= n;
		END IF;
END Behv;
