### token合约path
```
zig-test/fvt/network/config/artifacts/src/github.com/token/token.go
```
### 测试步骤
#### 1.用户和账户注册
```
./register-1-2-3-44.sh
```
#### 2.向新账户中转账(新账户Invoke需要消耗gas)
```
./transfer-7.sh
```
#### 3.设置用户权限
```
./access-4-45-47.sh
```
#### 4.一对多转账
```
./multi-transfer-4-45-47.sh
```
#### 5.合约升级
```
./upgrade-28.sh
```
#### 6.账户查询
```
./account-14-15-16.sh
```
#### 7.账户注销
```
./logout-4.sh
```