package main

import (
	"testing"
)

type People struct {
	name string
	age  int
}

func setNameImMut(p People, name string) People {
	p.name = name
	return p
}

func setAgeImMut(p People, age int) People {
	p.age = age
	return p
}

func createPeopleImMut() People {
	p := People{}
	p = setNameImMut(p, "name")
	p = setAgeImMut(p, 20)
	return p
}

func setNameMut(p *People, name string) {
	p.name = name
}

func setAgeMut(p *People, age int) {
	p.age = age
}

func createPeopleMut() People {
	p := People{}
	setNameMut(&p, "name")
	setAgeMut(&p, 20)
	return p
}

func BenchmarkCreatePeopleImMut(t *testing.B) {
	for n := 0; n < t.N; n++ {
		createPeopleImMut()
	}
}

func BenchmarkCreatePeopleMut(t *testing.B) {
	for n := 0; n < t.N; n++ {
		createPeopleMut()
	}
}
