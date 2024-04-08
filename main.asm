#include "syscall.h"
#include "constants.h"

.data
.align 1

	goodResponse: 	 	.asciz "HTTP/1.1 200 OK\r\n\r\n"
    badResponse: 	 	.asciz "HTTP/1.1 404 File not found\r\n\r\n"
    delimiterString: 	.asciz "\r\n\r\n"
	malformedReq:		.asciz "The Request is malformed"
    GET:  				.asciz "GET"
    POST: 				.asciz "POST"
	
	sockfd: 			.word 0x0
    currfd: 			.word 0x0

    addr: 				.half 	AF_INET		# AF_INET 
						.half 	5000		# sin_port
						.byte 	127,0,0,1	# sin_addr
						.word 	0x0			# sin_zero
						.word 	0x0

	goodResponseLen: 	.word badResponse 		- goodResponse 	- 1 
    badResponseLen:	 	.word delimiterString 	- badResponse 	- 1
	malformedReqLen:	.word GET 				- malformedReq 	- 1
	addrLen:			.word goodResponseLen 	- addr


.bss
    buffer:				.space BUFFER_SIZE
    currBufferLen:		.space 4
	reqMethod:			.space 4 # 0 means GET,1 means POST
    reqURI:				.space MAX_FILENAME_LEN+1
    reqFD:				.space 4


.text
.globl __start
__start:

	socket:
		li $a0,AF_INET
		li $a1,SOCK_STREAM
		li $a2,IPPROTO_IP

		li $v0,SYS_socket
		syscall

		la $t5,sockfd
		sw $v0,0($t5)

	bind:
		lw $a0,sockfd
		la $a1,addr
		lw $a2,addrLen

		li $v0, SYS_bind
		syscall


	listen:
		lw $a0,sockfd
		li $a1,NULL

		li $v0,SYS_listen
		syscall

	

	requestLoop:
		accept:
			lw $a0,sockfd
			li $a1,NULL
			li $a2,NULL

			li $v0,SYS_accept
			syscall

			la $t5,currfd
			sw $v0,0($t5)

		move $s0,$v0
		la $s1, buffer
		li $s4, 0x0 # counter

		readLoop:
			move $a0,$s0
			add $a1,$s1,$s4
			li $a2, 1

			li $v0, SYS_read
			syscall

			add $a1,$s1,$s4
			lb 	$t1,0($a1)
			li 	$t3,' '

			addiu $s4,$s4,1
			bne $t1, $t3, readLoop

	slti $t5,$s4,6
	beq $t5,$0,methodNotValid

	move $a0,$s0
	move $a1,$s1
	li $a2, 20
	
	li $v0,SYS_write
	syscall

	close:
		lw $a0,currfd
		li $v0,SYS_close
		syscall

	j requestLoop

	li $a0,0
	li $v0,SYS_exit
	syscall



.globl methodNotValid
methodNotValid:
	
	lw $a0,currfd
	la $a1,malformedReq
	lw $a2,malformedReqLen

	li $v0, SYS_write
	syscall

	jr $ra
	