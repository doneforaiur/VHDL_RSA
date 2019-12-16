# ac?klama sat?rÄ
vsim rsa_processor_1
add wave *
force -freeze sim:/rsa_processor_1/prime1 199 0
force -freeze sim:/rsa_processor_1/prime2 197 0

force -freeze sim:/rsa_processor_1/CLK 0 0, 1 {50 ns} -r 100
force -freeze sim:/rsa_processor_1/set_primes 0 0, 1 {50 ns} -r 100

force -freeze sim:/rsa_processor_1/set_primes 0 0
force -freeze sim:/rsa_processor_1/enc_dec_select 0 0, 1 {100 ns} -r 200
force -freeze sim:/rsa_processor_1/message_to_encrypt 65 0 
# A karakterinin ASCII kodu. 

run 400
