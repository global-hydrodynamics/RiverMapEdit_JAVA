import java.util.*;
import java.io.*;
import java.awt.*;
import java.lang.*;

//観測点位置情報（実際、T213）を緯度・経度情報で持つ
public class StationList
{
    public int nx, ny;
    public int stan = 1000;  //観測点情報の点の数
    public float sl[][];

    public StationList()
    {
        sl=new float[stan][4];
        for(int i=0;i<stan;i++){
          for(int j=0;j<4;j++){
              sl[i][j] = (float)999.99;
          }
        }
    }

    public StationList(DataInputStream fin)throws java.io.IOException,java.lang.NumberFormatException,NoSuchElementException
    {
        BufferedReader d = new BufferedReader(new InputStreamReader(fin));
        sl=new float[stan][4];
        for(int i=0;i<stan;i++){
          StringTokenizer str=new StringTokenizer( d.readLine()," \t,");
          for(int j=0;j<4;j++){
            String k = str.nextToken();
              sl[i][j] = Float.parseFloat(k);
          }
        }
    }
    
    //j=0は経度、j=1は緯度を返す
    public float getValue( int i, int j)
    {
        return sl[i][j];
    }    
}