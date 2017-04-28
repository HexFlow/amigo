package main

import "fmt"

var A [100]int

func partition(low int, high int) {
	x := A[low]
	i := p - 1
	j := r + 1

	for true; true; {

	}
}
func qsort(low int, high int) {
	if low < high {
		q := partition(p, r)
		qsort(p, q)
		qsort(q+1, r)
	}
}

func main() {
	for i := 0; i < 100; i++ {
		i := 0
		fmt.Scanf("%d", &i)
	}

	qsort(0, 100)

	for i := 0; i < 10; i++ {
		for j := 0; j < 10; j++ {
			fmt.Printf("%d ", A[10*i+j])
		}
		fmt.Printf("\n")
	}
}
