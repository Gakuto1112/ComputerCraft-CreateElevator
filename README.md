# ComputerCraft-CreateElevator
Createで作成したからくりエレベーターを制御するComputerCraft用のプログラムです。

## 技術情報
### データ構造
#### Elevator data
| フィールド名 | データ型 | 説明 |
| - | - | - |
| currentFloor | number | 現在エレベーターがいる階層 |
| direction | number | 1 = 上昇中, 0 = 停止中, -1 = 下降中 |

### 通信プロトコル
| プロトコル名 | 説明 | データ |
| - | - | - |
| EV_DATA_REQ | 子機が親機にエレベーターの情報を要求する。 | |
| EV_DATA_RES | 親機が子機にエレベーターの情報を送信する。 | エレベーター情報 |
| EV_CALL | エレベーターを特定の階に呼び出す。 | 呼び出す階 |