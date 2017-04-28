package main

func main() {
	var a int
	a = ffi.rand()
	ffi.printf("%d\n", a)
	a = ffi.rand()
	ffi.printf("%d\n", a)
	a = ffi.rand()
	ffi.printf("%d\n", a)
}
