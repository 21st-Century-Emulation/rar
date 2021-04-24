package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

type CpuFlags struct {
	Sign     bool `json:"sign"`
	Zero     bool `json:"zero"`
	AuxCarry bool `json:"auxCarry"`
	Parity   bool `json:"parity"`
	Carry    bool `json:"carry"`
}

type CpuState struct {
	A              uint8    `json:"a"`
	B              uint8    `json:"b"`
	C              uint8    `json:"c"`
	D              uint8    `json:"d"`
	E              uint8    `json:"e"`
	H              uint8    `json:"h"`
	L              uint8    `json:"l"`
	Flags          CpuFlags `json:"flags"`
	ProgramCounter uint16   `json:"programCounter"`
	StackPointer   uint16   `json:"stackPointer"`
	Cycles         uint64   `json:"cycles"`
}

type Cpu struct {
	Opcode uint8    `json:"opcode"`
	Id     string   `json:"id"`
	State  CpuState `json:"state"`
}

func rar(w http.ResponseWriter, r *http.Request) {
	var cpu Cpu
	body, _ := io.ReadAll(r.Body)
	r.Body.Close()
	json.Unmarshal(body, &cpu)

	var highBit = uint8(0)
	if cpu.State.Flags.Carry {
		highBit = 0b1000_0000
	}
	cpu.State.Flags.Carry = (cpu.State.A & 0b0000_0001) != 0
	cpu.State.A = (cpu.State.A >> 1) | highBit
	cpu.State.Cycles += 4

	w.Header().Set("Content-Type", "application/json; charset=UTF-8")
	w.WriteHeader(http.StatusOK)
	cpuString, _ := json.Marshal(cpu)
	w.Write(cpuString)
}

func main() {
	http.HandleFunc("/api/v1/execute", rar)
	http.HandleFunc("/status", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Healthy")
	})
	http.ListenAndServe(":8080", nil)
}
