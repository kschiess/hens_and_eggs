package main

import "fmt"

func counter() func() int {
  i := 0
  return func() int {
    i += 1
    return i
  }
}

func main() {
  a := counter()
  b := counter()
  
  a()
  a()
  fmt.Println(a())
  fmt.Println(b())
}