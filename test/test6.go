package main

import "fmt"

func main() {
	a := struct{}{}
	fmt.Println(a)
	if i := 0; i < 7 {
		i := 9
		fmt.Println(i)
	}
}
