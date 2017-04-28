package main

import "fmt"

func getVal2(a int) int {
	return 10 + a
}

func getVal() int {
	return 8 + getVal2(17)
}

func main() {
	fmt.Printf("%d\n", getVal())
}
