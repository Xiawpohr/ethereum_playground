# 建立一組以太坊私網 Part 2

> 學習目標：
>
> - 建立兩個節點
> - 連接不同的節點
> - 確認節點之間的資料同步

## 建立兩個節點

上篇我已經有一個節點，現在我需要兩個以上的節點才能形成網路。

不過首先進入第一個節點的 console。

```
$ geth --datadir node_1 --networkid 1234 --nodiscover console
```

> 重點提示：
>
> - `--datadir ./node_1`: 用來指定特定節點的區塊鏈資料目錄。預設是以太坊主網的資料。
>
> - `--networkid 1234`: 用來識別以太坊的網路，連盡相同以太坊網路的節點需要有相同的 networkid。networkid 可以是任意的整數值。
> - `--nodiscover`: 關閉節點的自動發現機制，開啟手動加入節點。

現在來查看這個節點的資訊。

```javascript
> admin.nodeInfo
{
  enode: "enode://f73eb2c82996f07923895eeb759cc6534b7e4e85e4e9d2a61af97a3a8e6ab02635bfe2c8cd220cf79d97b0d86192642f4bccf01e6c0301cb34bb059d0e43b5bb@127.0.0.1:30303?discport=0",
  enr: "0xf895b840b0e116061608fb75a16f7b3fc3b0b3c189e7f94f70985c91c2c53b7ea0ddc7432135a7495622ed508a5dd7c0856f4f93cfdf1b7ff572c19be6ce7f369641b8750a83636170ccc5836574683ec5836574683f826964827634826970847f00000189736563703235366b31a103f73eb2c82996f07923895eeb759cc6534b7e4e85e4e9d2a61af97a3a8e6ab0268374637082765f",
  id: "b1f524490b50df75c5a57afed2ead0f4e2faa44f2705c0bd2277ef912c55fc1a",
  ip: "127.0.0.1",
  listenAddr: "[::]:30303",
  name: "Geth/v1.8.20-stable/darwin-amd64/go1.11.2",
  ports: {
    discovery: 0,
    listener: 30303
  },
  protocols: {
    eth: {
      config: {
        chainId: 2019,
        eip150Hash: "0x0000000000000000000000000000000000000000000000000000000000000000",
        eip155Block: 0,
        eip158Block: 0,
        homesteadBlock: 0
      },
      difficulty: 12134944,
      genesis: "0xff13f60ec962e353ef2f026d6602d2c1b7ae75a1941376815fe889c4f01ed4dc",
      head: "0xef2d86b5a8f485fbbd5aa4e17e0249d3be348f50b6688438beec9afaa92aefc5",
      network: 1234
    }
  }
}
```

可以看到下列幾個資訊：

- enode 代表這個節點。
- 預設的 port 是 30303。
- discovery port 為 0，之前設定了 `--nodiscover`。
- networkid 是 1234。



再來用相同的 genesis.json 來再建立另一個節點。

```
$ geth --datadir node_2 init genesis.json
```

進入第二個節點的 console。

```
$ geth --datadir node_2 --networkid 1234 --port 30304 --nodiscover console
```

記得這裡要使用相同的 networkid。而 port 30303 正在使用，所以我需要指定另一個 port。

然後看一下這個節點的資訊。

```javascript
> admin.nodeInfo
{
  enode: "enode://291684d63118994de900a33f91a2f4028b7aaf6c920840b9b27688c6a2da1d2d0222f7ffcacc8aa6b28b3cda0a82c6b6dd2329373ce55007e96404180460cda3@127.0.0.1:30304?discport=0",
  enr: "0xf88fb84033dd78cd324eb803d660c43d819ed824e0259d049911de2c3c5a567c56961bfd6a28eae227a43467494fc3c54bbe4de496d5a07c2c5df1646a1a2d390eef077c0183636170c6c5836574683f826964827634826970847f00000189736563703235366b31a103291684d63118994de900a33f91a2f4028b7aaf6c920840b9b27688c6a2da1d2d83746370827660",
  id: "f1c47d69dc8303f669129305e739842ea601cafb1fd9a4a6f90dbd7c7511f863",
  ip: "127.0.0.1",
  listenAddr: "[::]:30304",
  name: "Geth/v1.8.20-stable/darwin-amd64/go1.11.2",
  ports: {
    discovery: 0,
    listener: 30304
  },
  protocols: {
    eth: {
      config: {
        chainId: 2019,
        eip150Hash: "0x0000000000000000000000000000000000000000000000000000000000000000",
        eip155Block: 0,
        eip158Block: 0,
        homesteadBlock: 0
      },
      difficulty: 1024,
      genesis: "0xff13f60ec962e353ef2f026d6602d2c1b7ae75a1941376815fe889c4f01ed4dc",
      head: "0xff13f60ec962e353ef2f026d6602d2c1b7ae75a1941376815fe889c4f01ed4dc",
      network: 1234
    }
  }
}
```

可以比較一下兩個節點的 enode。接著就要來把這兩個節點連接起來。

## 連接不同的節點

在這兩個節點的 console 執行以下命令。

```
> admin.peers
```

會發現兩邊都是 [] ，因為這兩個節點還沒連接在一起。

現在複製第二個節點的 enode 到第一個節點的 console。

```javascript
> var node2 = "enode://291684d63118994de900a33f91a2f4028b7aaf6c920840b9b27688c6a2da1d2d0222f7ffcacc8aa6b28b3cda0a82c6b6dd2329373ce55007e96404180460cda3@127.0.0.1:30304?discport=0"
```

在第一個節點的 console 中，加入這個節點至網路中。

```javascript
> admin.addPeer(node2)
```

接著在兩邊的 console 檢查是否加入成功。

```javascript
> admin.peers
[{
    caps: ["eth/63"],
    enode: "enode://291684d63118994de900a33f91a2f4028b7aaf6c920840b9b27688c6a2da1d2d0222f7ffcacc8aa6b28b3cda0a82c6b6dd2329373ce55007e96404180460cda3@127.0.0.1:30304?discport=0",
    id: "f1c47d69dc8303f669129305e739842ea601cafb1fd9a4a6f90dbd7c7511f863",
    name: "Geth/v1.8.20-stable/darwin-amd64/go1.11.2",
    network: {
      inbound: false,
      localAddress: "127.0.0.1:59144",
      remoteAddress: "127.0.0.1:30304",
      static: true,
      trusted: false
    },
    protocols: {
      eth: {
        difficulty: 1024,
        head: "0xff13f60ec962e353ef2f026d6602d2c1b7ae75a1941376815fe889c4f01ed4dc",
        version: 63
      }
    }
}]
```



## 確認節點之間的資料同步

現在來確認兩個節點之間是否有資料同步。當其中一個節點開始挖礦時，資料也會傳遞到另一個節點，而且兩邊區塊數量會相同。

```javascript
> eth.blockNumber
```

兩邊數字會一樣。

而且也可以檢查特定區塊的資料是否一樣，例如在兩邊都檢查第三個區塊的資料。

```javascript
> eth.getBlock(3)
```



## 總結

- 查看節點的資訊。
  - `admin.nodeInfo`
- 加入其他節點到網路中。
  - `admin.addPeer`
  - `admin.peers`

