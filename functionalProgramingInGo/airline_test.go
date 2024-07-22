package main

import (
	"encoding/json"
	"os"
	"testing"
)

// total hour delayed for Seattle airport (code: SEA)
type Entry struct {
	Airport struct {
		Code string `json:"Code"`
		Name string `json:"Name"`
	} `json:"Airport"`
	Statistics struct {
		MinutesDelayed struct {
			Total int `json:"Total"`
		} `json:"Minutes Delayed"`
	} `json:"Statistics"`
}

type filter[T any] func(t T) bool

func Filter[T any](entries []T, f filter[T]) []T {
	out := []T{}
	for _, entry := range entries {
		if f(entry) {
			out = append(out, entry)
		}
	}

	return out
}

type trans[S any, D any] func(s S) D

func Map[S any, D any](entries []S, f trans[S, D]) []D {
	out := make([]D, len(entries))
	for idx, entry := range entries {
		out[idx] = f(entry)
	}
	return out
}

type Sumable interface {
	// TODO: define full types
	~int | ~uint
}
type reduce[A any] func(a, b A) A

func Reduce[T any](entries []T, f reduce[T]) T {
	out := *new(T)
	for _, entry := range entries {
		out = f(out, entry)
	}

	return out
}

func getData() []Entry {
	// full file at https://github.com/PacktPublishing/Functional-Programming-in-Go./blob/main/Chapter6/resources/airlines.json
	f, err := os.Open("./sample.json")
	if err != nil {
		panic(err)
	}
	data := []Entry{}
	if err = json.NewDecoder(f).Decode(&data); err != nil {
		panic(err)
	}
	return data
}

// fillter all airport with code name
// reduce them by sum function
func TestGetTotalHourDelayed(t *testing.T) {
	data := getData()
	filtered := Filter(data, func(t Entry) bool {
		return t.Airport.Code == "SEA"
	})
	totals := Map(filtered, func(s Entry) int {
		return s.Statistics.MinutesDelayed.Total
	})

	final := Reduce(totals, func(a, b int) int {
		return a + b
	})

	println(len(data), final)
}
