import java.io.*;
// The main program to start the console

public class Starter
{
    int nx = 640;
    int ny = 320;
    FlowDirection fd;   // flow direction (gridded 1-8)
    RiverList     rl;   // river vector (point)
    CoastList     cl;   // caost data (point)
    LSMask        ls;   // land sea mask (gridded)
    LAKEfrac      lf;   // lake fraction (gridded)
    BasinList     bl;   // basin colors (gridded)
    StationList   sl;   // observation stations (point)

    public static void main(String args[]){
        new Starter(args);
    }

    public Starter(String args[])
    {
        try
        {
            boolean big = false;
            boolean small = false;
            fd = new FlowDirection(nx, ny);
            rl = new RiverList();
            cl = new CoastList();
            ls = new LSMask(nx,ny);
            lf = new LAKEfrac(nx,ny);
            bl = new BasinList(nx,ny);
            sl = new StationList();
            NFrame nfr = new NFrame();
            nfr.setData(nx,ny,big,small,fd,rl,cl,ls,lf,bl,sl);
            nfr.show();
        }catch (Exception e){
            System.err.println(e);
        }
    }
}