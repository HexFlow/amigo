package main

func main() {
	i := 10
	ffi.scanf("%d", (&i))
	ffi.printf("%d\n", i)
}
