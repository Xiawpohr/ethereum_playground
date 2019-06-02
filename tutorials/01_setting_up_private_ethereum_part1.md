# 建立一組以太坊私網 Part 1

> 學習目標：
>
> - 安裝 client tool - geth
> - 初始化第一個節點
> - 建立 Accounts
> - 以太坊上的一些基本操作：挖礦、交易、查詢鏈上的資訊

## 安裝 client tool

第一步，要先安裝 client tool。因為以太坊上是由好多的節點 (nodes) 所組成的分散式網路，client tool 可以幫助我們建立這些節點，所以有了 client tool 我們才可以設定以太坊的環境。



我的電腦是 MacOS，所以使用 [Homebrew](https://brew.sh) 來安裝，首先更新一下 Homebrew 。

```
$ brew update
$ brew upgrade
```



我選擇的 client tool 是 geth，是由 golang 所實作的版本，算是在被開發社群所採用的主流版本。如果想使用其他語言所實作的 client tool，可以去[官方的網頁](https://www.ethereum.org/cli)來玩玩。

```
$ brew tap ethereum/ethereum
$ brew install ethereum
```



安裝好後，執行 `geth version` 來確認是否安裝成功。

```
$ geth version
Geth
Version: 1.8.20-stable
Architecture: amd64
Protocol Versions: [63 62]
Network Id: 1
Go Version: go1.11.2
Operating System: darwin
GOPATH=
GOROOT=/usr/local/Cellar/go/1.11.2/libexec
```



這個時候執行 `geth` ，就會在電腦上建立一個以太坊節點，連接以太坊的主網並同步以太坊上的資料。如果是第一次執行這個指令，這會花費很多很多很多的時間。



## 準備創建第一個區塊所需要的資訊 (configuration)

由於我想要在自己的電腦上建立一組以太坊的私網來玩，所以我需要一個設定檔來設定這個私網的資訊，而且需要這些資訊來創造第一個區塊，通常這個檔案會命名為 genesis.json。以下是一個 genesis.json 的範例。

```json
{
  "config": {
    "chainId": 2019,
    "homesteadBlock": 0,
    "eip155Block": 0,
    "eip158Block": 0
  },

  "alloc"      : {},
  "coinbase"   : "0x0000000000000000000000000000000000000000",
  "difficulty" : "0x400",
  "extraData"  : "0x0000000000000000000000000000000000000000000000000000000000000000",
  "gasLimit"   : "0x4C4B40",
  "nonce"      : "0x0000000000000042",
  "mixhash"    : "0x0000000000000000000000000000000000000000000000000000000000000000",
  "parentHash" : "0x0000000000000000000000000000000000000000000000000000000000000000",
  "timestamp"  : "0x00"
}
```

[Configuration explanation](https://gist.github.com/0mkara/b953cc2585b18ee098cd#file-genesis-md)



## 初始化第一的節點

geth 需要一個資料夾 (folder) 來存放區塊鏈上的資料，和 genesis.json，來初始化第一個節點。 

```
$ geth --datadir ./node_1 init genesis.json
```

可以看執行結果。

並且可以發現在你的目錄下多了一個名為 node_1 的資料夾，這個資料夾下又有兩個資料夾，一個叫做 geth，用來紀錄區塊鏈上的資料；一個叫做 keystore，用來存放這個節點下的 Accounts 資料。



## 建立一個 Account

我們會先需要一些 Accounts，這樣才可以使用這些 Accounts 在區塊鏈上做交易。

建立 Account 有兩種不同的方式，這裡先用 cli 來建立 Account。

```
$ geth --datadir ./node_1 account new
```

這邊會需要輸入一個密碼 (passphrase)，而且需要記得這個密碼，等下會用到。

之後就會得到一個 account's address。而且會發現在剛才的 keystore 資料夾中多了一個檔案，這個檔案包含這個 account 的私鑰和關於這個 account 的其他資訊。

> 重點提示：
>
> - Account 都是自己創造的，而不是以太坊幫我們創造，所以在剛被創造的當下其他人是不知道這個 Account 的存在。
> - 只有當這個 Accounts 被記錄在區塊鏈上的交易 (transaction) 中，其他人才會知道這個 Account 的存在。



## 開始執行一些以太坊上的基本操作

首先需要進入剛才成功初始化的節點的 console。

```
$ geth --datadir ./node_1 console
```

這個 console 是一個 Javascript 的環境，所以可以使用任何 Javascript 的語法，而且提供了一些 Libraries 來讓我們可以操作區塊鏈。



第一個需要認識 Library 是 eth。

```javascript
> eth.accounts 
// returns the list of accounts on this blockchain
```

```javascript
> eth.getBalance(eth.accounts[0]) 
// returns the balance of the  first account. 
```

```javascript
> eth.blockNumber 
// returns the current block number. 0 for a new blockchain
```



在來我們需要挖礦，使用 miner 這個 Library。

```javascript
> miner.start()
// start mining
```

```javascript
> miner.stop()
// stop mining
```

這個時候可以回去檢查 `eth.blockNumber` 跟 `eth.getBalance(eth.accounts[0])` 是不是有不一樣的值。


> 重要提示：
>
> - 第一次挖礦時，Proof of Work 演算法會需要產生 1GB 的資料，可能花費數分鐘到數小時的時間。期間任何指令都沒有作用，包括 `miner.stop()`。
> - 這些資料被稱為 [Ethash DAG](https://github.com/ethereum/wiki/wiki/Ethash-DAG)。



這時只有一個 Account，是沒有辦法做交易，因此我需要第二個 Account，現在使用 Library 來新增 Account。任何跟 Account 有關的事情，使用 personal 這個 Library。

```javascript
> personal.newAccount("Write here a good, randomly generated, passphrase!")
// return this account's address that was just created
```



讓我們執行第一筆交易 (transaction)，把第一個 Account 的 2 ether 轉帳給第二個 Account。

```javascript
> personal.unlockAccount(eth.accounts[0], "First account's passphrase")
// we have to unlock the account with passphrase before making the transaction from this account
```

```javascript
> eth.sendTransaction({from: eth.accounts[0], to: eth.accounts[1], value: web3.toWei(2, "ether")})
// send the Transaction
```

你會得到這筆交易的 Id，例如："0x5ec34d4ea26e79c4298cf22dfaf5d970192f8087471b92b192637e679b58c212"，不過當你檢查第二個 Account 的資產時，會發現還是 0 ，因為這筆交易現在還沒有上鏈。所以你需要挖礦來將這筆交易記錄在區塊鏈上。

執行 `miner.start()` 和 `miner.stop()`。

這時再去檢查第二個 Account 的資產，就會發現有 2 ether 了。

你也可以去查看這筆交易的資訊。

```javascript
> eth.getTransaction("0x5ec34d4ea26e79c4298cf22dfaf5d970192f8087471b92b192637e679b58c212")
{
  blockHash: "0x2fa6fbbf2915762a6becc9bd8f2e691441caac9f6c8091e5af5faa5b70e009f5",
  blockNumber: 83,
  from: "0xd65dba2aff04139faf4ea6f0e85c5de1b6d30fae",
  gas: 90000,
  gasPrice: 1000000000,
  hash: "0x5ec34d4ea26e79c4298cf22dfaf5d970192f8087471b92b192637e679b58c212",
  input: "0x",
  nonce: 0,
  r: "0x9ee544ba0de3013d0a7fe04da4239d030be513b9ca5c8c249ac6b12a95fa180c",
  s: "0x7851495e6af788c55d2b86699bcca00f2d83fbe64217617223daf8777210e554",
  to: "0x120b6701c66130d9aaf63f4f15537837ce0ac1f0",
  transactionIndex: 0,
  v: "0xfea",
  value: 2000000000000000000
}
```

可以看到這筆交易被記錄在第 83 個區塊，這個區塊的 hash 值是 "0x2fa6fbbf2915762a6becc9bd8f2e691441caac9f6c8091e5af5faa5b70e009f5"，你也可以查看這個區塊的資訊。

```javascript
> eth.getBlock("0x2fa6fbbf2915762a6becc9bd8f2e691441caac9f6c8091e5af5faa5b70e009f5")
{
  difficulty: 131136,
  extraData: "0xd983010814846765746888676f312e31312e328664617277696e",
  gasLimit: 5421806,
  gasUsed: 21000,
  hash: "0x2fa6fbbf2915762a6becc9bd8f2e691441caac9f6c8091e5af5faa5b70e009f5",
  logsBloom: "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
  miner: "0xd65dba2aff04139faf4ea6f0e85c5de1b6d30fae",
  mixHash: "0xf22028f678b7117e60f06c7f92683e3229806356a25f6b2ac7e7d851abbf2d12",
  nonce: "0x7741a9a4b151e6a5",
  number: 83,
  parentHash: "0x48f3378d99bf3f1a5cdc3a3285306feeebaad072057df682aa4a0d5adcc7073e",
  receiptsRoot: "0x660e66bd0f8d5693fda88e582ea46cd298807ae2d7148a7cdcba61de9fb95200",
  sha3Uncles: "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347",
  size: 652,
  stateRoot: "0xfe88fcdf19b7bd0677283d5e3e032fef1ab7206b672b0c1599bbb6963f40c5d7",
  timestamp: 1549960350,
  totalDifficulty: 11083552,
  transactions: ["0x5ec34d4ea26e79c4298cf22dfaf5d970192f8087471b92b192637e679b58c212"],
  transactionsRoot: "0x07f6c33adca5b4440927bd6845916c4b42a3d2fc9a6e0d4f14c4677de327327b",
  uncles: []
}
```



最後我們要離開這個 console。

```javascript
> exit
```



## 總結

- 使用 geth 來創建以太坊的環境。

  - `geth --datadir ./node_1 init genesis.json`
  - `geth --datadir ./node_1 console`

- 建立 Accounts。

  - `geth --datadir ./node_1 account new`
  - `personal.newAccount()`

- 挖礦。

  - `miner.start()`
  - `miner.stop()`

- 轉帳以太幣 (ether)。

  - `personal.unlockAccount()`
  - `eth.sendTransaction()`

- 查看區塊鏈的資訊。

  - `eth.accounts`

  - `eth.getBalance()`

  - `eth.blockNumber`

  - `eth.getTransaction()`

  - `eth.getBlock()`

    


