package lang

import (
	"fmt"
	"github.com/syndtr/goleveldb/leveldb"
	"testing"
)

func TestChangeOrderer3(t *testing.T) {
	fmt.Println(">>> bootstrap the database")
	db, err := leveldb.OpenFile("crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tendermint/mychannel/data/state.db/", nil)
	if err == nil {
		defer db.Close()
	}
	err = db.Delete([]byte("genesisDoc"), nil)
	//err = db.Put([]byte("validatorsKey:1"), []byte("grapebaba"), nil)
	//iter := db.NewIterator(nil, nil)

	//for iter.Next() {
	//	key := iter.Key()
		//value := iter.Value()
	//	fmt.Println(string(key))
		//fmt.Println(string(value))
	//}
	//iter.Release()
}

func TestChangeOrderer2(t *testing.T) {
	fmt.Println(">>> bootstrap the database")
	db, err := leveldb.OpenFile("crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tendermint/mychannel/data/state.db/", nil)
	if err == nil {
		defer db.Close()
	}
	err = db.Delete([]byte("genesisDoc"), nil)
	//err = db.Delete([]byte("stateKey"), nil)
	//data, err := db.Get([]byte("stateKey"), nil)
	//err = db.Put([]byte("validatorsKey:1"), []byte("grapebaba"), nil)
	//fmt.Println(string(data))
	//iter := db.NewIterator(nil, nil)

	//for iter.Next() {
	//	key := iter.Key()
		//value := iter.Value()
	//	fmt.Println(string(key))
		//fmt.Println(string(value))
	//}
	//iter.Release()
}

//func TestMain(m *testing.M) {
//	fmt.Println(">>> setup the test suite")
//	exitCode := m.Run()
//	os.Exit(exitCode)
//}
