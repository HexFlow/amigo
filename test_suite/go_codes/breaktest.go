package main

import "fmt"

func main() {
	i := 0
	for i < 12 {
		i = i + 1
		if i < 5 {
			continue
		}
		fmt.Printf("%d\n", i)
		if i > 10 {
			break
		}
	}
}
