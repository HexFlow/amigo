package main

import "fmt"

func main() {
	var b [6]int
	b[0] = 7
	b[1] = 5
	b[2] = 9
	b[3] = 2
	b[4] = 6

	for i := 0; i < 5; i = i + 1 {
		for j := 0; j < 4; j = j + 1 {
			if b[j] > b[j+1] {
				c := b[j]
				b[j] = b[j+1]
				b[j+1] = c
			}
		}
	}

	for i := 0; i < 5; i = i + 1 {
		fmt.Printf("%d ", b[i])
	}
	fmt.Printf("\n")
}
