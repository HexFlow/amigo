package main

func main() {
	a := 6
	if a <= 10 {
		if a <= 5 {
			ffi.printf("A is <= 5\n")
		} else {
			ffi.printf("A is >= 5\n")
		}
	} else {
		ffi.printf("A is non <= 10\n")
	}
}
