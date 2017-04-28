package main

func main() {
	i := 0
	for ;i < 10; {
		for j := 0; j < 20; j = j + 1 {
			ffi.printf("%d %d, ", i, j)
		}
		ffi.printf("\n")
		i = i + 1
	}
}
