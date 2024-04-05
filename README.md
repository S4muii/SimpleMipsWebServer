# SimpleMipsWebServer

To install the required packages . assuming you're on Linux and a distro that uses `apt` 
```shell
sudo apt install gcc-mips-linux-gnu binutils-mips-linux-gnu qemu-user qemu-user-static
```

To run the server
```shell
make && qemu-mips ./main
```

To debug the server
```shell
make && qemu-mips -g 1234 ./main
gdb-multiarch --ex 'target remote :1234' --ex 'file ./main'
```
or if you're using GEF you can 
```shell
gdb-multiarch --ex 'gef-remote --qemu-user --qemu-binary ./main 127.0.0.1 1234'
```