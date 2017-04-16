package main

func main(a, c bool, b int) int {
	var i, j, tyu int
	//j, t := 1-67+"hello", 2+34
	i, j = j+56/34, i
	var m, n = 1/4 + 5/6, 3.0
	var k [9034]int
	var lop struct {
		a int
		b struct {
			qwe bool
			swd bool
		}
	}

	//var a int
	var b int
	var a int

	// 5 types of IfStmt for each rule
	if a == b {
		b = 7
	}

	if b = 2; a == 2 {
		b = 7
	}

	if 1 == 2 {
		b = 7
	} else {
		b = 9
	}

	if b = 2; 1 == 2 {
		b = 7
	} else if 3 == 3 {
		b = 10
	}

	if b = 2; 1 == 2 {
		b = 7
	} else {
		b = 10
	}

	// 4 types of ForStmt
	for {
		b = 2
	}

	for 1 == 1 {
		b = 9
	}

	for b := 2; b < 2; b = b + 1 {
		b = 111
	}

	for a, b := range 2 {
		b = 123
	}

	b = make(int)
	b = fmt.Hello
	c := make(map[int]int)
}

//func someotherfunc(a int) (bool, int, string) {
//return true, 5, "hello"
//}
