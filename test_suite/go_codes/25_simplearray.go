package main

import "fmt"

func main() {
	var b [5][5]int

	for i := 0; i < 5; i = i + 1 {
		for j := 0; j < 5; j = j + 1 {
			b[i][j] = i + j
			fmt.Printf("%d ", b[i][j])
		}
		fmt.Printf("\n")
	}
}
