package main

import "fmt"

func ackermann(m int, n int) int {
	if m == 0 {
		return n + 1
	}

	if n == 0 {
		return ackermann(m-1, 1)
	}

	c := ackermann(m, n-1)
	return ackermann(m-1, c)
}

func main() {
	fmt.Printf("%d\n", ackermann(3, 4))
}
