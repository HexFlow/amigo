package main

import "fmt"

var A [100]int

func partition(p int, r int) int {
	fmt.Printf("Partition %d %d\n", p, r)
	x := A[p]
	i := p - 1
	j := r + 1

	for {
		j--
		kk := A[j]
		for kk < x {
			fmt.Printf("J loop yes %d %d\n", A[j], x)
			j--
			kk = A[j]
		}
		i++
		for A[i] > x {
			fmt.Printf("I loop yes %d %d\n", A[i], x)
			i++
		}
		if i < j {
			tmp := A[i]
			A[i] = A[j]
			A[j] = tmp
		} else {
			fmt.Printf("Returning value: %d\n", j)
			return j
		}
	}
	fmt.Printf("Never reach here")
	return -1
}
func qsort(p int, r int) {
	if p < r {
		q := partition(p, r)
		fmt.Printf("Value returned: %d\n", q)
		qsort(p, q)
		qsort(q+1, r)
	}
}

func main() {
	for i := 0; i < 100; i++ {
		n := 0
		fmt.Scanf("%d", &n)
		A[i] = n
	}

	for i := 0; i < 10; i++ {
		for j := 0; j < 10; j++ {
			fmt.Printf("%d ", A[10*i+j])
		}
		fmt.Printf("\n")
	}

	qsort(0, 99)

	for i := 0; i < 10; i++ {
		for j := 0; j < 10; j++ {
			fmt.Printf("%d ", A[10*i+j])
		}
		fmt.Printf("\n")
	}
}
