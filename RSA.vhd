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
		public_key1, public_key2 : OUT unsigned(63 downto 0);
		CLK : IN std_logic
	);
END find_E;

ARCHITECTURE Behv OF find_E IS
BEGIN
	PROCESS (N,Z, CLK)
	BEGIN
		IF (Z'transaction'event and CLK='1') then -- D FlipFlopu laz?m.
			E <= to_unsigned(to_integer(Z) * 3 + 1, 64);
			public_key1 <= E;
			public_key2 <= N;
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
	PROCESS(E, CLK)
	VARIABLE i,j : unsigned(63 downto 0);
	VARIABLE temp : unsigned(63 downto 0) ;
	BEGIN
		IF(E'transaction'event) THEN -- CLK='1' kodunu yaz.
			i := to_unsigned(2,64);
			j := to_unsigned(2, 64);
			temp := to_unsigned(to_integer(Z) * 3 + 1, 64);
			WHILE (i * i <= temp) LOOP
				IF ((temp mod i) /= 0) THEN
					i := i + 1;
				ELSE
					temp := temp / i;
				END IF;
			END LOOP;
			D <= temp;
		END IF;
	END PROCESS;
END Behv;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


ENTITY Encrypt IS
	PORT( 	E : IN unsigned(63 downto 0);
		N : IN unsigned(63 downto 0);
		message_in : IN unsigned(63 downto 0);
		message_out : OUT unsigned(63 downto 0);
		CLK : IN std_logic;
		enc_dec_select : IN std_logic --Encrypt icin 0 biti.
		
	);
END Encrypt;

ARCHITECTURE behv_encrypt OF Encrypt IS

SIGNAL temp,temp1 : unsigned(63 downto 0);
BEGIN
	PROCESS(enc_dec_select)
	BEGIN
	IF(CLK'event AND enc_dec_select = '1') THEN
		temp <= to_unsigned(to_integer(message_in) ** to_integer(E) mod to_integer(N),temp'length);
			message_out <= temp;
	END IF;

	END PROCESS;
END behv_encrypt;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


ENTITY Decrypt IS
	PORT( 	D : IN unsigned(63 downto 0);
		N : IN unsigned(63 downto 0);
		message_in : IN unsigned(63 downto 0);
		message_out : OUT unsigned(63 downto 0);
		CLK : IN std_logic;
		enc_dec_select : IN std_logic --Decrypt icin 1 biti.
		
	);
END Decrypt;

ARCHITECTURE behv_decrypt OF Decrypt IS
BEGIN
	PROCESS(enc_dec_select)
	BEGIN
	IF(CLK'event AND enc_dec_select = '0') THEN
		message_out <= to_unsigned((((to_integer(message_in))**to_integer(D)) mod to_integer(N)), message_out'length);
	END IF;
	END PROCESS;
END behv_decrypt;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY RSA_Processor_1 IS
	PORT(	prime1, prime2 : UNSIGNED(31 downto 0);
		set_primes : IN std_logic;
		CLK : IN std_logic;
		enc_dec_select : IN std_logic;
		public_key1, public_key2 : OUT UNSIGNED(63 downto 0);
		message_out : OUT UNSIGNED(63 downto 0);
		message_in : IN UNSIGNED(63 downto 0)

);
END RSA_Processor_1;

ARCHITECTURE behv_RSA OF RSA_Processor_1 IS
	component N_and_Z
	PORT(	prime1,prime2 : IN unsigned(31 downto 0); 	--Kullanilacak asallar.
		calculate_priv_pub_key : IN std_logic; 	--Reset RSA, set primes and enc/dec select
		N : OUT unsigned(63 downto 0);               	-- (N,E) anahtar çifti.
		Z : OUT unsigned(63 downto 0);
		CLK : IN std_logic	-- Normal ya da sifreli mesaj.
	);

	END component;
	component find_E
	PORT(	Z : IN unsigned(63 downto 0);
		N : IN unsigned(63 downto 0);
		E : OUT unsigned(63 downto 0);
		CLK : IN std_logic
	);
	END COMPONENT;
	COMPONENT find_D
	PORT( 	E : IN unsigned(63 downto 0);
		Z : IN unsigned(63 downto 0);
		D : OUT unsigned(63 downto 0);
		CLK : IN std_logic
	);
	END COMPONENT;

	COMPONENT Decrypt IS
	PORT( 	D : IN unsigned(63 downto 0);
		N : IN unsigned(63 downto 0);
		message_in : IN unsigned(63 downto 0);
		message_out : OUT unsigned(63 downto 0);
		CLK : IN std_logic;
		enc_dec_select : IN std_logic --Decrypt icin 1 biti.
		
	);
	END COMPONENT;
	COMPONENT Encrypt IS
	PORT( 	E : IN unsigned(63 downto 0);
		N : IN unsigned(63 downto 0);
		message_in : IN unsigned(63 downto 0);
		message_out : OUT unsigned(63 downto 0);
		CLK : IN std_logic;
		enc_dec_select : IN std_logic --Encrypt icin 0 biti.
		
	);
	END COMPONENT;

SIGNAL N, Z, E : unsigned(63 downto 0);
SIGNAL D : unsigned(63 downto 0);
BEGIN
	n1 : N_and_Z port map(prime1, prime2, set_primes,N, Z, CLK);
	n2 : find_E port map(Z,N,E,CLK);
	n3 : find_D port map(E,Z,D,CLK);
	n4 : Decrypt port map(D,N,message_in, message_out, CLK, enc_dec_select);
	n5 : Encrypt port map(E, N, message_in, message_out, CLK, enc_dec_select);
END behv_RSA;