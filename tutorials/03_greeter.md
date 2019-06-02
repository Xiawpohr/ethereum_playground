# 寫一份 Hello World 的智慧合約

> 學習目標：
>
> - 智慧合約的基本結構
> - 使用 Remix 線上編譯器
> - 使用 cli 將智慧合約部署在以太坊私網上
> - 在以太坊上執行智慧合約的功能 (funciton)
> - 讓其他人也可以執行這份智慧合約

## Hello World 的智慧合約

我們可以這麼描述智慧合約 (smart contract)：

- 智慧合約與一般人一樣可以與其他合約交流、做決定、儲存資料、發送 ether 與接收 ether。
- 因此智慧合約就像是在區塊鏈執行上的機器人，它也具有一個 Account，稱為 Contract Account。
- 雖然是由開發者來寫智慧合約，但是這些智慧合約的執行與服務是由以太坊網路提供的。
- 因此一但智慧合約被部署進乙太坊，這些智慧合約將不能被串改，也無法更新。
- 只要以太坊的網路存在，這些智慧合約永遠不會消失，除非一開始它就被賦予自我毀滅的指令。



接著，讓我們從 Hello World 的智慧合約開始吧。這份智慧合約就像是會跟任何與他交流的人打招呼的機器人，它的招呼語就是 Hello World。

```solidity
pragma solidity >=0.4.22 <0.6.0;

contract Greeter {
    string greeting;

    constructor(string memory _greeting) public {
        greeting = _greeting;
    }

    function greet() public view returns (string memory) {
        return greeting;
    }
}
```

- 這份智慧合約是用 Solidity 寫的，Solidity 是一個在以太坊上專門用來寫智慧合約的語言。一個智慧合約的基本結構大概是如下：

    ```solidity
    pragma solidity >=0.4.22;
    
    contract ContractName {
        constructor() public {}
    }
    ```

- 第 1 行 `pragma solidity >=0.4.22;` 用來宣告這份合約所使用 Solidity 的版本，一定要寫在合約的第一行。

- 使用 `contract ContractName {}` 來宣告這份合約的名字，名字的字首按慣例會大寫。例如：Greeter。

- `constructor` 會在合約被部署到以太坊網路上時被執行。這裡 constructor 接受一個字串參數，來設定招呼語。之後會在部署時設定為 Hello World。

- 第 4 行 `string greeting` 在合約內宣告一個字串變數。

- 第 11 行宣告一個 greet function，來向其他人回應之前設定的招呼語。public 是指任何人都可以執行這份合約的功能。



## 使用 Remix 線上編譯器

雖然已經用 Solidity 來寫智慧合約，不過以太坊的網路無法直接執行 Solidity 這個語言，因此我們需要編譯 Solidity 來讓以太坊可以執行。官方推薦使用 [Remix](https://remix.ethereum.org/) 線上編譯器。

在 Remix 開一個新的文件，並把剛才的合約複製到 Remix，Remix 會自動編譯 Solidity 的檔案。

把編譯好的 code 複製下來，存成 greeter.js。

```javascript
var _greeting = /* var of type string here */ ;
var greeterContract = web3.eth.contract([{"constant":false,"inputs":[],"name":"kill","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"greet","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"inputs":[{"name":"_greeting","type":"string"}],"payable":false,"stateMutability":"nonpayable","type":"constructor"}]);
var greeter = greeterContract.new(
   _greeting,
   {
     from: web3.eth.accounts[0], 
     data: '0x608060405234801561001057600080fd5b506040516103c73803806...', 
     gas: '4700000'
   }, function (e, contract){
    console.log(e, contract);
    if (typeof contract.address !== 'undefined') {
         console.log('Contract mined! address: ' + contract.address + ' transactionHash: ' + contract.transactionHash);
    }
 })
```

把第 1 行改成 `var _greeting = "Hello World";`。



## 使用 cli 將智慧合約部署在以太坊私網上

之後進入以太坊的 console。

```
$ geth --datadir node_1 --networkid 1234 console
```

解鎖第一個 Account，因為要使用這個 Account 來部署智慧合約。

```javascript
> personal.unlockAccount(eth.accounts[0], "passphares")
```

載入剛才編譯好的 code。

```javascript
> loadScript("greeter.js")
```

等待一些時間，如果部署成功可以看到以下訊息。

```javascript
Contract mined! address: 0xdaa24d02bad7e9d6a80106db164bad9399a0423e
```

檢查合約是否是否部署成功。

```javascript
> eth.getCode(greeter.address)
```

如果看到除了 "0x" 以外的字串，表示合約已經成功上鏈。



## 在以太坊上執行智慧合約的功能 (funciton)

你可以執行這份智慧合約。

```javascript
> greeter.greet()
Hello World
```

成功看到 Hello World。



## 讓其他人也可以執行這份智慧合約

要讓其他人也可以使用這份智慧合約，會需要兩樣東西：

- Contract Address：合約在以太坊上的地址。
- ABI (Application Binary Interface)：合約的使用手冊，可以告訴其他人這份合約有哪些功能，及如何執行這些功能。



取得合約在以太坊上的地址。

```javascript
> greeter.address
```

取得 ABI。

Details -> ABI textbox



在另一個連上相同網路的節點使用這份合約。

```javascript
var greeter = eth.contract(ABI).at(Address)
```

在這個節點上執行這份合約。

```javascript
> greeter.greet()
Hello World
```

一樣可以看到 Hello World。

