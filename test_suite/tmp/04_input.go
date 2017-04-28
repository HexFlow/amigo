package main

import "fmt"

func main() {
	a := 0
	ffi.scanf("%d", &a)
	ffi.printf("%d\n", a+10)
}
