import java.util.*;
import java.io.*;
import java.awt.*;
//流向データを扱うクラス

public class FlowDirection{
    int[][] dirlist;
    int nx, ny;

    public FlowDirection(int nx, int ny)
    {
        this.nx = nx;
        this.ny = ny;
        dirlist = new int[nx][ny];
        for(int iy=0; iy<ny; iy++){
          for(int ix=0; ix<nx; ix++){
            dirlist[ix][iy] = 0;
          }
        }
    }

    //float(xn*yn)の流行データを読み込む。南北方向のデータ順は北→南
    public FlowDirection(int nx, int ny, DataInputStream fin)throws java.io.IOException,java.lang.NumberFormatException,NoSuchElementException
    {
        this.nx=nx;
        this.nx=ny;
        dirlist=new int[nx][ny];

        for(int iy=0; iy<ny; iy++){
          for(int ix=0; ix<nx; ix++){
            dirlist[ix][iy]=(int)fin.readFloat();
          }
        }
    }

    //流向ベクトルの終点グリッドを返す
    public java.awt.Point getEndPoint(int ix,int iy){
        switch(dirlist[ix][iy]){
            case 1: return new Point(ix  , iy-1);
            case 2: return new Point(ix+1, iy-1);
            case 3: return new Point(ix+1, iy  );
            case 4: return new Point(ix+1, iy+1);
            case 5: return new Point(ix  , iy+1);
            case 6: return new Point(ix-1, iy+1);
            case 7: return new Point(ix-1, iy  );
            case 8: return new Point(ix-1, iy-1);
        }
        return new Point(ix,iy);
    }

    public String getValue(int ix, int iy)
    {
        return Integer.toString(dirlist[ix][iy]);
    }

}