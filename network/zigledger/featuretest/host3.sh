#!/usr/bin/env bash

cp crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tendermint/node_key.json crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tendermint/testchainid;
cp crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tendermint/node_key.json crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tendermint/mychannel;
cp crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tendermint/priv_validator.json crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tendermint/testchainid;
cp crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tendermint/priv_validator.json crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tendermint/mychannel;
