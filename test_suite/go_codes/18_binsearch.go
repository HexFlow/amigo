package main

import "fmt"

func main() {
	n := 5
	var a [5]int
	var c int
	for i := 0; i < n; i++ {
		fmt.Scanf("%d", &c)
		a[i] = c
	}

	start := 0
	end := n - 1
	key := 8

	for start <= end {
		fmt.Printf("S %d, E %d\n", start, end)
		m := start + (end-start)/2
		fmt.Printf("m is %d\n", m)
		if a[m] == key {
			fmt.Printf("Found at %d\n", m)
		}

		if a[m] < key {
			start = m + 1
		} else {
			end = m - 1
		}
	}
}
