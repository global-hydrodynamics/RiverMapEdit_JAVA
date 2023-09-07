import java.util.*;
import java.io.*;
import java.awt.*;
import java.lang.*;

//海岸位置情報を緯度・経度情報で持つ
public class CoastList
{
    public int nx, ny;
    public int cosn = 400000;  //海岸情報の点の数
    public float cl[][];

    public CoastList()
    {
        cl=new float[cosn][2];
        for(int i=0;i<cosn;i++){
          for(int j=0;j<2;j++){
              cl[i][j] = 0;
          }
        }
    }

    public CoastList(DataInputStream fin)throws java.io.IOException,java.lang.NumberFormatException,NoSuchElementException
    {
        BufferedReader d = new BufferedReader(new InputStreamReader(fin));
        cl=new float[cosn][2];
        for(int i=0;i<cosn;i++){
          StringTokenizer str=new StringTokenizer( d.readLine()," \t,");
          for(int j=0;j<2;j++){
            String k = str.nextToken();
              cl[i][j] = Float.parseFloat(k);
          }
        }
    }
    
    //j=0は経度、j=1は緯度を返す
    public float getValue( int i, int j)
    {
        return cl[i][j];
    }    
}