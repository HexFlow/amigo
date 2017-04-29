package main

import "fmt"

func main() {
	var a [4][4]int
	var b [4][4]int
	var res [4][4]int

	c := 0
	for i := 0; i < 4; i++ {
		for j := 0; j < 4; j++ {
			fmt.Scanf("%d", &c)
			a[i][j] = c
		}
	}

	for i := 0; i < 4; i++ {
		for j := 0; j < 4; j++ {
			fmt.Scanf("%d", &c)
			b[i][j] = c
		}
	}

	for i := 0; i < 4; i++ {
		for j := 0; j < 4; j++ {
			c = 0
			for k := 0; k < 4; k++ {
				d := a[i][k]
				e := b[k][j]
				c += d * e
			}
			res[i][j] = c
		}
	}

	for i := 0; i < 4; i++ {
		for j := 0; j < 4; j++ {
			fmt.Printf("%d ", res[i][j])
		}
		fmt.Printf("\n")
	}
}
