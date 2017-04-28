package main

import "fmt"

func factorial(a int) int {
	if a == 0 {
		return 1
	}
	return a + factorial(a-1)
}

func main() {
	fmt.Printf("%d\n", factorial(10))
}
