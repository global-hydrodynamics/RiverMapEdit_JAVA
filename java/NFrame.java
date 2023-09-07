import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import java.io.*;

// program for managing main frame
public class NFrame extends JFrame 
{
    public int nx, ny;
    public int xs=0, ys=0; // origin
    public boolean big, small;
    public int mx = 320;   // # of grids to display
    public int my = 320;
    public int width, hight;
    FlowDirection fd;
    RiverList rl;
    CoastList cl;
    LSMask    ls;
    LAKEfrac  lf;
    BasinList bl;
    StationList sl;

    Panel2 rpanel; // main frame
    JScrollPane rscpane;
    JMenuBar menuBar;
    JMenu menu1, menu2, menu3, menu4, menu5, menu6, menu7;
    JMenuItem menuItem1, menuItem2, menuItem4;
    JMenuItem rvMenuItem1;
    JMenuItem clMenuItem1;
    JMenuItem blMenuItem1;
    JMenuItem slMenuItem1;
    JRadioButtonMenuItem rbMenuItem1,rbMenuItem2,rbMenuItem3;
    JTextField input1, input2;
    JButton move;
    JLabel prompt1, prompt2;
    private Ruler columnView, rowView;

    public NFrame()
    {
        final JFileChooser fc = new JFileChooser();

        menuBar = new JMenuBar();
        setJMenuBar(menuBar);

        // *** file manager **********
        menu1 = new JMenu("File");
        menuBar.add(menu1);

        menuItem1 = new JMenuItem("Open");
        menuItem1.addActionListener(new ActionListener() {
          public void actionPerformed(ActionEvent e) {
            int returnVal = fc.showOpenDialog(NFrame.this);
            if (returnVal == JFileChooser.APPROVE_OPTION) {
              try{
                File file = fc.getSelectedFile();
                setTitle( fc.getName(file) );
                System.out.println("Opening FlowDirection File");
                DataInputStream inf = new DataInputStream(new FileInputStream(file));
                fd=new FlowDirection(nx, ny, inf);
                inf.close();
                System.out.println("Done");
                rpanel.setData(nx,ny,big,small,fd,rl,cl,ls,lf,bl,sl);
                rpanel.repaint();
              }catch (Exception k){
                System.err.println(k);
              }
            }
          }
        });
        menu1.add(menuItem1);

        menuItem2 = new JMenuItem("Save");
        menuItem2.addActionListener(new ActionListener() {
          public void actionPerformed(ActionEvent e) {
            int returnVal = fc.showSaveDialog(NFrame.this);
            if (returnVal == JFileChooser.APPROVE_OPTION) {
              try{
                File file = fc.getSelectedFile();
                System.out.println("Saving File");
                DataOutputStream ouf = new DataOutputStream(new FileOutputStream(file));
                for(int iy=0; iy<ny; iy++){
                  for(int ix=0; ix<nx; ix++){
                    ouf.writeFloat( rpanel.fd.dirlist[ix][iy] );
                  }
                }
                ouf.close();
                System.out.println("Done");
              }catch (Exception k){
                System.err.println(k);
              }
            }
          }
        });
        menu1.add(menuItem2);
        menu1.addSeparator();

        menuItem4 = new JMenuItem("Exit");
        menuItem4.addActionListener(new ActionListener() {
          public void actionPerformed(ActionEvent e) {
            System.exit(0);
          }
        });
        menu1.add(menuItem4);

        // *** display size **********
        menu2 = new JMenu("Size");
        menuBar.add(menu2);

        RadioListener myListener = new RadioListener();

        rbMenuItem1 = new JRadioButtonMenuItem("Big");
        rbMenuItem1.addActionListener(myListener);

        rbMenuItem2 = new JRadioButtonMenuItem("Medium");
        rbMenuItem2.setSelected( true );
        big = false;
        rbMenuItem2.addActionListener(myListener);

        rbMenuItem3 = new JRadioButtonMenuItem("Small");
        small = false;
        rbMenuItem3.addActionListener(myListener);

        ButtonGroup group = new ButtonGroup();
        group.add(rbMenuItem1);
        group.add(rbMenuItem2);
        group.add(rbMenuItem3);

        menu2.add(rbMenuItem1);
        menu2.add(rbMenuItem2);
        menu2.add(rbMenuItem3);

        // *** display position **********
        menu3 = new JMenu("Position");
        menuBar.add(menu3);
    
        prompt1 = new JLabel( "LON west_edge");
        prompt2 = new JLabel( "LAT north_edge");
        input1 = new JTextField(5);
        input2 = new JTextField(5);

        move = new JButton( "Move" );
        move.addActionListener(new ActionListener() {
          public void actionPerformed(ActionEvent e) {
            xs = Integer.parseInt( input1.getText() );
            ys = Integer.parseInt( input2.getText() );

            ys = (int)((float) (90-ys)*ny/180);
            if( xs<0 )
              xs = (int)((float) (360+xs)*nx/360);
            else
              xs = (int)((float) xs*nx/360.0);

            // **** set origin information **********
            rpanel.setXYPosition(xs, ys);
            columnView.setXYPosition(xs, ys);
            rowView.setXYPosition(xs, ys);
            repaint();
          }
        });
        menu3.add( prompt1 );
        menu3.add( input1 );
        menu3.add( prompt2 );
        menu3.add( input2 );
        menu3.add( move );

        // *** river vector menu **********
        menu4 = new JMenu("River");
        menuBar.add(menu4);

        rvMenuItem1 = new JMenuItem("Open");
        rvMenuItem1.addActionListener(new ActionListener() {
          public void actionPerformed(ActionEvent e) {
            int returnVal = fc.showOpenDialog(NFrame.this);
            if (returnVal == JFileChooser.APPROVE_OPTION) {
              try{
                File file = fc.getSelectedFile();
                System.out.println("Opening RiverList File");
                DataInputStream inf = new DataInputStream(new FileInputStream(file));
                rl=new RiverList(inf);
                inf.close();
                System.out.println("Done");
                rpanel.setData(nx,ny,big,small,fd,rl,cl,ls,lf,bl,sl);
                rpanel.repaint();
              }catch (Exception k){
                System.err.println(k);
              }
            }
          }
        });
        menu4.add(rvMenuItem1);

        // *** coast vector menu **********
        menu5 = new JMenu("Coast");
        menuBar.add(menu5);

        clMenuItem1 = new JMenuItem("Open");
        clMenuItem1.addActionListener(new ActionListener() {
          public void actionPerformed(ActionEvent e) {
            int returnVal = fc.showOpenDialog(NFrame.this);
            if (returnVal == JFileChooser.APPROVE_OPTION) {
              try{
                File file = fc.getSelectedFile();
                System.out.println("Opening CoastList File");
                DataInputStream inf = new DataInputStream(new FileInputStream(file));
                cl=new CoastList(inf);
                inf.close();
                System.out.println("Done");
                rpanel.setData(nx,ny,big,small,fd,rl,cl,ls,lf,bl,sl);
                rpanel.repaint();
              }catch (Exception k){
                System.err.println(k);
              }
            }
          }
        });
        menu5.add(clMenuItem1);

        // *** basin color menu **********
        menu6 = new JMenu("Basin");
        menuBar.add(menu6);

        blMenuItem1 = new JMenuItem("Open");
        blMenuItem1.addActionListener(new ActionListener() {
          public void actionPerformed(ActionEvent e) {
            int returnVal = fc.showOpenDialog(NFrame.this);
            if (returnVal == JFileChooser.APPROVE_OPTION) {
              try{
                File file = fc.getSelectedFile();
                System.out.println("Opening BasinColor File");
                DataInputStream inf = new DataInputStream(new FileInputStream(file));
                bl=new BasinList(nx, ny, inf);
                inf.close();
                System.out.println("Done");
                rpanel.setData(nx,ny,big,small,fd,rl,cl,ls,lf,bl,sl);
                rpanel.repaint();
              }catch (Exception k){
                System.err.println(k);
              }
            }
          }
        });
        menu6.add(blMenuItem1);

        // *** observation points menu **********
        menu7 = new JMenu("Station");
        menuBar.add(menu7);

        slMenuItem1 = new JMenuItem("Open");
        slMenuItem1.addActionListener(new ActionListener() {
          public void actionPerformed(ActionEvent e) {
            int returnVal = fc.showOpenDialog(NFrame.this);
            if (returnVal == JFileChooser.APPROVE_OPTION) {
              try{
                File file = fc.getSelectedFile();
                System.out.println("Opening StationList File");
                DataInputStream inf = new DataInputStream(new FileInputStream(file));
                sl=new StationList(inf);
                inf.close();
                System.out.println("Done");
                rpanel.setData(nx,ny,big,small,fd,rl,cl,ls,lf,bl,sl);
                rpanel.repaint();
              }catch (Exception k){
                System.err.println(k);
              }
            }
          }
        });
        menu7.add(slMenuItem1);

        setTitle("Flow Direction Edditor");
        setSize(800,600);

        addWindowListener(new WindowAdapter() 
           {
              public void windowClosing(WindowEvent e) 
              {
               System.exit(0);
              }
           }
        );

        // *** display frames **********
        width = mx*20;
        hight = my*20;
        rpanel = new Panel2(width, hight);
        rpanel.setPreferredSize( new Dimension(width+20,hight+20));
        columnView = new Ruler(width, hight, Ruler.HORIZONTAL, big, small);
        columnView.setPreferredWidth(width+20);
        rowView = new Ruler(width, hight, Ruler.VERTICAL, big, small);
        rowView.setPreferredHeight(hight+20);
        rscpane = new JScrollPane(rpanel,
               JScrollPane.VERTICAL_SCROLLBAR_ALWAYS,
               JScrollPane.HORIZONTAL_SCROLLBAR_ALWAYS);
        rscpane.setColumnHeaderView(columnView);
        rscpane.setRowHeaderView(rowView);
        rscpane.setPreferredSize( new Dimension(800, 600));
        getContentPane().add(BorderLayout.CENTER, rscpane );
    }

    public static void main(String args[])
    {
        (new NFrame()).setVisible(true);
    }

    public void setData(int nx, int ny, boolean big, boolean small,
                        FlowDirection fd, RiverList rl, CoastList cl, LSMask ls,
                        LAKEfrac lf, BasinList bl, StationList sl)
    {
        this.nx = nx;
        this.ny = ny;
        this.big = big;
        this.small = small;
        this.fd = fd;
        this.rl = rl;
        this.cl = cl;
        this.ls = ls;
        this.lf = lf;
        this.bl = bl;
        this.sl = sl;
        rpanel.setData(nx,ny,big,small,fd,rl,cl,ls,lf,bl,sl);
    }

    public void setBig( boolean big )
    {
        this.big = big;
    }
    public void setSmall( boolean small )
    {
        this.small = small;
    }

    public void repaint()
    {
        rpanel.setData(nx,ny,big,small,fd,rl,cl,ls,lf,bl,sl);
        rowView.setBS(big,small);
        columnView.setBS(big,small);
    }

    // *** size set buttons **********
    class RadioListener implements ActionListener
    {
        public void actionPerformed(ActionEvent e)
        {
          if( rbMenuItem1.isSelected() == true ){
            setBig( true );
            setSmall( false );
            repaint();
          }
          else if( rbMenuItem2.isSelected() == true ){
            setBig( false );
            setSmall( false );
            repaint();
          }
          else if( rbMenuItem3.isSelected() == true ){
            setBig( false );
            setSmall( true );
            repaint();
          }
        }
    }
}