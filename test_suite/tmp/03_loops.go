package main

import "fmt"

func main() {
	i := 0
	for ; i < 10; i = i + 1 {
		for j := 0; j < 20; j = j + 1 {
			ffi.printf("%d %d, ", i, j)
		}
		ffi.printf("\n")
	}
}
