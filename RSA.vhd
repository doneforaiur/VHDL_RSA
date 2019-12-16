--============================================
-- Donanim Tanimlama Dilleri Dersi Proje Ödevi
-- 19/10/2019
--============================================
-- Mirza ATLI
-- Yücel TOPRAK
-- Halil Ibrahim BASKAYA
--============================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY N_and_Z IS
	PORT(	prime1,prime2 : IN unsigned(31 downto 0); 	
		calculate_priv_pub_key : IN std_logic; 		
		N : OUT unsigned(63 downto 0);            
		Z : OUT unsigned(63 downto 0);
		CLK : IN std_logic
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
		D : IN unsigned(63 downto 0);
		E : OUT unsigned(63 downto 0);
		public_key1 : OUT unsigned(63 downto 0);
		CLK : IN std_logic
	);
END find_E;

ARCHITECTURE Behv OF find_E IS
BEGIN
	PROCESS(CLK)
	BEGIN
		IF (CLK'event AND CLK='1') then 
			E <= to_unsigned(to_integer(Z) * 3 + 1, 64) / D; 
			public_key1 <= to_unsigned(to_integer(Z) * 3 + 1, 64) / D; 
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
		public_key2 : OUT unsigned(63 downto 0);
		CLK : IN std_logic
	);
END find_D;

ARCHITECTURE Behv OF find_D IS
BEGIN
	PROCESS(E)
	VARIABLE i,j : unsigned(63 downto 0);
	VARIABLE temp : unsigned(63 downto 0) ;
	BEGIN
		IF(E'transaction'event) THEN 
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
			public_key2 <= temp;
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
		enc_dec_select : IN std_logic
	);
END Encrypt;

ARCHITECTURE behv_encrypt OF Encrypt IS

	SIGNAL temp3 : unsigned (255 downto 0) := to_unsigned(1, 256);
BEGIN
	PROCESS(CLK, enc_dec_select)
	type powersOfTwo is array (62 downto 0) of unsigned(63 downto 0);
	variable modsOfTwos : powersOfTwo;

	variable i : integer range 0 to 63;
	variable temp3 : unsigned (255 downto 0) := to_unsigned(1, 256);
	BEGIN
	IF(CLK'event AND enc_dec_select = '1') THEN
		temp3 := to_unsigned(1,256);
		modsOfTwos(0) := message_in mod N;
		i := 1;
		WHILE (i < 63) LOOP
			modsOfTwos(i) := (modsOfTwos(i-1) * modsOfTwos(i-1)) mod N;
			i := i + 1;
		END LOOP;
		i := 0;
		WHILE (i < 63) LOOP
			IF(E(i) = '1') THEN
				temp3 :=  resize(((temp3 * modsOfTwos(i)) mod N), 256);
			END IF;
			i := i + 1;

		END LOOP;
		message_out <= temp3 mod N;
		temp3 := to_unsigned(1,256);
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
		enc_dec_select : IN std_logic
	);
END Decrypt;

ARCHITECTURE behv_decrypt OF Decrypt IS


	SIGNAL temp3 : unsigned (255 downto 0) := to_unsigned(1, 256);
BEGIN
	PROCESS(CLK, enc_dec_select)
	type powersOfTwo is array (62 downto 0) of unsigned(63 downto 0);
	variable modsOfTwos : powersOfTwo;

	variable i : integer range 0 to 63;
	variable temp3 : unsigned (255 downto 0) := to_unsigned(1, 256);
	BEGIN
	IF(CLK'event AND enc_dec_select = '0') THEN
		modsOfTwos(0) := message_in mod N;
		i := 1;
		WHILE (i < 63) LOOP
			modsOfTwos(i) := (modsOfTwos(i-1) * modsOfTwos(i-1)) mod N;
			i := i + 1;
		END LOOP;
		i := 0;
		WHILE (i < 63) LOOP
			IF(D(i) = '1') THEN
				temp3 :=  resize((temp3 * modsOfTwos(i)), 256);
			END IF;
			i := i + 1;

		END LOOP;
		message_out <= temp3 mod N;
		temp3 := to_unsigned(1,256);
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
		decrypted_message, encrypted_message : OUT UNSIGNED(63 downto 0);
		message_to_encrypt, message_to_decrypt : IN UNSIGNED(63 downto 0)
);
END RSA_Processor_1;

ARCHITECTURE behv_RSA OF RSA_Processor_1 IS
	component N_and_Z
	PORT(	prime1,prime2 : IN unsigned(31 downto 0); 	
		calculate_priv_pub_key : IN std_logic; 
		N : OUT unsigned(63 downto 0);
		Z : OUT unsigned(63 downto 0);
		CLK : IN std_logic
	);

	END component;
	component find_E
	PORT(	Z : IN unsigned(63 downto 0);
		D : IN unsigned(63 downto 0);
		E : OUT unsigned(63 downto 0);
		public_key1 : OUT unsigned(63 downto 0);
		CLK : IN std_logic
	);
	END COMPONENT;
	COMPONENT find_D
	PORT( 	E : IN unsigned(63 downto 0);
		Z : IN unsigned(63 downto 0);
		D : OUT unsigned(63 downto 0);
		public_key2 : OUT unsigned(63 downto 0);
		CLK : IN std_logic
	);
	END COMPONENT;

	COMPONENT Decrypt IS
	PORT( 	D : IN unsigned(63 downto 0);
		N : IN unsigned(63 downto 0);
		message_in : IN unsigned(63 downto 0);
		message_out : OUT unsigned(63 downto 0);
		CLK : IN std_logic;
		enc_dec_select : IN std_logic
		
	);
	END COMPONENT;
	COMPONENT Encrypt IS
	PORT( 	E : IN unsigned(63 downto 0);
		N : IN unsigned(63 downto 0);
		message_in : IN unsigned(63 downto 0);
		message_out : OUT unsigned(63 downto 0);
		CLK : IN std_logic;
		enc_dec_select : IN std_logic
		
	);
	END COMPONENT;

SIGNAL N, Z, E : unsigned(63 downto 0);
SIGNAL D : unsigned(63 downto 0);
BEGIN
	n1 : N_and_Z port map(prime1, prime2, set_primes,N, Z, CLK);
	n2 : find_E port map(Z,D,E,public_key1,CLK);
	n3 : find_D port map(E,Z,D,public_key2,CLK);


	n4 : Decrypt port map(D, N,message_to_decrypt, decrypted_message, CLK, enc_dec_select);
	n5 : Encrypt port map(E, N, message_to_encrypt, encrypted_message, CLK, enc_dec_select);
END behv_RSA;