package main

import (
	"errors"
	"testing"
)

// problem
// - buy something, need to pay, change CreditCard balance
// - want function do not direct change CreditCard
// solution
// - let caller charge, we just validate
// ////////////////////////////////////////////////////////////////////////////
type Book struct {
	Price int
}

func NewBook(price int) Book {
	return Book{Price: price}
}

type CreditCard struct {
	Credit int
}

func NewCreditCard(init int) CreditCard {
	return CreditCard{Credit: init}
}

type CreditError error

var NotEnoughCreditErr = CreditError(errors.New("not enough credit"))

type (
	ChargeFunc func(CreditCard, int) (CreditCard, error)
	CreditFunc func() (CreditCard, CreditError)
)

func BuyBook(card CreditCard, pay ChargeFunc) (Book, CreditFunc) {
	book := NewBook(100)
	creditFunc := func() (CreditCard, CreditError) {
		return pay(card, book.Price)
	}
	return book, creditFunc
}

// ////////////////////////////////////////////////////////////////////////////
type tc struct {
	name string
	card CreditCard
	err  error
}

func newTestcases() []tc {
	return []tc{
		{
			name: "card not enough credit can not buy",
			card: NewCreditCard(10),
			err:  NotEnoughCreditErr,
		},
		{
			name: "card enough credit can buy",
			card: NewCreditCard(200),
			err:  nil,
		},
	}
}

// ////////////////////////////////////////////////////////////////////////////
// charge in-mem, in real-world, can be call api gateway
func Charge(card CreditCard, amount int) (CreditCard, error) {
	if card.Credit < amount {
		return card, NotEnoughCreditErr
	}
	card.Credit -= amount
	return card, nil
}

func TestBuyBook(t *testing.T) {
	tcs := newTestcases()
	for _, tc := range tcs {
		_, fun := BuyBook(tc.card, Charge)
		_, err := fun()
		if err != tc.err {
			t.Error("ERR testcase:", tc.name, err)
		}
	}
}

type chargeMock struct {
	called bool
	charge func(CreditCard, int) (CreditCard, error)
}

func newChargeMock() *chargeMock {
	mock := &chargeMock{}
	mock.charge = func(card CreditCard, _ int) (CreditCard, error) {
		mock.called = true
		return card, nil
	}

	return mock
}

func TestBuyBookMockCharge(t *testing.T) {
	tcs := newTestcases()
	for _, tc := range tcs {
		mock := newChargeMock()
		_, fun := BuyBook(tc.card, mock.charge)
		_, _ = fun()
		if !mock.called {
			t.Error("ERR mock testcase:", tc.name)
		}
	}
}
