package main

import (
	"io"
	"os"
	"sync"
	"testing"
)

/*
* input: [<city: string, val: float>]
* output: [<city: string, min, mean, max: float>]
 */

/*
* solution: map, reduce
* read lines, send to workers, combine workers result
 */

// core
var (
	readBufSize = 64 * 1024 * 1024
	workers     = 8
	batchSize   = 100
)

type inpRec struct {
	city string
	val  int
}

type outRec struct {
	city  string
	min   int
	max   int
	count int
	sum   int
}

func mbrc(path string) (map[string]outRec, error) {
	f, err := os.Open(path)
	if err != nil {
		return nil, err
	}

	// start reduce
	finalOuts := make(chan map[string]outRec)
	tmpOutc := make(chan map[string]outRec, workers)
	go func() {
		outs := map[string]outRec{}
		for out := range tmpOutc {
			for city, out := range out {
				finalOut, found := outs[city]
				if !found {
					outs[city] = out
					continue
				}

				if finalOut.max < out.max {
					finalOut.max = out.max
				}
				if finalOut.min < out.min {
					finalOut.min = out.min
				}

				finalOut.sum += out.sum
				finalOut.count += out.count
			}
		}

		finalOuts <- outs
	}()

	// start map
	wrkWg := sync.WaitGroup{}
	inpsc := make(chan []inpRec, workers)
	for i := 0; i < workers; i++ {
		wrkWg.Add(1)
		go func() {
			defer wrkWg.Done()

			// this not ensure even distribute of inps to goroutines
			// here, distribution depend on internal golang runtime (embedded in compiled file)
			//
			// it's ok, cause we don't care about evenly now
			// if we need even distribution, we can do
			// for _, workerChan := range sliceOfWorkerChans {
			//     workerChan <- inps
			// }
			for inps := range inpsc {
				tmps := map[string]outRec{}
				for _, inpRec := range inps {
					tmp, found := tmps[inpRec.city]
					if !found {
						tmps[inpRec.city] = outRec{
							city: inpRec.city,
							min:  inpRec.val, max: inpRec.val,
							count: 1,
							sum:   inpRec.val,
						}
						continue
					}

					if tmp.max < inpRec.val {
						tmp.max = inpRec.val
					}
					if tmp.min > inpRec.val {
						tmp.min = inpRec.val
					}
					tmp.count += 1
					tmp.sum += inpRec.val
				}

				tmpOutc <- tmps
			}
		}()
	}

	// read into batch of lines, send to worker
	readBuf := make([]byte, readBufSize)
	var procBuf []byte

	curBatchSize := 0
	inpBatch := make([]inpRec, batchSize)
	for {
		count, err := f.Read(readBuf)
		if err != nil {
			if err == io.EOF {
				break
			}
			return nil, err
		}

		prvIdx := 0
		tmpIp := inpRec{}
		procBuf = append(procBuf, readBuf[:count]...)
		for i := 0; i < len(procBuf); i++ {
			switch procBuf[i] {
			// procBuf: hanoi;12,5\nhochiminh;15,6\n
			case ';':
				tmpIp.city = string(procBuf[prvIdx:i])
				prvIdx = i + 1
			case '\n':
				tmpIp.val = floatToInt(string(procBuf[prvIdx:i]))
				prvIdx = i + 1

				inpBatch[curBatchSize] = tmpIp
				curBatchSize += 1
				if curBatchSize >= batchSize {
					inpsc <- append([]inpRec{}, inpBatch...)
					curBatchSize = 0
				}
			}
		}
		// remain not yet process
		if prvIdx < len(procBuf)-1 {
			procBuf = procBuf[prvIdx:]
		}
	}
	// it safe to close channel at write side here
	// at read side (map workers) they still can read remain messages
	close(inpsc)
	// wait map workers done
	wrkWg.Wait()
	// after map worker done, no one write to tmpOutc, it safe to close it now
	close(tmpOutc)

	return <-finalOuts, nil
}

// input: string containing signed number in the range [-99.9, 99.9]
// output: signed int in the range [-999, 999]
func floatToInt(fStr string) int {
	isNeg := false
	if fStr[0] == '-' {
		isNeg = true
		fStr = fStr[1:]
	}

	var out int
	switch len(fStr) {
	// 9.9
	case 3:
		// to get int from character, subtract it for '0'
		out = int(fStr[0]-'0')*10 + int(fStr[2]-'0')
	// 99.9
	case 4:
		out = int(fStr[0]-'0')*100 + int(fStr[1]-'0')*10 + int(fStr[3]-'0')
	}

	if isNeg {
		return -out
	}
	return out
}

func Test1brc(t *testing.T) {
	// outPath := os.Getenv("1BRC_OUTPATH")
	// outFile, err := os.Open(outPath)
	// if err != nil {
	// 	t.Error(err)
	// }
	// expectedOut, err := io.ReadAll(outFile)
	// if err != nil {
	// 	t.Error(err)
	// }
	//
	// // {id1=1.0/1.0/1.0, id10=1.0/1.0/1.0}
	//  for

	inpPath := os.Getenv("1BRC_INPPATH")
	_, err := mbrc(inpPath)
	if err != nil {
		t.Error(err)
	}
	// println(actualOut)
}
