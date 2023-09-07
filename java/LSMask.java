import java.util.*;
import java.io.*;
import java.awt.*;

// land sea mask
public class LSMask {
    int[][] mask;
    int nx, ny;

    // file format "float(xn*yn) north => south"
    public LSMask(int nx, int ny)
    {
        this.nx=nx;
        this.nx=ny;
        mask=new int[nx][ny];

        try{
            File file = new File("./data/lndfrc.big");
            DataInputStream fin = new DataInputStream(new FileInputStream(file));
            for(int iy=0; iy<ny; iy++){
              for(int ix=0; ix<nx; ix++){
                float a = fin.readFloat();
                mask[ix][iy]=(int)(a*100);
                if( a>0 && a<0.01 ) mask[ix][iy]=1;
              }
            }
        }catch(Exception e){
            System.err.println(e);
        }
    }
   
    public String getValue(int ix, int iy)
    {
        return Integer.toString(mask[ix][iy]);
    }
}

