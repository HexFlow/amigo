package main

import "fmt"

func main() {
	//var b [5][2]int
	//b[2][1] = 3
	//c := b[2][1]

	var b [5]int
	var c int

	for i := 0; i < 5; i = i + 1 {
		b[i] = i
		c = b[i]
		ffi.printf("%d\n", c)
	}
}
