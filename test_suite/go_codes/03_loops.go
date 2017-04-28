package main

import "fmt"

func main() {
	i := 0
	for ; i < 10; i++ {
		for j := 0; j < 20; j += 1 {
			fmt.Printf("%d %d, ", i, j)
		}
		continue
		fmt.Printf("\n")
	}
}
