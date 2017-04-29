package main

import "fmt"

func getValues() (int, int) {
	a := 9
	b := 8
	return 45, (56 - a - b)
}

func main() {
	a, b := getValues()
	fmt.Printf("%d %d\n", a, b)
}
