河道網と河道幅データの計算。
 (LGM-T42河道網を作ったときのメモです)

====================
1. 下準備 (in src)
% s01-setup.sh

1-1.
　GTOOL形式の緯度情報、GRLAND、GRZをバイナリに変換

1-2. set_basin.f90
　MIRPOC5-T42オリジナルの河道網 flwdir_t42.grdから、
　流域界（basin_t42.grd)と流域色分け（color_t42.grd）を作成。


====================
2. LGM河道網の作成
% s02-modify.sh

2-1. set_flwdir.f90
　GRZを河口まで流れ着くように修正。
　オリジナルの河道網は残しつつ、
　陸地が増えたLGMの河道網（flwdir_LGM.grd）を計算する。

2-2. set_basin.f90
　LGM-T42の河道網 flwdir_LGM.grdから、
　流域界（basin_LGM.grd)と流域色分け（color_LGM.grd）を作成。


2-3.
　LGM河道網をGTOOL形式に変換

====================
3. 川幅の計算
% s03-rivwth.sh

3-1. 流出量データの解像度変換
1度解像度の流出量データ（runoff_1deg.grd）を解像度変換

3-2. calc_rivwth.f90
流出量から河道幅（rivwth_LGM.grd）を計算

3-3.
grdデータをgtool形式に変更（rivwth_LGM.gt）


====================
4. 河道網の可視化と修正　※結局手作業の修正は不要だった

4-1. Javaのコードで可視化と修正を行える(in java、Windows環境で実行)
　% javac Starter.java　（コンパイル）
　% java Starter　（起動）

4-2.　河道網の修正
　File > Open > $java/data/flwdir_LGM.grd で河道網を開く。
　右クリック・左クリックで河道網の向きを変更
　中央クリック×１で海に、×２で河口に、×３で内陸消失点に
　File > Save で編集した河道網を保存

　四角い色つき格子：　GRLNDF=1.0
　丸い色つき格子：　　0.0<GRLNDF<1.0
　四角い灰色格子：　　GRLNDF=0.0

　赤丸：　　河道網にエラー
　茶色丸：　内陸消失点
　水色丸：　湖（現在気候）

4-3.　各種情報の表示
　Basin > Open > $java/data/color_LGM.grd　で流域色分け。
　River > Open > $java/data/rivlist.txt　　で河道位置表示（現在気候）
　Coast > Open > $java/data/coastlist.txt　で海岸位置表示（現在気候）

4-4. 移動とサイズ
　Positionにlonlatを入れると始点を変更
　Sizeで表示する大きさを変更