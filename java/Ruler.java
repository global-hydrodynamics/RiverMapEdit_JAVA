import java.awt.*;
import javax.swing.*;

//メモリパネルを描画するクラス
public class Ruler extends JComponent
{
    public static final int HORIZONTAL = 0;
    public static final int VERTICAL = 1;
    public static final int SIZE = 35;      // 

    public int nx, ny;
    public int width, hight;
    public int orientation;  // ruler direction
    public int by;           // int width
    public boolean big, small;
    public int xs=0, ys=0;
    public double gsize=0.5625;
    private int unit=8;     // interval

    public Ruler(int width, int hight, int o, boolean p, boolean q)
    {
        this.width = width;
        this.hight = hight;
        orientation = o;
        big = p;
        small = q;
        setIncrement();
    }

    public void setBS(boolean b, boolean s )
    {
        this.big = b;
        this.small = s;
        setIncrement();
        repaint();
    }

    public void setXYPosition( int xs, int ys )
    {
        this.xs = xs;
        this.ys = ys;
        repaint();
    }

    // int width
    private void setIncrement()
    {
        by = 20;
        if(big)
          by = 40;
        else if(small)
          by = 10;
    }

    // ruler width and height
    public void setPreferredHeight(int ph)
    {
        setPreferredSize(new Dimension(SIZE, ph));
    }
    public void setPreferredWidth(int pw)
    {
        setPreferredSize(new Dimension(pw, SIZE));
    }

    // 
    public void paintComponent(Graphics g)
    {
        //  
        int tickLength;
        int a;
        String text = null;

        g.setColor(Color.gray);
        g.fillRect(0, 0, width+20, hight+20);
        g.setFont(new Font("SansSerif", Font.PLAIN, 10));
        g.setColor(Color.black);

        // calculate origin pixels for ruler
        if (orientation == HORIZONTAL){
          for (int i=0; i<width; i+=by){
            if ((xs*by+i) % (unit*by) == 0){ // store text for ruler
              tickLength = 10;
              a = (int)((xs+(i/by))*gsize);
              if (a < 0)
                a = a + 360;
              if (a > 360)
                a = a - 360;
              text = Integer.toString(a);
            }
            else{
              tickLength = 7;
              text = null;
            }
              g.drawLine(i+20, SIZE-1, i+20, SIZE-tickLength-1);
            if (text != null)
              g.drawString(text, i-5+20, 21);
          }
        }
        else{
          for (int i=0; i<hight; i+=by){
            if ((ys*by+i) % (unit*by) == 0){
              tickLength = 10;
              a = 90-(int)((ys+(i/by))*gsize);
            if (a < -90)
              a = a + 180;
            text = Integer.toString(a);
          }
          else{
            tickLength = 7;
            text = null;
          }
            g.drawLine(SIZE-1, i+20, SIZE-tickLength-1, i+20);
          if (text != null)
            g.drawString(text, 9, i+3+20);
          }
        }
    }
}