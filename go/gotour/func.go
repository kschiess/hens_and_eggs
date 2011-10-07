package main

import "fmt"

func main() {
  a := 1
  printFunc := func () {
    var b int = a+1
    fmt.Println(a)
    fmt.Println(b)
  }
  
  a = 2
  printFunc()
}