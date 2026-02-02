# ``md5``

Calculate a message-digest fingerprint for a file.

## **SYNOPSIS**

    md5 [-pqrtx] [-s string] [file ...]

## **DESCRIPTION**

The **md5** utility takes as input a message of arbitrary length and produces as output a 128-bit "fingerprint" or "message digest" of the input. It is typical for a 128-bit hash to be represented as a hexadecimal number 32 digits long.

The **md5** utility is particularly useful for verifying the integrity of files by comparing the digest of a file after transfer with a known good digest.

## **OPTIONS**

- `-s string`
Print a checksum of the given *string*.

- `-p`
Echoes standard input to standard output and appends the checksum to standard error.

- `-q`
Quiet mode — only the checksum is printed, omitting the filename.

- `-r`
Reverses the output format, making it easier for parsing by other tools.

- `-t`
Run a built-in speed trial (benchmark). Measures the time required to process a large set of data and outputs the throughput in bytes per second.

- `-x`
Run a standard suite of test vectors to verify the correctness of the MD5 implementation.

## **EXIT STATUS**
The md5 utilitiy exit 0 on success and other than 0 on error.

## **EXAMPLES**

To calculate the MD5 hash for a string:

```bash
$ md5 -s "Hello Bastie"
MD5 ("Hello World") = 3a13ee24530df822a4ce9eac1ccd46f1
```

To benchmark the performance of the MD5 algorithm on your machine:

```bash
$ md5 -t
MD5 time trial. Digesting 100000000 128-byte blocks ... done
Time = 1.234567 seconds
Speed = 10368007532.00 bytes/second
```

## **SEE ALSO**

For more information on the algorithm, refer to [RFC 1321: The MD5 Message-Digest Algorithm](https://datatracker.ietf.org/doc/search?name=1321&rfcs=on&activedrafts=on).

> Important: The MD5 algorithm is no longer considered cryptographically secure. For security-sensitive applications, consider using SHA-256 or higher.

## **AUTHORS**

**Implementation:** Gemini, Deepseek, Claude - refined by Sebastian Ritter 

**Documentation:** Created by Gemini, refined by Sebastian Ritter
