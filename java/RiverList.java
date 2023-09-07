import java.util.*;
import java.io.*;
import java.awt.*;
import java.lang.*;

//河道位置情報を緯度・経度情報で持つ
public class RiverList
{
    public int nx, ny;
    public int rivn = 400000;  //河道情報の点の数
    public float rl[][];

    public RiverList()
    {
        rl=new float[rivn][3];
        for(int i=0;i<rivn;i++){
          for(int j=0;j<3;j++){
              rl[i][j] = 0;
          }
        }
    }

    public RiverList(DataInputStream fin)throws java.io.IOException,java.lang.NumberFormatException,NoSuchElementException
    {
        BufferedReader d = new BufferedReader(new InputStreamReader(fin));
        rl=new float[rivn][3];
        for(int i=0;i<rivn;i++){
          StringTokenizer str=new StringTokenizer( d.readLine()," \t,");
          for(int j=0;j<3;j++){
            String k = str.nextToken();
              rl[i][j] = Float.parseFloat(k);
          }
        }
    }
    
    //j=0は経度、j=1は緯度を返す
    public float getValue( int i, int j)
    {
        return rl[i][j];
    }    
}