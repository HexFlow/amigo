package main

import "fmt"

func main() {
	var b [5][5]int
	var c int
	//var b [5]int

	//b[2][1] = 3
	//c := b[2][1]

	for i := 0; i < 5; i = i + 1 {
		for j := 0; j < 5; j = j + 1 {
			b[i][j] = i + j
			ffi.printf("%d ", b[i][j])
		}
		ffi.printf("\n")
		//b[0][i] = i
		//c = b[0][i]
		//ffi.printf("%d %d\n", b[0][i], c+2)
	}
}
