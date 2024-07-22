package main

import (
	"testing"
)

type node struct {
	value int
	left  *node
	right *node
}

func buildTree() *node {
	return &node{
		value: 1,
		left: &node{
			value: 2,
			left: &node{
				value: 3,
			},
			right: &node{
				value: 4,
			},
		},
		right: &node{
			value: 5,
		},
	}
}

func interativeSum(root *node) int {
	// use channel as a queue
	queue := make(chan *node, 10)

	queue <- root
	sum := 0
	for {
		select {
		case n := <-queue:
			sum += n.value
			if n.left != nil {
				queue <- n.left
			}
			if n.right != nil {
				queue <- n.right
			}
		default:
			return sum
		}
	}
}

func recursionSum(root *node) int {
	if root == nil {
		return 0
	}
	return root.value + recursionSum(root.left) + recursionSum(root.right)
}

func TestSum(t *testing.T) {
	tree := buildTree()
	sumInt := interativeSum(tree)
	if sumInt != 15 {
		t.Error("Err sumInt", sumInt)
	}

	sumRec := recursionSum(tree)
	if sumRec != 15 {
		t.Error("Err sumRec", sumRec)
	}
}

func max(root *node) int {
	var inner func(*node)

	maxVal := 0
	inner = func(n *node) {
		// stop condition
		if n == nil {
			return
		}

		if n.value > maxVal {
			maxVal = n.value
		}
		// recursion
		inner(n.left)
		inner(n.right)
	}

	inner(root)
	return maxVal
}

func TestMax(t *testing.T) {
	val := max(buildTree())
	if val != 5 {
		t.Error("Err max", val)
	}
}

func interativeFact(n int) int {
	ret := 1
	for i := 2; i < n; i++ {
		ret = ret * i
	}
	return ret
}

func recursionFact(n int) int {
	if n <= 1 {
		return 1
	}

	return n * recursionFact(n-1)
}

func TestFact(t *testing.T) {
	ret := interativeFact(10)
	if ret != 100 {
		t.Error("Err interativeFact", ret)
	}

	ret = recursionFact(10)
	if ret != 100 {
		t.Error("Err recursionFact", ret)
	}
}

func BenchmarkInterativeFact(t *testing.B) {
	for i := 0; i < t.N; i++ {
		interativeFact(10)
	}
}

func BenchmarkRecursionFact(t *testing.B) {
	for i := 0; i < t.N; i++ {
		recursionFact(10)
	}
}
