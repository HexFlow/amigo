package main

import "fmt"

func main() {
	a := 4
	if a <= 10 {
		if a <= 5 {
			fmt.Printf("A is <= 5\n")
		} else {
			fmt.Printf("A is >= 5\n")
		}
	} else {
		fmt.Printf("A is non <= 10\n")
	}
}
