/*
Copyright Zhigui.com. All Rights Reserved.

SPDX-License-Identifier: Apache-2.0
*/

package main

import (
	"encoding/json"
	"fmt"
	"math/big"
	"strings"

	"github.com/zhigui/zigledger/core/chaincode/shim"
	pb "github.com/zhigui/zigledger/protos/peer"
	"time"
	"strconv"
	"bytes"
)

const (
	//func name
	GetBalance                    string = "getBalance"
	GetAccount                    string = "getAccount"
	Transfer                      string = "transfer"
	Sender                        string = "sender"
	CalcFee                       string = "calcFee"
	GetAccountHistory             string = "getAccountHistory"
	GetStateByPartialCompositeKey string = "getStateByPartialCompositeKey"
)

// User chaincode for token operations
// After a token issued, users can use this chaincode to make query or transfer operations.
type tokenChaincode struct {
}

// Init func
func (t *tokenChaincode) Init(stub shim.ChaincodeStubInterface) pb.Response {
	fmt.Println("token user chaincode Init.")
	return shim.Success([]byte("Init success."))
}

// Invoke func
func (t *tokenChaincode) Invoke(stub shim.ChaincodeStubInterface) pb.Response {
	fmt.Println("token user chaincode Invoke")
	function, args := stub.GetFunctionAndParameters()

	switch function {
	case GetBalance:
		if len(args) != 2 {
			return shim.Error("Incorrect number of arguments. Expecting 2.")
		}
		return t.getBalance(stub, args)

	case GetAccount:
		if len(args) != 1 {
			return shim.Error("Incorrect number of arguments. Expecting 1.")
		}
		return t.getAccount(stub, args)

	case Transfer:
		if len(args) != 3 {
			return shim.Error("Incorrect number of arguments. Expecting 3")
		}
		return t.transfer(stub, args)

	case Sender:
		sender, err := stub.GetSender()
		if err != nil {
			return shim.Error("Get sender failed.")
		}
		return shim.Success([]byte(sender))

	case CalcFee:
		if len(args) != 1 {
			return shim.Error("Incorrect number of arguments. Expecting 1")
		}
		return t.calcFee(stub, args)

	case GetAccountHistory:
		if len(args) != 1 {
			return shim.Error("Incorrect number of arguments. Expecting 1")
		}
		return t.getAccountHistory(stub, args)
	case GetStateByPartialCompositeKey:
		return t.getStateByPartialCompositeKey(stub, args)
	}

	return shim.Error("Invalid invoke function name. Expecting \"getBalance\", \"getAccount\", \"transfer\", \"sender\", \"calcFee\".")
}

// getBalance
// Get the balance of a specific token type in an account
func (t *tokenChaincode) getBalance(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var A string           // Address
	var BalanceType string // Token type
	var err error

	A = strings.ToLower(args[0])
	BalanceType = args[1]
	// Get the state from the ledger
	account, err := stub.GetAccount(A)
	if err != nil {
		return shim.Error("account does not exists")
	}

	if account == nil || account.Balance[BalanceType] == nil {
		return shim.Error("Nil amount for " + A)
	}
	result := make(map[string]string)
	result[BalanceType] = account.Balance[BalanceType].String()
	balanceJson, jsonErr := json.Marshal(result)
	if jsonErr != nil {
		return shim.Error(jsonErr.Error())
	}
	return shim.Success([]byte(balanceJson))
}

// getAccount
// Get the balances of all token types in an account
func (t *tokenChaincode) getAccount(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var A string // Address
	var err error

	A = strings.ToLower(args[0])
	// Get the state from the ledger
	account, err := stub.GetAccount(A)
	if err != nil {
		return shim.Error("account does not exists")
	}

	if account == nil {
		return shim.Error("Nil amount for " + A)
	}
	result := make(map[string]string)
	for key, value := range account.Balance {
		result[key] = value.String()
	}
	balanceJson, jsonErr := json.Marshal(result)
	if jsonErr != nil {
		return shim.Error(jsonErr.Error())
	}
	return shim.Success([]byte(balanceJson))
}

// transfer
// Send tokens to the specified address
func (t *tokenChaincode) transfer(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var B string           // To address
	var BalanceType string // Token type
	var err error

	B = strings.ToLower(args[0])
	BalanceType = args[1]

	// Amount
	amount := big.NewInt(0)
	_, good := amount.SetString(args[2], 10)
	if !good {
		return shim.Error("Expecting integer value for amount")
	}
	err = stub.Transfer(B, BalanceType, amount)
	if err != nil {
		return shim.Error("transfer error" + err.Error())
	}
	sender, err := stub.GetSender()
	if err != nil {
		return shim.Error("Get sender failed.")
	}
	txTimestamp, err := stub.GetTxTimestamp()
	if err != nil {
		return shim.Error("GetTxTimestamp failed")
	}

	//send_address ~ to_address ~ token_type ~ amount ~ tx_time ~ tx_id
	err = t.historyByComposite(stub, "accountHistory", []string{sender, B, BalanceType,
		args[2], strconv.FormatInt(txTimestamp.GetSeconds(), 10), stub.GetTxID()})
	if err != nil {
		return shim.Error(err.Error())
	}

	return shim.Success(nil)
}

func (t *tokenChaincode) calcFee(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	fee, err := stub.CalcFee(string(args[0]))
	if err != nil {
		return shim.Error("Query fee failed.")
	}
	res := map[string]interface{}{
		"fee": fee,
	}
	resJson, err := json.Marshal(res)
	if err != nil {
		return shim.Error(err.Error())
	}
	return shim.Success(resJson)
}

// getAccountHistory returns a history of key values across time.
func (t *tokenChaincode) getAccountHistory(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	userAddress := strings.ToLower(args[0])
	// Get the state from the ledger
	resultsIterator, err := stub.GetAccountHistory(userAddress)
	if err != nil {
		return shim.Error(err.Error())
	}
	defer resultsIterator.Close()

	// buffer is a JSON array containing historic values for the account
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		response, err := resultsIterator.Next()
		if err != nil {
			return shim.Error(err.Error())
		}
		// Add a comma before array members, suppress it for the first array member
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"TxId\":")
		buffer.WriteString("\"")
		buffer.WriteString(response.TxId)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Value\":")
		// if it was a delete operation on given key, then we need to set the
		//corresponding value null. Else, we will write the response.Value
		//as-is (as the Value itself a JSON marble)
		if response.IsDelete {
			buffer.WriteString("null")
		} else {
			buffer.WriteString(string(response.Value))
		}

		buffer.WriteString(", \"Timestamp\":")
		buffer.WriteString("\"")
		buffer.WriteString(time.Unix(response.Timestamp.Seconds, int64(response.Timestamp.Nanos)).String())
		buffer.WriteString("\"")

		buffer.WriteString(", \"IsDelete\":")
		buffer.WriteString("\"")
		buffer.WriteString(strconv.FormatBool(response.IsDelete))
		buffer.WriteString("\"")

		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	fmt.Printf("- getAccountHistory returning:\n%s\n", buffer.String())

	return shim.Success(buffer.Bytes())
}

func (t *tokenChaincode) historyByComposite(stub shim.ChaincodeStubInterface, compositeKey string, args []string) (err error) {
	var indexKey string
	if indexKey, err = stub.CreateCompositeKey(compositeKey, args); err != nil {
		return
	}

	value := []byte{0x00}
	if err = stub.PutState(indexKey, value); err != nil {
		return
	}
	return
}

func (t *tokenChaincode) getStateByPartialCompositeKey(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	// "user_name", "start_time", "end_time"
	if len(args) < 2 {
		return shim.Error("Incorrect number of arguments. Expecting 2")
	}

	var startTime, endTime int64
	var targetAddress string
	var nIndex, recordNumber int
	var err error
	if nIndex, err = strconv.Atoi(args[0]); err != nil {
		return shim.Error("query type error")
	}

	switch nIndex {
	case 1:
		if len(args) < 3 {
			return shim.Error("Incorrect number of arguments. Expecting 4")
		}
		if args[1] != "" {
			startTime, err = strconv.ParseInt(args[1], 10, 64)
			if err != nil {
				return shim.Error("Incorrect number of arguments 1")
			}
		}
		if args[2] != "" {
			endTime, err = strconv.ParseInt(args[2], 10, 64)
			if err != nil {
				return shim.Error("Incorrect number of arguments 2")
			}
		}
	case 2:
		if recordNumber, err = strconv.Atoi(args[1]); err != nil {
			return shim.Error("query type error")
		}
	case 3:
		targetAddress = strings.ToLower(args[1])
	default:
		return shim.Error("invalid query type")
	}

	resultsIterator, err := stub.GetStateByPartialCompositeKey("accountHistory", []string{})
	if err != nil {
		return shim.Error(err.Error())
	}
	defer resultsIterator.Close()

	// buffer is a JSON array containing historic values for the account
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for i := 0; resultsIterator.HasNext(); i++ {
		responseRange, err := resultsIterator.Next()
		if err != nil {
			return shim.Error(err.Error())
		}
		objectType, compositeKeyParts, err := stub.SplitCompositeKey(responseRange.Key)
		if err != nil {
			return shim.Error(err.Error())
		}

		if nIndex == 1 {
			tm, err := strconv.ParseInt(compositeKeyParts[4], 10, 64)
			if err != nil || (startTime > 0 && tm < startTime) || (endTime > 0 && tm >= endTime) {
				continue
			}
		} else if nIndex == 2 {
			if i >= recordNumber {
				break
			}
		} else {
			if compositeKeyParts[0] != targetAddress {
				continue
			}
		}

		// Add a comma before array members, suppress it for the first array member
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"objectType\":")
		buffer.WriteString("\"")
		buffer.WriteString(objectType)
		buffer.WriteString("\"")

		// send_address ~ to_address ~ token_type ~ amount ~ tx_time ~ tx_id
		buffer.WriteString(", \"sender\":")
		buffer.WriteString("\"")
		buffer.WriteString(compositeKeyParts[0])
		buffer.WriteString("\"")

		buffer.WriteString(", \"to\":")
		buffer.WriteString("\"")
		buffer.WriteString(compositeKeyParts[1])
		buffer.WriteString("\"")

		buffer.WriteString(", \"tokenType\":")
		buffer.WriteString("\"")
		buffer.WriteString(compositeKeyParts[2])
		buffer.WriteString("\"")

		buffer.WriteString(", \"amount\":")
		buffer.WriteString("\"")
		buffer.WriteString(compositeKeyParts[3])
		buffer.WriteString("\"")

		buffer.WriteString(", \"timestamp\":")
		buffer.WriteString("\"")
		buffer.WriteString(compositeKeyParts[4])
		buffer.WriteString("\"")

		buffer.WriteString(", \"txID\":")
		buffer.WriteString("\"")
		buffer.WriteString(compositeKeyParts[5])
		buffer.WriteString("\"")

		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	fmt.Printf("queryAccountRecordByTime returning:\n%s\n", buffer.String())
	return shim.Success(buffer.Bytes())
}

func main() {
	err := shim.Start(new(tokenChaincode))
	if err != nil {
		fmt.Printf("Error starting tokenChaincode: %s", err)
	}
}
