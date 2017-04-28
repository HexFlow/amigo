package main

import "fmt"

func getVal() int {
	return 8
}

func main() {
	ffi.printf("%d\n", getVal())
}
