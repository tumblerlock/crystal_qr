# Notes on QR Code formatting
# Encoding
# If the input string only consists of decimal digits (0 through 9), use numeric mode.
# If numeric mode is not applicable, and if all of the characters in the input string can be found in the left column of the alphanumeric table, use alphanumeric mode. Lowercase letters CANNOT be encoded in alphanumeric mode; only uppercase.
# If there is a character that is not in the left column of the alphanumeric table but can be encoded in ISO 8859-1, use byte mode. As mentioned above, QR code readers may be able to recognize UTF-8 in byte mode.
# If all of the characters are in the Shift JIS character set, use Kanji mode. Shift JIS characters can be encoded in UTF-8 instead, so it is possible to use byte mode for Kanji, but it is generally more efficient to use Shift JIS and use Kanji mode for Kanji characters.

| Encoding modes Indicator | Meaning                                                                      |
|--------------------------|------------------------------------------------------------------------------|
| 0001                     | Numeric encoding (10 bits per 3 digits)                                      |
| 0010                     | Alphanumeric encoding (11 bits per 2 characters)                             |
| 0100                     | Byte encoding (8 bits per character)                                         |
| 1000                     | Kanji encoding (13 bits per character)                                       |
| 0011                     | Structured append (used to split a message across multiple QR symbols)       |
| 0111                     | Extended Channel Interpretation (select alternate character set or encoding) |
| 0101                     | FNC1 in first position (see Code 128 for more information)                   |
| 1001                     | FNC1 in second position                                                      |
| 0000                     | End of message (Terminator)                                                  |

Length field bitsize
| Encoding     | Ver. 1–9 | 10–26 | 27–40 |
|--------------|----------|-------|-------|
| Numeric      | 10       | 12    | 14    |
| Alphanumeric | 9        | 11    | 13    |
| Byte         | 8        | 16    | 16    |
| Kanji        | 8        | 10    | 12    |

| Mode indicator | Description             | Typical structure '[ type : sizes in bits ]'                                                    |
|----------------|-------------------------|-------------------------------------------------------------------------------------------------|
| 0001           | Numeric                 | [0001 : 4] [ Character Count Indicator : variable ] [ Data Bit Stream : 10 × charcount ]        |
| 0010           | Alphanumeric            | [0010 : 4] [ Character Count Indicator : variable ] [ Data Bit Stream : 11 × charcount ]        |
| 0100           | Byte encoding           | [0100 : 4] [ Character Count Indicator : variable ] [ Data Bit Stream : 8 × charcount ]         |
| 1000           | Kanji encoding          | [1000 : 4] [ Character Count Indicator : variable ] [ Data Bit Stream : 13 × charcount ]        |
| 0011           | Structured append       | [0011 : 4] [ Symbol Position : 4 ] [ Total Symbols: 4 ] [ Parity : 8 ]                          |
| 0111           | ECI                     | [0111 : 4] [ ECI Assignment number : variable ]                                                 |
| 0101           | FNC1 in first position  | [0101 : 4] [ Numeric/Alphanumeric/Byte/Kanji payload : variable ]                               |
| 1001           | FNC1 in second position | [1001 : 4] [ Application Indicator : 8 ] [ Numeric/Alphanumeric/Byte/Kanji payload : variable ] |
| 0000           | End of message          | [0000 : 4]                                                                                      |

Alphanumeric character codes
| Code | Character | Code | Character | Code | Character | Code | Character | Code | Character |
|------|-----------|------|-----------|------|-----------|------|-----------|------|-----------|
| 00   | 0         | 09   | 9         | 18   | I         | 27   | R         | 36   | Space     |
| 01   | 1         | 10   | A         | 19   | J         | 28   | S         | 37   | $         |
| 02   | 2         | 11   | B         | 20   | K         | 29   | T         | 38   | %         |
| 03   | 3         | 12   | C         | 21   | L         | 30   | U         | 39   | *         |
| 04   | 4         | 13   | D         | 22   | M         | 31   | V         | 40   | +         |
| 05   | 5         | 14   | E         | 23   | N         | 32   | W         | 41   | –         |
| 06   | 6         | 15   | F         | 24   | O         | 33   | X         | 42   | .         |
| 07   | 7         | 16   | G         | 25   | P         | 34   | Y         | 43   | /         |
| 08   | 8         | 17   | H         | 26   | Q         | 35   | Z         | 44   | :         |


| Error Correction Level | Level Indicator | Error Correction Bytes | Message Data Bytes |
|------------------------|-----------------|------------------------|--------------------|
| L                      | 01              | 7                      | 19                 |
| M                      | 00              | 10                     | 16                 |
| Q                      | 11              | 13                     | 13                 |
| H                      | 10              | 17                     | 9                  |

# Schema

[mode 4bits][character count 

