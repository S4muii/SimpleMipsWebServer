from pwn import *
context.log_level = 'debug'
exe = context.binary = ELF('./main')

p = gdb.debug(exe.path, gdbscript= '')

pause()
r = remote('127.0.0.1',5000)

r.interactive()