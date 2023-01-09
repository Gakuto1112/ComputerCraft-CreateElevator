# ComputerCraft-CreateElevator
Createで作成した、からくりエレベーターを制御するComputerCraft用のプログラムです。

## 技術情報
### データ構造
#### Elevator data
| フィールド名 | データ型 | 説明 |
| - | - | - |
| currentFloor | number | 現在エレベーターがいる階層 |
| direction | number | 1 = 上昇中, 0 = 停止中, -1 = 下降中 |
| minFloor | number | 最下階の階 |
| maxFloor | number | 最上階の階 |

#### Floor arrival data
| フィールド名 | データ型 | 説明 |
| - | - | - |
| floor | number | 到着・通過したフロア |
| isArrived | boolean | 到着なら`true`、通過なら`false` |
| minFloor | number | 最下階の階 |
| maxFloor | number | 最上階の階 |

### 通信プロトコル
| プロトコル名 | 説明 | データ |
| - | - | - |
| EV_DATA_REQ | 子機が親機にエレベーターの情報を要求する。 | |
| EV_DATA_RES | 親機が子機にエレベーターの情報を送信する。 | Elevator data |
| EV_CALL | エレベーターを特定の階に呼び出す。 | 呼び出す階 |
| EV_DIRECTION | エレベーターの移動方向を通知する。 | 1 = 上昇, -1 = 下降 |
| EV_FLOOR | エレベーターがフロアへの到着・通過の際を通知する。 | Floor arrival data |