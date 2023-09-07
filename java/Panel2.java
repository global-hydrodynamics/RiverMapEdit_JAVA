import java.awt.*;
import javax.swing.*;
import java.lang.*;
import javax.swing.event.MouseInputAdapter;
import java.awt.event.MouseEvent;

// frame to display flow directions
public class Panel2 extends JPanel 
{
    public int nx, ny;
    public boolean big, small;
    public boolean mouseon = false;
    public int xs=0, ys=0;
    public int ix, iy;
    public int by;          // size of grids
    public int width, hight;
    public int mx, my;
    FlowDirection fd;
    RiverList     rl;
    CoastList     cl;
    LSMask        ls;
    LAKEfrac      lf;
    BasinList     bl;
    StationList   sl;
    int nriv = 400000;
    int ncos = 400000;
    int stan = 1000;
    int moun = 500;

    // constructor
    public Panel2(int width, int hight)
    {
       this.width=width;
       this.hight=hight;
       setBackground(Color.white);
       MyListener myListener = new MyListener(this);
       addMouseListener(myListener);
       addMouseMotionListener(myListener);
    }

    // 
    public void setData(int nx, int ny, boolean big, boolean small,
                        FlowDirection fd, RiverList rl,  CoastList cl, LSMask ls,
                        LAKEfrac lf, BasinList bl, StationList sl)
    {
         this.nx=nx;
         this.ny=ny;
         this.big = big;
         this.small = small;
         this.fd=fd;
         this.rl=rl;
         this.cl=cl;
         this.ls=ls;
         this.lf=lf;
         this.bl=bl;
         this.sl=sl;
    }

    //
    public void paintComponent(Graphics g)
    {
       super.paintComponent(g);
       drawLS(g);
       drawGrid(g);
       drawRiver(g);
       drawCoast(g);
       drawFD(g);
       drawSta(g);
/*
       if( small==false )
         drawNumber(g);
       if( mouseon )
*/
       drawS(g, ix, iy);
       mouseon = false;
    }

    //
    public void setXYPosition( int xs, int ys )
    {
        this.xs = xs;
        this.ys = ys;
    }

    // pixel num => grid num
    public void setX( int px )
    {
       int by = 20;
       if(big)
         by *= 2;
       if(small)
         by /= 2;
       ix = (px-20)/by;
    }
    public void setY( int py )
    {
       int by = 20;
       if(big)
         by *= 2;
       if(small)
         by /= 2;
       iy = (py-20)/by;
    }

    // grid num => pixel num
    private int getP(int p)
    {
       if(big)
       return 20+20+40*p;
       if(small)
       return 20+5+10*p;

       return 20+10+20*p;
    }

    public void setOn( boolean h )
    {
       mouseon = h;
    }

    // grid lines
    private void drawGrid(Graphics g)
    {
        g.setColor(Color.gray);
        int by = 20;
        if( big ){
          by *= 2;
        }
        if( small ){
          by /= 2;
        }
        int mx = (int)(width/by);
        int my = (int)(hight/by);

        for( int ix=0; ix<mx; ix++ )
          g.drawLine( ix*by+20, 20, ix*by+20, ny*by+20 );

        for( int iy=0; iy<my; iy++ )
          g.drawLine( 20, iy*by+20, nx*by+20, iy*by+20 );
    }

    // change color of the grid where mouse is on
    private void drawS( Graphics g, int ix, int iy )
    {
       int by = 20;
         if(big)
         by *= 2;
       if(small)
         by /= 2;

       int xp = ix*by+20;
       int yp = iy*by+20;

       g.setColor(Color.red);
       g.drawRect(xp, yp, by,by);
    }

    // flow directions
    private void drawFD(Graphics g)
    {
        int by = 20;
        if( big ){
          by *= 2;
        }
        if( small ){
          by /= 2;
        }
        int mx = (int)(width/by);
        int my = (int)(hight/by);

        for(int iy=0; iy<my; iy++){
          for(int ix=0; ix<mx; ix++){
            int jx= ix + xs;      // 
            int jy= iy + ys;
            int pxs = xs * by;    // shift from the origin
            int pys = ys * by;

            int xp = ix*by+20;
            int yp = iy*by+20;

            if( jx >= nx) {
              jx =  jx - nx;
              pxs = pxs - nx*by;
            }
            if( jy >= ny) {
              jy = jy - ny;
              pys = pys - ny*by;
            }
            if ( fd.dirlist[jx][jy]>=1 && fd.dirlist[jx][jy]<=8 ){
              g.setColor(Color.blue);
              g.drawLine(getP(jx)-pxs,getP(jy)-pys,
                         getP(fd.getEndPoint(jx,jy).x)-pxs,getP(fd.getEndPoint(jx,jy).y)-pys);
              g.drawLine(getP(jx)-pxs+1,getP(jy)-pys,
                           getP(fd.getEndPoint(jx,jy).x)-pxs,getP(fd.getEndPoint(jx,jy).y)-pys);
              g.drawLine(getP(jx)-pxs-1,getP(jy)-pys,
                           getP(fd.getEndPoint(jx,jy).x)-pxs,getP(fd.getEndPoint(jx,jy).y)-pys);
              g.drawLine(getP(jx)-pxs,getP(jy)-pys+1,
                         getP(fd.getEndPoint(jx,jy).x)-pxs,getP(fd.getEndPoint(jx,jy).y)-pys);
              g.drawLine(getP(jx)-pxs,getP(jy)-pys-1,
                         getP(fd.getEndPoint(jx,jy).x)-pxs,getP(fd.getEndPoint(jx,jy).y)-pys);
            }
            if( fd.dirlist[jx][jy]==9 ){
              g.setColor(Color.blue);
              g.fillOval( getP(ix)-4, getP(iy)-4, 8, 8);
            }
            // inland depression
            if( fd.dirlist[jx][jy]==10 ){
              g.setColor(new Color(64,0,0));
              int a=(int)(by*0.1);
              g.fillOval(xp+a*2,yp+a*2,a*6,a*6);
              g.setColor(Color.red);
              g.fillOval( getP(ix)-4, getP(iy)-4, 8, 8);
            }
            // other
            if( fd.dirlist[jx][jy]==11 ){
              g.setColor(new Color(0,0,0));
              int a=(int)(by*0.1);
              g.fillOval(xp+a*2,yp+a*2,a*6,a*6);
            }
          }
        }
    }

    // draw numbers
    public void drawNumber(Graphics g)
    {
        char charArray[] = { '+', 'i', '#', 'X', 't', '@', '0' }; //
        g.setColor(Color.black);
        int by = 20;
        if( big ){
          by *= 2;
        }
        if( small ){
          by /= 2;
        }
        int mx = (int)(width/by);
        int my = (int)(hight/by);

        for(int iy=0; iy<my; iy++){
          for(int ix=0; ix<mx; ix++){
            int jx = ix + xs;
            int jy = iy + ys;

            if( jx >= nx)
              jx = jx - nx;
            if( jy >= ny)
              jy = jy - ny;
            int a = fd.dirlist[jx][jy];
            if( a >= 1 && a <= 8 )
              g.drawString( Integer.toString(a), getP(ix), getP(iy));
            else if(a >= 9 && a <=15 )
              g.drawString( String.valueOf(charArray[a-9]) , getP(ix), getP(iy));
          }
        }
    }

    // land sea mask
    public void drawLS(Graphics g)
    {
        int by = 20;
        if( big ){
          by *= 2;
        }
        if( small ){
          by /= 2;
        }
        int mx = (int)(width/by);
        int my = (int)(hight/by);

        for(int iy=0; iy<my; iy++){
          for(int ix=0; ix<mx; ix++){
            int xp = ix*by+20;
            int yp = iy*by+20;

            int jx = ix + xs;
            int jy = iy + ys;

            if( jx >= nx)
              jx = jx - nx;
            if( jy >= ny)
              jy = jy - ny;
            //
//            if( ls.mask[jx][jy]==0 ){
              g.setColor(Color.lightGray);
              g.fillRect(xp,yp,by,by);
//            }
            // *** basin colors ***
            if( bl.color[jx][jy]<=1 && (ls.mask[jx][jy]>0 || lf.lake[jx][jy]>0 ) ){
              g.setColor(new Color(220,255,220));
              // g.fillRect(xp,yp,by,by);
              if( ls.mask[jx][jy] <100  ) g.fillOval(xp,yp,by,by);
              if( ls.mask[jx][jy] ==100 ) g.fillRect(xp,yp,by,by);
            }
            if( bl.color[jx][jy]==2 && (ls.mask[jx][jy]>0 || lf.lake[jx][jy]>0 ) ){
              g.setColor(new Color(255,255,180));
              // g.fillRect(xp,yp,by,by);
              if( ls.mask[jx][jy] <100  ) g.fillOval(xp,yp,by,by);
              if( ls.mask[jx][jy] ==100 ) g.fillRect(xp,yp,by,by);
            }
            if( bl.color[jx][jy]==3 && (ls.mask[jx][jy]>0 || lf.lake[jx][jy]>0 ) ){
              g.setColor(new Color(200,220,255));
              // g.fillRect(xp,yp,by,by);
              if( ls.mask[jx][jy] <100  ) g.fillOval(xp,yp,by,by);
              if( ls.mask[jx][jy] ==100 ) g.fillRect(xp,yp,by,by);
            }
            if( bl.color[jx][jy]==4 && (ls.mask[jx][jy]>0 || lf.lake[jx][jy]>0 ) ){
              g.setColor(new Color(255,220,255));
              // g.fillRect(xp,yp,by,by);
              if( ls.mask[jx][jy] <100  ) g.fillOval(xp,yp,by,by);
              if( ls.mask[jx][jy] ==100 ) g.fillRect(xp,yp,by,by);
            }
            if( bl.color[jx][jy]==5 && (ls.mask[jx][jy]>0 || lf.lake[jx][jy]>0 ) ){
              g.setColor(new Color(150,255,155));
              // g.fillRect(xp,yp,by,by);
              if( ls.mask[jx][jy] <100  ) g.fillOval(xp,yp,by,by);
              if( ls.mask[jx][jy] ==100 ) g.fillRect(xp,yp,by,by);
            }
            if( bl.color[jx][jy]==6 && (ls.mask[jx][jy]>0 || lf.lake[jx][jy]>0 ) ){
              g.setColor(new Color(180,255,180));
              // g.fillRect(xp,yp,by,by);
              if( ls.mask[jx][jy] <100  ) g.fillOval(xp,yp,by,by);
              if( ls.mask[jx][jy] ==100 ) g.fillRect(xp,yp,by,by);
            }
            // unexpected flow direction
            if( ls.mask[jx][jy]==0 && lf.lake[jx][jy]==0 && fd.dirlist[jx][jy]>0 ){
              g.setColor(new Color(0,96,255));
              int a=(int)(by*0.1);
              g.fillOval(xp+a,yp+a,a*9,a*9);
            }
            // no flow direction
            if( (ls.mask[jx][jy]>0 || lf.lake[jx][jy] >0) && fd.dirlist[jx][jy]==0){
              g.setColor(Color.red);
              int a=(int)(by*0.1);
              g.fillOval(xp+a,yp+a,a*9,a*9);
            }
            // inland error
            if( ls.mask[jx][jy]==100  && fd.dirlist[jx][jy]==9){
              g.setColor(Color.red);
              int a=(int)(by*0.1);
              g.fillOval(xp+a,yp+a,a*9,a*9);
            }
            // lake
            if( lf.lake[jx][jy]>0 ){
              g.setColor(new Color(0,255,255));
              int a=(int)(Math.sqrt(lf.lake[jx][jy])*by);
              int b=(int)(by*0.5-a*0.5);
              g.fillOval(xp+b,yp+b,a,a);
            }
          }
        }
    }

    // river vector
    public void drawRiver(Graphics g)
    {
        int by = 20;
        if(big)
           by *= 2;
        if(small)
           by /= 2;

        int xp, yp;
        for( int i=0 ; i<nriv; i++ ){
          double area = (double) rl.getValue(i,2);
          if (area > 0.0){
            float lon = rl.getValue(i,0);
            if (lon >= 0.0 )
              xp = 20 + (int)((float) lon*nx/360*by)-xs*by+by/2;
            else
              xp = 20 + (int)((float) (lon+360)*nx/360*by)-xs*by+by/2;

            float lat = rl.getValue(i,1);
            lat=(float)(lat*1.0016);          //Gausian adjust
            yp = 20 + (int)((float) (90-lat)*ny/180*by)-ys*by;

            int col=(int)(150-(Math.log(area))*20);
            if (col<=0) col=0;

            if( xp<20 )
              xp=xp+nx*by;
            if( xp>20+nx*by)
              xp=xp-nx*by;
            if( yp<20 )
              yp=yp+ny*by;
            if( yp>20+ny*by)
              yp=yp-ny*by;

            if ( xp>=20 && xp<=20+width && yp>=20 &&yp<=20+hight ){
              g.setColor(new Color(255,col,col));
//              g.setColor(Color.pink);
              g.drawRect( xp , yp, 1, 1);
            }
          }
        }
    }

    // coast vector
    public void drawCoast(Graphics g)
    {
        int by = 20;
        if(big)
           by *= 2;
        if(small)
           by /= 2;

        int xp, yp;
        for( int i=0 ; i<ncos; i++ ){
          float lon = cl.getValue(i,0);
          if (lon >= 0.0 )
            xp = 20 + (int)((float) lon*nx/360*by)-xs*by+by/2;
          else
            xp = 20 + (int)((float) (lon+360)*nx/360*by)-xs*by+by/2;

          float lat = cl.getValue(i,1);
          lat=(float)(lat*1.0016);          // gausian adjust
          yp = 20 + (int)((float) (90-lat)*ny/180*by)-ys*by;

          if( xp<20 )
            xp=xp+nx*by;
          if( xp>20+nx*by)
            xp=xp-nx*by;
          if( yp<20 )
            yp=yp+ny*by;
          if( yp>20+ny*by)
            yp=yp-ny*by;

          if ( xp>=20 && xp<=20+width && yp>=20 &&yp<=20+hight ){
            g.setColor(new Color(100,150,100));
            g.drawLine( xp , yp, xp, yp);
          }
        }
    }

    // observation stations
    public void drawSta(Graphics g)
    {
        int by = 20;
        if(big)
          by *= 2;
        if(small)
          by /= 2;

        int xp,yp,xp2,yp2;
        for( int i=0 ; i<stan; i++ ){
          float lon = sl.getValue(i,0);
          if (lon < 360) {
            if (lon >= 0.0 )
              xp = 20 + (int)((float) lon*nx/360*by)-xs*by+by/2;
            else
              xp = 20 + (int)((float) (lon+360)*nx/360*by)-xs*by+by/2;

            float lat = sl.getValue(i,1);
            lat=(float)(lat*1.0016);          // Gausian adjust
            yp = 20 + (int)((float) (90-lat)*ny/180*by)-ys*by;

            int x_mod=0;
            int y_mod=0;
            if( xp<20 ){
              xp=xp+nx*by;
              x_mod=1;
            }
            if( xp>20+nx*by){
              xp=xp-nx*by;
              x_mod=-1;
            }
            if( yp<20 ){
              yp=yp+ny*by;
              y_mod=1;
            }
            if( yp>20+ny*by){
              yp=yp-ny*by;
              y_mod=-1;
            }

            if ( xp>=20 && xp<=20+width && yp>=20 &&yp<=20+hight ){
              g.setColor(new Color(0,255,0));
              g.fillRect( xp-2, yp-2, 5, 5);

              float lon2 = sl.getValue(i,2);
              if (lon2 < 360) {
                if (lon2 >= 0.0 )
                  xp2 = 20 + (int)((float) lon2*nx/360*by)-xs*by+by/2;
                else
                  xp2 = 20 + (int)((float) (lon2+360)*nx/360*by)-xs*by+by/2;

                float lat2 = sl.getValue(i,3);
                lat2=(float)(lat2*1.0016);          // Gausian adjust
                yp2 = 20 + (int)((float) (90-lat2)*ny/180*by)-ys*by;

                if( x_mod>0 )
                  xp2=xp2+nx*by;
                if( x_mod<0 )
                  xp2=xp2-nx*by;
                if( y_mod>0 )
                  yp2=yp2+ny*by;
                if( y_mod<0 )
                  yp2=yp2-ny*by;

                if ( xp2>=20 && xp2<=20+width && yp2>=20 && yp2<=20+hight ){
                  g.setColor(new Color(0,192,0));
                  g.drawLine( xp, yp, xp2, yp2);
                  g.drawLine( xp+1, yp, xp2+1, yp2);
                  g.drawLine( xp, yp+1, xp2, yp2+1);
                  g.drawLine( xp+1, yp+1, xp2+1, yp2+1);
                }
              }
              g.setColor(new Color(0,0,0));
              g.drawString( Integer.toString(i+1), xp+5, yp+5);
            }
          }
        }
    }
}



// mouse manager
class MyListener extends MouseInputAdapter
{
    Panel2 sm;
    int j = 0;

    public MyListener(Panel2 sm)
    {
        this.sm = sm;
    }

    public void mousePressed(MouseEvent e)
    {
        sm.setX(e.getX());
        sm.setY(e.getY());
        int ix = sm.ix;
        int iy = sm.iy;
        int xs = sm.xs;
        int ys = sm.ys;
        int nx = sm.nx;
        int ny = sm.ny;

        int jx = ix + xs;
        int jy = iy + ys;

        if( jx < 0 )
          jx = jx + nx;
        if( jx >= nx )
          jx = jx - nx;

        if( jy < 0 )
          jy = jy + ny;
        if( jy >= ny )
          jy = jy - ny;

        // edit flow direction (right $ left click)
        if( (e.getModifiers() & e.BUTTON1_MASK) == e.BUTTON1_MASK ){
          if(sm.fd.dirlist[jx][jy]<8 && sm.fd.dirlist[jx][jy]>0 )             
            sm.fd.dirlist[jx][jy]+=1;
          else
            sm.fd.dirlist[jx][jy]=1;
          sm.repaint();
          System.out.println((jx+1)+" : "+(jy+1)+" Modified to "+sm.fd.dirlist[jx][jy]);
        }
        else if( (e.getModifiers() & e.BUTTON3_MASK) == e.BUTTON3_MASK ){
          if(sm.fd.dirlist[jx][jy]>1 && sm.fd.dirlist[jx][jy]<9)
            sm.fd.dirlist[jx][jy]-=1;
          else
            sm.fd.dirlist[jx][jy]=8;
          sm.repaint();
          System.out.println((jx+1)+" : "+(jy+1)+" Modified to "+sm.fd.dirlist[jx][jy]);
        }
        // edit flow direction (center click)
        else if( (e.getModifiers() & e.BUTTON2_MASK) == e.BUTTON2_MASK ){
          if( j>2 )
            j = 0;
          if(j==0)
            sm.fd.dirlist[jx][jy]=0;
          else
            sm.fd.dirlist[jx][jy]=j+8;
          j++;
          sm.repaint();
          System.out.println((jx+1)+" : "+(jy+1)+" Modified to "+sm.fd.dirlist[jx][jy]);
        }
    }

    public void mouseMoved(MouseEvent e)
    {
        j = 0;
        boolean mouseon = true;
        int xp = e.getX();
        int yp = e.getY();
        sm.setOn(mouseon);
        sm.setX(xp);
        sm.setY(yp);
        sm.repaint();
    }
}