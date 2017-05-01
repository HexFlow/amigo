package main

func getVal(a int) int {
	return a
}

func main() {
	i := getVal(90)
	ffi.printf("%d\n", i)
}
