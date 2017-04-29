package main

import "fmt"

func main() {
	a := 1
	b := 2
	a, b = a+b, a-b
	ffi.printf("%d %d\n", a, b)
}
