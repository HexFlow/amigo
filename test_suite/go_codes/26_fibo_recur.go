package main

import "fmt"

func fibo(a int) int {
	if a == 0 {
		return 1
	}
	if a == 1 {
		return 1
	}
	b := fibo(a - 1)
	c := fibo(a - 2)
	return b + c
}

func main() {
	fmt.Printf("%d\n", fibo(32))
}
