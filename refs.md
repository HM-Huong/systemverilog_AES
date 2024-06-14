# SystemVerilog AES

## Chú thích cú pháp

- `r[<begin> +: <offset>]`: lấy bit từ `begin` đến `begin + offset - 1`
- `r[<begin> -: <offset>]`: lấy bit từ `begin` đến `begin - offset + 1`

<https://github.com/ahegazy/aes>

```txt
i0	i1	i2	i3			s0	s4	s8	s12
i4	i5	i6	i7			s1	s5	s9	s13
i8	i9	i10	i11			s2	s6	s10	s14
i12	i13	i14	i15			s3	s7	s11	s15
```

mul matrix in mix column:  multiply the row by row -> Indexing is simpler because the index in a column is sequential
shift row  -> shift column

```txt
Key:     0123456789abcdef
Block:   0123456789abcdef
Plain text:     30313233343536373839616263646566
Round 0:        00000000000000000000000000000000
Round 1:
        SubBytes:       63636363636363636363636363636363
        ShiftRows:      63636363636363636363636363636363
        MixColumns:     63636363636363636363636363636363
        AddRoundKey:    111f62ab252a549c1d1335fe7e775098
Round 2:
        SubBytes:       82c0aa623fe520dea47d96bbf3f55346
        ShiftRows:      82e596463f7d5362a4f5aadef3c020bb
        MixColumns:     fbb49a62c85242ab236e670f3db3a583
        AddRoundKey:    710b940e04a47b3891e808019221f976
Round 3:
        SubBytes:       a32b22abf2492107819b307c4ffd9938
        ShiftRows:      a3493038f29b99ab81fd22074f2b217c
        MixColumns:     8e59c2f77bc4a64220013149be06a223
        AddRoundKey:    4fac2ae276c777c49f848fc1ae11405e
Round 4:
        SubBytes:       8491e59838c6f51cdb5f7378e4820958
        ShiftRows:      84c67358385f0998db82e51ce491f578
        MixColumns:     69de4c920005c635c9ecac29f6a10ca3
        AddRoundKey:    50b35b4d346b006c4207d4f86d5d960f
Round 5:
        SubBytes:       536d39e3187f63502cc548413c4c9076
        ShiftRows:      537f487618c590e32c4c39503c6d6341
        MixColumns:     1903262e17c1d8a0e5afe2a1ed0254c8
        AddRoundKey:    80d6a0e5ba7a9832c3ffdae250aef627
Round 6:
        SubBytes:       cdf6e0d9f4da46232e16579853e442cc
        ShiftRows:      cdda57ccf41642d92ee4e02353f64698
        MixColumns:     6f57f64252c716faa8e5743079f69a6e
        AddRoundKey:    47b8aff3d7930fd90be15550675e19e1
Round 7:
        SubBytes:       a06c790d0edc76352bf8fc538558d4f8
        ShiftRows:      a0dcfcf80ef8d40d2b587935856c7653
        MixColumns:     20e48c30d68f5224f225de368094f028
        AddRoundKey:    8ae7a6f3f9d861c47e76ccb6126f6127
Round 8:
        SubBytes:       7e94240d9961ef1cf3384b4ec9a8efcc
        ShiftRows:      7e614bcc9938ef0df3a8241cc994ef4e
        MixColumns:     d8adc62b83ce737d26c837ba8f9e4aa7
        AddRoundKey:    fd2f9aa7891b1c11a04e4a569be3a644
Round 9:
        SubBytes:       5415b85ca7af9c82e02fd6b11411241b
        ShiftRows:      54afd61ba72f245ce011b88214159cb1
        MixColumns:     8f6b61b35cc92441d293078d3a30eacc
        AddRoundKey:    4e272cc59750065b9f8c587b635259d9
Key schedule:
								30313233343536373839616263646566
								727c01c8464937ff7e70569d1d1433fb
								8abf0e6cccf63993b2866f0eaf925cf5
								c1f5e8150d03d186bf85be881017e27d
								396d17df346ec6598beb78d19bfc9aac
								99d586cbadbb409226503843bdaca2ef
								28ef59b185541923a30421601ea8838f
								aa032ac32f5733e08c53128092fb910f
								25825c8c0ad56f6c86867dec147dece3
								c14c4d76cb99221a4d1f5ff65962b315
								5d2114bd96b836a7dba7695182c5da44
```

3f 7d 53 62 a4 f5 aa de f3 c0 20 bb 82 e5 96 46

82 c0 aa 62
3f e5 20 de
a4 7d 96 bb
f3 f5 53 46

82 3f a4 f3
c0 e5 7d f5
aa 20 96 53
62 de bb 46
