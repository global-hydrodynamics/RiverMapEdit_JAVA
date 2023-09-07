import java.util.*;
import java.io.*;
import java.awt.*;

// lake fraction
public class LAKEfrac {
    float[][] lake;
    int nx, ny;

    // file format "float(xn*yn) north => south"
    public LAKEfrac(int nx, int ny)
    {
        this.nx=nx;
        this.nx=ny;
        lake=new float[nx][ny];

        try{
            File file = new File("./data/lkfrc.big");
            DataInputStream fin = new DataInputStream(new FileInputStream(file));
            for(int iy=0; iy<ny; iy++){
              for(int ix=0; ix<nx; ix++){
                float a = fin.readFloat();
                lake[ix][iy]=a;
                if( lake[ix][iy] < 0 ) lake[ix][iy]=0 ;
             }
            }
        }catch(Exception e){
            System.err.println(e);
        }
    }
   
    public String getValue(int ix, int iy)
    {
        return Integer.toString((int)(lake[ix][iy]*100));
    }
}

