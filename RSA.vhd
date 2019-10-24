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
use ieee.numeric_std.all;

ENTITY N_and_Z IS
	PORT(	prime1,prime2 : IN unsigned(31 downto 0); 	--Kullanilacak asallar.
		calculate_priv_pub_key : IN std_logic; 	--Reset RSA, set primes and enc/dec select
		N : OUT unsigned(63 downto 0);               	-- (N,E) anahtar çifti.
		Z : OUT unsigned(63 downto 0);
		CLK : IN std_logic	-- Normal ya da sifreli mesaj.
	);
END N_and_Z;

ARCHITECTURE Behv OF N_and_Z IS
BEGIN
	PROCESS(calculate_priv_pub_key)
	BEGIN
	IF (calculate_priv_pub_key'transaction'event  and calculate_priv_pub_key ='1') then
		n <= prime1 * prime2;
		z <= (prime1-1)*(prime2-1);
	END IF;
	END PROCESS;
END Behv;



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


ENTITY find_E IS
	PORT(	Z : IN unsigned(63 downto 0);
		N : IN unsigned(63 downto 0);
		E : OUT unsigned(63 downto 0);
		CLK : IN std_logic
	);

END find_E;

ARCHITECTURE Behv OF find_E IS

BEGIN
	PROCESS (N,Z, CLK)
		VARIABLE i : unsigned(63 downto 0);
		function COPRIME_CHECK (z_temp, i: unsigned(63 downto 0))	return BOOLEAN is
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
		end function COPRIME_CHECK;




	BEGIN
		IF (CLK'event and CLK='1') then -- D FlipFlopu laz?m.
		i := (N - 1) / 1000;
		WHILE (i < N) LOOP -- Z'nin yar?s?ndan büyük bir E bulan loop.
			if COPRIME_CHECK(Z, i) then
				E <= i;
				exit;
			END IF;
			i := i + 1;
		END LOOP;
		END IF;
	END PROCESS;
END Behv;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY find_D IS
	PORT( 	E : IN unsigned(63 downto 0);
		Z : IN unsigned(63 downto 0);
		D : OUT unsigned(63 downto 0);
		CLK : IN std_logic
	);

END find_D;
ARCHITECTURE Behv OF find_D IS
BEGIN
	PROCESS(Z,E, CLK)
	VARIABLE i : unsigned(63 downto 0);
	VARIABLE temp : unsigned(127 downto 0);
	BEGIN
		IF() -- CLK='1' kodunu yaz.
		i := to_unsigned(1, i'length);
		WHILE (i < 10000) LOOP
			temp := (E * i) - 1;
			IF ( (Z rem temp) = 0 ) THEN -- z%(e*d - 1) = 0'a uyan D sayisini bulma.
				D <= i;
				exit;
			END IF;
			i := i + 1;
		END LOOP;
	END PROCESS;
END Behv;