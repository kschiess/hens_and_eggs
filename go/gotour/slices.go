package main

import "fmt"

func main() {
  p := []int{1,2,3,4,5,6}
  
  fmt.Println("p ==", p)
  fmt.Println("p[1:4] ==", p[1:4])

  // missing low index implies 0
  fmt.Println("p[:3] ==", p[:3])

  // missing high index implies len(s)
  fmt.Println("p[4:] ==", p[4:])

  // This panics: nice stack traces!
  // for i:=0; i<len(p)+1; i++ {
  //   fmt.Println(p[i])
  // } 
  
  v := new([10]int)
  fmt.Println(v)
}