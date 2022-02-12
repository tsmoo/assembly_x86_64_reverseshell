# Linux Reverse Shell in Assembly x86_64

### Requirements 

```apt install -y nasm binutils```

### Compile / Link

`nasm -f elf64 -o reverse_shell.o reverse_shell.asm; ld -o reverse_shell.bin reverse_shell.o`

### Generate shellcode from the binary

The `reverse_shell.asm` file is optimized to avoid nullbytes. Nullbytes can cause troubles in shellcodes.
If we disassemble the `reverse_shell.bin` binary file with [objdump](https://sourceware.org/binutils/docs/binutils/objdump.html), we can see no nullbytes : 

![objdump_img](img/objdump)

To extract the opcodes from the binary, you can do this with the following command :

```
objdump -d ./reverse_shell.bin|grep '[0-9a-f]:'|grep -v 'file'|cut -f2 -d:|cut -f1-7 -d' '|tr -s ' '|tr '\t' ' '|sed 's/ $//g'|sed 's/ /\\x/g'|paste -d '' -s |sed 's/^/"/'|sed 's/$/"/g'
```

![shellcode](img/extract_shellcode)

Once opcodes extracted, you can test your shellcode in a C program like this [one](https://www.exploit-db.com/exploits/38065) !
