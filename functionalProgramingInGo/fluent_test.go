package main

import (
	"testing"
)

// input.Filter(filterFunc).Map(transFunc).Reduce(reduceFunc)
type EntryList []Entry

func (l EntryList) Filter(f filter[Entry]) EntryList {
	return Filter[Entry](l, f)
}

type Ints []int

func (l EntryList) Map(f trans[Entry, int]) Ints {
	return Map[Entry, int](l, f)
}

func (l Ints) Reduce(f reduce[int]) int {
	return Reduce[int](l, f)
}

func TestFluentStyle(t *testing.T) {
	sum := EntryList(getData()).Filter(func(t Entry) bool {
		return t.Airport.Code == "SEA"
	}).Map(func(s Entry) int {
		return s.Statistics.MinutesDelayed.Total
	}).Reduce(func(a, b int) int {
		return a + b
	})

	if sum != 100 {
		t.Error("Err TestFluentStyle", sum)
	}
}
