import java.util.*;
import java.io.*;
import java.awt.*;

//流域データを扱うクラス
public class BasinList{
    int[][] color;
    int nx, ny;

    public BasinList(int nx, int ny)
    {
        this.nx = nx;
        this.ny = ny;
        color = new int[nx][ny];
        for(int iy=0; iy<ny; iy++){
          for(int ix=0; ix<nx; ix++){
            color[ix][iy] = 0;
          }
        }
    }

    //float(xn*yn)の流行データを読み込む。南北方向のデータ順は北→南
    public BasinList(int nx, int ny, DataInputStream fin)throws java.io.IOException,java.lang.NumberFormatException,NoSuchElementException
    {
        this.nx=nx;
        this.nx=ny;
        color=new int[nx][ny];

        for(int iy=0; iy<ny; iy++){
          for(int ix=0; ix<nx; ix++){
            color[ix][iy]=(int)fin.readFloat();
          }
        }
    }

    public String getValue(int ix, int iy)
    {
        return Integer.toString(color[ix][iy]);
    }

}