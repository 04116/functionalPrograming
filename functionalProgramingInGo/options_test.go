package main

import (
	"testing"
)

type Option map[string]any

type ConfigOption func(opt Option) Option

// example for http server config demo
func SetPort(port int) ConfigOption {
	return func(opt Option) Option {
		opt["port"] = port
		return opt
	}
}

func SetRateLimit(thresh int) ConfigOption {
	return func(opt Option) Option {
		opt["thresh_hold"] = thresh
		return opt
	}
}

func CreateServerConfig(cfgOpts ...ConfigOption) Option {
	opt := Option{"port": 8080}
	for _, cfgOpt := range cfgOpts {
		opt = cfgOpt(opt)
	}
	return opt
}

func TestCreateServerConfig(t *testing.T) {
	opt := CreateServerConfig(SetPort(1111), SetRateLimit(2222))
	if port, ok := opt["port"]; ok {
		if port != 8080 {
			t.Error("Err TestCreateServerConfig", opt)
		}
	}
}
