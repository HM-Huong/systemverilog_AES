
'''
For easier to implement mixColumns (which is a matrix multiplication), we can change the state matrix order like this:
        Implement               vs              Specification
b0      b1      b2      b3              s0      s4      s8      s12
b4      b5      b6      b7              s1      s5      s9      s13
b8      b9      b10     b11             s2      s6      s10     s14
b12     b13     b14     b15             s3      s7      s11     s15

state = [b0, b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14, b15]
         ^                                                                ^
        MSB                                                              LSB

1 word = 4 bytes
state = [w0, w1, w2, w3]
w0 = [b0, b1, b2, b3]       =   [s0, s1, s2, s3]
w1 = [b4, b5, b6, b7]       =   [s4, s5, s6, s7]
w2 = [b8, b9, b10, b11]     =   [s8, s9, s10, s11]
w3 = [b12, b13, b14, b15]   =   [s12, s13, s14, s15]

That means, the shiftRows operation is actually a column shift operation. And in the mixColumns operation, we can do the matrix multiplication by fixMatrixRow x stateRow, which is more easier to implement in hardware.
'''

import copy

def main():
    global fTestVector
    fTestVector = open("../aesTestVector.mem", "w")
    fTestVector.write(f"// {"Key" : ^30} {"Plain text" : ^32} {"Cipher text" : ^32}\n")

    test("0123456789abcdef", "0123456789abcdef")
    test("0123456789abcdef", "1408200220062007")
    test("passwordPassword", "Hoang Minh Huong")
    test("This's a testKey", "And there's text")
    fTestVector.close()

def test(key, block):
    print("Key:\t", key)
    print("Block:\t", block)
    key = list(map(ord, key))
    block = list(map(ord, block))
    w = keyExpansion(key, 4, 10)
    # showHex("Key schedule:", w)
    e = cipher(block, 10, w)
    showHex("Key (hex):\t", key)
    showHex("Block (hex):\t", block)
    showHex("Cipher (hex):\t", e)
    print()
    testCase(key, block, e)

def testCase(key, iblock, oblock):
    global fTestVector
    if type(fTestVector) is type(None):
        return

    def toString(data):
        return ''.join([f"{b:02x}" for b in data])

    fTestVector.write(f"{toString(key)}_{toString(iblock)}_{toString(oblock)}\n")



def showHex(message, data, sep='', elementPerLine=16):
    print(message, end="")
    for i in range(len(data)):
        print(f"{data[i]:02x}", end=sep)
        if i % elementPerLine == elementPerLine - 1:
            print()

def appendWord(dest, src):
    for i in range(4):
        dest.append(src[i])

def xorWord(dest, src):
    for i in range(4):
        dest[i] ^= src[i]
    return dest

def keyExpansion(key, nk, nr):
    def rotWord(word):
        return [word[1], word[2], word[3], word[0]]
    def subWord(word):
        global SBox
        return [SBox[b] for b in word]

    w = []
    for i in range(0, nk * 4, 4):
        appendWord(w, key[i:i+4])
    for i in range(nk * 4, 16 * (nr + 1), 4):
        temp = w[i-4:i]
        if i % (nk * 4) == 0:
            temp = xorWord(subWord(rotWord(temp)), Rcon[int(i / (nk * 4))])
        elif nk > 6 and i % (nk * 4) == 4:
            temp = subWord(temp)
        appendWord(w, xorWord(temp, w[i - nk * 4:i - nk * 4 + 4]))
    return w

def cipher(block, nr, w):
    state = copy.deepcopy(block)
    w = copy.deepcopy(w)
    state = addRoundKey(state, w[0:16])
    showHex("Round 0:\t", state)
    for round in range(1, nr):
        print(f"Round {round}:")
        state = subBytes(state)
        showHex("\tSubBytes:\t", state)
        state = shiftRows(state)
        showHex("\tShiftRows:\t", state)
        state = mixColumns(state)
        showHex("\tMixColumns:\t", state)
        roundKey = w[round*16:round*16+16]
        state = addRoundKey(state, roundKey)
        showHex("\tAddRoundKey:\t", state)
    state = subBytes(state)
    state = shiftRows(state)
    state = addRoundKey(state, w[nr*16:nr*16+16])
    return state

def addRoundKey(state, key):
    for i in range(16):
        state[i] ^= key[i]
    return state

def subBytes(state):
    for i in range(16):
        state[i] = SBox[state[i]]
    return state

def shiftRows(state):
    # actually, it is column shift
    # column 0: no change
    # column 1: shift 1 byte
    state[1], state[5], state[9], state[13] = state[5], state[9], state[13], state[1]
    # column 2: shift 2 bytes
    state[2], state[6], state[10], state[14] = state[10], state[14], state[2], state[6]
    # column 3: shift 3 bytes
    state[3], state[7], state[11], state[15] = state[15], state[3], state[7], state[11]
    return state

def mixColumns(state):
    def mul2(b):
        return ((b << 1) ^ (0x1b & ((b >> 7) * 0xff))) & 0xff
    def mul3(b):
        return mul2(b) ^ b
    # row x row
    for i in range(0, 16, 4):
        s0, s1, s2, s3 = state[i:i+4]
        state[i] = mul2(s0) ^ mul3(s1) ^ s2 ^ s3
        state[i+1] = s0 ^ mul2(s1) ^ mul3(s2) ^ s3
        state[i+2] = s0 ^ s1 ^ mul2(s2) ^ mul3(s3)
        state[i+3] = mul3(s0) ^ s1 ^ s2 ^ mul2(s3)
    return state


SBox = (0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5,
        0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76,
        0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0,
        0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0,
        0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc,
        0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15,
        0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a,
        0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75,
        0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0,
        0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84,
        0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b,
        0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf,
        0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85,
        0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8,
        0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5,
        0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2,
        0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17,
        0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73,
        0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88,
        0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb,
        0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c,
        0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79,
        0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9,
        0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08,
        0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6,
        0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a,
        0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e,
        0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e,
        0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94,
        0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf,
        0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68,
        0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16)

Rcon =(
    [0, 0, 0, 0],
    [0x01, 0, 0, 0],
    [0x02, 0, 0, 0],
    [0x04, 0, 0, 0],
    [0x08, 0, 0, 0],
    [0x10, 0, 0, 0],
    [0x20, 0, 0, 0],
    [0x40, 0, 0, 0],
    [0x80, 0, 0, 0],
    [0x1b, 0, 0, 0],
    [0x36, 0, 0, 0]
)

if __name__ == '__main__':
    main()