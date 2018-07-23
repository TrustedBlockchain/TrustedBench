/**
* Copyright 2017 HUAWEI. All Rights Reserved.
*
* SPDX-License-Identifier: Apache-2.0
*
 */

package main

import (
	"fmt"
	"strconv"

	"github.com/zhigui/zigledger/bccsp"
	"github.com/zhigui/zigledger/bccsp/factory"
	"github.com/zhigui/zigledger/core/chaincode/shim"
	"github.com/zhigui/zigledger/core/chaincode/shim/ext/entities"
	pb "github.com/zhigui/zigledger/protos/peer"
)

const ERROR_SYSTEM = "{\"code\":300, \"reason\": \"system error: %s\"}"
const ERROR_WRONG_FORMAT = "{\"code\":301, \"reason\": \"command format is wrong\"}"
const ERROR_ACCOUNT_EXISTING = "{\"code\":302, \"reason\": \"account already exists\"}"
const ERROR_ACCOUT_ABNORMAL = "{\"code\":303, \"reason\": \"abnormal account\"}"
const ERROR_MONEY_NOT_ENOUGH = "{\"code\":304, \"reason\": \"account's money is not enough\"}"

const DEFAULT_KEY = "zigledger"

type SimpleChaincode struct {
}

func (t *SimpleChaincode) Init(stub shim.ChaincodeStubInterface) pb.Response {
	// nothing to do
	return shim.Success(nil)
}

func (t *SimpleChaincode) Invoke(stub shim.ChaincodeStubInterface) pb.Response {
	function, args := stub.GetFunctionAndParameters()
	fmt.Println(">>> The function is " + function)
	if function == "open" {
		return t.Open(stub, args)
	}
	if function == "delete" {
		return t.Delete(stub, args)
	}
	if function == "query" {
		return t.Query(stub, args)
	}
	if function == "transfer" {
		return t.Transfer(stub, args)
	}

	if function == "putPrivateData" {
		return t.PutPrivateData(stub, args)
	}

	if function == "getPrivateData" {
		return t.GetPrivateData(stub, args)
	}

	return shim.Error(ERROR_WRONG_FORMAT)
}

// open an account, should be [open account money]
func (t *SimpleChaincode) Open(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	if len(args) != 2 {
		return shim.Error(ERROR_WRONG_FORMAT)
	}

	account := args[0]
	money, err := stub.GetState(account)
	if money != nil {
		return shim.Error(ERROR_ACCOUNT_EXISTING)
	}

	_, err = strconv.Atoi(args[1])
	if err != nil {
		return shim.Error(ERROR_WRONG_FORMAT)
	}

	err = stub.PutState(account, []byte(args[1]))
	if err != nil {
		s := fmt.Sprintf(ERROR_SYSTEM, err.Error())
		return shim.Error(s)
	}

	return shim.Success(nil)
}

// delete an account, should be [delete account]
func (t *SimpleChaincode) Delete(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	if len(args) != 1 {
		return shim.Error(ERROR_WRONG_FORMAT)
	}

	err := stub.DelState(args[0])
	if err != nil {
		s := fmt.Sprintf(ERROR_SYSTEM, err.Error())
		return shim.Error(s)
	}

	return shim.Success(nil)
}

// query current money of the account,should be [query accout]
func (t *SimpleChaincode) Query(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	if len(args) != 1 {
		return shim.Error(ERROR_WRONG_FORMAT)
	}

	if args[0] == "getPrivateData" {
		fmt.Println(">>> The first argument is getPrivateData")
		return t.GetPrivateData(stub, args)
	}
	money, err := stub.GetState(args[0])
	if err != nil {
		s := fmt.Sprintf(ERROR_SYSTEM, err.Error())
		return shim.Error(s)
	}

	if money == nil {
		// return shim.Error(ERROR_ACCOUT_ABNORMAL)
		return shim.Success([]byte("0"))
	}

	return shim.Success(money)
}

// transfer money from account1 to account2, should be [transfer accout1 accout2 money]
func (t *SimpleChaincode) Transfer(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	if len(args) != 3 {
		return shim.Error(ERROR_WRONG_FORMAT)
	}
	money, err := strconv.Atoi(args[1])
	if err != nil {
		return shim.Error(ERROR_WRONG_FORMAT)
	}

	moneyBytes1, err1 := stub.GetState(args[0])
	moneyBytes2, err2 := stub.GetState(args[0])
	if err1 != nil || err2 != nil {
		s := fmt.Sprintf(ERROR_SYSTEM, err.Error())
		return shim.Error(s)
	}
	if moneyBytes1 == nil || moneyBytes2 == nil {
		return shim.Error(ERROR_ACCOUT_ABNORMAL)
	}

	money1, _ := strconv.Atoi(string(moneyBytes1))
	money2, _ := strconv.Atoi(string(moneyBytes1))
	if money1 < money {
		return shim.Error(ERROR_MONEY_NOT_ENOUGH)
	}

	money1 -= money
	money2 += money

	err = stub.PutState(args[0], []byte(strconv.Itoa(money1)))
	if err != nil {
		s := fmt.Sprintf(ERROR_SYSTEM, err.Error())
		return shim.Error(s)
	}

	err = stub.PutState(args[1], []byte(strconv.Itoa(money2)))
	if err != nil {
		stub.PutState(args[0], []byte(strconv.Itoa(money1+money)))
		s := fmt.Sprintf(ERROR_SYSTEM, err.Error())
		return shim.Error(s)
	}

	return shim.Success(nil)
}

func (t *SimpleChaincode) PutPrivateData(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	Encrypter(stub, DEFAULT_KEY, []byte("simpletest"))
	return shim.Success(nil)
}

func (t *SimpleChaincode) GetPrivateData(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	value, err := Decrypter(stub, DEFAULT_KEY)
	if err != nil {
		s := fmt.Sprintf(ERROR_SYSTEM, err.Error())
		return shim.Error(s)
	}
	return shim.Success(value)
}

func getStateAndDecrypt(stub shim.ChaincodeStubInterface, ent entities.Encrypter, key string) ([]byte, error) {
	// at first we retrieve the ciphertext from the ledger
	ciphertext, err := stub.GetState(key)
	if err != nil {
		fmt.Println("The get error is ", err)
		return nil, err
	}
	fmt.Println(">>> The ciphertext from state is " + string(ciphertext))
	if len(ciphertext) == 0 {
		return nil, fmt.Errorf("no ciphertext to decrypt")
	}

	return ent.Decrypt(ciphertext)
}

func encryptAndPutState(stub shim.ChaincodeStubInterface, ent entities.Encrypter, key string, value []byte) error {
	ciphertext, err := ent.Encrypt(value)
	if err != nil {
		fmt.Println("The  encrpt error is ", err)
		return err
	}
	fmt.Println(">>> The ciphertext to be putted is " + string(ciphertext))
	return stub.PutState(key, ciphertext)
}

type EncCC struct {
	bccspInst bccsp.BCCSP
}

// Encrypter encrypts the data and writes to the ledger
func Encrypter(stub shim.ChaincodeStubInterface, key string, valueAsBytes []byte) error {
	factory.InitFactories(nil)
	encCC := EncCC{factory.GetDefault()}
	encKey := make([]byte, 32)
	iv := make([]byte, 16)
	ent, err := entities.NewAES256EncrypterEntity("ID", encCC.bccspInst, encKey, iv)
	if err != nil {
		return err
	}

	return encryptAndPutState(stub, ent, key, valueAsBytes)
}

// Decrypter decrypts the data and writes to the ledger
func Decrypter(stub shim.ChaincodeStubInterface, key string) ([]byte, error) {
	factory.InitFactories(nil)
	encCC := EncCC{factory.GetDefault()}
	decKey := make([]byte, 32)
	iv := make([]byte, 16)
	ent, err := entities.NewAES256EncrypterEntity("ID", encCC.bccspInst, decKey, iv)
	if err != nil {
		return nil, err
	}

	return getStateAndDecrypt(stub, ent, key)
}

func main() {
	err := shim.Start(new(SimpleChaincode))
	if err != nil {
		fmt.Printf("Error starting chaincode: %v \n", err)
	}

}
