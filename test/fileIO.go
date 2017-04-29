package main

func main() {
	a := ffi.fopen("abc", "r")
	ffi.printf("here\n")
	b := 0
	ffi.printf("here %d\n", a)
	ffi.fscanf(a, "%d", &b)
	ffi.printf("here\n")
	ffi.printf("%d\n", b)
	ffi.printf("here\n")
}
