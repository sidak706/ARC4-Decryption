# ARC4-Decryption

### ARC4 Decryption

This section describes the ARC4 cipher. A stream cipher like ARC4 uses the provided encryption key to generate a pseudo-random byte stream that is xor'd with the plaintext to obtain the ciphertext. Because xor is symmetric, encryption and decryption are exactly the same.

The basic ARC4 algorithm uses the following parameters:

| Parameter | Type | Semantics |
| --- | --- | --- |
| `key[]` | input | array of bytes that represent the secret key (3 bytes in our implementation) |
| `ciphertext[]` | input | array of bytes that represent the encrypted message |
| `plaintext[]` | output | array of bytes that represent the decrypted result (same length as ciphertext) |

and proceeds as shown in this pseudocode:

    -- key-scheduling algorithm: initialize the s array
    for i = 0 to 255:
        s[i] = i
    j = 0
    for i = 0 to 255:
        j = (j + s[i] + key[i mod keylength]) mod 256  -- for us, keylength is 3
        swap values of s[i] and s[j]

    -- pseudo-random generation algorithm: generate byte stream (“pad”) to be xor'd with the ciphertext
    i = 0, j = 0
    message_length = ciphertext[0]
    for k = 1 to message_length:
        i = (i+1) mod 256
        j = (j+s[i]) mod 256
        swap values of s[i] and s[j]
        pad[k] = s[(s[i]+s[j]) mod 256]

    -- ciphertext xor pad --> plaintext
    plaintext[0] = message_length
    for k = 1 to message_length:
        plaintext[k] = pad[k] xor ciphertext[k]  -- xor each byte


# Ready Enable Protocol
Each phase and module in this project uses the ready-enable protocol handshake. Whenever `rdy` is asserted, it means that the callee is able to accept a request _in the same cycle_. When the caller asserts `en`, the handshake is complete. `rdy` is reasserted only when the module is ready to run again. 

# Memory Initialization
I have included 1 sample test to run, and see the output of the key. The values in test.mif are used to initialize the ct RAM. Upon completion a human readable sentence (in HEX values) will be produced in the FPGA pt RAM. 

# 5 phases
I have broken down the implementation of the above algorithm into 5 different phases. 
Phases 1-3 implement the ARC4 algorithm. 
Phase 4 is used to sequentially search through the key space starting from key 'h000000 and incrementing by 1 every iteration  and find a key that produces an output such that 
each character in pt is readable i.e 'h20 and 'h7E inclusive (i.e., readable ASCII).
Phase 5 speeds up the search process by 100% by running 2 crack modules in parallel with the first one iterating over
even keys, and the second one iterating over odd keys. 

Once a suitable key is found, it will be displayed on the DE1-SOC in big-endian form. 

# Running instructions
To see the algorithm in action with the given test file, simply upload the phase5.sv onto the DE1-SOC with all 
modules (except the phases) found in the modules folder. The final key will then be displayed on the FPGA with 
readable sentence in the PT RAM (which can be viewed on Quartus). 


# Optional
To simulate on modelsim, initialize the ct RAM using the following:
initial $readmemh("test2.memh", ct.altsyncram_component.m_default.altsyncram_inst.mem_data);
